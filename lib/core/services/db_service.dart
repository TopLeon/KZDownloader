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
}
