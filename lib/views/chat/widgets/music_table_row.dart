import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:not_static_icons/not_static_icons.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/views/widgets/confirm_dialog.dart';

// Row widget for displaying music tracks in a table format.
class MusicTableRow extends ConsumerStatefulWidget {
  final int index;
  final DownloadTask task;
  final bool isPlaying;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MusicTableRow({
    super.key,
    required this.index,
    required this.task,
    required this.isPlaying,
    required this.colorScheme,
    required this.onTap,
    required this.onDelete,
  });

  @override
  ConsumerState<MusicTableRow> createState() => _MusicTableRowState();
}

class _MusicTableRowState extends ConsumerState<MusicTableRow> {
  bool _isHovered = false;
  final _controller = AnimatedIconController();

  String _formatDuration() {
    try {
      if (widget.task.stepDetailsJson != null &&
          widget.task.stepDetailsJson!.isNotEmpty) {
        final details = jsonDecode(widget.task.stepDetailsJson!);

        if (details is Map && details.containsKey('Metadata Retrieval')) {
          final metadataStr = details['Metadata Retrieval'] as String?;
          if (metadataStr != null) {
            try {
              final metadata = jsonDecode(metadataStr);
              if (metadata is Map && metadata.containsKey('duration')) {
                final durationSeconds = metadata['duration'];
                if (durationSeconds is num) {
                  final duration = Duration(seconds: durationSeconds.toInt());
                  final minutes = duration.inMinutes;
                  final seconds = duration.inSeconds % 60;
                  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                }
              }
            } catch (_) {}
          }
        }
      }
    } catch (_) {}

    return '--:--';
  }

  String _getFormatLabel() {
    final ext = widget.task.filePath?.split('.').last.toUpperCase() ?? 'MP3';
    if (ext == 'M4A') return 'M4A';
    if (ext == 'OGG') return 'OGG';
    return 'MP3';
  }

  @override
  Widget build(BuildContext context) {
    final isPlayingRow = widget.isPlaying;

    // Watch live progress for immediate UI updates
    final liveProgressMap = ref.watch(activeDownloadProgressProvider);
    final live = liveProgressMap[widget.task.id];

    // Consider downloading active if status is 'downloading' OR if there's live progress data
    final isDownloading =
        widget.task.downloadStatus == WorkStatus.running || live != null;
    final isCompleted = widget.task.downloadStatus.isSuccess;
    final canPlay = isCompleted && widget.task.filePath != null;

    final hoverColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);

    final baseColor = Theme.of(context).scaffoldBackgroundColor;

    return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: canPlay
              ? () {
                  widget.onTap();
                  Future.delayed(const Duration(milliseconds: 200),
                      () => _controller.animate());
                }
              : null,
          child: Opacity(
            opacity: canPlay ? 1.0 : 0.6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: isPlayingRow
                    ? widget.colorScheme.tertiary
                    : _isHovered
                        ? Color.alphaBlend(hoverColor, baseColor)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isPlayingRow
                    ? Border.all(
                        color: widget.colorScheme.primary.withOpacity(0.15),
                        width: 1,
                      )
                    : null,
                boxShadow: [
                  if (isPlayingRow)
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .shadow
                          .withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 2),
                    )
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: isDownloading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                value: widget.task.progress > 0
                                    ? widget.task.progress
                                    : null,
                                strokeWidth: 2,
                                color: widget.colorScheme.primary,
                              ),
                            )
                          : _isHovered && !isPlayingRow && canPlay
                              ? Icon(
                                  Icons.play_arrow_rounded,
                                  size: 20,
                                  color: widget.colorScheme.onSurface,
                                )
                              : isPlayingRow
                                  ? AudioLinesIcon(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      controller: _controller,
                                      interactive: false,
                                      infiniteLoop: true,
                                      enableTouchInteraction: false,
                                      size: 20,
                                    )
                                  : Text(
                                      widget.index.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: !canPlay
                                            ? widget
                                                .colorScheme.onSurfaceVariant
                                                .withOpacity(0.5)
                                            : widget
                                                .colorScheme.onSurfaceVariant,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures()
                                        ],
                                      ),
                                    ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: widget.colorScheme.surfaceContainerHighest,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: widget.task.thumbnail != null &&
                                  widget.task.thumbnail!.isNotEmpty
                              ? Transform.scale(
                                  scale: 1.35,
                                  child: CachedNetworkImage(
                                    imageUrl: widget.task.thumbnail!,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.medium,
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Theme.brightnessOf(context) ==
                                              Brightness.dark
                                          ? Colors.grey[800]
                                          : Colors.grey[500],
                                      child: const Icon(Icons.music_note,
                                          size: 20, color: Colors.white54),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Theme.brightnessOf(context) ==
                                          Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[500],
                                  child: const Icon(Icons.music_note,
                                      size: 20, color: Colors.white54),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.task.title ??
                                      AppLocalizations.of(context)!.unknown,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2,
                                      wordSpacing: 0.2,
                                      letterSpacing: 0.1),
                                ),
                                Text(
                                  widget.task.url
                                      .split('/')[2]
                                      .replaceAll("www.", ""),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: isPlayingRow
                                        ? widget.colorScheme.primary
                                            .withOpacity(0.7)
                                        : widget.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      widget.task.channelName ??
                          AppLocalizations.of(context)!.unknownArtist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.unknownAlbum,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      _formatDuration(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        color: isPlayingRow
                            ? widget.colorScheme.primary
                            : widget.colorScheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: Center(
                      child: isDownloading
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${(widget.task.progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: widget.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : _isHovered && canPlay
                              ? _buildIconButton(
                                  context,
                                  icon: RI.RiDeleteBinLine,
                                  onTap: () {
                                    final l10n = AppLocalizations.of(context)!;
                                    showConfirmDialog(
                                      context,
                                      title: l10n.deleteTrackTitle,
                                      content: l10n.deleteTrackContent(
                                          widget.task.title ?? l10n.unknown),
                                      onConfirm: widget.onDelete,
                                    );
                                  },
                                  tooltip: AppLocalizations.of(context)!.delete,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isPlayingRow
                                        ? widget.colorScheme.primary
                                        : widget.colorScheme
                                            .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getFormatLabel(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isPlayingRow
                                          ? widget.colorScheme.onPrimary
                                          : widget.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildIconButton(
    BuildContext context, {
    required FIconObject icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: null,
            child: FIcon(
              icon,
              size: 20,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
