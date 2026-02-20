import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/views/chat/widgets/media_detail_pane.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:open_file/open_file.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';

part 'playlist_detail_pane.g.dart';

// Provider for the currently selected video within a playlist.
@riverpod
class SelectedPlaylistVideo extends _$SelectedPlaylistVideo {
  @override
  DownloadTask? build() => null;

  void select(DownloadTask? video) => state = video;
  void clear() => state = null;
}

// Detail pane for displaying YouTube playlist details.
class YouTubePlaylistDetailPane extends ConsumerWidget {
  final DownloadTask playlist;

  const YouTubePlaylistDetailPane({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVideo = ref.watch(selectedPlaylistVideoProvider);
    final l10n = AppLocalizations.of(context)!;

    // If a video is selected, show its MediaDetailPane
    if (selectedVideo != null) {
      return SizedBox(
          width: MediaQuery.of(context).size.width * 0.35 < 600
              ? MediaQuery.of(context).size.width * 0.35
              : 600,
          child: Column(
            children: [
              // Header with back button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withOpacity(0.5),
                    ),
                    left: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withOpacity(0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        ref
                            .read(selectedPlaylistVideoProvider.notifier)
                            .clear();
                      },
                      tooltip: l10n.backToPlaylist,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.playlistVideo,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // MediaDetailPane for the selected video
              Expanded(
                child: MediaDetailPane(task: selectedVideo),
              ),
            ],
          ));
    }

    // Main playlist view
    return _PlaylistOverview(playlist: playlist);
  }
}

// Playlist overview with video list.
class _PlaylistOverview extends ConsumerWidget {
  final DownloadTask playlist;

  const _PlaylistOverview({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final allTasksAsync = ref.watch(downloadListProvider);

    // Recupera la playlist aggiornata dal provider invece di usare il parametro statico
    final updatedPlaylist = allTasksAsync.when(
      data: (tasks) => tasks.firstWhere(
        (task) => task.id == playlist.id,
        orElse: () => playlist,
      ),
      loading: () => playlist,
      error: (_, __) => playlist,
    );

    final childVideos = allTasksAsync.when(
      data: (tasks) =>
          tasks.where((task) => task.playlistParentId == playlist.id).toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      loading: () => <DownloadTask>[],
      error: (_, __) => <DownloadTask>[],
    );

    return Container(
      width: MediaQuery.of(context).size.width * 0.35 < 600
          ? MediaQuery.of(context).size.width * 0.35
          : 600,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child:
            // Playlist info header
            Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large thumbnail
            if (updatedPlaylist.thumbnail != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.brightnessOf(context) == Brightness.dark
                        ? Colors.white.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: updatedPlaylist.thumbnail!,
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: FIcon(
                                RI.RiPlayListLine,
                                size: 64,
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        const Center(
                          child: FIcon(
                            RI.RiPlayListFill,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Title
            Text(
              updatedPlaylist.title ?? l10n.playlist,
              style: GoogleFonts.montserrat(
                  fontSize: 20, fontWeight: FontWeight.w600, height: 1.2),
            ),
            const SizedBox(height: 2),

            // Channel
            if (updatedPlaylist.channelName != null)
              Text(
                updatedPlaylist.channelName!,
                style: GoogleFonts.montserrat(
                    fontSize: 15,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 16),

            // Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FIcon(
                          RI.RiCalendarLine,
                          size: 14,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMM yyyy',
                                  Localizations.localeOf(context).toString())
                              .format(playlist.createdAt),
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FIcon(
                          RI.RiVideoLine,
                          size: 14,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${updatedPlaylist.playlistCompletedVideos ?? 0}/${updatedPlaylist.playlistTotalVideos ?? 0}',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    if (playlist.playlistCompletedVideos ==
                        playlist.playlistTotalVideos)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FIcon(
                            RI.RiDownloadLine,
                            size: 14,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.downloaded,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Open folder button
            if (updatedPlaylist.dirPath != null)
              OutlinedButton.icon(
                onPressed: () => OpenFile.open(updatedPlaylist.dirPath),
                icon: const FIcon(RI.RiFolderOpenLine),
                label: Text(l10n.openFolder),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  backgroundColor: colorScheme.tertiary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  side:
                      BorderSide(color: colorScheme.primary.withOpacity(0.15)),
                ),
              ),
            Divider(
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),

            // Video list
            childVideos.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 64),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FIcon(
                            RI.RiPlayListLine,
                            size: 64,
                            color:
                                colorScheme.onSurfaceVariant.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noVideosFound,
                            style: GoogleFonts.notoSans(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        for (var video in childVideos) ...[
                          _PlaylistVideoItem(
                            video: video,
                            index: childVideos.indexOf(video) + 1,
                            onTap: () {
                              ref
                                  .read(selectedPlaylistVideoProvider.notifier)
                                  .select(video);
                            },
                          ),
                        ]
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// Item widget for a video within the playlist.
class _PlaylistVideoItem extends ConsumerStatefulWidget {
  final DownloadTask video;
  final int index;
  final VoidCallback onTap;

  const _PlaylistVideoItem({
    required this.video,
    required this.index,
    required this.onTap,
  });

  @override
  ConsumerState<_PlaylistVideoItem> createState() => _PlaylistVideoItemState();
}

class _PlaylistVideoItemState extends ConsumerState<_PlaylistVideoItem> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Watch live progress for immediate UI updates
    final liveProgressMap = ref.watch(activeDownloadProgressProvider);
    final live = liveProgressMap[widget.video.id];
    
    // Consider downloading active if status is 'downloading' OR if there's live progress data
    final isDownloading = widget.video.downloadStatus == WorkStatus.running || live != null;
    final effectiveProgress = (live?['progress'] as double?) ?? widget.video.progress;
    final effectiveSpeed = (live?['downloadSpeed'] as String?) ?? widget.video.downloadSpeed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.15),
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Index number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.index}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Thumbnail
              if (widget.video.thumbnail != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: widget.video.thumbnail!,
                    width: 80,
                    height: 45,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 45,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title ??
                          AppLocalizations.of(context)!.unknownTrack,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.video.channelName != null)
                      Text(
                        widget.video.channelName!,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (isDownloading)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: effectiveProgress,
                                backgroundColor:
                                    colorScheme.primary.withOpacity(0.2),
                                minHeight: 3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(effectiveProgress * 100).toStringAsFixed(0)}% • ${effectiveSpeed ?? "..."}',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Status icon
              _buildStatusIcon(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    IconData icon;
    Color color;

    switch (widget.video.downloadStatus) {
      case WorkStatus.completed:
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case WorkStatus.running:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        );
      case WorkStatus.failed:
        icon = Icons.error_rounded;
        color = Theme.of(context).colorScheme.error;
        break;
      default:
        icon = Icons.schedule_rounded;
        color = colorScheme.onSurfaceVariant;
    }

    return Icon(icon, color: color, size: 24);
  }
}
