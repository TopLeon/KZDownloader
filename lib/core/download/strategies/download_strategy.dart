import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/core/services/db_service.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/core/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

// Base class for all download strategies.
// Concrete strategies implement start/pause/cancel and use the shared template methods.
abstract class DownloadStrategy {
  final int taskId;
  final DbService db;
  final Ref ref;

  DownloadStrategy(this.taskId, this.db, this.ref);

  Future<void> start({String? format, String? quality, bool isAudio = false});
  Future<void> pause();
  Future<void> cancel();

  // Updates the real-time progress map (bypasses Isar for performance).
  void updateProgress(Map<String, dynamic> data) {
    try {
      final container = ref.container;
      final notifier = container.read(activeDownloadProgressProvider.notifier);
      notifier.update(taskId, data);
    } catch (e) {
      debugPrint('Progress update skipped: $e');
    }
  }

  // Removes this task's entry from the live progress map.
  void removeProgress() {
    try {
      final container = ref.container;
      final notifier = container.read(activeDownloadProgressProvider.notifier);
      notifier.remove(taskId);
    } catch (e) {
      debugPrint('Progress removal skipped: $e');
    }
  }

  // Template: marks the task as successfully completed in the database.
  Future<void> finalizeSuccess(DateTime startedAt) async {
    // Capture totalSize from live progress before clearing it
    String? liveTotal;
    try {
      final progressMap = ref.container.read(activeDownloadProgressProvider);
      liveTotal = progressMap[taskId]?['totalSize'] as String?;
    } catch (_) {}

    removeProgress();

    final elapsed = calculateProcessTime(startedAt);
    final task = await db.getTask(taskId);
    if (task == null) return;

    task.downloadStatus = WorkStatus.completed;
    task.progress = 1.0;
    task.completedAt = DateTime.now();
    task.processTime = elapsed;
    task.downloadSpeed = null;
    task.eta = null;
    task.errorMessage = null;
    // Persist totalSize if we captured it (prefer existing DB value if already set)
    if (liveTotal != null &&
        (task.totalSize == null || task.totalSize!.isEmpty)) {
      task.totalSize = liveTotal;
    }
    await db.saveTask(task);
  }

  // Template: marks the task as failed with an error message.
  Future<void> handleError(Object error) async {
    removeProgress();

    final msg = error.toString();
    if (msg.toLowerCase().contains('paused') ||
        msg.toLowerCase().contains('cancel')) {
      return;
    }

    debugPrint('Download error (task $taskId): $msg');
    final task = await db.getTask(taskId);
    if (task == null) return;

    task.downloadStatus = WorkStatus.failed;
    task.errorMessage = msg;
    task.downloadSpeed = null;
    task.eta = null;
    await db.saveTask(task);
  }
}
