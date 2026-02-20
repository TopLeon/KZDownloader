import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:kzdownloader/core/download/logic/yt_dlp_service.dart';
import 'package:kzdownloader/core/download/strategies/download_strategy.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/core/utils/utils.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:path_provider/path_provider.dart';

// Download strategy that delegates to yt-dlp for video/audio downloads.
class YtDlpStrategy extends DownloadStrategy {
  final YtDlpService _service;
  Process? _process;
  bool _isCancelled = false;
  StreamSubscription? _stdoutSub;
  StreamSubscription? _stderrSub;
  late DateTime _startedAt;

  YtDlpStrategy(super.taskId, super.db, super.ref, this._service);

  @override
  Future<void> start(
      {String? format, String? quality, bool isAudio = false}) async {
    _startedAt = DateTime.now();
    _isCancelled = false;

    try {
      final task = await db.getTask(taskId);
      if (task == null) throw Exception('Task $taskId not found');

      // Resolve target directory
      final settings = SettingsService();
      final userPath = await settings.getDownloadPath();
      final targetDir = userPath ??
          ((await getDownloadsDirectory()) ??
                  await getApplicationDocumentsDirectory())
              .path;

      // Resolve file name
      String? sanitizedFilename;
      if (task.title != null && task.title!.isNotEmpty) {
        sanitizedFilename = FileUtils.sanitizeFilename(task.title!);
        if (sanitizedFilename.contains('.')) {
          sanitizedFilename =
              sanitizedFilename.substring(0, sanitizedFilename.lastIndexOf('.'));
        }
      }

      // Map format and quality strings to enums
      final targetFormat = _resolveFormat(format, isAudio: isAudio);
      final targetQuality = _resolveQuality(quality);
      final appTempDir = await getTemporaryDirectory();

      // Compute the final file path deterministically before starting yt-dlp
      final ext = _formatExtension(targetFormat);
      final baseName = sanitizedFilename ?? task.title ?? 'download';
      final expectedFilePath = '$targetDir${Platform.pathSeparator}$baseName.$ext';

      // Save expected path to DB before starting, so UI always has the right dir
      await db.updateFilePath(taskId, expectedFilePath, targetDir);

      _process = await _service.startDownload(
        task.url,
        targetDir,
        format: targetFormat,
        quality: targetQuality,
        tempPath: appTempDir.path,
        customFilename: sanitizedFilename,
      );

      _stdoutSub = _process!.stdout.transform(const SystemEncoding().decoder).listen((line) {
        if (_isCancelled) return;
        for (var l in line.split('\n')) {
          l = l.trim();
          if (l.isEmpty) continue;

          // Parse progress — keys must match what the UI expects
          final progress = _service.parseProgress(l);
          if (progress != null) {
            updateProgress({
              'progress': (progress['progress'] ?? 0.0) / 100.0,
              'downloadSpeed': progress['speed'],
              'eta': progress['eta'],
              'totalSize': progress['totalSize'],
            });
          }
        }
      });

      _stderrSub = _process!.stderr.transform(const SystemEncoding().decoder).listen((line) {
        if (_isCancelled) return;
        debugPrint('yt-dlp stderr: $line');
      });

      final exitCode = await _process!.exitCode;
      await _stdoutSub?.cancel();
      await _stderrSub?.cancel();

      if (_isCancelled) return;

      if (exitCode == 0) {
        // Verify the expected file exists; if not, scan for the actual output
        if (!await File(expectedFilePath).exists()) {
          await _scanForOutputFile(targetDir, sanitizedFilename, task);
        }

        await finalizeSuccess(_startedAt);
      } else {
        throw Exception('yt-dlp exited with code $exitCode');
      }
    } catch (e) {
      if (_isCancelled) return;
      await handleError(e);
      rethrow;
    }
  }

  String _formatExtension(DownloadFormat format) {
    switch (format) {
      case DownloadFormat.mp4:
        return 'mp4';
      case DownloadFormat.mkv:
        return 'mkv';
      case DownloadFormat.mp3:
        return 'mp3';
      case DownloadFormat.m4a:
        return 'm4a';
      case DownloadFormat.ogg:
        return 'ogg';
    }
  }

  Future<void> _scanForOutputFile(
      String targetDir, String? baseName, DownloadTask task) async {
    try {
      final dir = Directory(targetDir);
      if (!await dir.exists()) return;

      final searchName = baseName ?? task.title ?? '';
      if (searchName.isEmpty) return;

      final files = await dir
          .list()
          .where((e) => e is File && e.path.contains(searchName))
          .toList();

      if (files.isNotEmpty) {
        files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        await db.updateFilePath(taskId, files.first.path, targetDir);
      }
    } catch (e) {
      debugPrint('File scan failed: $e');
    }
  }

  DownloadFormat _resolveFormat(String? format, {bool isAudio = false}) {
    switch (format?.toLowerCase()) {
      case 'mp4':
        return DownloadFormat.mp4;
      case 'mkv':
        return DownloadFormat.mkv;
      case 'mp3':
        return DownloadFormat.mp3;
      case 'm4a':
        return DownloadFormat.m4a;
      case 'ogg':
        return DownloadFormat.ogg;
      default:
        // No explicit format — use sensible default based on content type
        return isAudio ? DownloadFormat.mp3 : DownloadFormat.mp4;
    }
  }

  DownloadQuality _resolveQuality(String? quality) {
    switch (quality?.toLowerCase()) {
      case 'best':
        return DownloadQuality.best;
      case 'high':
      case '1080':
      case '1080p':
        return DownloadQuality.p1080;
      case 'medium':
      case '720':
      case '720p':
        return DownloadQuality.p720;
      case 'low':
      case '480':
      case '480p':
        return DownloadQuality.p480;
      case '1440':
      case '1440p':
        return DownloadQuality.p1440;
      case '2160':
      case '2160p':
      case '4k':
        return DownloadQuality.p2160;
      default:
        return DownloadQuality.best;
    }
  }

  @override
  Future<void> pause() async {
    _isCancelled = true;
    await _stdoutSub?.cancel();
    await _stderrSub?.cancel();
    try {
      _process?.kill();
    } catch (_) {}

    final task = await db.getTask(taskId);
    if (task != null) {
      task.downloadStatus = WorkStatus.paused;
      task.downloadSpeed = null;
      task.eta = null;
      await db.saveTask(task);
    }
    removeProgress();
  }

  @override
  Future<void> cancel() async {
    _isCancelled = true;
    await _stdoutSub?.cancel();
    await _stderrSub?.cancel();
    try {
      _process?.kill();
    } catch (_) {}
    removeProgress();
  }
}
