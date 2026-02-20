import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/core/services/db_service.dart';
import 'package:kzdownloader/core/services/download_service.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/core/utils/utils.dart';
import 'package:kzdownloader/core/utils/download_helper.dart';
import 'package:kzdownloader/core/utils/checksum_verifier.dart';
import 'package:disk_space_2/disk_space_2.dart';

import 'package:kzdownloader/core/download/logic/yt_dlp_service.dart';
import 'package:kzdownloader/core/download/providers/summary_provider.dart';
import 'package:kzdownloader/core/download/providers/url_metadata.dart';

import 'package:kzdownloader/core/download/strategies/download_strategy.dart';
import 'package:kzdownloader/core/download/strategies/standard_download_strategy.dart';
import 'package:kzdownloader/core/download/strategies/idm_download_strategy.dart';
import 'package:kzdownloader/core/download/strategies/ytdlp_strategy.dart';
import 'package:kzdownloader/core/download/strategies/playlist_strategy.dart';
import 'package:kzdownloader/core/download/strategies/download_manager.dart';

part 'download_provider.g.dart';

// ===========================================================================
// Support Providers
// ===========================================================================

@Riverpod(keepAlive: true)
DbService dbService(Ref ref) => DbService();

@Riverpod(keepAlive: true)
Future<void> dbInit(Ref ref) async {
  final db = ref.read(dbServiceProvider);
  await db.init();
  await _sanitizeZombieTasks(db);
}

// Resets tasks left in a running state after an app crash.
Future<void> _sanitizeZombieTasks(DbService db) async {
  final tasks = await db.getAllTasks();
  for (var task in tasks) {
    if (task.downloadStatus == WorkStatus.running ||
        task.summaryStatus == WorkStatus.running) {
      await db.updateTask(task.id, (t) {
        if (t.downloadStatus == WorkStatus.running) {
          t.downloadStatus = WorkStatus.paused;
        }
        if (t.summaryStatus == WorkStatus.running) {
          t.summaryStatus = WorkStatus.paused;
        }
        t.downloadSpeed = null;
        t.eta = null;
        t.activeWorkers = 0;
      });
    }
  }
}

@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  TaskCategory? build() => null;
  void setCategory(TaskCategory? category) => state = category;
}

@riverpod
class LastAddedTaskId extends _$LastAddedTaskId {
  @override
  int? build() => null;
  void setTaskId(int id) => state = id;
}

@riverpod
class ExpandedTaskId extends _$ExpandedTaskId {
  @override
  int? build() => null;
  void setTaskId(int? id) => state = id;
}

// High-frequency UI progress map (bypasses Isar for performance).
@Riverpod(keepAlive: true)
class ActiveDownloadProgress extends _$ActiveDownloadProgress {
  @override
  Map<int, Map<String, dynamic>> build() => {};

  void update(int taskId, Map<String, dynamic> data) {
    state = {...state, taskId: data};
  }

  void remove(int taskId) {
    if (state.containsKey(taskId)) {
      final newState = Map<int, Map<String, dynamic>>.from(state);
      newState.remove(taskId);
      state = newState;
    }
  }
}

// ===========================================================================
// Main Download Provider
// ===========================================================================

@riverpod
class DownloadList extends _$DownloadList {
  final DownloadManager _manager = DownloadManager();

  final Map<String, Future<UrlMetadata?>> _headRequestCache = {};
  final Map<String, Future<Map<String, dynamic>>> _ytMetadataCache = {};

  @override
  Stream<List<DownloadTask>> build() async* {
    await ref.watch(dbInitProvider.future);
    final db = ref.read(dbServiceProvider);
    yield* db.watchTasks();
    ref.onDispose(() {
      _manager.pauseAll();
    });
  }

  // =========================================================================
  // Public API
  // =========================================================================

