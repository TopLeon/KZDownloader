import 'dart:async';
import 'dart:io';
import 'package:kzdownloader/core/download/logic/chunk_downloader.dart';
import 'package:kzdownloader/core/download/logic/file_path_resolver.dart';
import 'package:kzdownloader/core/download/strategies/download_strategy.dart';
import 'package:kzdownloader/core/utils/download_helper.dart';
import 'package:kzdownloader/models/download_task.dart';

// Single-threaded download strategy using ChunkDownloader.
class StandardDownloadStrategy extends DownloadStrategy {
  final int? knownSize;
  final bool? knownAcceptRanges;

  ChunkDownloader? _downloader;
  late DateTime _startedAt;

  StandardDownloadStrategy(
    super.taskId,
    super.db,
    super.ref, {
    this.knownSize,
    this.knownAcceptRanges,
  });

  @override
  Future<void> start(
      {String? format, String? quality, bool isAudio = false}) async {
    _startedAt = DateTime.now();

    try {
      final task = await db.getTask(taskId);
      if (task == null) throw Exception('Task $taskId not found');

      final filePath = await FilePathResolver.resolve(taskId, db);

      _downloader = ChunkDownloader();

      await _downloader!.download(
        task.url,
        filePath,
        knownFileSize: knownSize,
        knownAcceptRanges: knownAcceptRanges,
        onProgress: (progress, speed, downloaded) {
          final total = knownSize ?? 0;
          updateProgress({
            'progress': progress,
            'downloadSpeed': DownloadHelper.formatSpeed(speed),
            'downloaded': DownloadHelper.formatBytes(downloaded),
            'totalSize': total > 0 ? DownloadHelper.formatBytes(total) : null,
          });
        },
      );

      // If size was unknown, measure the finished file so finalizeSuccess can persist it
      if ((knownSize == null || knownSize == 0)) {
        try {
          final fileSize = await File(filePath).length();
          if (fileSize > 0) {
            updateProgress({
              'totalSize': DownloadHelper.formatBytes(fileSize),
            });
          }
        } catch (_) {}
      }

      await finalizeSuccess(_startedAt);
    } catch (e) {
      // ChunkDownloader throws 'Download paused by user' on pause;
      // pause() already sets status correctly, so don't call handleError.
      final isPause = e.toString().toLowerCase().contains('paused');
      if (!isPause) {
        await handleError(e);
        rethrow;
      }
    }
  }

  @override
  Future<void> pause() async {
    _downloader?.pause();

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
    _downloader?.pause();
    removeProgress();
  }
}
