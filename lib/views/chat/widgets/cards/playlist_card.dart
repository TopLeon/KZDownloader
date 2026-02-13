import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/views/widgets/confirm_dialog.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:open_file/open_file.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';

// Card widget for YouTube playlists (non-expandable, tap to open detail pane).
class YouTubePlaylistCard extends ConsumerStatefulWidget {
  final DownloadTask playlist;
  final VoidCallback? onTap;
  final bool isSelected;

  const YouTubePlaylistCard({
    super.key,
    required this.playlist,
    this.onTap,
    required this.isSelected,
  });

  @override
  ConsumerState<YouTubePlaylistCard> createState() =>
      _YouTubePlaylistCardState();
}

class _YouTubePlaylistCardState extends ConsumerState<YouTubePlaylistCard> {
  bool _isHovered = false;

  Future<void> _openFolder() async {
    if (widget.playlist.dirPath != null) {
      await OpenFile.open(widget.playlist.dirPath);
    }
  }

  void _copyLink() {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: widget.playlist.url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.linkCopiedToClipboard),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    showConfirmDialog(
      context,
      title: l10n.deletePlaylist,
      content: l10n.deletePlaylistConfirmMessage,
      onConfirm: () async {
        await ref
            .read(downloadListProvider.notifier)
            .deleteTask(widget.playlist.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hoverColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);

    final baseColor = widget.isSelected
        ? colorScheme.tertiary
        : Theme.of(context).scaffoldBackgroundColor;

    // Determine border color based on status
    Color borderColor = colorScheme.primary.withOpacity(0.15);
    if (widget.playlist.status == 'downloading')
      borderColor = colorScheme.primary.withOpacity(0.5);
    if (widget.playlist.status == 'error') {
      borderColor = colorScheme.error.withOpacity(0.5);
    }

    return Row(
      children: [
        if (widget.isSelected)
          Container(
            width: 6,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
        Expanded(
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _isHovered
                    ? Color.alphaBlend(hoverColor, baseColor)
                    : baseColor,
                borderRadius: BorderRadius.circular(16),
                border: (widget.isSelected || widget.playlist.status == 'error')
                    ? Border.all(color: borderColor, width: 1)
                    : null,
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail
                          Container(
                            width: 120,
                            height: 68,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : colorScheme.surfaceContainerHighest,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (widget.playlist.thumbnail != null)
                                    Image.network(
                                      widget.playlist.thumbnail!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _buildPlaceholder(colorScheme),
                                    )
                                  else
                                    _buildPlaceholder(colorScheme),
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
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Playlist info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  widget.playlist.title ?? l10n.playlist,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2,
                                      wordSpacing: 0.2,
                                      letterSpacing: 0.1),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // Channel
                                if (widget.playlist.channelName != null)
                                  Text(
                                    '${widget.playlist.url.split('/')[2]} - ${widget.playlist.channelName!}',
                                    style: GoogleFonts.montserrat(
                                        fontSize: 11.5,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                // Video info and status
                                Row(
                                  children: [
                                    FIcon(RI.RiPlayListLine,
                                        size: 12,
                                        color: colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.playlist,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: colorScheme.onSurfaceVariant),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                if (widget.playlist.status == 'downloading')

                                  // Progress bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: widget.playlist.progress,
                                      backgroundColor:
                                          colorScheme.primary.withOpacity(0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getProgressColor(colorScheme),
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Hover action buttons
                      if (_isHovered)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isHovered ? 1.0 : 0.0,
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 80, right: 0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.alphaBlend(hoverColor, baseColor)
                                        .withOpacity(0.0),
                                    Color.alphaBlend(hoverColor, baseColor),
                                    Color.alphaBlend(hoverColor, baseColor),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.playlist.dirPath != null)
                                    IconButton(
                                      icon: const FIcon(RI.RiFolderOpenLine),
                                      onPressed: _openFolder,
                                      tooltip: "Apri Cartella",
                                      style: IconButton.styleFrom(
                                        shape: CircleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                color: colorScheme.primary
                                                    .withOpacity(0.15))),
                                        backgroundColor: colorScheme.tertiary,
                                        foregroundColor: colorScheme.primary,
                                      ),
                                    ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const FIcon(RI.RiLinkM),
                                    onPressed: _copyLink,
                                    tooltip: "Copia Link",
                                    style: IconButton.styleFrom(
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              width: 1,
                                              color: colorScheme.primary
                                                  .withOpacity(0.15))),
                                      backgroundColor: colorScheme.tertiary,
                                      foregroundColor: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const FIcon(RI.RiDeleteBinLine),
                                    onPressed: _confirmDelete,
                                    tooltip: "Elimina",
                                    style: IconButton.styleFrom(
                                      backgroundColor: colorScheme.tertiary,
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              width: 1,
                                              color: colorScheme.primary
                                                  .withOpacity(0.15))),
                                      foregroundColor: colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : colorScheme.surfaceContainerHighest,
      child: Center(
        child: FIcon(
          RI.RiPlayListLine,
          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
          size: 32,
        ),
      ),
    );
  }

  Color _getProgressColor(ColorScheme colorScheme) {
    switch (widget.playlist.status) {
      case 'completed':
        return Colors.green;
      case 'error':
        return Theme.of(context).colorScheme.error;
      case 'downloading':
        return colorScheme.primary;
      default:
        return colorScheme.primary;
    }
  }
}