  Future<DownloadTask?> addTask(
    String rawUrl,
    String provider, {
    String? format,
    String? quality,
    bool summarize = false,
    bool isAudio = false,
    bool onlySummary = false,
    String summaryType = 'short',
    TaskCategory? category,
    String? expectedChecksum,
    String? checksumAlgorithm,
  }) async {
    final db = ref.read(dbServiceProvider);
    final url = rawUrl.trim();

    TaskCategory finalCategory = category ?? UrlUtils.detectCategory(url);
    if (finalCategory == TaskCategory.playlist ||
        UrlUtils.isYouTubePlaylist(url)) {
      finalCategory = isAudio ? TaskCategory.music : TaskCategory.video;
    }
    if (isAudio && finalCategory != TaskCategory.playlist) {
      finalCategory = TaskCategory.music;
    }

    final existingTask = await db.findTaskByUrl(url);
    if (existingTask != null) {
      return _handleExistingTask(existingTask.id, db, finalCategory, provider,
          format, quality, summarize, isAudio, onlySummary, summaryType);
    }

    final task = DownloadTask()
      ..url = url
      ..provider = provider
      ..category = finalCategory
      ..progress = 0
      ..summaryType = summaryType
      ..createdAt = DateTime.now()
      ..isPlaylistContainer =
          (category == TaskCategory.playlist || UrlUtils.isYouTubePlaylist(url))
      ..downloadStatus = onlySummary ? WorkStatus.none : WorkStatus.pending
      ..summaryStatus =
          (summarize || onlySummary) ? WorkStatus.pending : WorkStatus.none;

    // Store checksum info if provided
    if (expectedChecksum != null && expectedChecksum.isNotEmpty) {
      task.expectedChecksum = expectedChecksum.trim();
      task.checksumAlgorithm = checksumAlgorithm ??
          ChecksumVerifier.detectAlgorithm(expectedChecksum);
    }

    await db.saveTask(task);

    ref.read(selectedCategoryProvider.notifier).setCategory(finalCategory);
    ref.read(lastAddedTaskIdProvider.notifier).setTaskId(task.id);
    ref.read(expandedTaskIdProvider.notifier).setTaskId(task.id);

    if (onlySummary) {
      await _ensureMetadata(task.id, url, provider);
      final freshTask = await db.getTask(task.id);
      if (freshTask != null) {
        ref.read(summaryManagerProvider.notifier).generateSummary(freshTask,
            summaryType: summaryType, skipMetadataRetrieval: true);
      }
    } else {
      _startDownloadStrategy(task.id,
          format: format,
          quality: quality,
          isAudio: isAudio,
          summarize: summarize);
    }

    return (await db.getTask(task.id))!;
  }

  Future<void> pauseTask(int id) async {
    if (_manager.hasActive(id)) {
      await _manager.get(id)?.pause();
    }
    _manager.onCancel(id);

    final db = ref.read(dbServiceProvider);
    await db.updateTask(id, (t) {
      if (t.downloadStatus == WorkStatus.running ||
          t.downloadStatus == WorkStatus.pending) {
        t.downloadStatus = WorkStatus.paused;
      }
    });
  }

  Future<void> resumeTask(int id) async {
    final db = ref.read(dbServiceProvider);
    final task = await db.getTask(id);
    if (task == null) return;
    if (task.downloadStatus == WorkStatus.running) return;
    if (task.downloadStatus.isFinished &&
        task.downloadStatus != WorkStatus.failed) {
      ref.read(activeDownloadProgressProvider.notifier).remove(task.id);
      return;
    }

    _startDownloadStrategy(id);
  }

  // Resets task state and restarts from scratch.
  Future<void> retryDownload(int id) async {
    final db = ref.read(dbServiceProvider);
    final task = await db.getTask(id);
    if (task == null) return;
    if (task.downloadStatus == WorkStatus.running) return;

    if (_manager.hasActive(id)) {
      await _manager.get(id)?.cancel();
      _manager.unregister(id);
    }

    await db.updateTask(id, (t) {
      t.downloadStatus = WorkStatus.pending;
      t.progress = 0;
      t.createdAt = DateTime.now();
      t.downloadSpeed = null;
      t.eta = null;
      t.errorMessage = null;
      t.completedSteps =
          t.completedSteps.where((s) => s != 'Download Completed').toList();
    });

    _startDownloadStrategy(id);
  }

  Future<void> cancelTask(int id) async {
    final db = ref.read(dbServiceProvider);

    final task = await db.getTask(id);
    if (task != null && task.isPlaylistContainer) {
      final children =
          (await db.getAllTasks()).where((t) => t.playlistParentId == id);
      for (var child in children) {
        if (!child.downloadStatus.isFinished) await cancelTask(child.id);
      }
    }

    if (_manager.hasActive(id)) {
      await _manager.get(id)?.cancel();
    }
    _manager.onCancel(id);

    await db.updateTask(id, (t) {
      t.downloadStatus = WorkStatus.cancelled;
      if (t.summaryStatus.isActive || t.summaryStatus == WorkStatus.pending) {
        t.summaryStatus = WorkStatus.cancelled;
      }
    });
    ref.read(activeSummariesProvider.notifier).remove(id);
  }

