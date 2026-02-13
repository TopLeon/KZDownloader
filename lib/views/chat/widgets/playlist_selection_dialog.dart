import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kzdownloader/core/download/providers/playlist_provider.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';

class PlaylistSelectionDialog extends ConsumerWidget {
  final DownloadTask task;

  const PlaylistSelectionDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch playlists state
    final playlists = ref.watch(playlistListProvider);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.addToPlaylist),
      content: SizedBox(
        width: double.maxFinite,
        child: playlists.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text(l10n.noPlaylistsCreated)),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  // Check if already in playlist (optional optimization)
                  final isInPlaylist =
                      playlist.tasks.any((t) => t.id == task.id);

                  return ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text(playlist.name),
                    subtitle: Text(
                        l10n.tracksCount(playlist.tasks.length.toString())),
                    trailing: isInPlaylist
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    enabled: !isInPlaylist,
                    onTap: () {
                      if (!isInPlaylist) {
                        ref
                            .read(playlistListProvider.notifier)
                            .addTasksToPlaylist(playlist.id, [task]);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text(l10n.addedToPlaylist(playlist.name))),
                        );
                      }
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
