import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
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

    // Watch live progress for immediate UI updates (bypasses Isar watch coalescing)
    final liveProgressMap = ref.watch(activeDownloadProgressProvider);
    final live = liveProgressMap[task.id];

    // Consider downloading active if status is 'downloading' OR if there's live progress data
    final isDownloading =
        task.downloadStatus == WorkStatus.running || live != null;
    final isSummarizing = task.summaryStatus.isActive;

    // Use live data when available for active downloads
    final effectiveProgress = live?['progress'] as double? ?? task.progress;
    final effectiveSpeed =
        live?['downloadSpeed'] as String? ?? task.downloadSpeed;
    final effectiveEta = live?['eta'] as String? ?? task.eta;
    final effectiveActiveWorkers =
        live?['activeWorkers'] as int? ?? task.activeWorkers;
    // ignore: unused_local_variable
    final effectiveTotalWorkers =
        live?['totalWorkers'] as int? ?? task.totalWorkers;
    final effectiveWorkersJson =
        live?['workersProgressJson'] as String? ?? task.workersProgressJson;

    final hoverColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);

    final baseColor = Theme.of(context).scaffoldBackgroundColor;
    Color borderColor = colorScheme.primary.withOpacity(0.15);
    if (task.downloadStatus == WorkStatus.failed) {
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
              disabled: !isSummarizing && !isDownloading,
              borderRadius: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? colorScheme.tertiary
                      : _isHovered
                          ? Color.alphaBlend(hoverColor, baseColor)
                          : baseColor,
                  borderRadius: BorderRadius.circular(16),
                  border: (widget.isSelected ||
                              task.downloadStatus == WorkStatus.failed) &&
                          !isSummarizing
                      ? Border.all(color: borderColor, width: 1)
                      : null,
                  boxShadow: [
                    if (widget.isSelected)
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 2),
                      )
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
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                height: 1.2,
                                                wordSpacing: 0.2,
                                                letterSpacing: 0.1),
                                            maxLines:
                                                widget.hideActions ? 1 : 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            task.category == TaskCategory.video ? "${task.url.split('/')[2].replaceAll("www.", "")} - ${task.channelName ?? l10n.unknownChannel}" : task.url,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 13,
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
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.easeOutCubic,
                                        builder: (context, value, child) =>
                                            Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset:
                                                Offset((1 - value) * 12, 0),
                                            child: child,
                                          ),
                                        ),
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
                                              if (task.downloadStatus ==
                                                      WorkStatus.running ||
                                                  task.downloadStatus ==
                                                      WorkStatus.paused)
                                                IconButton(
                                                  icon: FIcon(
                                                    task.downloadStatus ==
                                                            WorkStatus.running
                                                        ? RI.RiPauseLine
                                                        : RI.RiPlayLine,
                                                  ),
                                                  onPressed: () {
                                                    if (task.downloadStatus ==
                                                        WorkStatus.running) {
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
                                                  tooltip:
                                                      task.downloadStatus ==
                                                              WorkStatus.running
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
                                              const SizedBox(width: 4),

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
                                              const SizedBox(width: 4),
                                              // Cancel button for active/paused downloads
                                              if (task.downloadStatus ==
                                                      WorkStatus.running ||
                                                  task.downloadStatus ==
                                                      WorkStatus.paused)
                                                IconButton(
                                                  icon: FIcon(
                                                    RI.RiCloseLine,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                                  ),
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                            downloadListProvider
                                                                .notifier)
                                                        .cancelTask(task.id);
                                                  },
                                                  tooltip: l10n.cancelDownload,
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
                                                            .error,
                                                  ),
                                                ),

                                              const SizedBox(width: 4),
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
                                // Speed history graph overlay
                                _buildSpeedGraphOverlay(context, live),
                                if (task.category == TaskCategory.generic &&
                                    effectiveActiveWorkers != null &&
                                    effectiveActiveWorkers > 1) ...[
                                  // IDM-style multi-threaded download indicator
                                  _buildIdmDownloadIndicatorLive(
                                    context,
                                    task,
                                    effectiveProgress: effectiveProgress * 100,
                                    effectiveSpeed: effectiveSpeed,
                                    effectiveEta: effectiveEta,
                                    effectiveActiveWorkers:
                                        effectiveActiveWorkers,
                                    effectiveWorkersJson: effectiveWorkersJson,
                                  ),
                                ] else ...[
                                  // Standard progress bar
                                  FAProgressBar(
                                    currentValue: effectiveProgress * 100,
                                    progressColor: colorScheme.primary,
                                    animatedDuration:
                                        const Duration(milliseconds: 200),
                                    size: 3,
                                    backgroundColor:
                                        colorScheme.primary.withOpacity(0.15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${(effectiveProgress * 100).toStringAsFixed(0)}% • ${effectiveSpeed ?? '0.00MiB/s'} • ${l10n.eta}: ${effectiveEta ?? l10n.etaPlaceholder}",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12,
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

  Widget _buildIdmDownloadIndicatorLive(
    BuildContext context,
    DownloadTask task, {
    required double effectiveProgress,
    required String? effectiveSpeed,
    required String? effectiveEta,
    required int? effectiveActiveWorkers,
    required String? effectiveWorkersJson,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    List<dynamic> workers = [];
    if (effectiveWorkersJson != null) {
      try {
        workers = jsonDecode(effectiveWorkersJson) as List<dynamic>;
      } catch (e) {
        // Fallback if JSON parsing fails
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IDM-style worker status text
        Text(
          l10n.proDownloading(effectiveActiveWorkers ?? 0),
          style: GoogleFonts.montserrat(
            fontSize: 12,
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
                            child: FAProgressBar(
                                currentValue: progress * 100,
                                size: 3,
                                animatedDuration:
                                    const Duration(milliseconds: 200),
                                backgroundColor: isDone
                                    ? colorScheme.primary.withOpacity(0.3)
                                    : colorScheme.primary.withOpacity(0.15),
                                progressColor: isDone
                                    ? colorScheme.primary.withOpacity(0.7)
                                    : colorScheme.primary),
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
                }),
                if (workers.length > 6)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '... e altri ${workers.length - 6} worker',
                      style: GoogleFonts.montserrat(
                        fontSize: 7,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.9),
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
          "${effectiveProgress.toStringAsFixed(1)}% • ${effectiveSpeed ?? '0.00MiB/s'} • ${l10n.eta}: ${effectiveEta ?? l10n.etaPlaceholder}",
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaInternal(
      FIconObject icon, String text, ThemeData theme, bool isDark,
      {Color? color}) {
    final effectiveColor = color ?? theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FIcon(icon, size: 12, color: effectiveColor),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: effectiveColor)),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMetadataBadge(BuildContext context,
      {required DownloadTask task}) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;

    // Check live proxy status for generic downloads
    final liveProgressMap = ref.watch(activeDownloadProgressProvider);
    final live = liveProgressMap[task.id];
    final proxyActive = live?['proxyActive'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          // Proxy badge for generic downloads
          if (task.category == TaskCategory.generic && proxyActive)
            _buildMetaInternal(RI.RiShieldLine, 'Proxy', theme, isDark,
                color: const Color(0xFF2196F3)),
          // Protocol badge
          if (task.category == TaskCategory.generic) ...[
            if (task.url.startsWith('https://'))
              _buildMetaInternal(RI.RiLockLine, 'HTTPS', theme, isDark,
                  color: Colors.green)
            else if (task.url.startsWith('http://'))
              _buildMetaInternal(RI.RiLockUnlockLine, 'HTTP', theme, isDark,
                  color: Colors.orange),
          ],
          // Checksum Status
          if (task.category == TaskCategory.generic &&
              task.expectedChecksum != null &&
              task.expectedChecksum!.isNotEmpty &&
              task.downloadStatus == WorkStatus.completed) ...[
            if (task.checksumResult == 'match')
              _buildMetaInternal(
                  RI.RiCheckboxCircleLine, l10n.checksumMatch, theme, isDark,
                  color: Colors.green)
            else if (task.checksumResult == 'mismatch')
              _buildMetaInternal(
                  RI.RiCloseCircleLine, l10n.checksumMismatch, theme, isDark,
                  color: colorScheme.error)
            else if (task.checksumResult == 'error')
              _buildMetaInternal(
                  RI.RiAlertLine, l10n.checksumError, theme, isDark,
                  color: colorScheme.error)
            else if (task.checksumResult == null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.checksumVerifying,
                    style: TextStyle(
                        fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                ],
              )
          ],
          // Check task status first
          if (task.downloadStatus == WorkStatus.paused) ...[
            _buildMetaInternal(RI.RiPauseLine, l10n.actionPause, theme, isDark),
          ] else if (task.downloadStatus == WorkStatus.failed) ...[
            _buildMetaInternal(RI.RiAlertLine, l10n.error, theme, isDark),
          ] else if (task.downloadStatus == WorkStatus.cancelled) ...[
            _buildMetaInternal(RI.RiCloseLine, l10n.cancel, theme, isDark),
          ] else if (File(task.filePath ?? '').existsSync()) ...[
            _buildMetaInternal(RI.RiDownloadLine, l10n.downloaded, theme, isDark),
          ] else if (task.filePath != null) ...[
            _buildMetaInternal(RI.RiDeleteBinLine, l10n.deleted, theme, isDark),
          ],
      
          if (task.totalSize != null)
            _buildMetaInternal(RI.RiSdCardLine, task.totalSize!, theme, isDark),
          if (task.summary != null)
            _buildMetaInternal(RI.RiBardLine, l10n.summarized, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, DownloadTask task) {
    // For generic downloads, use file type icon
    if (task.category == TaskCategory.generic && task.thumbnail == null) {
      final fileInfo = _getFileTypeInfo(task.filePath ?? task.title);
      return SizedBox(
        width: 120,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
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
          ),
        ),
      );
    }

    // Standard video/thumbnail display
    return SizedBox(
      width: 120,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (task.thumbnail != null)
                Transform.scale(
                  scale: 1.01,
                  child: CachedNetworkImage(
                    imageUrl: task.thumbnail!,
                    filterQuality: FilterQuality.medium,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        _buildPlaceholder(Theme.of(context).colorScheme),
                  ),
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

  // Builds the speed history graph overlay (frosted glass effect)
  Widget _buildSpeedGraphOverlay(
      BuildContext context, Map<String, dynamic>? live) {
    final speedHistory = live?['speedHistory'];
    if (speedHistory == null ||
        speedHistory is! List ||
        speedHistory.length < 3) {
      return const SizedBox.shrink();
    }

    final List<double> history = speedHistory.cast<double>();
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 28,
        width: double.infinity,
        child: Stack(
          children: [
            Opacity(
              opacity: 0.2,
              child: CustomPaint(
                size: const Size(double.infinity, 28),
                painter: _SpeedHistoryPainter(
                  speeds: history,
                  lineColor: colorScheme.primary,
                  fillColor: colorScheme.primary.withOpacity(0.15),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: const SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws a smooth Bezier speed history line graph.
class _SpeedHistoryPainter extends CustomPainter {
  final List<double> speeds;
  final Color lineColor;
  final Color fillColor;

  _SpeedHistoryPainter({
    required this.speeds,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (speeds.length < 2) return;

    final maxSpeed = speeds.reduce(math.max);
    if (maxSpeed <= 0) return;

    final n = speeds.length;
    final dx = size.width / (n - 1);

    // Build list of points
    final points = <Offset>[];
    for (int i = 0; i < n; i++) {
      final x = i * dx;
      final y = size.height - (speeds[i] / maxSpeed) * size.height * 0.9;
      points.add(Offset(x, y.clamp(0, size.height)));
    }

    // Draw smooth Bezier path
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = (i + 2 < points.length) ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // Fill area under curve
    final fillPath = Path.from(linePath);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpeedHistoryPainter oldDelegate) {
    return speeds.length != oldDelegate.speeds.length ||
        (speeds.isNotEmpty &&
            oldDelegate.speeds.isNotEmpty &&
            speeds.last != oldDelegate.speeds.last);
  }
}
