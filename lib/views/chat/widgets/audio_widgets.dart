import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/core/download/providers/playlist_provider.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/models/playlist.dart';
import 'package:kzdownloader/views/widgets/confirm_dialog.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';

class PlaylistCard extends ConsumerStatefulWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final List<Color> gradientColors;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
    this.gradientColors = const [Color(0xFF2563EB), Color(0xFF4F46E5)],
  });

  @override
  ConsumerState<PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends ConsumerState<PlaylistCard> {
  bool _isHovered = false;

  void _showEditNameDialog() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: widget.playlist.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renamePlaylist),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.playlistNamePlaceholder),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(playlistListProvider.notifier)
                    .renamePlaylist(widget.playlist.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    showConfirmDialog(
      context,
      title: l10n.deletePlaylistTitle,
      content: l10n.deletePlaylistContent(widget.playlist.name),
      confirmText: l10n.delete,
      onConfirm: () => ref
          .read(playlistListProvider.notifier)
          .deletePlaylist(widget.playlist.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      //Cover
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.gradientColors,
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.queue_music,
                              color: Colors.white.withOpacity(0.8), size: 32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.playlist.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.createdOn(
                                  "${widget.playlist.createdAt.day}/${widget.playlist.createdAt.month}/${widget.playlist.createdAt.year}"),
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.1)
                                        : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withOpacity(0.1)),
                                  ),
                                  child: Text(
                                    l10n.tracksCount(widget
                                        .playlist.tasks.length
                                        .toString()),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isHovered)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const FIcon(RI.RiEditLine, size: 16),
                          onPressed: _showEditNameDialog,
                          tooltip: l10n.rename,
                          style: IconButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.tertiary,
                              shape: CircleBorder(
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.15)))),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: FIcon(RI.RiDeleteBinLine,
                              size: 16,
                              color: Theme.of(context).colorScheme.error),
                          onPressed: _confirmDelete,
                          tooltip: l10n.delete,
                          style: IconButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.tertiary,
                              shape: CircleBorder(
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.15)))),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showAddMusicUrlDialog(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context)!;
  final TextEditingController urlController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.addMusicUrl),
      content: TextField(
        controller: urlController,
        decoration: InputDecoration(
          hintText: l10n.pasteMusicLink,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (urlController.text.isNotEmpty) {
              // Trigger logic manually since _controller is bound to another UI
              ref.read(downloadListProvider.notifier).addTask(
                    urlController.text,
                    'Auto', // Detect
                    quality: 'best',
                    isAudio: true, // Force Audio for Music section
                    category: TaskCategory.music,
                  );
              ref
                  .read(selectedCategoryProvider.notifier)
                  .setCategory(TaskCategory.music);
              Navigator.pop(context);
            }
          },
          child: Text(l10n.downloadAction),
        ),
      ],
    ),
  );
}

List<DownloadTask> filterMusicTasks(
    List<DownloadTask> allTasks, String searchQuery) {
  return allTasks.where((t) {
    // Filter by Category Music OR by isAudio flag if generic?
    // Strict category filtering as requested
    if (t.category != TaskCategory.music) return false;

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      final title = t.title?.toLowerCase() ?? '';
      final artist = t.channelName?.toLowerCase() ?? '';
      return title.contains(query) || artist.contains(query);
    }
    return true;
  }).toList();
}

Widget buildNewMixCard(BuildContext context, Color primaryColor,
    {VoidCallback? onTap}) {
  final l10n = AppLocalizations.of(context)!;
  return Container(
    width: 140,
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          style: BorderStyle.solid),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(Icons.add, color: primaryColor),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.newPlaylist,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    ),
  );
}
