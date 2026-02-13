import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kzdownloader/core/download/logic/chunck_downloader.dart';
import 'package:kzdownloader/core/download/logic/idm_downloader.dart';
import 'package:kzdownloader/core/services/db_service.dart';
import 'package:kzdownloader/core/utils/download_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/core/utils/utils.dart';
import 'package:kzdownloader/core/download/logic/yt_dlp_service.dart';
import 'package:kzdownloader/src/rust/api/download.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/core/services/llm_service.dart';

part 'download_provider.g.dart';

@Riverpod(keepAlive: true)
DbService dbService(Ref ref) {
  return DbService();
}

@Riverpod(keepAlive: true)
Future<void> dbInit(Ref ref) async {
  await ref.read(dbServiceProvider).init();
}

@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  TaskCategory? build() => null;

  void setCategory(TaskCategory? category) {
    state = category;
  }
}

@riverpod
class LastAddedTaskId extends _$LastAddedTaskId {
  @override
  int? build() => null;

  void setTaskId(int id) {
    state = id;
  }
}

@riverpod
class ExpandedTaskId extends _$ExpandedTaskId {
  @override
  int? build() => null;

  void setTaskId(int? id) {
    state = id;
  }
}

@riverpod
class DownloadList extends _$DownloadList {
  final Map<int, Process> _runningProcesses = {};
  final Map<String, CancelToken> _genericCancelTokens = {};
  final Map<int, ChunkDownloader> _activeChunkDownloaders = {};
  final Map<int, IDMDownloader> _activeIdmDownloaders = {};
  final Map<String, Future<UrlMetadata?>> _metadataCache = {};
  final Map<String, dynamic> _videoMetadataCache = {};

  @override
  Stream<List<DownloadTask>> build() async* {
    await ref.watch(dbInitProvider.future);
    final db = ref.read(dbServiceProvider);
    await _sanitizeZombieTasks(db);
    yield* db.watchTasks();
  }

  // Prefetches metadata for a URL by performing a HEAD request.
  // Skips video platform URLs as they are handled by yt-dlp.
  void prefetchMetadata(String url) {
    if (url.trim().isEmpty) return;

    final provider = UrlUtils.detectProvider(url);
    if (provider == 'yt-dlp') return;

    if (!_metadataCache.containsKey(url)) {
      _metadataCache[url] = _performHeadRequest(url);
    }
  }

  // Prefetches video metadata using yt-dlp.
  void prefetchVideoMetadata(String url) {
    if (url.trim().isEmpty) return;

    final provider = UrlUtils.detectProvider(url);
    if (provider != 'yt-dlp') return;

    if (!_metadataCache.containsKey(url)) {
      _metadataCache[url] = _performVideoMetadataExtraction(url);
    }
  }

  // Performs video metadata extraction using yt-dlp.
  Future<UrlMetadata?> _performVideoMetadataExtraction(String url) async {
    try {
      final ytDlp = YtDlpService();

      if (UrlUtils.isYouTubePlaylist(url)) {
        final metadata = await ytDlp.getPlaylistMetadata(url);
        _videoMetadataCache[url] = metadata;
      } else {
        final metadata = await ytDlp.getMetadata(url);
        _videoMetadataCache[url] = metadata;
      }

      return UrlMetadata(size: 0, acceptRanges: false, remoteFileName: null);
    } catch (e) {
      return null;
    }
  }

  // Performs a HEAD request to retrieve file metadata.
  Future<UrlMetadata?> _performHeadRequest(String url) async {
    try {
      final headRes = await getHeadInfoRust(url: url, headers: {});

      final contentLength = headRes['content-length'];
      int size = 0;
      if (contentLength != null) {
        size = int.tryParse(contentLength) ?? 0;
      }

      final acceptRangesHeader = headRes['accept-ranges'];
      final acceptRanges = acceptRangesHeader != null &&
          acceptRangesHeader.toLowerCase().contains('bytes');

      final contentDisposition = headRes['content-disposition'];
      final fileName = _parseFileNameFromHeader(contentDisposition);

      return UrlMetadata(
        size: size,
        acceptRanges: acceptRanges,
        remoteFileName: fileName,
      );
    } catch (e) {
      return null;
    }
  }

  // Sanitizes tasks that were interrupted by app closure.
  // Marks downloading/summarizing/converting tasks as paused on startup.
  Future<void> _sanitizeZombieTasks(DbService db) async {
    final tasks = await db.getAllTasks();

    for (var task in tasks) {
      if (task.status == 'downloading' ||
          task.status == 'summarizing' ||
          task.status == 'converting') {
        task.status = 'paused';
        task.errorMessage = "Interrupted by app closure";
        task.downloadSpeed = null;
        task.eta = null;
        await db.saveTask(task);
      }
    }
  }

  // Routes download to appropriate handler based on URL type.
  // Handles playlists, video platforms (yt-dlp), or generic HTTP downloads.
  Future<void> _startDownloadCheck(
    DownloadTask task,
    ytDlp,
    db, {
    String? format,
    String? quality,
    bool summarize = false,
    bool isAudio = false,
  }) async {
    if (task.category == TaskCategory.playlist ||
        UrlUtils.isYouTubePlaylist(task.url)) {
      task.category = TaskCategory.video;
      await _startPlaylistDownload(
        task,
        ytDlp,
        db,
        format: format,
        quality: quality,
        isAudio: isAudio,
      );
      return;
    }

    final detectedProvider = UrlUtils.detectProvider(task.url);
    bool useYtDlp = detectedProvider == 'yt-dlp';

    if (useYtDlp) {
      task.provider = 'yt-dlp';
      await _startYtDlpDownload(
        task,
        ytDlp,
        db,
        format: format,
        quality: quality,
        summarize: summarize,
        isAudio: isAudio,
      );
    } else {
      if (task.provider == 'yt-dlp') task.provider = 'http';
      await _startSmartDownload(task, db);
    }
  }

