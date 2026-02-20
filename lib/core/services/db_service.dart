import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/models/playlist.dart';

// Service for managing local database operations (Isar).
class DbService {
  late Isar isar;

  // Initializes the database, recreating it if the schema is incompatible.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      isar = await Isar.open(
        [DownloadTaskSchema, PlaylistSchema],
        directory: dir.path,
      );
    } catch (e) {
      debugPrint('Database schema error, recreating: $e');
      await Isar.open(
        [DownloadTaskSchema, PlaylistSchema],
        directory: dir.path,
        name: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      ).then((tempIsar) => tempIsar.close());

      final dbPath = '${dir.path}/default.isar';
      final lockPath = '${dir.path}/default.isar.lock';
      try {
        final dbFile = File(dbPath);
        final lockFile = File(lockPath);
        if (await dbFile.exists()) await dbFile.delete();
        if (await lockFile.exists()) await lockFile.delete();
      } catch (_) {}

      isar = await Isar.open(
        [DownloadTaskSchema, PlaylistSchema],
        directory: dir.path,
      );
    }
  }

  // Retrieves all cached tasks.
  Future<List<DownloadTask>> getAllTasks() async {
    return await isar.downloadTasks.where().findAll();
  }

  // Retrieves a task by its ID.
  Future<DownloadTask?> getTask(int id) async {
    return await isar.downloadTasks.get(id);
  }

  // Finds a task matching the given URL.
  Future<DownloadTask?> findTaskByUrl(String url) async {
    return await isar.downloadTasks.filter().urlEqualTo(url).findFirst();
  }

  // Saves or updates a task in the database.
  Future<void> saveTask(DownloadTask task) async {
    await isar.writeTxn(() async {
      await isar.downloadTasks.put(task);
    });
  }

  // Deletes a task by ID.
  Future<void> deleteTask(int id) async {
    await isar.writeTxn(() async {
      await isar.downloadTasks.delete(id);
    });
  }

  // Clears all tasks from the database.
  Future<void> clearAllTasks() async {
    await isar.writeTxn(() async {
      await isar.downloadTasks.clear();
    });
  }

  // Retrieves all playlists.
  Future<List<Playlist>> getAllPlaylists() async {
    return await isar.playlists.where().findAll();
  }

  // Retrieves a playlist by its ID.
  Future<Playlist?> getPlaylist(int id) async {
    return await isar.playlists.get(id);
  }

  // Saves or updates a playlist in the database.
  Future<void> savePlaylist(Playlist playlist) async {
    await isar.writeTxn(() async {
      await isar.playlists.put(playlist);
      await playlist.tasks.save();
    });
  }

  // Deletes a playlist by ID.
  Future<void> deletePlaylist(int id) async {
    await isar.writeTxn(() async {
      await isar.playlists.delete(id);
    });
  }

  // Updates the name of a playlist.
  Future<void> updatePlaylistName(int id, String newName) async {
    await isar.writeTxn(() async {
      final playlist = await isar.playlists.get(id);
      if (playlist != null) {
        playlist.name = newName;
        await isar.playlists.put(playlist);
      }
    });
  }

  // Updates the cover image of a playlist.
  Future<void> updatePlaylistImage(int id, String? imagePath) async {
    await isar.writeTxn(() async {
      final playlist = await isar.playlists.get(id);
      if (playlist != null) {
        playlist.coverImage = imagePath;
        await isar.playlists.put(playlist);
      }
    });
  }

  // Adds tasks to a playlist.
  Future<void> addTasksToPlaylist(
      int playlistId, List<DownloadTask> tasks) async {
    await isar.writeTxn(() async {
      final playlist = await isar.playlists.get(playlistId);
      if (playlist != null) {
        playlist.tasks.addAll(tasks);
        await playlist.tasks.save();
        await isar.playlists.put(playlist);
      }
    });
  }

  // Removes a task from a playlist.
  Future<void> removeTaskFromPlaylist(int playlistId, DownloadTask task) async {
    await isar.writeTxn(() async {
      final playlist = await isar.playlists.get(playlistId);
      if (playlist != null) {
        playlist.tasks.remove(task);
        await playlist.tasks.save();
        await isar.playlists.put(playlist);
      }
    });
  }

  // Watches for changes in the playlists collection.
  Stream<List<Playlist>> watchPlaylists() {
    return isar.playlists.where().watch(fireImmediately: true);
  }

  // Watches for changes in the tasks collection.
  Stream<List<DownloadTask>> watchTasks() {
    return isar.downloadTasks.where().watch(fireImmediately: true);
  }

  // ============================================================================
  // ATOMIC UPDATE METHODS - Fix for Race Conditions
  // ============================================================================

  // Generic atomic update: reads, modifies, and saves in a single transaction.
  // This prevents "Lost Update" race conditions where concurrent reads/writes
  // can overwrite each other's changes.
  Future<void> updateTask(int id, void Function(DownloadTask) updates) async {
    await isar.writeTxn(() async {
      final task = await isar.downloadTasks.get(id);
      if (task != null) {
        updates(task);
        await isar.downloadTasks.put(task);
      }
    });
  }

  // Atomically updates download progress fields.
  Future<void> updateDownloadProgress({
    required int id,
    required double progress,
    String? downloadSpeed,
    String? eta,
    int? totalSize,
  }) async {
    await updateTask(id, (task) {
      task.progress = progress;
      task.downloadSpeed = downloadSpeed;
      task.eta = eta;
      if (totalSize != null) task.totalSize = totalSize.toString();
    });
  }

  // Atomically sets download state using the WorkStatus state machine.
  // Converts legacy boolean parameters to the appropriate WorkStatus value.
  Future<void> setDownloadState(int id, {
    bool isDownloading = false,
    bool isPaused = false,
    bool isCancelled = false,
  }) async {
    await updateTask(id, (task) {
      if (isCancelled) {
        task.downloadStatus = WorkStatus.cancelled;
      } else if (isPaused) {
        task.downloadStatus = WorkStatus.paused;
      } else if (isDownloading) {
        task.downloadStatus = WorkStatus.running;
      }
    });
  }

  // Atomically adds a completed step (prevents duplicates).
  Future<void> addCompletedStep(int id, String step) async {
    await updateTask(id, (task) {
      if (!task.completedSteps.contains(step)) {
        task.completedSteps = [...task.completedSteps, step];
      }
    });
  }

  // Atomically adds multiple completed steps.
  Future<void> addCompletedSteps(int id, List<String> steps) async {
    await updateTask(id, (task) {
      final currentSteps = Set<String>.from(task.completedSteps);
      currentSteps.addAll(steps);
      task.completedSteps = currentSteps.toList();
    });
  }

  // Atomically updates summary-related fields.
  Future<void> updateSummary({
    required int id,
    String? summary,
    WorkStatus? summaryStatus,
    String? cachedTranscript,
    String? cachedDescription,
  }) async {
    await updateTask(id, (task) {
      if (summary != null) task.summary = summary;
      if (summaryStatus != null) task.summaryStatus = summaryStatus;
      if (cachedTranscript != null) task.cachedTranscript = cachedTranscript;
      if (cachedDescription != null) task.cachedDescription = cachedDescription;
    });
  }

  // Atomically sets summary state flags
  Future<void> setSummaryState(int id, {
    WorkStatus? summaryStatus,
    String? summary,
  }) async {
    await updateTask(id, (task) {
      if (summaryStatus != null) task.summaryStatus = summaryStatus;
      if (summary != null) task.summary = summary;
    });
  }

  // Atomically sets error state for download
  Future<void> setError(int id, String errorMessage) async {
    await updateTask(id, (task) {
      task.downloadStatus = WorkStatus.failed;
      task.errorMessage = errorMessage;
    });
  }

  // Atomically updates error message.
  Future<void> updateErrorMessage(int id, String? errorMessage) async {
    await updateTask(id, (task) {
      task.errorMessage = errorMessage;
    });
  }

  // Atomically updates file path and directory.
  Future<void> updateFilePath(int id, String? filePath, String? dirPath) async {
    await updateTask(id, (task) {
      if (filePath != null) task.filePath = filePath;
      if (dirPath != null) task.dirPath = dirPath;
    });
  }

  // Atomically updates worker progress (for chunked downloads).
  Future<void> updateWorkerProgress({
    required int id,
    int? activeWorkers,
    int? totalWorkers,
    String? workersProgressJson,
  }) async {
    await updateTask(id, (task) {
      if (activeWorkers != null) task.activeWorkers = activeWorkers;
      if (totalWorkers != null) task.totalWorkers = totalWorkers;
      if (workersProgressJson != null) task.workersProgressJson = workersProgressJson;
    });
  }
}
