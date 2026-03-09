import 'dart:convert';
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
import 'package:kzdownloader/core/utils/utils.dart';

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

    // For M3U8 containers, show M3U8-specific detail view.
    // Use isPlaylistContainer (set by M3U8Strategy at runtime) rather than
    // URL extension — many HLS streams have no .m3u8 in the URL.
    final isM3U8 =
        playlist.isPlaylistContainer && !UrlUtils.isYouTubePlaylist(playlist.url);
    if (isM3U8) {
      return _M3U8DetailView(playlist: playlist);
    }

    // Main YT playlist view
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

            // Title and Control Actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    updatedPlaylist.title ?? l10n.playlist,
                    style: GoogleFonts.montserrat(
                        fontSize: 20, fontWeight: FontWeight.w600, height: 1.2),
                  ),
                ),
                const SizedBox(width: 8),
                if (updatedPlaylist.downloadStatus == WorkStatus.running ||
                    updatedPlaylist.downloadStatus == WorkStatus.pending)
                  IconButton(
                    icon: const FIcon(RI.RiPauseFill),
                    onPressed: () => ref
                        .read(downloadListProvider.notifier)
                        .pauseTask(updatedPlaylist.id),
                    tooltip: l10n.actionPause,
                  )
                else if (updatedPlaylist.downloadStatus == WorkStatus.paused)
                  IconButton(
                    icon: const FIcon(RI.RiPlayFill),
                    onPressed: () => ref
                        .read(downloadListProvider.notifier)
                        .resumeTask(updatedPlaylist.id),
                    tooltip: l10n.actionResume,
                  ),
                if (updatedPlaylist.downloadStatus == WorkStatus.running ||
                    updatedPlaylist.downloadStatus == WorkStatus.pending ||
                    updatedPlaylist.downloadStatus == WorkStatus.paused)
                  IconButton(
                    icon: const FIcon(RI.RiCloseFill),
                    onPressed: () => ref
                        .read(downloadListProvider.notifier)
                        .cancelTask(updatedPlaylist.id),
                    tooltip: l10n.cancel,
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
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
                    if (playlist.playlistCompletedVideos != null &&
                        playlist.playlistCompletedVideos ==
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
    final isDownloading =
        widget.video.downloadStatus == WorkStatus.running || live != null;
    final effectiveProgress =
        (live?['progress'] as double?) ?? widget.video.progress;
    final effectiveSpeed =
        (live?['downloadSpeed'] as String?) ?? widget.video.downloadSpeed;

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

/// M3U8-specific detail view: shows variant info, segment progress, and file path.
class _M3U8DetailView extends ConsumerWidget {
  final DownloadTask playlist;

  const _M3U8DetailView({required this.playlist});

  Map<String, dynamic>? _parseVariantMeta(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String _formatBandwidth(int? bps) {
    if (bps == null) return 'Unknown';
    if (bps >= 1000000) return '${(bps / 1000000).toStringAsFixed(1)} Mbps';
    if (bps >= 1000) return '${(bps / 1000).toStringAsFixed(0)} kbps';
    return '$bps bps';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final allTasksAsync = ref.watch(downloadListProvider);
    final updatedPlaylist = allTasksAsync.when(
      data: (tasks) => tasks.firstWhere(
        (task) => task.id == playlist.id,
        orElse: () => playlist,
      ),
      loading: () => playlist,
      error: (_, __) => playlist,
    );

    final variantMeta = _parseVariantMeta(updatedPlaylist.stepDetailsJson);
    final liveProgressMap = ref.watch(activeDownloadProgressProvider);
    final live = liveProgressMap[updatedPlaylist.id];
    final isDownloading =
        updatedPlaylist.downloadStatus == WorkStatus.running || live != null;
    final effectiveProgress =
        (live?['progress'] as double?) ?? updatedPlaylist.progress;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HLS Badge + Action buttons
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'HLS Stream',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                if (isDownloading)
                  IconButton(
                    icon: const FIcon(RI.RiPauseFill),
                    onPressed: () => ref
                        .read(downloadListProvider.notifier)
                        .pauseTask(updatedPlaylist.id),
                    tooltip: l10n.actionPause,
                  )
                else if (updatedPlaylist.downloadStatus == WorkStatus.paused)
                  IconButton(
                    icon: const FIcon(RI.RiPlayFill),
                    onPressed: () => ref
                        .read(downloadListProvider.notifier)
                        .resumeTask(updatedPlaylist.id),
                    tooltip: l10n.actionResume,
                  ),
                if (updatedPlaylist.downloadStatus == WorkStatus.running ||
                    updatedPlaylist.downloadStatus == WorkStatus.pending ||
                    updatedPlaylist.downloadStatus == WorkStatus.paused)
                  IconButton(
                    icon: const FIcon(RI.RiCloseFill),
                    onPressed: () => ref
                        .read(downloadListProvider.notifier)
                        .cancelTask(updatedPlaylist.id),
                    tooltip: l10n.cancel,
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              updatedPlaylist.title ?? 'M3U8 Video',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),

            // URL (muted)
            Text(
              updatedPlaylist.url,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // Variant metadata info rows
            if (variantMeta != null) ...[
              _buildInfoRow(
                context,
                icon: RI.RiFullscreenLine,
                label: 'Resolution',
                value: variantMeta['resolution'] as String? ?? 'Unknown',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                icon: RI.RiSpeedLine,
                label: 'Bandwidth',
                value: _formatBandwidth(variantMeta['bandwidth'] as int?),
              ),
              if (variantMeta['codecs'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  icon: RI.RiCodeLine,
                  label: 'Codecs',
                  value: variantMeta['codecs'] as String,
                ),
              ],
              if (variantMeta['frameRate'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  icon: RI.RiFilmLine,
                  label: 'Frame Rate',
                  value:
                      '${(variantMeta['frameRate'] as num).toStringAsFixed(0)} fps',
                ),
              ],
              const SizedBox(height: 16),
            ],

            // Segment progress
            if (updatedPlaylist.playlistTotalVideos != null &&
                updatedPlaylist.playlistTotalVideos! > 0) ...[
              Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text(
                'Segments',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: effectiveProgress,
                        backgroundColor: colorScheme.primary.withOpacity(0.15),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${updatedPlaylist.playlistCompletedVideos ?? 0}/${updatedPlaylist.playlistTotalVideos}',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${(effectiveProgress * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status
            _buildInfoRow(
              context,
              icon: RI.RiDownloadLine,
              label: 'Status',
              value: _statusText(updatedPlaylist.downloadStatus, l10n),
            ),
            const SizedBox(height: 8),

            // Date
            _buildInfoRow(
              context,
              icon: RI.RiCalendarLine,
              label: 'Date',
              value: DateFormat('dd MMM yyyy HH:mm',
                      Localizations.localeOf(context).toString())
                  .format(updatedPlaylist.createdAt),
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

            // Error message
            if (updatedPlaylist.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: colorScheme.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        updatedPlaylist.errorMessage!,
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required dynamic icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        FIcon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _statusText(WorkStatus status, AppLocalizations l10n) {
    switch (status) {
      case WorkStatus.completed:
        return l10n.downloaded;
      case WorkStatus.running:
        return 'Downloading';
      case WorkStatus.paused:
        return l10n.actionPause;
      case WorkStatus.failed:
        return 'Failed';
      case WorkStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}