  // Intelligently routes generic downloads to either Dio (Standard) or IDM (Pro) based on file size.
  Future<void> _startSmartDownload(DownloadTask task, DbService db) async {
    try {
      task.status = 'downloading';
      task.startedAt = DateTime.now();
      if (!task.completedSteps.contains('Initialization')) {
        task.completedSteps = ['Initialization'];
      }
      task.errorMessage = null;

      _setSanitizedFileName(task);
      await db.saveTask(task);

      UrlMetadata? meta;
      if (!_metadataCache.containsKey(task.url)) {
        _metadataCache[task.url] = _performHeadRequest(task.url);
      }

      meta = await _metadataCache[task.url];
      _metadataCache.remove(task.url);

      int size = 0;
      bool acceptRanges = false;

      if (meta != null) {
        size = meta.size;
        acceptRanges = meta.acceptRanges;

        if (size > 0) {
          task.totalSize = DownloadHelper.formatBytes(size);
        }

        if (meta.remoteFileName != null && meta.remoteFileName!.isNotEmpty) {
          task.title = meta.remoteFileName;
          task.title = task.title!.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
        }
      }

      if (!task.completedSteps.contains('Metadata Retrieval')) {
        task.completedSteps = [...task.completedSteps, 'Metadata Retrieval'];
      }

      const int threshold = 100 * 1024 * 1024;
      bool useIdm;
      if (task.provider == 'Standard') {
        useIdm = false;
      } else if (task.provider == 'Pro') {
        useIdm = true;
      } else {
        useIdm = size >= threshold || size == 0;
        task.provider = useIdm ? 'Pro' : 'Standard';
      }
      await db.saveTask(task);

      if (useIdm) {
        await _startGenericDownloadIdm(
          task,
          db,
          knownSize: size,
          knownAcceptRanges: acceptRanges,
        );
      } else {
        await _startGenericDownload(task, db);
      }
    } catch (e) {
      task.status = 'error';
      task.errorMessage = e.toString();
      await db.saveTask(task);
    }
  }

  // Sets a sanitized filename from URL if task title is missing.
  void _setSanitizedFileName(DownloadTask task) {
    if (task.title == null || task.title!.isEmpty) {
      String rawName = task.url.split('/').last.split('?').first;
      if (rawName.isEmpty) rawName = "file_download";
      try {
        rawName = Uri.decodeComponent(rawName);
      } catch (_) {}
      task.title = rawName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    }
  }

  // Handles generic file downloads using Dio (Standard mode).
  Future<void> _startGenericDownload(DownloadTask task, DbService db) async {
    try {
      task.status = 'downloading';
      task.startedAt = DateTime.now();
      if (!task.completedSteps.contains('Initialization')) {
        task.completedSteps = ['Initialization'];
      }
      task.errorMessage = null;

      // Title already sanitized by _startSmartDownload

      final settings = SettingsService();
      final downloadPath = await settings.getDownloadPath();

      final targetDir =
          downloadPath ?? (await getDownloadsDirectory())?.path ?? '.';
      task.dirPath = targetDir;
      task.filePath = "$targetDir${Platform.pathSeparator}${task.title}";

      final cancelToken = CancelToken();
      _genericCancelTokens[task.id.toString()] = cancelToken;

      final downloader = ChunkDownloader();
      _activeChunkDownloaders[task.id] = downloader;

      await db.saveTask(task);

      DateTime lastDbSave = DateTime.now();
      await downloader.download(
        task.url,
        "$targetDir/${task.title}",
        onProgress: (progress, speed, downloaded) {
          task.progress = progress * 100;
          final speedMiB = speed / (1024 * 1024);
          task.downloadSpeed = '${speedMiB.toStringAsFixed(2)}MiB/s';

          // Throttle DB writes to at most once per second
          final now = DateTime.now();
          if (now.difference(lastDbSave).inMilliseconds >= 1000) {
            lastDbSave = now;
            db.saveTask(task);
          }
        },
      );

      if (!task.completedSteps.contains('Downloading')) {
        task.completedSteps = [...task.completedSteps, 'Downloading'];
      }

      task.status = 'completed';
      task.progress = 100.0;
      task.downloadSpeed = null;
      task.eta = null;
      task.completedAt = DateTime.now();
      task.processTime = calculateProcessTime(task.startedAt ?? task.createdAt);

      if (!task.completedSteps.contains('Download Completed')) {
        task.completedSteps.add('Download Completed');
      }

      _genericCancelTokens.remove(task.id.toString());
      _activeChunkDownloaders.remove(task.id);
      await db.saveTask(task);
    } catch (e) {
      _genericCancelTokens.remove(task.id.toString());
      _activeChunkDownloaders.remove(task.id);

      final errorMsg = e.toString().toLowerCase();
      if ((e is DioException && e.type == DioExceptionType.cancel) ||
          errorMsg.contains('paused') ||
          errorMsg.contains('cancelled')) {
        task.status = 'paused';
      } else {
        task.status = 'error';
        task.errorMessage = e.toString();
      }
      await db.saveTask(task);
    }
  }

