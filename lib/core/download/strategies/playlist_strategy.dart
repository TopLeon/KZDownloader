import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:kzdownloader/core/download/logic/yt_dlp_service.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/core/download/strategies/download_strategy.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/core/utils/utils.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:path_provider/path_provider.dart';

// Orchestrates multi-video playlist downloads through individual yt-dlp invocations.
class PlaylistStrategy extends DownloadStrategy {
  final YtDlpService _service;
  bool _isCancelled = false;
  final List<Process> _activeProcesses = [];

  PlaylistStrategy(super.taskId, super.db, super.ref, this._service);

  @override
  Future<void> start(
      {String? format, String? quality, bool isAudio = false}) async {
    _isCancelled = false;

    try {
      final task = await db.getTask(taskId);
      if (task == null) throw Exception('Task $taskId not found');

      final metadata = await _service.getPlaylistMetadata(task.url);
      final videos = metadata['videos'] as List<Map<String, dynamic>>? ?? [];

      // Update container task
      task.title ??= metadata['title'] ?? 'Playlist';
      task.thumbnail ??= metadata['thumbnail'];
      task.playlistTotalVideos = videos.length;
      task.playlistCompletedVideos = 0;
      task.isPlaylistContainer = true;
      task.downloadStatus = WorkStatus.running;
      await db.saveTask(task);

      // Resolve target directory
      final settings = SettingsService();
      final userPath = await settings.getDownloadPath();
      final baseDir = userPath ??
          ((await getDownloadsDirectory()) ??
                  await getApplicationDocumentsDirectory())
              .path;

      final playlistDir =
          '$baseDir${Platform.pathSeparator}${FileUtils.sanitizeFilename(task.title ?? "Playlist")}';
      await Directory(playlistDir).create(recursive: true);

      task.dirPath = playlistDir;
      await db.saveTask(task);

      // Process videos
      int completed = 0;
      final settings2 = SettingsService();
      final concurrency = await settings2.getMaxConcurrentDownloads();

      for (int i = 0; i < videos.length && !_isCancelled; i += concurrency) {
        final end = (i + concurrency).clamp(0, videos.length);
        final batch = videos.sublist(i, end);

        final futures = batch.map((video) async {
          if (_isCancelled) return;

          final videoUrl = video['url'] ?? video['webpage_url'];
          if (videoUrl == null) return;

          // Resolve thumbnail from multiple possible keys
          String? childThumbnail = video['thumbnail'] as String?;
          if (childThumbnail == null && video['thumbnails'] is List) {
            final thumbs = video['thumbnails'] as List;
            if (thumbs.isNotEmpty && thumbs.last is Map) {
              childThumbnail = thumbs.last['url'] as String?;
            }
          }

          final childTask = DownloadTask()
            ..url = videoUrl
            ..provider = task.provider
            ..title = video['title'] ?? 'Video'
            ..thumbnail = childThumbnail
            ..channelName = video['channel'] ?? video['uploader']
            ..category = task.category
            ..downloadStatus = WorkStatus.running
            ..playlistParentId = taskId;

          await db.saveTask(childTask);

          try {
            final childId = childTask.id;
            final childFilename = FileUtils.sanitizeFilename(
                '${completed + 1} - ${childTask.title ?? "Video"}');

            final format0 = _resolveFormat(format, isAudio: isAudio);
            final quality0 = _resolveQuality(quality);
            final appTempDir = await getTemporaryDirectory();

            // Compute expected file path for this child
            final ext = format0.name; // mp4, mkv, mp3, m4a, ogg
            final expectedChildPath =
                '$playlistDir${Platform.pathSeparator}$childFilename.$ext';

            final process = await _service.startDownload(
              videoUrl,
              playlistDir,
              format: format0,
              quality: quality0,
              tempPath: appTempDir.path,
              customFilename: childFilename,
            );

            _activeProcesses.add(process);

            process.stdout.transform(const SystemEncoding().decoder).listen((line) {
              for (var l in line.split('\n')) {
                l = l.trim();
                if (l.isEmpty) continue;
                final progress = _service.parseProgress(l);
                if (progress != null) {
                  final childProgress = (progress['progress'] ?? 0.0) / 100.0;

                  // Update parent container with overall progress
                  updateProgress({
                    'progress': (completed + childProgress) / videos.length,
                    'downloadSpeed': progress['speed'],
                    'childTitle': childTask.title,
                    'childProgress': childProgress,
                  });

                  // Update individual child task so its UI row updates
                  try {
                    final notifier = ref.container.read(
                        activeDownloadProgressProvider.notifier);
                    notifier.update(childId, {
                      'progress': childProgress,
                      'downloadSpeed': progress['speed'],
                      'eta': progress['eta'],
                      'totalSize': progress['totalSize'],
                    });
                  } catch (_) {}
                }
              }
            });

            final exitCode = await process.exitCode;
            _activeProcesses.remove(process);

            if (_isCancelled) return;

            // Remove child live progress entry
            try {
              ref.container.read(activeDownloadProgressProvider.notifier)
                  .remove(childId);
            } catch (_) {}

            final child = await db.getTask(childId);
            if (child != null) {
              child.downloadStatus =
                  exitCode == 0 ? WorkStatus.completed : WorkStatus.failed;
              child.progress = exitCode == 0 ? 1.0 : 0.0;

              if (exitCode == 0) {
                // Set filePath and dirPath for the child
                child.dirPath = playlistDir;
                if (await File(expectedChildPath).exists()) {
                  child.filePath = expectedChildPath;
                } else {
                  // Scan for the actual file if extension differs
                  child.filePath = await _findChildFile(
                      playlistDir, childFilename) ?? expectedChildPath;
                }
              }

              await db.saveTask(child);
            }

            if (exitCode == 0) completed++;
          } catch (e) {
            debugPrint('Playlist child download failed: $e');
          }
        });

        await Future.wait(futures);

        // Update container progress
        final container = await db.getTask(taskId);
        if (container != null) {
          container.playlistCompletedVideos = completed;
          container.progress = videos.isNotEmpty ? completed / videos.length : 0.0;
          await db.saveTask(container);
        }
      }

      if (!_isCancelled) {
        final container = await db.getTask(taskId);
        if (container != null) {
          container.downloadStatus = WorkStatus.completed;
          container.progress = 1.0;
          container.completedAt = DateTime.now();
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

  // Scan directory for a file matching the base name (in case yt-dlp chose a different extension)
  Future<String?> _findChildFile(String dir, String baseName) async {
    try {
      final directory = Directory(dir);
      await for (final entity in directory.list()) {
        if (entity is File) {
          final name = entity.path.split(Platform.pathSeparator).last;
          if (name.startsWith(baseName)) {
            return entity.path;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  DownloadFormat _resolveFormat(String? format, {bool isAudio = false}) {
    switch (format?.toLowerCase()) {
      case 'mp4': return DownloadFormat.mp4;
      case 'mkv': return DownloadFormat.mkv;
      case 'mp3': return DownloadFormat.mp3;
      case 'm4a': return DownloadFormat.m4a;
      case 'ogg': return DownloadFormat.ogg;
      default: return isAudio ? DownloadFormat.mp3 : DownloadFormat.mp4;
    }
  }

  DownloadQuality _resolveQuality(String? quality) {
    switch (quality?.toLowerCase()) {
      case 'best': return DownloadQuality.best;
      case 'high': case '1080': case '1080p': return DownloadQuality.p1080;
      case 'medium': case '720': case '720p': return DownloadQuality.p720;
      case 'low': case '480': case '480p': return DownloadQuality.p480;
      case '1440': case '1440p': return DownloadQuality.p1440;
      case '2160': case '2160p': case '4k': return DownloadQuality.p2160;
      default: return DownloadQuality.best;
    }
  }

  @override
  Future<void> pause() async {
    _isCancelled = true;
    for (var p in _activeProcesses) {
      try { p.kill(); } catch (_) {}
    }
    _activeProcesses.clear();

    final task = await db.getTask(taskId);
    if (task != null) {
      task.downloadStatus = WorkStatus.paused;
      await db.saveTask(task);
    }
    removeProgress();
  }

  @override
  Future<void> cancel() async {
    _isCancelled = true;
    for (var p in _activeProcesses) {
      try { p.kill(); } catch (_) {}
    }
    _activeProcesses.clear();
    removeProgress();
  }
}