  Future<void> deleteTask(int id) async {
    await cancelTask(id);
    final db = ref.read(dbServiceProvider);

    final task = await db.getTask(id);
    if (task != null && task.isPlaylistContainer) {
      final children =
          (await db.getAllTasks()).where((t) => t.playlistParentId == id);
      for (var c in children) {
        await db.deleteTask(c.id);
      }
    }

    await db.deleteTask(id);
    ref.read(activeSummariesProvider.notifier).remove(id);
  }

  // =========================================================================
  // Private Logic
  // =========================================================================

  Future<DownloadTask?> _handleExistingTask(
      int taskId,
      DbService db,
      TaskCategory newCat,
      String provider,
      String? format,
      String? quality,
      bool summarize,
      bool isAudio,
      bool onlySummary,
      String summaryType) async {
    final task = await db.getTask(taskId);
    if (task == null) return null;

    if (task.downloadStatus == WorkStatus.running) {
      if (onlySummary) {
        await db.updateTask(taskId, (t) => t.summaryType = summaryType);
        final fresh = await db.getTask(taskId);
        if (fresh != null) {
          ref.read(summaryManagerProvider.notifier).generateSummary(fresh,
              summaryType: summaryType, skipMetadataRetrieval: true);
        }
      }
      return db.getTask(taskId);
    }

    await db.updateTask(taskId, (t) {
      t.category = newCat;
      t.provider = provider;
      t.summaryType = summaryType;
      t.createdAt = DateTime.now();
      t.errorMessage = null;

      if (onlySummary) {
        t.downloadStatus = WorkStatus.none;
        t.summaryStatus = WorkStatus.pending;
      } else {
        t.downloadStatus = WorkStatus.pending;
        t.summaryStatus = summarize
            ? WorkStatus.pending
            : (t.summaryStatus.isActive ? t.summaryStatus : WorkStatus.none);
      }
    });

    if (onlySummary) {
      await _ensureMetadata(taskId, task.url, provider);
      final fresh = await db.getTask(taskId);
      if (fresh != null) {
        ref.read(summaryManagerProvider.notifier).generateSummary(fresh,
            summaryType: summaryType, skipMetadataRetrieval: true);
      }
    } else {
      _startDownloadStrategy(taskId,
          format: format,
          quality: quality,
          isAudio: isAudio,
          summarize: summarize);
    }

    return db.getTask(taskId);
  }

  // Selects and launches the correct download strategy for a task.
  // Routes through DownloadManager queue for global concurrency control.
  Future<void> _startDownloadStrategy(
    int taskId, {
    String? format,
    String? quality,
    bool isAudio = false,
    bool summarize = false,
  }) async {
    final db = ref.read(dbServiceProvider);

    // Resolve format from settings if not explicitly provided
    if (format == null || format.isEmpty) {
      final settings = SettingsService();
      final defaultFormat = isAudio
          ? await settings.getDefaultAudioFormat()
          : await settings.getDefaultFormat();
      format = defaultFormat.name;
    }

    final initialTask = await db.getTask(taskId);
    if (initialTask == null) return;

    // Fetch yt-dlp metadata if needed (do this before queueing so title resolves)
    if (UrlUtils.detectProvider(initialTask.url) == 'yt-dlp' ||
        initialTask.provider == 'yt-dlp') {
      await _ensureMetadata(taskId, initialTask.url, initialTask.provider);
    }

    // Capture resolved format for closure
    final resolvedFormat = format;

    // Enqueue through the manager — it will call the callback when
    // the concurrency limit allows.
    await _manager.enqueue(taskId, () async {
      await _executeDownloadStrategy(
        taskId,
        format: resolvedFormat,
        quality: quality,
        isAudio: isAudio,
        summarize: summarize,
      );
    });
  }