  // Handles large file downloads using IDM (Pro mode) with multi-threaded chunks.
  Future<void> _startGenericDownloadIdm(
    DownloadTask task,
    DbService db, {
    int? knownSize,
    bool? knownAcceptRanges,
  }) async {
    task.status = 'downloading';
    task.startedAt = DateTime.now();
    if (!task.completedSteps.contains('Initialization')) {
      task.completedSteps = ['Initialization'];
    }
    task.errorMessage = null;

    final appSupportDir = await getApplicationSupportDirectory();
    final metaDir = appSupportDir.path;

    final downloader = IDMDownloader(
      maxWorkers: 8,
      minChunkSize: 5 * 1024 * 1024,
      metaDir: metaDir,
    );

    _activeIdmDownloaders[task.id] = downloader;

    // Throttle DB writes from the IDM status stream (fires every 500ms)
    DateTime lastIdmDbSave = DateTime.now();
    final subscription = downloader.statusStream.listen((data) {
      if (data['status'] == 'running') {
        task.progress = (data['progress'] as double) * 100;

        final speedBytesPerSec =
            data.containsKey('speed') ? (data['speed'] as num).toDouble() : 0.0;

        if (speedBytesPerSec > 0) {
          final speedMiBPerSec = speedBytesPerSec / (1024 * 1024);
          task.downloadSpeed = '${speedMiBPerSec.toStringAsFixed(2)}MiB/s';
        }

        // ETA is pre-calculated by IDMDownloader using stable session-average
        if (data.containsKey('eta') && data['eta'] != null) {
          task.eta = data['eta'] as String;
        }

        if (data.containsKey('activeWorkers')) {
          task.activeWorkers = data['activeWorkers'] as int?;
        }
        if (data.containsKey('totalWorkers')) {
          task.totalWorkers = data['totalWorkers'] as int?;
        }
        if (data.containsKey('workers')) {
          task.workersProgressJson = jsonEncode(data['workers']);
        }

        // Persist ~4x per second for smooth progress bar animation
        final now = DateTime.now();
        if (now.difference(lastIdmDbSave).inMilliseconds >= 250) {
          lastIdmDbSave = now;
          db.saveTask(task);
        }
      } else if (data['status'] == 'error') {
        task.status = 'error';
        task.errorMessage = data['error'];
        db.saveTask(task);
      } else if (data['status'] == 'paused') {
        task.status = 'paused';
        db.saveTask(task);
      }
    });

    if (task.title == null || task.title!.isEmpty) {
      task.title = "file_download";
    }
    task.title = task.title!.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

    final settings = SettingsService();
    final downloadPath = await settings.getDownloadPath();

    final targetDir =
        downloadPath ?? (await getDownloadsDirectory())?.path ?? '.';
    task.dirPath = targetDir;
    task.filePath = "$targetDir${Platform.pathSeparator}${task.title}";

    await db.saveTask(task);

    try {
      await downloader.download(
        task.url,
        "$targetDir/${task.title}",
        headers: {},
        knownFileSize: knownSize,
        knownAcceptRanges: knownAcceptRanges,
      );

      if (!task.completedSteps.contains('Downloading')) {
        task.completedSteps = [...task.completedSteps, 'Downloading'];
      }

      if (task.status != 'error' && task.status != 'paused') {
        task.status = 'completed';
        task.progress = 100.0;
        task.downloadSpeed = null;
        task.eta = null;
        task.completedAt = DateTime.now();
        task.processTime =
            calculateProcessTime(task.startedAt ?? task.createdAt);

        task.activeWorkers = null;
        task.totalWorkers = null;
        task.workersProgressJson = null;

        if (!task.completedSteps.contains('Download Completed')) {
          task.completedSteps.add('Download Completed');
        }
        await db.saveTask(task);
      }
    } catch (e) {
      if (e.toString().contains("Paused")) {
        task.status = 'paused';
      } else {
        task.status = 'error';
        task.errorMessage = e.toString();
      }
      await db.saveTask(task);
    } finally {
      subscription.cancel();
      _activeIdmDownloaders.remove(task.id);
    }
  }

  // Pauses any type of download task (Generic Dio, IDM, or yt-dlp).
  Future<void> pauseTaskGen(DownloadTask task) async {
    if (_genericCancelTokens.containsKey(task.id.toString())) {
      _genericCancelTokens[task.id.toString()]?.cancel();
    } else if (_activeIdmDownloaders.containsKey(task.id)) {
      await _activeIdmDownloaders[task.id]?.pause();
    } else if (_runningProcesses.containsKey(task.id)) {
      _runningProcesses[task.id]?.kill();
      _runningProcesses.remove(task.id);
    }
  }

