import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as stdhttp;
import 'package:rhttp_plus/rhttp_plus.dart';
import 'package:kzdownloader/core/download/strategies/download_strategy.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/core/utils/m3u8_utils.dart';
import 'package:kzdownloader/core/utils/utils.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Strategy for downloading HLS (M3U8) streams.
///
/// Handles master → variant resolution, segment downloading,
/// AES-128 decryption, and concatenation into a single output file.
class M3U8Strategy extends DownloadStrategy {
  bool _isCancelled = false;

  /// Optional: which variant to select from a master playlist (0-indexed).
  /// If null, picks the first (best quality) variant.
  final int? selectedVariantIndex;

  M3U8Strategy(super.taskId, super.db, super.ref, {this.selectedVariantIndex});

  @override
  Future<void> start(
      {String? format, String? quality, bool isAudio = false}) async {
    _isCancelled = false;

    try {
      final task = await db.getTask(taskId);
      if (task == null) throw Exception('Task $taskId not found');

      // 1. Fetch top-level M3U8
      final topContent = await _fetchContent(task.url);
      var result = M3U8Utils.parseHLS(topContent);
      var currentBaseUrl = task.url;

      // 2. If master playlist, resolve to media playlist (pick best variant)
      if (result.isMasterPlaylist) {
        if (result.variants.isEmpty) {
          throw Exception('Master playlist has no variants');
        }

        // Pick variant by user selection or default to best (first)
        final variantIndex =
            selectedVariantIndex?.clamp(0, result.variants.length - 1) ?? 0;
        final selectedVariant = result.variants[variantIndex];
        final variantUrl =
            M3U8Utils.resolveUrl(currentBaseUrl, selectedVariant.url);

        debugPrint(
            '[M3U8] Resolved variant #$variantIndex: ${selectedVariant.resolution ?? "unknown"} '
            '(${selectedVariant.bandwidth ?? 0} bps)');

        // Store selected variant metadata in stepDetailsJson
        task.stepDetailsJson = jsonEncode({
          'selectedVariantIndex': variantIndex,
          'resolution': selectedVariant.resolution,
          'bandwidth': selectedVariant.bandwidth,
          'codecs': selectedVariant.codecs,
          'frameRate': selectedVariant.frameRate,
        });
        await db.saveTask(task);

        final variantContent = await _fetchContent(variantUrl);
        result = M3U8Utils.parseHLS(variantContent);
        currentBaseUrl = variantUrl;

        // Could still be nested — resolve once more
        if (result.isMasterPlaylist) {
          if (result.variants.isEmpty) {
            throw Exception('Nested master playlist has no variants');
          }
          final innerVariant = result.variants.first;
          final innerUrl =
              M3U8Utils.resolveUrl(currentBaseUrl, innerVariant.url);
          final innerContent = await _fetchContent(innerUrl);
          result = M3U8Utils.parseHLS(innerContent);
          currentBaseUrl = innerUrl;
        }
      }

      // 3. Now we have a media playlist with segments
      if (result.segments.isEmpty) {
        throw Exception('No segments found in media playlist');
      }

      debugPrint('[M3U8] Found ${result.segments.length} segments, '
          'encryption: ${result.encryption?.method ?? "NONE"}');

      // 4. Update container task
      task.title ??= _extractPlaylistName(task.url);
      task.playlistTotalVideos = result.segments.length;
      task.playlistCompletedVideos = 0;
      task.isPlaylistContainer = true;
      task.downloadStatus = WorkStatus.running;
      await db.saveTask(task);

      // 5. Resolve target directory and output file
      final settings = SettingsService();
      final userPath = await settings.getDownloadPath();
      final baseDir = userPath ??
          ((await getDownloadsDirectory()) ??
                  await getApplicationDocumentsDirectory())
              .path;

      final sanitizedTitle =
          FileUtils.sanitizeFilename(task.title ?? 'M3U8 Video');
      final outputDir = '$baseDir${Platform.pathSeparator}$sanitizedTitle';
      await Directory(outputDir).create(recursive: true);

      task.dirPath = outputDir;
      await db.saveTask(task);

      final outputPath =
          '$outputDir${Platform.pathSeparator}$sanitizedTitle.ts';

      // 6. Fetch encryption key if needed
      Uint8List? encryptionKey;
      Uint8List? encryptionIV;

      if (result.encryption != null &&
          result.encryption!.method == 'AES-128' &&
          result.encryption!.keyUri != null) {
        final keyUrl =
            M3U8Utils.resolveUrl(currentBaseUrl, result.encryption!.keyUri!);
        debugPrint('[M3U8] Fetching encryption key from: $keyUrl');

        final keyHttpResponse = await stdhttp.get(Uri.parse(keyUrl));

        if (keyHttpResponse.statusCode == 200) {
          encryptionKey = keyHttpResponse.bodyBytes;
        } else {
          debugPrint('[M3U8] Warning: Failed to fetch encryption key: HTTP ${keyHttpResponse.statusCode}');
        }

        if (result.encryption!.iv != null) {
          encryptionIV = _parseIV(result.encryption!.iv!);
        }
      }

      // 7. Download segments sequentially and concatenate
      int completed = 0;
      if (task.stepDetailsJson != null && task.stepDetailsJson!.isNotEmpty) {
        try {
          final json = jsonDecode(task.stepDetailsJson!);
          if (json['m3u8_completed'] != null) {
            completed = json['m3u8_completed'] as int;
          }
        } catch (_) {}
      }

      final mode = completed > 0 ? FileMode.append : FileMode.write;
      final outputFile = File(outputPath);
      final sink = outputFile.openWrite(mode: mode);

      final totalSegments = result.segments.length;

      try {
        for (int i = completed; i < totalSegments && !_isCancelled; i++) {
          final segment = result.segments[i];
          final segmentUrl = M3U8Utils.resolveUrl(currentBaseUrl, segment.url);

          // Download segment
          final segResponse = await stdhttp.get(Uri.parse(segmentUrl));
          if (segResponse.statusCode != 200) {
            debugPrint('[M3U8] Segment $i failed: HTTP ${segResponse.statusCode}');
            continue;
          }

          Uint8List segmentData = segResponse.bodyBytes;

          // Decrypt if needed
          if (encryptionKey != null && result.encryption?.method == 'AES-128') {
            segmentData = _decryptSegment(
              segmentData,
              encryptionKey,
              encryptionIV,
              i,
            );
          }

          // Write to output
          sink.add(segmentData);

          completed++;

          // Update progress
          updateProgress({
            'progress': completed / totalSegments,
            'downloadSpeed': null,
            'childTitle': '${segment.duration?.toStringAsFixed(1) ?? "?"}s',
            'childProgress': completed / totalSegments,
          });

          // Update container in DB periodically (every 10 segments)
          if (completed % 10 == 0 || completed == totalSegments) {
            final container = await db.getTask(taskId);
            if (container != null) {
              container.playlistCompletedVideos = completed;
              container.progress = completed / totalSegments;
              await db.saveTask(container);
            }
          }
        }
      } finally {
        await sink.close();
      }

      if (!_isCancelled) {
        // Set file path on the container task
        final container = await db.getTask(taskId);
        if (container != null) {
          container.downloadStatus = WorkStatus.completed;
          container.progress = 1.0;
          container.completedAt = DateTime.now();
          container.filePath = outputPath;
          container.playlistCompletedVideos = completed;
          await db.saveTask(container);
        }
        removeProgress();
      }
    } catch (e) {
      if (_isCancelled) return;
      await handleError(e);
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    _isCancelled = true;
    final task = await db.getTask(taskId);
    if (task != null) {
      task.downloadStatus = WorkStatus.paused;

      // Save current segment progress
      Map<String, dynamic> details = {};
      if (task.stepDetailsJson != null && task.stepDetailsJson!.isNotEmpty) {
        try {
          details =
              Map<String, dynamic>.from(jsonDecode(task.stepDetailsJson!));
        } catch (_) {}
      }
      details['m3u8_completed'] = task.playlistCompletedVideos ?? 0;
      task.stepDetailsJson = jsonEncode(details);

      await db.saveTask(task);
    }
    removeProgress();
  }

  @override
  Future<void> cancel() async {
    _isCancelled = true;
    removeProgress();
  }

  /// Fetches M3U8 content from a URL.
  Future<String> _fetchContent(String url) async {
    const settings = ClientSettings(
      emulator: Emulation.chrome136,
      redirectSettings: RedirectSettings.limited(10),
    );
    final response = await Rhttp.get(url, settings: settings);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch M3U8: HTTP ${response.statusCode}');
    }
    return response.body;
  }

