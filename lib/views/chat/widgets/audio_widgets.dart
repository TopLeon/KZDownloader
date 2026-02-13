import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kzdownloader/core/services/audio_player_service.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/core/download/providers/playlist_provider.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/models/playlist.dart';
import 'package:kzdownloader/views/widgets/confirm_dialog.dart';
import 'package:kzdownloader/views/chat/widgets/playlist_selection_dialog.dart';
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]),
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
                            const SizedBox(height: 4),
                            Text(
                              l10n.createdOn(
                                  "${widget.playlist.createdAt.day}/${widget.playlist.createdAt.month}/${widget.playlist.createdAt.year}"),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
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
                                        fontSize: 9,
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

class MusicCard extends ConsumerStatefulWidget {
  final DownloadTask task;
  final VoidCallback onTap;

  const MusicCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  ConsumerState<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends ConsumerState<MusicCard> {
  bool _isHovered = false;

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    showConfirmDialog(
      context,
      title: l10n.deleteTrackTitle,
      content: l10n.deleteTrackContent(widget.task.title ?? ''),
      onConfirm: () =>
          ref.read(downloadListProvider.notifier).deleteTask(widget.task.id),
    );
  }

  void _addToPlaylist() {
    showDialog(
      context: context,
      builder: (context) => PlaylistSelectionDialog(task: widget.task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const accentStart = Colors.white;
    final isPlaying = ref.watch(audioStateProvider.select(
      (state) => state.currentTaskId == widget.task.id && state.isPlaying,
    ));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Art Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    if (widget.task.thumbnail != null &&
                        widget.task.thumbnail!.isNotEmpty)
                      Image.network(
                        widget.task.thumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[850],
                            child: const Icon(Icons.music_note,
                                color: Colors.white54)),
                      )
                    else
                      Container(
                        color: Colors.grey[850],
                        child: const Icon(Icons.music_note,
                            size: 48, color: accentStart),
                      ),

                    // Hover/Action Overlay
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: IconButton(
                                icon: Icon(
                                    isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow_rounded,
                                    size: 48,
                                    color: Colors.white),
                                onPressed: widget.onTap,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.playlist_add,
                                        color: Colors.white),
                                    onPressed: _addToPlaylist,
                                    tooltip: l10n.addToPlaylistTooltip,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black45,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.white),
                                    onPressed: _confirmDelete,
                                    tooltip: l10n.delete,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    // Format Badge (hidden on hover)
                    if (!_isHovered)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Text(
                            "MP3",
                            style: TextStyle(
                              color: accentStart,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),

                    // Download Progress Overlay
                    if (widget.task.status == 'downloading' ||
                        widget.task.status == 'pending' ||
                        widget.task.status == 'converting')
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: widget.task.progress > 0
                                ? widget.task.progress
                                : null,
                            color: accentStart,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.task.title ?? l10n.unknownTrack,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "${widget.task.url.split('/')[2]} - ${widget.task.channelName ?? l10n.unknownArtist}",
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
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
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    ),
  );
}