  // Creates and starts a new download task or resumes an existing one.
  Future<DownloadTask> addTask(
    String rawUrl,
    String provider, {
    String? format,
    String? quality,
    bool summarize = false,
    bool isAudio = false,
    bool onlySummary = false,
    String summaryType = 'short',
    TaskCategory? category,
  }) async {
    final url = rawUrl;
    final db = ref.read(dbServiceProvider);
    final ytDlp = YtDlpService();

    TaskCategory finalCategory;
    bool isVideoPlatform = false;

    if (category != null) {
      finalCategory = category;
      isVideoPlatform = finalCategory == TaskCategory.video;
    } else {
      finalCategory = UrlUtils.detectCategory(url);
      isVideoPlatform = finalCategory == TaskCategory.video;
    }

    if (isAudio) {
      finalCategory = TaskCategory.music;
    }

    if (!isVideoPlatform) {
      summarize = false;
      onlySummary = false;
    }

    final existingTask = await db.findTaskByUrl(url);

    if (existingTask != null) {
      existingTask.createdAt = DateTime.now();
      if (category != null) {
        existingTask.category = category;
      }
      existingTask.status = 'pending';
      existingTask.progress = 0;
      existingTask.downloadSpeed = null;
      existingTask.eta = null;
      existingTask.errorMessage = null;
      existingTask.summaryType = summaryType;
      existingTask.completedSteps = [];

      await db.saveTask(existingTask);

      ref
          .read(selectedCategoryProvider.notifier)
          .setCategory(existingTask.category);
      ref.read(lastAddedTaskIdProvider.notifier).setTaskId(existingTask.id);

      if (onlySummary && isVideoPlatform) {
        if (existingTask.summary == null || existingTask.summary!.isEmpty) {
          _startSummaryGeneration(
            existingTask,
            ytDlp,
            db,
            onlySummary: true,
            summaryType: summaryType,
          );
        }
        return existingTask;
      }

      _startDownloadCheck(
        existingTask,
        ytDlp,
        db,
        format: format,
        quality: quality,
        summarize: summarize,
        isAudio: isAudio,
      );

      return existingTask;
    }

    final task = DownloadTask()
      ..url = url
      ..provider = provider
      ..category = finalCategory
      ..status = onlySummary ? 'summarizing' : 'pending'
      ..progress = 0
      ..summaryType = summaryType
      ..createdAt = DateTime.now();

    await db.saveTask(task);

    ref.read(selectedCategoryProvider.notifier).setCategory(finalCategory);
    ref.read(lastAddedTaskIdProvider.notifier).setTaskId(task.id);
    ref.read(expandedTaskIdProvider.notifier).setTaskId(task.id);

    if (onlySummary && isVideoPlatform) {
      _startSummaryGeneration(
        task,
        ytDlp,
        db,
        onlySummary: true,
        summaryType: summaryType,
      );
    } else {
      _startDownloadCheck(
        task,
        ytDlp,
        db,
        format: format,
        quality: quality,
        summarize: summarize,
        isAudio: isAudio,
      );
    }

    return task;
  }

  // Creates a summary-only task for a video URL without downloading.
  Future<DownloadTask> addSummaryTask(String url) async {
    return addTask(url, 'yt-dlp', onlySummary: true, summaryType: 'short');
  }

  // Manually triggers summary generation for an existing task.
  Future<void> generateSummary(DownloadTask task) async {
    final db = ref.read(dbServiceProvider);
    final ytDlp = YtDlpService();

    task.status = 'summarizing';
    if (task.summaryType == null || task.summaryType!.isEmpty) {
      task.summaryType = 'short';
    }
    await db.saveTask(task);

    _startSummaryGeneration(
      task,
      ytDlp,
      db,
      onlySummary: true,
      summaryType: task.summaryType!,
    );
  }

  Future<void> _startSummaryGeneration(
    DownloadTask task,
    YtDlpService ytDlp,
    DbService db, {
    bool onlySummary = false,
    bool skipMetadataRetrieval = false,
    String summaryType = 'short',
  }) async {
    try {
      String description = '';
      if (!task.completedSteps.contains('Initialization')) {
        task.completedSteps = ['Initialization'];
      }
      await db.saveTask(task);

      if (onlySummary) {
        task.status = 'summarizing';
        task.title = task.title ?? 'Analyzing...';
        await db.saveTask(task);
      }

      if (!skipMetadataRetrieval && (onlySummary || task.title == null)) {
        if (_metadataCache.containsKey(task.url)) {
          await _metadataCache[task.url];
          _metadataCache.remove(task.url);
        }

        dynamic metadata = _videoMetadataCache[task.url];
        if (metadata == null) {
          metadata = await ytDlp.getMetadata(task.url);
        } else {
          _videoMetadataCache.remove(task.url);
        }
        task.title = metadata['title'];
        task.thumbnail = metadata['thumbnail'];
        description = metadata['description'] ?? '';

        if (metadata.containsKey('channelId')) {
          task.channelId = metadata['channelId'];
        }
        if (metadata.containsKey('channel')) {
          task.channelName = metadata['channel'];
        }

        Map<String, String> details = {};
        if (task.stepDetailsJson != null) {
          try {
            details = Map<String, String>.from(
              jsonDecode(task.stepDetailsJson!),
            );
          } catch (_) {}
        }
        details['Metadata Retrieval'] = const JsonEncoder.withIndent(
          '  ',
        ).convert(metadata);
        task.stepDetailsJson = jsonEncode(details);

        if (!task.completedSteps.contains('Metadata Retrieval')) {
          task.completedSteps = [...task.completedSteps, 'Metadata Retrieval'];
        }
        await db.saveTask(task);
      } else {
        description = _extractDescriptionFromMetadata(task);
      }

      if (!task.completedSteps.contains('Subtitle Extraction')) {
        task.completedSteps = [...task.completedSteps, 'Subtitle Extraction'];
        await db.saveTask(task);
      }

      final settings = SettingsService();
      final lang = await settings.getLanguage();
      final langCode = lang == 'it' ? 'it' : 'en';
      String? subtitleText = '';

      if (!skipMetadataRetrieval) {
        subtitleText = await ytDlp.fetchVideoSubtitles(
          task.url,
          langCode: langCode,
        );
      } else {
        subtitleText = task.cachedTranscript;
      }

      if (subtitleText != null) {
        if (subtitleText.isNotEmpty) {
          String cached = subtitleText;
          final settings = SettingsService();
          final maxChars = await settings.getMaxCharactersForAI();
          if (cached.length > maxChars) {
            cached = "${cached.substring(0, maxChars)}\n[TRUNCATED]";
          }
          task.cachedTranscript = cached;
          task.cachedDescription = description;
          await db.saveTask(task);
        }

        if (!task.completedSteps.contains('Summary Generation')) {
          task.completedSteps = [...task.completedSteps, 'Summary Generation'];
          await db.saveTask(task);
        }

        final llmService = LlmService();
        final targetLangName = lang == 'it' ? 'Italian' : 'English';

        final settings = SettingsService();
        final maxChars = await settings.getMaxCharactersForAI();

        final summaryStream = await llmService.generateSummary(
          subtitleText: task.cachedTranscript ?? '',
          targetLanguageName: targetLangName,
          videoTitle: task.title ?? 'Unknown Video',
          videoDescription: description,
          maxCharacters: maxChars,
        );

        String fullSummary = '';
        await for (final chunk in summaryStream) {
          fullSummary += chunk;
        }

        if (fullSummary.trim().isEmpty) {
          throw Exception("AI generated an empty response. Please try again.");
        }

        task.summary = fullSummary;

        if (onlySummary || task.status == 'summarizing') {
          task.status = 'completed';
          task.progress = 100.0;
          task.errorMessage = null;

          if (!task.completedSteps.contains('Completed')) {
            task.completedSteps = [...task.completedSteps, 'Completed'];
          }
        }

        await db.saveTask(task);
      } else {
        if (task.status == 'summarizing') {
          task.status = 'completed';
          if (!task.completedSteps.contains('Completed')) {
            task.completedSteps = [...task.completedSteps, 'Completed'];
          }
        }
        await db.saveTask(task);
      }
    } catch (e) {
      if (onlySummary) {
        task.status = 'error';
        task.errorMessage = e.toString().replaceAll("Exception: ", "");
      } else {
        if (task.status == 'summarizing') {
          task.status = 'completed';
          if (!task.completedSteps.contains('Completed')) {
            task.completedSteps = [...task.completedSteps, 'Completed'];
          }
        }
      }
      await db.saveTask(task);
    }
  }

