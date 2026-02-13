import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/views/chat/widgets/rainbow.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:kzdownloader/views/widgets/confirm_dialog.dart';

class DownloadCard extends ConsumerStatefulWidget {
  final DownloadTask task;
  final bool isLatest;
  final bool hideActions;
  final bool isSelected;

  const DownloadCard(
      {super.key,
      required this.task,
      this.isLatest = false,
      this.isSelected = false,
      this.hideActions = false});

  @override
  ConsumerState<DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends ConsumerState<DownloadCard>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _rotateController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    showConfirmDialog(
      context,
      title: l10n.deleteTask,
      content: l10n.deleteTaskConfirmMessage,
      onConfirm: () =>
          ref.read(downloadListProvider.notifier).deleteTask(widget.task.id),
    );
  }

  void _copyLink() {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: widget.task.url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.linkCopied),
        behavior: SnackBarBehavior.floating,
        width: 200,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Helper to get file type info (icon and color)
  Map<String, dynamic> _getFileTypeInfo(String? filePath) {
    if (filePath == null) {
      return {'icon': RI.RiFileUnknowLine, 'color': Colors.grey};
    }

    final extension = path.extension(filePath).toLowerCase();

    // Videos
    if (['.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v']
        .contains(extension)) {
      return {'icon': RI.RiVideoLine, 'color': const Color(0xFFE91E63)};
    }
    // Audio
    if (['.mp3', '.wav', '.flac', '.aac', '.ogg', '.m4a', '.wma']
        .contains(extension)) {
      return {'icon': RI.RiMusicLine, 'color': const Color(0xFF9C27B0)};
    }
    // Images
    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg', '.ico']
        .contains(extension)) {
      return {'icon': RI.RiImageLine, 'color': const Color(0xFF4CAF50)};
    }
    // Archives
    if (['.zip', '.rar', '.7z', '.tar', '.gz', '.bz2', '.xz']
        .contains(extension)) {
      return {'icon': RI.RiFolderZipLine, 'color': const Color(0xFFFF9800)};
    }
    // Documents
    if (['.pdf'].contains(extension)) {
      return {'icon': RI.RiFilePdfLine, 'color': const Color(0xFFF44336)};
    }
    if (['.doc', '.docx', '.txt', '.rtf', '.odt'].contains(extension)) {
      return {'icon': RI.RiFileTextLine, 'color': const Color(0xFF2196F3)};
    }
    // Spreadsheets
    if (['.xls', '.xlsx', '.csv', '.ods'].contains(extension)) {
      return {'icon': RI.RiFileExcelLine, 'color': const Color(0xFF4CAF50)};
    }
    // Code
    if ([
      '.html',
      '.css',
      '.js',
      '.json',
      '.xml',
      '.dart',
      '.py',
      '.java',
      '.cpp',
      '.c'
    ].contains(extension)) {
      return {'icon': RI.RiCodeLine, 'color': const Color(0xFF00BCD4)};
    }
    // Executables/Apps
    if (['.exe', '.dmg', '.app', '.apk', '.deb', '.rpm'].contains(extension)) {
      return {'icon': RI.RiInstallLine, 'color': const Color(0xFF607D8B)};
    }

    // Default
    return {'icon': RI.RiFileLine, 'color': const Color(0xFF9E9E9E)};
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDownloading = task.status == 'downloading';
    final isSummarizing = task.status == 'summarizing';

    final hoverColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);

    final baseColor = Theme.of(context).scaffoldBackgroundColor;

    Color borderColor = colorScheme.primary.withOpacity(0.15);
    if (task.status == 'error') {
      borderColor = colorScheme.error.withOpacity(0.5);
    }

    Widget cardContent = Row(
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
            child: RainbowAnimatedBorderForever(
              disabled: !isSummarizing,
              borderRadius: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? colorScheme.tertiary
                      : _isHovered
                          ? Color.alphaBlend(hoverColor, baseColor)
                          : baseColor,
                  borderRadius: BorderRadius.circular(16),
                  border: (widget.isSelected || task.status == 'error') &&
                          !isSummarizing
                      ? Border.all(color: borderColor, width: 1)
                      : null,
                  boxShadow: [
                    if (widget.isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildThumbnail(context, task),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: widget.hideActions ? 0 : 100),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title ?? l10n.analyzing,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                height: 1.2,
                                                wordSpacing: 0.2,
                                                letterSpacing: 0.1),
                                            maxLines:
                                                widget.hideActions ? 1 : 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "${task.url.split('/')[2]} - ${task.channelName ?? l10n.unknownChannel}",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 11.5,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_isHovered)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        opacity: _isHovered ? 1.0 : 0.0,
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 100, right: 0),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                if (!widget.isSelected) ...[
                                                  Color.alphaBlend(
                                                          hoverColor, baseColor)
                                                      .withOpacity(0.0),
                                                  Color.alphaBlend(
                                                      hoverColor, baseColor),
                                                  Color.alphaBlend(
                                                      hoverColor, baseColor),
                                                ] else ...[
                                                  colorScheme.tertiary
                                                      .withOpacity(0.0),
                                                  colorScheme.tertiary,
                                                  colorScheme.tertiary
                                                ]
                                              ],
                                              stops: const [0.0, 0.5, 1.0],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                          ),
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              // Pause/Resume button for non-music downloads
                                              if (task.status ==
                                                      'downloading' ||
                                                  task.status == 'paused')
                                                IconButton(
                                                  icon: FIcon(
                                                    task.status == 'downloading'
                                                        ? RI.RiPauseLine
                                                        : RI.RiPlayLine,
                                                  ),
                                                  onPressed: () {
                                                    if (task.status ==
                                                        'downloading') {
                                                      ref
                                                          .read(
                                                              downloadListProvider
                                                                  .notifier)
                                                          .pauseTask(task.id);
                                                    } else {
                                                      ref
                                                          .read(
                                                              downloadListProvider
                                                                  .notifier)
                                                          .resumeTask(task.id);
                                                    }
                                                  },
                                                  tooltip: task.status ==
                                                          'downloading'
                                                      ? l10n.actionPause
                                                      : l10n.actionResume,
                                                  style: IconButton.styleFrom(
                                                    shape: CircleBorder(
                                                        side: BorderSide(
                                                            width: 1,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary
                                                                .withOpacity(
                                                                    0.15))),
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .tertiary,
                                                    foregroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                  ),
                                                ),
                                              IconButton(
                                                icon: const FIcon(RI.RiLinkM),
                                                onPressed: _copyLink,
                                                tooltip: l10n.copyLink,
                                                style: IconButton.styleFrom(
                                                  shape: CircleBorder(
                                                      side: BorderSide(
                                                          width: 1,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary
                                                                  .withOpacity(
                                                                      0.15))),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .tertiary,
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                ),
                                              ),
                                              IconButton(
                                                icon: FIcon(
                                                  RI.RiDeleteBinLine,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                ),
                                                onPressed: _confirmDelete,
                                                tooltip: l10n.delete,
                                                style: IconButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .tertiary,
                                                  shape: CircleBorder(
                                                      side: BorderSide(
                                                          width: 1,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary
                                                                  .withOpacity(
                                                                      0.15))),
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (isDownloading) ...[
                                const SizedBox(height: 6),
                                if (task.category == TaskCategory.generic &&
                                    task.activeWorkers != null &&
                                    task.activeWorkers! > 1) ...[
                                  // IDM-style multi-threaded download indicator
                                  _buildIdmDownloadIndicator(context, task),
                                ] else ...[
                                  // Standard progress bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: task.progress / 100,
                                      minHeight: 3,
                                      backgroundColor:
                                          colorScheme.primary.withOpacity(0.2),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${task.progress.toStringAsFixed(0)}% • ${task.downloadSpeed ?? '0.00MiB/s'} • ${l10n.eta}: ${task.eta ?? l10n.etaPlaceholder}",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 9,
                                        color: colorScheme.primary),
                                  )
                                ],
                              ] else
                                _buildMetadataBadge(
                                  context,
                                  task: task,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return cardContent;
  }

  Widget _buildIdmDownloadIndicator(BuildContext context, DownloadTask task) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    List<dynamic> workers = [];
    if (task.workersProgressJson != null) {
      try {
        workers = jsonDecode(task.workersProgressJson!) as List<dynamic>;
      } catch (e) {
        // Fallback if JSON parsing fails
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IDM-style worker status text
        Text(
          l10n.proDownloading(task.activeWorkers ?? 0),
          style: GoogleFonts.montserrat(
            fontSize: 9,
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        // Worker progress bars
        if (workers.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                ...workers.take(6).map((worker) {
                  final progress =
                      (worker['progress'] as num?)?.toDouble() ?? 0.0;
                  final isDone = worker['isDone'] as bool? ?? false;
                  final workerId = worker['id'] as int? ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text(
                            '#${workerId + 1}',
                            style: GoogleFonts.robotoMono(
                              fontSize: 7.5,
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 3,
                              backgroundColor: isDone
                                  ? colorScheme.primary.withOpacity(0.3)
                                  : colorScheme.primary.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDone
                                    ? colorScheme.primary.withOpacity(0.7)
                                    : colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.robotoMono(
                              fontSize: 7.5,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                if (workers.length > 6)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '... e altri ${workers.length - 6} worker',
                      style: GoogleFonts.montserrat(
                        fontSize: 7,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
        // Overall progress
        Text(
          "${task.progress.toStringAsFixed(1)}% • ${task.downloadSpeed ?? '0.00MiB/s'} • ${l10n.eta}: ${task.eta ?? l10n.etaPlaceholder}",
          style: GoogleFonts.montserrat(
            fontSize: 9,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaInternal(
      FIconObject icon, String text, ThemeData theme, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FIcon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMetadataBadge(BuildContext context,
      {required DownloadTask task}) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        if (task.totalSize != null) ...[
          // Check task status first
          if (task.status == 'paused') ...[
            _buildMetaInternal(RI.RiPauseLine, l10n.actionPause, theme, isDark),
          ] else if (task.status == 'error') ...[
            _buildMetaInternal(RI.RiAlertLine, l10n.error, theme, isDark),
          ] else if (File(task.filePath ?? '').existsSync()) ...[
            _buildMetaInternal(
                RI.RiDownloadLine, l10n.downloaded, theme, isDark),
          ] else ...[
            _buildMetaInternal(RI.RiDeleteBinLine, l10n.deleted, theme, isDark),
          ],
          _buildMetaInternal(RI.RiSdCardLine, task.totalSize!, theme, isDark),
        ] else ...[
          _buildMetaInternal(RI.RiBardLine, l10n.summarized, theme, isDark),
        ],
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context, DownloadTask task) {
    // For generic downloads, use file type icon
    if (task.category == TaskCategory.generic && task.thumbnail == null) {
      final fileInfo = _getFileTypeInfo(task.filePath ?? task.title);
      return Container(
        width: 120,
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (fileInfo['color'] as Color).withOpacity(0.2),
              (fileInfo['color'] as Color).withOpacity(0.4),
            ],
          ),
        ),
        child: Center(
          child: FIcon(
            fileInfo['icon'],
            color: fileInfo['color'],
            size: 36,
          ),
        ),
      );
    }

    // Standard video/thumbnail display
    return Container(
      width: 120,
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (task.thumbnail != null)
              Image.network(
                task.thumbnail!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(Theme.of(context).colorScheme),
              )
            else
              _buildPlaceholder(Theme.of(context).colorScheme),
            if (task.thumbnail == null) ...[
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
                  RI.RiVideoOnLine,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: FIcon(
          RI.RiVideoOnLine,
          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
          size: 32,
        ),
      ),
    );
  }
}
