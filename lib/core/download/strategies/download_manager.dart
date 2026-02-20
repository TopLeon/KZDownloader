import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kzdownloader/core/download/strategies/download_strategy.dart';
import 'package:kzdownloader/core/services/settings_service.dart';

/// Entry in the download queue waiting to be started.
class _QueueEntry {
  final int taskId;
  final Future<void> Function() startCallback;

  _QueueEntry(this.taskId, this.startCallback);
}

/// Manages active download strategies and enforces global concurrency limits.
class DownloadManager {
  final Map<int, DownloadStrategy> _strategies = {};
  final List<_QueueEntry> _queue = [];
  final Set<int> _runningTaskIds = {};
  final SettingsService _settingsService = SettingsService();

  int _maxConcurrent = 3;

  DownloadManager() {
    _loadMaxConcurrent();
  }

  Future<void> _loadMaxConcurrent() async {
    _maxConcurrent = await _settingsService.getMaxConcurrentGlobalDownloads();
  }

  /// Update the max concurrent limit (called when settings change).
  void setMaxConcurrent(int value) {
    _maxConcurrent = value;
    _tryStartNext();
  }

  /// Register a strategy for a task (used for pause/cancel lookups).
  void register(int taskId, DownloadStrategy strategy) {
    if (_strategies.containsKey(taskId)) {
      _strategies[taskId]?.pause();
    }
    _strategies[taskId] = strategy;
  }

  /// Enqueue a download. If under the concurrency limit, starts immediately;
  /// otherwise queues it for later.
  Future<void> enqueue(
      int taskId, Future<void> Function() startCallback) async {
    // If already running or queued, skip
    if (_runningTaskIds.contains(taskId)) return;
    if (_queue.any((e) => e.taskId == taskId)) return;

    await _loadMaxConcurrent();

    if (_runningTaskIds.length < _maxConcurrent) {
      _runningTaskIds.add(taskId);
      try {
        await startCallback();
      } catch (e) {
        debugPrint('[DownloadManager] startCallback error for $taskId: $e');
      }
    } else {
      _queue.add(_QueueEntry(taskId, startCallback));
      debugPrint(
          '[DownloadManager] Task $taskId queued (${_queue.length} in queue, $_maxConcurrent max)');
    }
  }

  /// Called when a download finishes (success or failure).
  void onComplete(int taskId) {
    _runningTaskIds.remove(taskId);
    _strategies.remove(taskId);
    _tryStartNext();
  }

  /// Called when a download is paused or cancelled by the user.
  void onCancel(int taskId) {
    _runningTaskIds.remove(taskId);
    _strategies.remove(taskId);
    // Also remove from queue if it was pending
    _queue.removeWhere((e) => e.taskId == taskId);
    _tryStartNext();
  }

  /// Check if a task is waiting in the queue (not yet started).
  bool isQueued(int taskId) => _queue.any((e) => e.taskId == taskId);

  /// Try to start the next queued download if under the limit.
  void _tryStartNext() {
    while (_queue.isNotEmpty && _runningTaskIds.length < _maxConcurrent) {
      final entry = _queue.removeAt(0);
      _runningTaskIds.add(entry.taskId);
      debugPrint(
          '[DownloadManager] Dequeuing task ${entry.taskId} (${_queue.length} remaining)');
      entry.startCallback().catchError((e) {
        debugPrint(
            '[DownloadManager] Queued startCallback error for ${entry.taskId}: $e');
      });
    }
  }

  void unregister(int taskId) {
    _strategies.remove(taskId);
  }

  DownloadStrategy? get(int taskId) => _strategies[taskId];

  bool hasActive(int taskId) => _strategies.containsKey(taskId);

  int get runningCount => _runningTaskIds.length;
  int get queuedCount => _queue.length;

  Future<void> pauseAll() async {
    for (var s in _strategies.values) {
      await s.pause();
    }
    _strategies.clear();
    _runningTaskIds.clear();
    _queue.clear();
  }

  Future<void> cancelAll() async {
    for (var s in _strategies.values) {
      await s.cancel();
    }
    _strategies.clear();
    _runningTaskIds.clear();
    _queue.clear();
  }
}