  // Extracts description from cached metadata JSON.
  String _extractDescriptionFromMetadata(DownloadTask task) {
    if (task.stepDetailsJson != null) {
      try {
        final details = jsonDecode(task.stepDetailsJson!);
        if (details is Map && details.containsKey('Metadata Retrieval')) {
          final metaJson = details['Metadata Retrieval'];
          if (metaJson is String) {
            final meta = jsonDecode(metaJson);
            if (meta is Map) {
              return meta['description'] ?? '';
            }
          }
        }
      } catch (_) {}
    }
    return '';
  }

  // Pauses a download task by stopping all associated processes and updating state.
  Future<void> pauseTask(int id) async {
    final process = _runningProcesses[id];
    if (process != null) {
      process.kill();
      _runningProcesses.remove(id);
    }

    if (_activeIdmDownloaders.containsKey(id)) {
      await _activeIdmDownloaders[id]?.pause();
      _activeIdmDownloaders.remove(id);
    }

    if (_activeChunkDownloaders.containsKey(id)) {
      _activeChunkDownloaders[id]?.pause();
      _activeChunkDownloaders.remove(id);
    }

    final strId = id.toString();
    if (_genericCancelTokens.containsKey(strId)) {
      _genericCancelTokens[strId]?.cancel();
      _genericCancelTokens.remove(strId);
    }

    final db = ref.read(dbServiceProvider);
    final task = await db.getTask(id);
    if (task != null) {
      task.status = 'paused';
      await db.saveTask(task);
    }
  }

  // Resumes a paused download task.
  Future<void> resumeTask(int id) async {
    final db = ref.read(dbServiceProvider);
    final task = await db.getTask(id);
    if (task != null) {
      final ytDlp = YtDlpService();
      if (task.status == 'summarizing') {
        _startSummaryGeneration(task, ytDlp, db, onlySummary: true);
      } else if (task.provider == 'yt-dlp') {
        _startYtDlpDownload(task, ytDlp, db, summarize: false);
      } else {
        _startSmartDownload(task, db);
      }
    }
  }

  // Retries a failed download by resetting progress and restarting.
  Future<void> retryDownload(int id) async {
    final db = ref.read(dbServiceProvider);
    final task = await db.getTask(id);
    if (task != null) {
      task.status = 'pending';
      task.progress = 0;
      task.errorMessage = null;
      task.completedSteps = [];
      task.playlistCompletedVideos = 0;
      task.startedAt = DateTime.now();
      await db.saveTask(task);

      final ytDlp = YtDlpService();

      if (task.isPlaylistContainer || UrlUtils.isYouTubePlaylist(task.url)) {
        _startPlaylistDownload(task, ytDlp, db);
      } else if (task.provider == 'yt-dlp' ||
          task.category == TaskCategory.video) {
        _startYtDlpDownload(task, ytDlp, db);
      } else {
        _startSmartDownload(task, db);
      }
    }
  }

  // Regenerates the summary for an existing task using cached data.
  Future<void> regenerateSummary(DownloadTask task) async {
    final db = ref.read(dbServiceProvider);
    final ytDlp = YtDlpService();
    task.status = 'summarizing';
    task.errorMessage = null;
    task.completedSteps = task.completedSteps
        .where(
          (s) =>
              s != 'Subtitle Extraction' &&
              s != 'Summary Generation' &&
              s != 'Completed',
        )
        .toList();

    await db.saveTask(task);
    _startSummaryGeneration(task, ytDlp, db,
        onlySummary: true,
        summaryType: task.summaryType ?? 'short',
        skipMetadataRetrieval: true);
  }

