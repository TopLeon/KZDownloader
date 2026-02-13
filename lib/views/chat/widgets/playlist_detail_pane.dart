import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          width: MediaQuery.of(context).size.width * 0.35,
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
                      icon: const Icon(Icons.arrow_back),
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
    final childVideos = allTasksAsync.when(
      data: (tasks) =>
          tasks.where((task) => task.playlistParentId == playlist.id).toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      loading: () => <DownloadTask>[],
      error: (_, __) => <DownloadTask>[],
    );

    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          // Playlist info header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large thumbnail
                if (playlist.thumbnail != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            playlist.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
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
                const SizedBox(height: 16),

                // Title
                Text(
                  playlist.title ?? l10n.playlist,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Channel
                if (playlist.channelName != null)
                  Row(
                    children: [
                      FIcon(
                        RI.RiUserLine,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        playlist.channelName!,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FIcon(
                                RI.RiVideoLine,
                                size: 14,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${playlist.playlistCompletedVideos ?? 0}/${playlist.playlistTotalVideos ?? 0}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: playlist.progress,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            playlist.status == 'completed'
                                ? Colors.green
                                : colorScheme.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Open folder button
                if (playlist.dirPath != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => OpenFile.open(playlist.dirPath),
                      icon: const FIcon(RI.RiFolderOpenLine, size: 18),
                      label: Text(l10n.openFolder),
                    ),
                  ),
              ],
            ),
          ),

          // Video list
          Expanded(
            child: childVideos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FIcon(
                          RI.RiPlayListLine,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: childVideos.length,
                    itemBuilder: (context, index) {
                      final video = childVideos[index];
                      return _PlaylistVideoItem(
                        video: video,
                        index: index + 1,
                        onTap: () {
                          ref
                              .read(selectedPlaylistVideoProvider.notifier)
                              .select(video);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Item widget for a video within the playlist.
class _PlaylistVideoItem extends StatefulWidget {
  final DownloadTask video;
  final int index;
  final VoidCallback onTap;

  const _PlaylistVideoItem({
    required this.video,
    required this.index,
    required this.onTap,
  });

  @override
  State<_PlaylistVideoItem> createState() => _PlaylistVideoItemState();
}

class _PlaylistVideoItemState extends State<_PlaylistVideoItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _isHovered
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
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
                    child: Image.network(
                      widget.video.thumbnail!,
                      width: 80,
                      height: 45,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 45,
                        color: colorScheme.surfaceContainerHighest,
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
                        widget.video.title ?? 'Video ${widget.index}',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.video.status == 'downloading')
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: widget.video.progress / 100,
                                  backgroundColor:
                                      colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.video.progress.toStringAsFixed(0)}% • ${widget.video.downloadSpeed ?? "..."}',
                                style: GoogleFonts.notoSans(
                                  fontSize: 10,
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
      ),
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    IconData icon;
    Color color;

    switch (widget.video.status) {
      case 'completed':
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case 'downloading':
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        );
      case 'error':
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