  /// Decrypts an AES-128 encrypted segment.
  Uint8List _decryptSegment(
    Uint8List data,
    Uint8List key,
    Uint8List? iv,
    int segmentIndex,
  ) {
    try {
      final encKey = encrypt.Key(key);

      // If no explicit IV, use segment sequence number as IV (HLS spec)
      final encIV = iv != null
          ? encrypt.IV(iv)
          : encrypt
              .IV(Uint8List(16)..buffer.asByteData().setInt64(8, segmentIndex));

      final encrypter = encrypt.Encrypter(
          encrypt.AES(encKey, mode: encrypt.AESMode.cbc, padding: null));

      // PKCS7 unpadding is handled manually since we use padding: null
      final decrypted =
          encrypter.decryptBytes(encrypt.Encrypted(data), iv: encIV);

      return _removePKCS7Padding(Uint8List.fromList(decrypted));
    } catch (e) {
      debugPrint('[M3U8] Decryption failed for segment $segmentIndex: $e');
      // Return raw data as fallback
      return data;
    }
  }

  /// Removes PKCS7 padding from decrypted data.
  Uint8List _removePKCS7Padding(Uint8List data) {
    if (data.isEmpty) return data;
    final padLen = data.last;
    if (padLen > 0 && padLen <= 16 && padLen <= data.length) {
      // Verify all padding bytes are correct
      final allMatch =
          data.sublist(data.length - padLen).every((b) => b == padLen);
      if (allMatch) {
        return Uint8List.fromList(data.sublist(0, data.length - padLen));
      }
    }
    return data;
  }

  /// Parses an IV hex string (e.g., 0x43A6D967...) to bytes.
  Uint8List _parseIV(String ivHex) {
    var hex = ivHex;
    if (hex.startsWith('0x') || hex.startsWith('0X')) {
      hex = hex.substring(2);
    }
    // Pad to 32 hex chars (16 bytes)
    hex = hex.padLeft(32, '0');

    final bytes = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  /// Extracts a playlist name from the URL path.
  String _extractPlaylistName(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final last = segments.last;
        if (last.contains('.')) {
          return last.substring(0, last.lastIndexOf('.'));
        }
        return last;
      }
    } catch (_) {}
    return 'M3U8 Video';
  }
}