  // Deletes a task, stops all processes, removes metadata files.
  // If task is a playlist container, deletes all child video tasks.
  Future<void> deleteTask(int id) async {
    final process = _runningProcesses[id];
    if (process != null) {
      process.kill();
      _runningProcesses.remove(id);
    }

    if (_genericCancelTokens.containsKey(id.toString())) {
      _genericCancelTokens[id.toString()]?.cancel();
      _genericCancelTokens.remove(id.toString());
    }

    if (_activeIdmDownloaders.containsKey(id)) {
      await _activeIdmDownloaders[id]?.pause();
      _activeIdmDownloaders.remove(id);
    }

    final db = ref.read(dbServiceProvider);
    final task = await db.getTask(id);

    final currentExpandedId = ref.read(expandedTaskIdProvider);
    if (currentExpandedId == id) {
      final allTasks = await db.getAllTasks();
      if (allTasks.isNotEmpty) {
        ref.read(expandedTaskIdProvider.notifier).setTaskId(allTasks.first.id);
      } else {
        ref.read(expandedTaskIdProvider.notifier).setTaskId(null);
      }
    }

    if (task != null && (task.provider == 'Pro' || task.provider == 'http')) {
      final appSupportDir = await getApplicationSupportDirectory();
      final metaDir = appSupportDir.path;

      if (task.filePath != null && task.title != null) {
        final fileName = task.title!;
        final metaPath = "$metaDir${Platform.pathSeparator}$fileName.meta";
        final metaFile = File(metaPath);
        if (await metaFile.exists()) {
          await metaFile.delete();
        }

        final oldMetaPath = "${task.filePath}/${task.title}.meta";
        final oldMetaFile = File(oldMetaPath);
        if (await oldMetaFile.exists()) {
          await oldMetaFile.delete();
        }
      }
    }

    await db.deleteTask(id);

    if (task != null && task.isPlaylistContainer) {
      final allTasks = await db.getAllTasks();
      final childTasks =
          allTasks.where((t) => t.playlistParentId == task.id).toList();

      for (final childTask in childTasks) {
        final childProcess = _runningProcesses[childTask.id];
        if (childProcess != null) {
          childProcess.kill();
          _runningProcesses.remove(childTask.id);
        }

        await db.deleteTask(childTask.id);
      }
    }
  }

  // Cancels a download and deletes the downloaded file and metadata.
  Future<void> cancelTask(int id) async {
    final process = _runningProcesses[id];
    if (process != null) {
      process.kill();
      _runningProcesses.remove(id);
    }

    if (_activeIdmDownloaders.containsKey(id)) {
      await _activeIdmDownloaders[id]?.pause();
      _activeIdmDownloaders.remove(id);
    }

    final strId = id.toString();
    if (_genericCancelTokens.containsKey(strId)) {
      _genericCancelTokens[strId]?.cancel();
      _genericCancelTokens.remove(strId);
    }

    final db = ref.read(dbServiceProvider);
    final task = await db.getTask(id);

    if (task != null) {
      if (task.filePath != null && task.title != null) {
        final file = File(
          "${task.filePath}${Platform.pathSeparator}${task.title}",
        );
        if (await file.exists()) {
          await file.delete();
        }

        final appSupportDir = await getApplicationSupportDirectory();
        final metaPath =
            "${appSupportDir.path}${Platform.pathSeparator}${task.title}.meta";
        if (await File(metaPath).exists()) await File(metaPath).delete();

        final localMeta = File("${file.path}.meta");
        if (await localMeta.exists()) await localMeta.delete();
      }

      task.status = 'cancelled';
      task.progress = 0;
      task.downloadSpeed = null;
      task.eta = null;

      await db.saveTask(task);
    }
  }

  // Clears all download history.
  Future<void> clearHistory() async {
    final db = ref.read(dbServiceProvider);
    await db.clearAllTasks();
  }

  // Deletes all tasks in a specific category.
  Future<void> clearCategory(TaskCategory category) async {
    final db = ref.read(dbServiceProvider);
    final tasks = await db.getAllTasks();

    for (var task in tasks) {
      if (task.category == category) {
        final process = _runningProcesses[task.id];
        if (process != null) {
          process.kill();
          _runningProcesses.remove(task.id);
        }
        await db.deleteTask(task.id);
      }
    }
  }

