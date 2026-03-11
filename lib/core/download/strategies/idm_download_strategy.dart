import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:kzdownloader/core/download/logic/idm_downloader.dart';
import 'package:kzdownloader/core/download/logic/file_path_resolver.dart';
import 'package:kzdownloader/core/download/logic/speed_tracker.dart';
import 'package:kzdownloader/core/download/strategies/download_strategy.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/core/utils/download_helper.dart';
import 'package:kzdownloader/core/utils/utils.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:path_provider/path_provider.dart';

// Multi-threaded IDM-like download strategy with resume support.
class IDMDownloadStrategy extends DownloadStrategy {
  final int? knownSize;
  final bool? knownAcceptRanges;

  /// Per-download overrides (null = use global settings)
  final int? maxWorkers;
  final String? targetDirOverride;
  final int? speedLimitBpsOverride;

  IDMDownloader? _downloader;
  StreamSubscription? _statusSub;
  late DateTime _startedAt;

  IDMDownloadStrategy(
    super.taskId,
    super.db,
    super.ref, {
    this.knownSize,
    this.knownAcceptRanges,
    this.maxWorkers,
    this.targetDirOverride,
    this.speedLimitBpsOverride,
  });

  @override
  Future<void> start(
      {String? format, String? quality, bool isAudio = false}) async {
    _startedAt = DateTime.now();

    try {
      final task = await db.getTask(taskId);
      if (task == null) throw Exception('Task $taskId not found');

      // Resolve file path: use targetDirOverride if set, else default
      String filePath;
      if (targetDirOverride != null) {
        // Build path in override directory without touching global settings
        final t = await db.getTask(taskId);
        final filename = (t?.title != null && t!.title!.isNotEmpty)
            ? FileUtils.sanitizeFilename(t.title!)
            : 'download_${DateTime.now().millisecondsSinceEpoch}.bin';
        filePath = '$targetDirOverride${Platform.pathSeparator}$filename';
        await db.updateFilePath(taskId, filePath, targetDirOverride!);
      } else {
        filePath = await FilePathResolver.resolve(taskId, db);
      }

      final tempDir = await getTemporaryDirectory();
      final metaDir = '${tempDir.path}${Platform.pathSeparator}kz_meta';
      await Directory(metaDir).create(recursive: true);

      // Read advanced settings
      final settings = SettingsService();
      final customUserAgent = await settings.getCustomUserAgent();
      final proxyEnabled = await settings.getProxyEnabled();
      // Speed limit: per-download override takes precedence over global setting
      final globalSpeedLimit = await settings.getGlobalSpeedLimitBps();
      final speedLimit = speedLimitBpsOverride ?? globalSpeedLimit;

      ProxyConfig? proxyConfig;
      if (proxyEnabled) {
        final host = await settings.getProxyHost();
        final port = await settings.getProxyPort();
        if (host.isNotEmpty && port > 0) {
          proxyConfig = ProxyConfig(
            host: host,
            port: port,
            type: await settings.getProxyType(),
            username: (await settings.getProxyUsername()).isNotEmpty
                ? await settings.getProxyUsername()
                : null,
            password: (await settings.getProxyPassword()).isNotEmpty
                ? await settings.getProxyPassword()
                : null,
          );
        }
      }

      _downloader = IDMDownloader(
        maxWorkers: maxWorkers ?? 6,
        metaDir: metaDir,
        globalSpeedLimit: speedLimit,
        proxyConfig: proxyConfig,
      );

      // Build headers with optional custom user agent
      final headers = <String, String>{};
      if (customUserAgent != null && customUserAgent.isNotEmpty) {
        headers['User-Agent'] = customUserAgent;
      }

      _statusSub = _downloader!.statusStream.listen((data) {
        _handleStatus(data, task);
      });

      await _downloader!.download(
        task.url,
        filePath,
        headers: headers,
        knownFileSize: knownSize,
        knownAcceptRanges: knownAcceptRanges,
      );

      await _statusSub?.cancel();
      await finalizeSuccess(_startedAt);
    } catch (e) {
      await _statusSub?.cancel();
      // IDMDownloader.pause() completes with Exception('Download Paused');
      // pause() already sets status to paused, so don't call handleError.
      final isPause = e.toString().toLowerCase().contains('paused');
      if (!isPause) {
        await handleError(e);
        rethrow;
      }
    }
  }

  void _handleStatus(Map<String, dynamic> data, DownloadTask task) {
    final status = data['status'] as String?;
    if (status != 'running') return;

    final progress = (data['progress'] as num?)?.toDouble() ?? 0.0;
    final speed = (data['speed'] as num?)?.toDouble() ?? 0.0;
    final eta = data['eta'] as String?;
    final totalSize = (data['totalSize'] as num?)?.toInt() ?? 0;
    final downloaded = (data['downloaded'] as num?)?.toInt() ?? 0;
    final activeWorkers = data['activeWorkers'] as int? ?? 0;
    final totalWorkers = data['totalWorkers'] as int? ?? 0;
    final workers = data['workers'] as List?;
    final speedHistory = data['speedHistory'] as List<double>?;
    final proxyActive = data['proxyActive'] as bool? ?? false;

    final progressData = <String, dynamic>{
      'progress': progress,
      'downloadSpeed': SpeedTracker.formatSpeed(speed),
      'eta': eta,
      'downloaded': DownloadHelper.formatBytes(downloaded),
      'totalSize': totalSize > 0 ? DownloadHelper.formatBytes(totalSize) : null,
      'activeWorkers': activeWorkers,
      'totalWorkers': totalWorkers,
      'proxyActive': proxyActive,
    };

    if (workers != null) {
      progressData['workersProgressJson'] = jsonEncode(workers);
    }
    if (speedHistory != null && speedHistory.isNotEmpty) {
      progressData['speedHistory'] = speedHistory;
    }

    updateProgress(progressData);
  }

  @override
  Future<void> pause() async {
    await _statusSub?.cancel();
    await _downloader?.pause();

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
    await _statusSub?.cancel();
    await _downloader?.pause();

    // Clean up meta files
    try {
      final task = await db.getTask(taskId);
      if (task?.filePath != null) {
        final metaFile = File('${task!.filePath!}.meta');
        if (await metaFile.exists()) await metaFile.delete();
      }
    } catch (e) {
      debugPrint('Meta cleanup failed: $e');
    }

    removeProgress();
  }
}