  // Actually executes the download strategy (called by the queue).
  Future<void> _executeDownloadStrategy(
    int taskId, {
    String? format,
    String? quality,
    bool isAudio = false,
    bool summarize = false,
  }) async {
    final db = ref.read(dbServiceProvider);

    await db.updateTask(taskId, (t) => t.downloadStatus = WorkStatus.running);

    if (summarize) {
      final freshTask = await db.getTask(taskId);
      if (freshTask != null) {
        ref.read(summaryManagerProvider.notifier).generateSummary(freshTask,
            summaryType: freshTask.summaryType ?? 'short',
            skipMetadataRetrieval: true);
      }
    }

    final task = await db.getTask(taskId);
    if (task == null) return;

    DownloadStrategy strategy;

    if (task.isPlaylistContainer || UrlUtils.isYouTubePlaylist(task.url)) {
      final ytDlp = YtDlpService();
      strategy = PlaylistStrategy(taskId, db, ref, ytDlp);
    } else if (UrlUtils.detectProvider(task.url) == 'yt-dlp' ||
        task.provider == 'yt-dlp') {
      final ytDlp = YtDlpService();
      strategy = YtDlpStrategy(taskId, db, ref, ytDlp);
    } else {
      final meta = await _performHeadRequest(task.url);
      if (meta != null) {
        await db.updateTask(taskId, (t) {
          if (meta.size > 0) {
            t.totalSize = DownloadHelper.formatBytes(meta.size);
          }
          if (meta.remoteFileName != null &&
              (t.title == null || t.title!.isEmpty)) {
            t.title = FileUtils.sanitizeFilename(meta.remoteFileName!);
          }
        });
      }

      final size = meta?.size ?? 0;
      final acceptRanges = meta?.acceptRanges ?? false;

      // Disk space check for generic downloads with known size
      if (size > 0) {
        try {
          final freeMB = await DiskSpace.getFreeDiskSpace;
          if (freeMB != null) {
            final requiredMB =
                (size / (1024 * 1024)).ceil() + 100; // +100MB safety margin
            if (freeMB < requiredMB) {
              throw Exception(
                  'Insufficient disk space: ${freeMB.toStringAsFixed(0)} MB free, '
                  '${requiredMB} MB required');
            }
          }
        } catch (e) {
          if (e.toString().contains('Insufficient disk space')) rethrow;
          debugPrint('[DownloadProvider] Disk space check skipped: $e');
        }
      }

      bool useIdm = (task.provider == 'Pro' ||
              (task.provider != 'Standard' && size > 100 * 1024 * 1024)) &&
          size > 0 &&
          acceptRanges;

      if (useIdm) {
        strategy = IDMDownloadStrategy(taskId, db, ref,
            knownSize: size, knownAcceptRanges: acceptRanges);
      } else {
        strategy = StandardDownloadStrategy(taskId, db, ref,
            knownSize: size, knownAcceptRanges: acceptRanges);
      }
    }

    _manager.register(taskId, strategy);

    try {
      await strategy.start(format: format, quality: quality, isAudio: isAudio);

      // Checksum verification after successful download
      final completedTask = await db.getTask(taskId);
      if (completedTask != null &&
          completedTask.downloadStatus == WorkStatus.completed &&
          completedTask.expectedChecksum != null &&
          completedTask.checksumAlgorithm != null &&
          completedTask.filePath != null) {
        debugPrint('[DownloadProvider] Verifying checksum for task $taskId...');
        try {
          final result = await ChecksumVerifier.verify(
            completedTask.filePath!,
            completedTask.expectedChecksum!,
            completedTask.checksumAlgorithm!,
          );
          await db.updateTask(taskId, (t) => t.checksumResult = result);
          debugPrint(
              '[DownloadProvider] Checksum result for task $taskId: $result');
        } catch (e) {
          debugPrint('[DownloadProvider] Checksum error for task $taskId: $e');
          await db.updateTask(taskId, (t) => t.checksumResult = 'error');
        }
      }
    } catch (e) {
      debugPrint('[DownloadProvider] Strategy error for task $taskId: $e');
      await db.updateTask(taskId, (t) {
        t.downloadStatus = WorkStatus.failed;
        t.errorMessage = e.toString();
      });
    } finally {
      // Notify queue that this download slot is free
      _manager.onComplete(taskId);
    }
  }

  /// Updates the URL of a failed/paused task (for link expiration recovery).
  Future<void> updateTaskUrl(int id, String newUrl) async {
    final db = ref.read(dbServiceProvider);
    await db.updateTask(id, (t) {
      t.url = newUrl.trim();
      t.errorMessage = null;
    });
  }

  // =========================================================================
  // Prefetch API (UI Optimizations)
  // =========================================================================

  // Prefetches generic file metadata (HEAD request) for size/name preview.
  void prefetchMetadata(String url) {
    if (url.trim().isEmpty) return;
    if (UrlUtils.detectProvider(url) == 'yt-dlp') return;
    if (!_headRequestCache.containsKey(url)) {
      _performHeadRequest(url);
    }
  }