  // Handles playlist downloads by creating individual tasks for each video.
  // Downloads videos concurrently with user-defined limits.
  Future<void> _startPlaylistDownload(
    DownloadTask task,
    YtDlpService ytDlp,
    DbService db, {
    String? format,
    String? quality,
    bool isAudio = false,
  }) async {
    try {
      task.status = 'downloading';
      task.startedAt = DateTime.now();
      task.isPlaylistContainer = true;
      if (!task.completedSteps.contains('Initialization')) {
        task.completedSteps = ['Initialization'];
      }
      await db.saveTask(task);

      if (_metadataCache.containsKey(task.url)) {
        await _metadataCache[task.url];
        _metadataCache.remove(task.url);
      }

      dynamic playlistMeta = _videoMetadataCache[task.url];
      if (playlistMeta == null) {
        playlistMeta = await ytDlp.getPlaylistMetadata(task.url);
      } else {
        _videoMetadataCache.remove(task.url);
      }
      task.title = playlistMeta['title'] ?? 'Playlist';
      task.channelName = playlistMeta['uploader'] ?? 'Unknown';
      task.thumbnail = playlistMeta['thumbnail'];
      task.playlistId = UrlUtils.extractPlaylistId(task.url);

      final videos = playlistMeta['videos'] as List<dynamic>;
      task.playlistTotalVideos = videos.length;
      task.playlistCompletedVideos = 0;

      if (!task.completedSteps.contains('Metadata Retrieval')) {
        task.completedSteps = [...task.completedSteps, 'Metadata Retrieval'];
      }

      Map<String, String> details = {};
      details['Playlist Info'] =
          'Playlist: ${task.title}\nVideo Count: ${videos.length}\nUploader: ${task.channelName}';
      task.stepDetailsJson = jsonEncode(details);
      await db.saveTask(task);

      final settings = SettingsService();
      final baseDownloadPath = await settings.getDownloadPath();

      String sanitizedPlaylistName = (task.title ?? 'Playlist')
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .trim();

      final playlistFolder = '$baseDownloadPath/$sanitizedPlaylistName';
      final directory = Directory(playlistFolder);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      task.dirPath = playlistFolder;
      await db.saveTask(task);

      final maxConcurrentDownloads = await settings.getMaxConcurrentDownloads();
      final List<DownloadTask> pendingTasks = [];

      for (int i = 0; i < videos.length; i++) {
        final video = videos[i];
        final videoUrl = video['url'] ?? video['webpage_url'] ?? '';

        if (videoUrl.isEmpty) continue;

        final videoTask = DownloadTask()
          ..url = videoUrl
          ..provider = 'yt-dlp'
          ..category = isAudio ? TaskCategory.music : TaskCategory.video
          ..title = video['title'] ?? 'Video ${i + 1}'
          ..thumbnail = video['thumbnail']
          ..channelName = task.channelName
          ..channelId = task.channelId
          ..playlistParentId = task.id
          ..status = 'pending'
          ..progress = 0
          ..createdAt = DateTime.now();

        await db.saveTask(videoTask);
        pendingTasks.add(videoTask);
      }

      int completedCount = 0;

      Future<void> startNextDownload() async {
        if (pendingTasks.isEmpty) return;

        final videoTask = pendingTasks.removeAt(0);

        try {
          await _startYtDlpDownload(
            videoTask,
            ytDlp,
            db,
            format: format,
            quality: quality,
            isAudio: isAudio,
            customDownloadPath: playlistFolder,
          );

          completedCount++;
          final parent = await db.getTask(task.id);
          if (parent != null) {
            parent.playlistCompletedVideos = completedCount;
            parent.progress =
                completedCount / (parent.playlistTotalVideos ?? 1);

            if (completedCount == parent.playlistTotalVideos) {
              parent.status = 'completed';
              parent.completedSteps = [
                ...parent.completedSteps,
                'Post-Processing'
              ];
            }
            await db.saveTask(parent);
          }
        } catch (e) {
          debugPrint('Playlist video download error: $e');
        } finally {
          if (pendingTasks.isNotEmpty) {
            startNextDownload();
          }
        }
      }

      for (int i = 0; i < maxConcurrentDownloads && i < videos.length; i++) {
        startNextDownload();
      }

      task.status = 'downloading';
      if (!task.completedSteps.contains('Download')) {
        task.completedSteps = [...task.completedSteps, 'Download'];
      }
      await db.saveTask(task);
    } catch (e) {
      task.status = 'error';
      task.errorMessage = e.toString();
      await db.saveTask(task);
    }
  }

