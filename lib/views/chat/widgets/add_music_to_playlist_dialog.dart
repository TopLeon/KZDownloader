import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';

class AddMusicToPlaylistDialog extends ConsumerStatefulWidget {
  final List<DownloadTask> currentTasks;
  final Function(List<DownloadTask>) onAdd;

  const AddMusicToPlaylistDialog({
    super.key,
    required this.currentTasks,
    required this.onAdd,
  });

  @override
  ConsumerState<AddMusicToPlaylistDialog> createState() =>
      _AddMusicToPlaylistDialogState();
}

class _AddMusicToPlaylistDialogState
    extends ConsumerState<AddMusicToPlaylistDialog> {
  final Set<int> _selectedTaskIds = {};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allTasksAsync = ref.watch(downloadListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.addSongsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: l10n.subSearchSong,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: allTasksAsync.when(
                data: (tasks) {
                  // Filter for music only and not already in playlist (optional, user might want dupes?)
                  // Usually playlists don't really block dupes, but let's filter out ones already in playlist if we want to be strict?
                  // User request: "add music directly". Typically add from library.
                  final musicTasks = tasks.where((t) {
                    final isMusic = t.category == TaskCategory.music;
                    final queryMatch = t.title
                            ?.toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ??
                        false;
                    // Filter out tasks already in playlist?
                    final alreadyIn = widget.currentTasks
                        .any((existing) => existing.id == t.id);
                    return isMusic && queryMatch && !alreadyIn;
                  }).toList();

                  if (musicTasks.isEmpty) {
                    return Center(child: Text(l10n.noSongsFound));
                  }

                  return ListView.builder(
                    itemCount: musicTasks.length,
                    itemBuilder: (context, index) {
                      final task = musicTasks[index];
                      final isSelected = _selectedTaskIds.contains(task.id);

                      return ListTile(
                        leading: task.thumbnail != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(task.thumbnail!,
                                    width: 40, height: 40, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.music_note),
                        title: Text(task.title ?? l10n.unknown),
                        subtitle: Text(task.channelName ?? ""),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedTaskIds.add(task.id);
                              } else {
                                _selectedTaskIds.remove(task.id);
                              }
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTaskIds.remove(task.id);
                            } else {
                              _selectedTaskIds.add(task.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("${l10n.error}: $e")),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.btnCancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _selectedTaskIds.isEmpty
                      ? null
                      : () {
                          ref.read(downloadListProvider.future).then((tasks) {
                            final selected = tasks
                                .where((t) => _selectedTaskIds.contains(t.id))
                                .toList();
                            widget.onAdd(selected);
                            Navigator.pop(context);
                          });
                        },
                  child: Text(l10n.btnAddCount(_selectedTaskIds.length)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
