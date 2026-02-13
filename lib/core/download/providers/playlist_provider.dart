import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kzdownloader/core/services/db_service.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/models/playlist.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';

final playlistListProvider =
    NotifierProvider<PlaylistNotifier, List<Playlist>>(PlaylistNotifier.new);

class PlaylistNotifier extends Notifier<List<Playlist>> {
  late DbService _db;

  @override
  List<Playlist> build() {
    _db = ref.watch(dbServiceProvider);
    _loadPlaylists();
    return [];
  }

  Future<void> _loadPlaylists() async {
    final playlists = await _db.getAllPlaylists();
    state = playlists;

    // Listen to changes
    final subscription = _db.watchPlaylists().listen((playlists) {
      state = playlists;
    });

    ref.onDispose(() {
      subscription.cancel();
    });
  }

  Future<void> createPlaylist(String name) async {
    final colors = Playlist.generateRandomGradientColors();
    final playlist = Playlist()
      ..name = name
      ..gradientColor1 = colors[0]
      ..gradientColor2 = colors[1];
    await _db.savePlaylist(playlist);
  }

  Future<void> deletePlaylist(int id) async {
    await _db.deletePlaylist(id);
  }

  Future<void> renamePlaylist(int id, String newName) async {
    await _db.updatePlaylistName(id, newName);
  }

  Future<void> updatePlaylistImage(int id, String? imagePath) async {
    await _db.updatePlaylistImage(id, imagePath);
  }

  Future<void> addTasksToPlaylist(
      int playlistId, List<DownloadTask> tasks) async {
    await _db.addTasksToPlaylist(playlistId, tasks);
  }

  Future<void> removeTaskFromPlaylist(int playlistId, DownloadTask task) async {
    await _db.removeTaskFromPlaylist(playlistId, task);
  }
}
