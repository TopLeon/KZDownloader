import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kzdownloader/src/rust/api/download.dart';

// Simple Chunk Downloader with write buffering, connection reuse, and EMA speed smoothing.
//
// Downloads a file in sequential chunks to manage memory usage and allow basic progress monitoring.
// Supports resuming if the server supports range requests.
class ChunkDownloader {
  CancelToken? _cancelToken;
  bool _isPaused = false;

  // Shared Dio instance with connection pooling for the lifetime of this downloader.
  static Dio? _sharedDio;

  static Dio _getDio() {
    _sharedDio ??= Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 60),
    ));
    return _sharedDio!;
  }

  // Pauses the download.
  void pause() {
    _isPaused = true;
    _cancelToken?.cancel('Download paused');
  }

  // Starts the download.
  Future<void> download(
    String url,
    String savePath, {
    Map<String, String>? headers,
    Function(double progress, double speed, int downloaded)? onProgress,
    int chunkSize = 20 * 1024 * 1024,
  }) async {
    _isPaused = false;
    _cancelToken = CancelToken();
    final dio = _getDio();

    if (headers != null) {
      dio.options.headers.addAll(headers);
    }

    int totalSize = 0;
    bool acceptRanges = false;

    try {
      final headRes = await getHeadInfoRust(url: url, headers: headers ?? {});
      final contentLength = headRes['content-length'];
      if (contentLength != null) {
        totalSize = int.tryParse(contentLength) ?? 0;
      }

      final acceptRangesHeader = headRes['accept-ranges'];
      if (acceptRangesHeader != null &&
          acceptRangesHeader.toLowerCase().contains('bytes')) {
        acceptRanges = true;
      }
    } catch (e) {
      debugPrint("HEAD request failed, trying GET stream: $e");
    }

    final file = File(savePath);

    int received = 0;
    RandomAccessFile raf;

    if (await file.exists() && acceptRanges && totalSize > 0) {
      final existingSize = await file.length();
      if (existingSize < totalSize) {
        received = existingSize;
        raf = await file.open(mode: FileMode.writeOnly);
        debugPrint("Resuming download from byte $received of $totalSize");
      } else {
        await file.delete();
        raf = await file.open(mode: FileMode.write);
      }
    } else {
      if (await file.exists()) {
        await file.delete();
      }
      raf = await file.open(mode: FileMode.write);
    }

    // EMA-based speed calculation for smooth display
    double emaSpeed = 0.0;
    const double emaAlpha = 0.3;
    int lastDownloaded = received;
    DateTime lastSpeedUpdate = DateTime.now();

    // Write buffer to reduce filesystem syscalls
    final writeBuffer = BytesBuilder(copy: false);
    const int writeBufferThreshold = 1024 * 1024; // 1MB

    Future<void> flushWriteBuffer() async {
      if (writeBuffer.length > 0) {
        final data = writeBuffer.takeBytes();
        await raf.writeFrom(data);
      }
    }

    void updateSpeed() {
      final now = DateTime.now();
      final elapsed = now.difference(lastSpeedUpdate).inMilliseconds;
      if (elapsed < 500) return;

      final diff = received - lastDownloaded;
      final timeDiff = elapsed / 1000.0;
      if (timeDiff > 0) {
        final instantSpeed = diff / timeDiff;
        emaSpeed = emaSpeed == 0
            ? instantSpeed
            : emaAlpha * instantSpeed + (1 - emaAlpha) * emaSpeed;
      }
      lastDownloaded = received;
      lastSpeedUpdate = now;

      if (onProgress != null) {
        onProgress(
          totalSize > 0 ? received / totalSize : 0.0,
          emaSpeed,
          received,
        );
      }
    }

    try {
      if (acceptRanges && totalSize > 0) {
        int start = received;
        const int maxRetries = 5;

        while (start < totalSize) {
          if (_isPaused) throw Exception('Download paused by user');

          final end = min(start + chunkSize - 1, totalSize - 1);
          int retryCount = 0;
          bool chunkSuccess = false;

          while (!chunkSuccess && retryCount < maxRetries) {
            if (_isPaused) throw Exception('Download paused by user');
            try {
              final response = await dio.get<ResponseBody>(
                url,
                cancelToken: _cancelToken,
                options: Options(
                  responseType: ResponseType.stream,
                  headers: {
                    'range': 'bytes=$start-$end',
                    if (headers != null) ...headers,
                  },
                ),
              );

              final stream = response.data!.stream;
              await raf.setPosition(start);
              await for (final chunk in stream) {
                writeBuffer.add(chunk);
                received += chunk.length;

                if (writeBuffer.length >= writeBufferThreshold) {
                  await flushWriteBuffer();
                }

                updateSpeed();
              }

              await flushWriteBuffer();
              chunkSuccess = true;
            } catch (e) {
              retryCount++;
              if (!_isPausedOrCancelled(e)) {
                debugPrint("Error chunk $start-$end (Attempt $retryCount): $e");
              }
              if (retryCount >= maxRetries) rethrow;
              await Future.delayed(Duration(seconds: retryCount * 2));
            }
          }

          start = end + 1;
        }
      } else {
        await raf.truncate(0);
        await raf.setPosition(0);
        received = 0;

        final response = await dio.get<ResponseBody>(
          url,
          options: Options(
            responseType: ResponseType.stream,
            headers: headers,
          ),
        );

        if (totalSize == 0) {
          final cl = response.headers.value('content-length');
          if (cl != null) totalSize = int.tryParse(cl) ?? 0;
        }

        final stream = response.data!.stream;
        await for (final chunk in stream) {
          if (_isPaused) throw Exception('Download paused by user');

          writeBuffer.add(chunk);
          received += chunk.length;

          if (writeBuffer.length >= writeBufferThreshold) {
            await flushWriteBuffer();
          }

          updateSpeed();
        }

        await flushWriteBuffer();
      }
    } catch (e) {
      await flushWriteBuffer();
      if (!_isPausedOrCancelled(e)) {
        debugPrint("Critical Error: $e");
      }
      rethrow;
    } finally {
      await raf.close();
    }
  }

  // Checks if error is user-initiated pause or cancellation.
  static bool _isPausedOrCancelled(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('paused') || msg.contains('cancel');
  }
}