  // Downloads video/audio using yt-dlp with optional parallel summarization.
  Future<void> _startYtDlpDownload(
    DownloadTask task,
    YtDlpService ytDlp,
    DbService db, {
    String? format,
    String? quality,
    bool summarize = false,
    bool isAudio = false,
    String? customDownloadPath,
  }) async {
    try {
      task.status = 'downloading';
      task.startedAt = DateTime.now();
      if (!task.completedSteps.contains('Initialization')) {
        task.completedSteps = ['Initialization'];
      }
      await db.saveTask(task);

      if (_metadataCache.containsKey(task.url)) {
        await _metadataCache[task.url];
        _metadataCache.remove(task.url);
      }

      dynamic metadata = _videoMetadataCache[task.url];
      if (metadata == null) {
        metadata = await ytDlp.getMetadata(task.url);
      } else {
        _videoMetadataCache.remove(task.url);
      }
      String rawTitle = metadata['title'] ?? 'video';
      String sanitizedTitle = rawTitle.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      task.title = rawTitle;
      task.thumbnail = metadata['thumbnail'];

      if (metadata.containsKey('channelId')) {
        task.channelId = metadata['channelId'];
      }
      if (metadata.containsKey('channel')) {
        task.channelName = metadata['channel'];
      }

      if (!task.completedSteps.contains('Metadata Retrieval')) {
        task.completedSteps = [...task.completedSteps, 'Metadata Retrieval'];
      }

      Map<String, String> details = {};
      if (task.stepDetailsJson != null) {
        try {
          details = Map<String, String>.from(jsonDecode(task.stepDetailsJson!));
        } catch (_) {}
      }
      details['Metadata Retrieval'] =
          const JsonEncoder.withIndent('  ').convert(metadata);
      task.stepDetailsJson = jsonEncode(details);
      await db.saveTask(task);

      if (summarize) {
        _startSummaryGeneration(task, ytDlp, db, onlySummary: false);
      }

      final settings = SettingsService();
      final downloadPath =
          customDownloadPath ?? await settings.getDownloadPath();

      DownloadFormat targetFormat;
      if (isAudio) {
        targetFormat = DownloadFormat.mp3;
      } else if (format != null) {
        switch (format.toLowerCase()) {
          case 'mp4':
            targetFormat = DownloadFormat.mp4;
            break;
          case 'mkv':
            targetFormat = DownloadFormat.mkv;
            break;
          case 'mp3':
            targetFormat = DownloadFormat.mp3;
            break;
          case 'm4a':
            targetFormat = DownloadFormat.m4a;
            break;
          default:
            targetFormat = await settings.getDefaultFormat();
        }
      } else {
        targetFormat = await settings.getDefaultFormat();
      }

      DownloadQuality targetQuality;
      if (quality != null) {
        switch (quality.toLowerCase()) {
          case '1080p':
            targetQuality = DownloadQuality.p1080;
            break;
          case '720p':
            targetQuality = DownloadQuality.p720;
            break;
          case '480p':
            targetQuality = DownloadQuality.p480;
            break;
          case 'best':
            targetQuality = DownloadQuality.best;
            break;
          case 'medium':
            targetQuality = DownloadQuality.medium;
            break;
          case 'low':
            targetQuality = DownloadQuality.low;
            break;
          default:
            targetQuality = await settings.getDefaultQuality();
        }
      } else {
        targetQuality = await settings.getDefaultQuality();
      }

      String extension = '.mp4';
      switch (targetFormat) {
        case DownloadFormat.mp4:
          extension = '.mp4';
          break;
        case DownloadFormat.mkv:
          extension = '.mkv';
          break;
        case DownloadFormat.mp3:
          extension = '.mp3';
          break;
        case DownloadFormat.m4a:
          extension = '.m4a';
          break;
      }

      final targetDir =
          downloadPath ?? (await getDownloadsDirectory())?.path ?? '.';
      task.dirPath = targetDir;
      task.filePath =
          "$targetDir${Platform.pathSeparator}$sanitizedTitle$extension";
      await db.saveTask(task);

      final tempDir = await getTemporaryDirectory();
      final appTempDir = Directory('${tempDir.path}/kzdownloader_temp');
      if (!await appTempDir.exists()) {
        await appTempDir.create(recursive: true);
      }

      final process = await ytDlp.startDownload(
        task.url,
        targetDir,
        format: targetFormat,
        quality: targetQuality,
        tempPath: appTempDir.path,
        customFilename: sanitizedTitle,
      );

      _runningProcesses[task.id] = process;

      // Throttle DB writes from yt-dlp progress (fires very frequently)
      DateTime lastYtDlpDbSave = DateTime.now();
      process.stdout.transform(const SystemEncoding().decoder).listen((line) {
        if (line.contains('[Merger]') || line.contains('[Fixup]')) {
          if (!task.completedSteps.contains('Processing')) {
            task.completedSteps = [...task.completedSteps, 'Processing'];
            db.saveTask(task);
          }
        }

        final info = ytDlp.parseProgress(line);
        if (info != null) {
          if (!task.completedSteps.contains('Downloading')) {
            task.completedSteps = [...task.completedSteps, 'Downloading'];
          }

          task.progress = info['progress'] ?? task.progress;
          if (info.containsKey('speed')) task.downloadSpeed = info['speed'];
          if (info.containsKey('eta')) task.eta = info['eta'];
          if (info.containsKey('totalSize')) task.totalSize = info['totalSize'];

          // Persist at most once per second to reduce DB pressure
          final now = DateTime.now();
          if (now.difference(lastYtDlpDbSave).inMilliseconds >= 1000) {
            lastYtDlpDbSave = now;
            db.saveTask(task);
          }
        }
      });

      final exitCode = await process.exitCode;

      if (!_runningProcesses.containsKey(task.id)) {
        return;
      }
      _runningProcesses.remove(task.id);

      if (exitCode == 0) {
        final updatedSteps = Set<String>.from(task.completedSteps);
        updatedSteps.add('Downloading');
        updatedSteps.add('Processing');
        task.completedSteps = updatedSteps.toList();

        if (summarize) {
          if (task.summary != null && task.summary!.isNotEmpty) {
            task.status = 'completed';
            task.progress = 100.0;
            task.completedAt = DateTime.now();
            task.processTime =
                calculateProcessTime(task.startedAt ?? task.createdAt);

            if (!task.completedSteps.contains('Completed')) {
              task.completedSteps = [...task.completedSteps, 'Completed'];
            }
          } else {
            task.status = 'summarizing';
          }
        } else {
          task.status = 'completed';
          task.progress = 100.0;
          task.completedAt = DateTime.now();
          task.processTime =
              calculateProcessTime(task.startedAt ?? task.createdAt);

          if (!task.completedSteps.contains('Completed')) {
            task.completedSteps = [...task.completedSteps, 'Completed'];
          }
        }
        await db.saveTask(task);
      } else {
        task.status = 'error';
        task.errorMessage = 'Process exited with code $exitCode';
        await db.saveTask(task);
      }
    } catch (e) {
      if (!_runningProcesses.containsKey(task.id)) {
        return;
      }
      _runningProcesses.remove(task.id);

      task.status = 'error';
      task.errorMessage = e.toString();
      await db.saveTask(task);
    }
  }
}

// Extracts filename from Content-Disposition header.
String? _parseFileNameFromHeader(String? contentDisposition) {
  if (contentDisposition == null) return null;
  try {
    final RegExp nameRegex = RegExp(r'filename="?([^"]+)"?');
    final match = nameRegex.firstMatch(contentDisposition);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    if (contentDisposition.contains('filename=')) {
      return contentDisposition.split('filename=').last.trim();
    }
  } catch (_) {}
  return null;
}

class UrlMetadata {
  final int size;
  final bool acceptRanges;
  final String? remoteFileName;

  UrlMetadata({
    required this.size,
    required this.acceptRanges,
    this.remoteFileName,
  });
}
