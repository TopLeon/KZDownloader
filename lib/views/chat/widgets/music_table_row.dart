import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:not_static_icons/not_static_icons.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/views/widgets/confirm_dialog.dart';

// Row widget for displaying music tracks in a table format.
class MusicTableRow extends StatefulWidget {
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
  State<MusicTableRow> createState() => _MusicTableRowState();
}

class _MusicTableRowState extends State<MusicTableRow> {
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
    if (ext == 'FLAC') return 'FLAC';
    if (ext == 'WAV') return 'WAV';
    return 'MP3';
  }

  @override
  Widget build(BuildContext context) {
    final isPlayingRow = widget.isPlaying;
    final hoverColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);

    final baseColor = Theme.of(context).scaffoldBackgroundColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () {
          widget.onTap();
          Future.delayed(
              const Duration(milliseconds: 200), () => _controller.animate());
        },
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
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Center(
                  child: _isHovered && !isPlayingRow
                      ? Icon(
                          Icons.play_arrow_rounded,
                          size: 20,
                          color: widget.colorScheme.onSurface,
                        )
                      : isPlayingRow
                          ? AudioLinesIcon(
                              color: Theme.of(context).colorScheme.primary,
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
                                color: widget.colorScheme.onSurfaceVariant,
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: widget.colorScheme.surfaceContainerHighest,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.task.thumbnail != null &&
                              widget.task.thumbnail!.isNotEmpty
                          ? Image.network(
                              widget.task.thumbnail!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => FIcon(
                                RI.RiMusicLine,
                                color: widget.colorScheme.onSurfaceVariant
                                    .withOpacity(0.5),
                                size: 20,
                              ),
                            )
                          : FIcon(
                              RI.RiMusicLine,
                              color: widget.colorScheme.onSurfaceVariant
                                  .withOpacity(0.5),
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.task.title ??
                                  AppLocalizations.of(context)!.unknown,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: widget.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              widget.task.url.split('/')[2],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
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
              SizedBox(
                width: 80,
                child: Center(
                  child: _isHovered
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
                                : widget.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getFormatLabel(),
                            style: TextStyle(
                              fontSize: 10,
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
    );
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