  // Prefetches video metadata (title, thumbnail) via yt-dlp.
  void prefetchVideoMetadata(String url) {
    if (url.trim().isEmpty) return;
    if (UrlUtils.detectProvider(url) != 'yt-dlp') return;
    if (_ytMetadataCache.containsKey(url)) return;

    final ytDlp = YtDlpService();
    try {
      final future = UrlUtils.isYouTubePlaylist(url)
          ? ytDlp.getPlaylistMetadata(url)
          : ytDlp.getMetadata(url);

      _ytMetadataCache[url] = future;

      future.catchError((e) {
        debugPrint('[DownloadProvider] Prefetch error for $url: $e');
        _ytMetadataCache.remove(url);
        return <String, dynamic>{};
      });
    } catch (_) {}
  }

  // Fetches and persists yt-dlp metadata for a task.
  Future<bool> _ensureMetadata(int taskId, String url, String provider) async {
    final db = ref.read(dbServiceProvider);
    final currentTask = await db.getTask(taskId);
    if (currentTask == null) return false;
    if (currentTask.title != null && currentTask.title!.isNotEmpty) return true;
    if (UrlUtils.detectProvider(url) != 'yt-dlp' && provider != 'yt-dlp')
      return false;

    try {
      final ytDlp = YtDlpService();
      Map<String, dynamic> metadata;

      if (_ytMetadataCache.containsKey(url)) {
        metadata = await _ytMetadataCache[url]!;
      } else {
        final future = UrlUtils.isYouTubePlaylist(url)
            ? ytDlp.getPlaylistMetadata(url)
            : ytDlp.getMetadata(url);
        _ytMetadataCache[url] = future;
        metadata = await future;
      }

      Map<String, String> details = {};
      if (currentTask.stepDetailsJson != null) {
        try {
          details = Map<String, String>.from(
              jsonDecode(currentTask.stepDetailsJson!));
        } catch (_) {}
      }
      details['Metadata Retrieval'] =
          const JsonEncoder.withIndent('  ').convert(metadata);

      await db.updateTask(taskId, (t) {
        t.title = metadata['title'];
        t.thumbnail = metadata['thumbnail'];
        t.channelId = metadata['channelId'];
        t.channelName = metadata['channel'] ?? metadata['uploader'];
        t.cachedDescription = metadata['description'] ?? '';
        t.stepDetailsJson = jsonEncode(details);

        if (UrlUtils.isYouTubePlaylist(url)) {
          t.playlistTotalVideos = metadata['videoCount'];
          t.playlistId = metadata['playlistId'];
        }

        if (!t.completedSteps.contains('Metadata Retrieval')) {
          t.completedSteps = [...t.completedSteps, 'Metadata Retrieval'];
        }
      });

      return true;
    } catch (e) {
      debugPrint('[DownloadProvider] Metadata fetch error: $e');
      return false;
    }
  }

  // =========================================================================
  // HTTP Helpers
  // =========================================================================

  Future<UrlMetadata?> _performHeadRequest(String url) async {
    // Don't cache for resume — always get fresh metadata.
    final future = Future(() async {
      try {
        final headRes = await getHeadInfo(url, {});
        final size = int.tryParse(headRes['content-length'] ?? '0') ?? 0;
        final acceptRanges =
            headRes['accept-ranges']?.toLowerCase().contains('bytes') ?? false;

        String? fileName =
            _parseFileNameFromHeader(headRes['content-disposition']);
        if (fileName == null || fileName.isEmpty) {
          try {
            fileName = Uri.decodeComponent(Uri.parse(url).pathSegments.last);
          } catch (_) {}
        }
        return UrlMetadata(
            size: size, acceptRanges: acceptRanges, remoteFileName: fileName);
      } catch (_) {
        return null;
      }
    });

    _headRequestCache[url] = future;
    return future;
  }

  String? _parseFileNameFromHeader(String? contentDisposition) {
    if (contentDisposition == null) return null;
    final nameRegex = RegExp(r'filename="?([^"]+)"?');
    final match = nameRegex.firstMatch(contentDisposition);
    if (match != null) return match.group(1);
    return null;
  }

  Future<void> clearHistory() async {
    await _manager.pauseAll();
    await ref.read(dbServiceProvider).clearAllTasks();
    _headRequestCache.clear();
    _ytMetadataCache.clear();
  }

  Future<void> resumeTaskInternal(int id,
      {String? format, String? quality, bool isAudio = false}) async {
    _startDownloadStrategy(id,
        format: format, quality: quality, isAudio: isAudio);
  }
}
