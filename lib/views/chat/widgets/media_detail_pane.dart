import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/views/chat/widgets/rainbow.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'dart:io';

import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:kzdownloader/views/widgets/confirm_dialog.dart';

class MediaDetailPane extends ConsumerStatefulWidget {
  const MediaDetailPane(
      {super.key,
      required this.task,
      this.onChatPressed,
      this.onClose,
      this.onExpandSummary});
  final DownloadTask task;
  final VoidCallback? onChatPressed;
  final VoidCallback? onClose;
  final VoidCallback? onExpandSummary;

  @override
  ConsumerState<MediaDetailPane> createState() => MediaDetailPaneState();
}

class MediaDetailPaneState extends ConsumerState<MediaDetailPane> {
  late DownloadTask task;
  late VoidCallback? onChatPressed;
  late VoidCallback? onClose;
  late VoidCallback? onExpandSummary;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    task = widget.task;
    onChatPressed = widget.onChatPressed;
    onClose = widget.onClose;
    onExpandSummary = widget.onExpandSummary;
  }

  @override
  void didUpdateWidget(covariant MediaDetailPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always update the task to ensure we have the latest data.
    task = widget.task;
    onChatPressed = widget.onChatPressed;
    onClose = widget.onClose;
    onExpandSummary = widget.onExpandSummary;
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

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: task.summary ?? ''));
    setState(() {
      _isCopied = true;
    });

    // Haptic feedback (optional but nice)
    HapticFeedback.lightImpact();

    // Reset icon after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final borderColor = Theme.of(context).colorScheme.primary.withOpacity(0.15);
    final primaryColor = colorScheme.primary;

    final bool fileExists =
        task.filePath != null && File(task.filePath!).existsSync();
    final bool isCompleted = task.status == 'completed';
    final bool hasSummary = task.summary != null && task.summary!.isNotEmpty;
    bool isYt = false;
    if (task.provider == 'yt-dlp') {
      isYt = true;
    } else {
      isYt = task.url.contains('youtube') || task.url.contains('youtu.be');
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(left: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              children: [
                _buildHeader(context, isDark, fileExists, hasSummary),
                const SizedBox(height: 16),
                _buildTitleSection(context, theme, primaryColor),
                const SizedBox(height: 12),
                _buildMetadataChips(
                    context, theme, isDark, fileExists, hasSummary),
                const SizedBox(height: 16),
                _buildMainActions(context, ref, fileExists, isCompleted,
                    primaryColor, borderColor),
                const SizedBox(height: 10),
                Divider(color: borderColor),
                const SizedBox(height: 10),
                if (!isYt) ...[
                  _buildInfoHeader(context, isDark),
                  const SizedBox(height: 12),
                  _buildInfoCard(context, theme, isDark, fileExists),
                  const SizedBox(height: 16),
                  Divider(color: borderColor),
                  const SizedBox(height: 2),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        l10n.aiFeatureYouTubeOnly,
                        style: TextStyle(color: theme.hintColor, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                if (isYt) ...[
                  _buildAIHeader(context, isDark),
                  const SizedBox(height: 12),
                  _buildSummaryCard(context, ref, isDark, hasSummary),
                  const SizedBox(height: 12),
                  _buildChatButton(context, hasSummary),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          _buildFooter(context, ref, borderColor),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDark, bool fileExists, bool hasSummary) {
    // For generic downloads, use file type icon with gradient
    if (task.category == TaskCategory.generic && task.thumbnail == null) {
      final fileInfo = _getFileTypeInfo(task.filePath ?? task.title);
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (fileInfo['color'] as Color).withOpacity(0.2),
                (fileInfo['color'] as Color).withOpacity(0.4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: FIcon(
              fileInfo['icon'],
              color: fileInfo['color'],
              size: 80,
            ),
          ),
        ),
      );
    }

    // Standard video/thumbnail display
    return LayoutBuilder(builder: (context, constraints) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
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
              children: [
                (task.thumbnail != null)
                    ? Image.network(
                        task.thumbnail!,
                        fit: BoxFit.fitWidth,
                        width: constraints.maxWidth,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(Theme.of(context).colorScheme),
                      )
                    : _buildPlaceholder(Theme.of(context).colorScheme),
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
    });
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.1)
          : colorScheme.surfaceContainerHighest,
      child: Center(
        child: FIcon(
          RI.RiVideoOnLine,
          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildTitleSection(
      BuildContext context, ThemeData theme, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          task.title ?? AppLocalizations.of(context)!.untitled,
          style: GoogleFonts.montserrat(
              fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
        ),
        if (task.channelName != null)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              task.channelName!,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: primaryColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  Widget _buildMetadataChips(BuildContext context, ThemeData theme, bool isDark,
      bool fileExists, bool hasSummary) {
    var l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildMetaInternal(
            RI.RiCalendarLine,
            DateFormat(
                    'dd MMM yyyy', Localizations.localeOf(context).toString())
                .format(task.createdAt),
            theme,
            isDark),
        if (task.totalSize != null) ...[
          if (File(task.filePath ?? '').existsSync()) ...[
            _buildMetaInternal(
                RI.RiDownloadLine, l10n.downloaded, theme, isDark),
          ] else ...[
            _buildMetaInternal(RI.RiDeleteBinLine, l10n.deleted, theme, isDark),
          ],
          _buildMetaInternal(RI.RiSdCardLine, task.totalSize!, theme, isDark),
        ]
      ],
    );
  }

  Widget _buildMetaInternal(
      FIconObject icon, String text, ThemeData theme, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FIcon(icon, size: 14, color: theme.hintColor),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: theme.hintColor)),
      ],
    );
  }

  Widget _buildMainActions(BuildContext context, WidgetRef ref, bool fileExists,
      bool isCompleted, Color primary, Color borderColor) {
    // Disabled until download is complete.
    final canPlay = isCompleted && fileExists;
    final l10n = AppLocalizations.of(context)!;

    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: (!fileExists)
              ? () {
                  ref
                      .read(downloadListProvider.notifier)
                      .retryDownload(task.id);
                }
              : null,
          icon: FIcon(
            RI.RiDownloadFill,
            color: fileExists
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.38)
                : null,
          ),
          label: Text(l10n.modeDownload),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor:
                (!fileExists) ? Theme.of(context).colorScheme.tertiary : null,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: BorderSide(color: borderColor),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: canPlay ? () => _playFile() : null,
          icon: FIcon(
            task.category == TaskCategory.video
                ? RI.RiPlayFill
                : RI.RiExternalLinkLine,
            color: !canPlay
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.38)
                : null,
          ),
          label: Text(task.category == TaskCategory.video
              ? l10n.play
              : l10n.actionOpen),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor:
                canPlay ? Theme.of(context).colorScheme.tertiary : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(color: borderColor),
          ),
        ),
      ),
      const SizedBox(width: 12),
      InkWell(
        onTap: (task.dirPath != null && fileExists)
            ? () {
                OpenFile.open(task.dirPath);
              }
            : null,
        child: Container(
            width: 34,
            height: 34,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (task.dirPath != null && fileExists)
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: FIcon(RI.RiFolderOpenLine,
                color: (task.dirPath != null && fileExists)
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.38))),
      ),
    ]);
  }

  Widget _buildInfoHeader(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FIcon(RI.RiInformationLine,
                color: Theme.of(context).colorScheme.primary, size: 17),
            const SizedBox(width: 8),
            Text(
              l10n.downloadInfo,
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      BuildContext context, ThemeData theme, bool isDark, bool fileExists) {
    final l10n = AppLocalizations.of(context)!;
    final fileInfo = _getFileTypeInfo(task.filePath ?? task.title);
    final extension = task.filePath != null
        ? path.extension(task.filePath!).toUpperCase().replaceFirst('.', '')
        : l10n.unknown;

    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.tertiary,
        border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            RI.RiFileTextLine,
            l10n.fileType,
            extension,
            fileInfo['color'] as Color,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            RI.RiTimeLine,
            l10n.downloadTime,
            task.completedAt != null
                ? _calculateLocalizedProcessTime(
                    task.startedAt ?? task.createdAt,
                    task.completedAt!,
                    context)
                : task.processTime ?? l10n.unknown,
            theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          if (task.downloadSpeed != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              RI.RiSpeedLine,
              l10n.avgSpeed,
              task.downloadSpeed!,
              theme.colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, FIconObject icon, String label,
      String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
          ),
          child: FIcon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _calculateLocalizedProcessTime(
      DateTime startTime, DateTime endTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final duration = endTime.difference(startTime);

    if (duration.isNegative) {
      return l10n.unknown;
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final milliseconds = duration.inMilliseconds.remainder(1000);

    if (hours > 0) {
      final hStr = "$hours ${hours == 1 ? l10n.hour : l10n.hours}";
      final mStr = "$minutes ${minutes == 1 ? l10n.minute : l10n.minutes}";
      return minutes > 0 ? "$hStr ${l10n.and} $mStr" : hStr;
    } else if (minutes > 0) {
      final mStr = "$minutes ${minutes == 1 ? l10n.minute : l10n.minutes}";
      final sStr = "$seconds ${seconds == 1 ? l10n.second : l10n.seconds}";
      return seconds > 0 ? "$mStr ${l10n.and} $sStr" : mStr;
    } else if (seconds > 0) {
      return "$seconds ${seconds == 1 ? l10n.second : l10n.seconds}";
    } else {
      // Show milliseconds when less than 1 second
      return "$milliseconds ${milliseconds == 1 ? l10n.millisecond : l10n.milliseconds}";
    }
  }

  Widget _buildAIHeader(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FIcon(RI.RiSparklingFill,
                color: Theme.of(context).colorScheme.primary, size: 17),
            const SizedBox(width: 8),
            Text(
              l10n.aiInsights,
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                width: 1),
          ),
          child: Text(l10n.beta,
              style:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, WidgetRef ref, bool isDark, bool hasSummary) {
    final theme = Theme.of(context);
    final isGenerating = task.status == 'summarizing';
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.tertiary,
        border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l10n.executiveSummary,
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const Spacer(),
              if (hasSummary && !isGenerating) ...[
                Tooltip(
                  message: l10n.actionCopy,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _copyToClipboard,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: null,
                        child: FIcon(
                          _isCopied ? RI.RiCheckLine : RI.RiFileCopyLine,
                          size: 16,
                          color: _isCopied
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isCopied) ...[
                  Text(
                    l10n.statusCopied,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                ]
              ]
            ],
          ),
          SizedBox(height: (isGenerating) ? 8 : 0),
          if (hasSummary && !isGenerating) ...[
            Text(
              task.summary ?? l10n.noSummaryAvailable,
              maxLines: 3,
              style: GoogleFonts.montserrat(
                  fontSize: 13, color: theme.colorScheme.primary),
            ),
          ] else if (isGenerating)
            Row(
              children: [
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 8),
                Text(l10n.generating, style: const TextStyle(fontSize: 13)),
              ],
            )
          else
            Text(
              l10n.noSummaryAvailable,
              style: TextStyle(fontSize: 13, color: theme.hintColor),
            ),
          if (!hasSummary && !isGenerating)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                    onTap: () {
                      ref
                          .read(downloadListProvider.notifier)
                          .generateSummary(task);
                    },
                    child: AiButton(
                        text: l10n.generateAiSummary,
                        icon: RI.RiSparklingFill)),
              ),
            ),
          if (hasSummary && !isGenerating)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: InkWell(
                onTap: hasSummary ? onExpandSummary : null,
                child: Text(l10n.showAll,
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline)),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildChatButton(BuildContext context, bool enabled) {
    final theme = Theme.of(context);
    final color = enabled ? Theme.of(context).colorScheme.primary : Colors.grey;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: enabled ? onChatPressed : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.15), width: 1),
              ),
              child: Icon(Icons.chat_bubble_outline, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chatWithVideo,
                  style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? theme.textTheme.bodyLarge?.color
                          : theme.disabledColor),
                ),
                if (!enabled)
                  Text(l10n.generateSummaryFirst,
                      style:
                          TextStyle(fontSize: 10, color: theme.disabledColor)),
              ],
            ),
            const Spacer(),
            if (enabled)
              Icon(Icons.chevron_right, size: 20, color: theme.hintColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, Color borderColor) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () {
              showConfirmDialog(
                context,
                title: l10n.deleteTaskTitle,
                content: l10n.deleteTaskConfirmation,
                onConfirm: () {
                  ref.read(downloadListProvider.notifier).deleteTask(task.id);
                  if (widget.onClose != null) widget.onClose!();
                },
              );
            },
            icon: FIcon(
              RI.RiDeleteBinLine,
              size: 18,
              color: Theme.of(context).colorScheme.error,
            ),
            label: Text(l10n.actionDelete),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
          ),
          if (task.summary != null)
            TextButton.icon(
              onPressed: () {
                ref.read(downloadListProvider.notifier).regenerateSummary(task);
              },
              icon: const FIcon(
                RI.RiRefreshLine,
                size: 18,
                color: Colors.blueAccent,
              ),
              label: Text(l10n.regenerate),
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
            ),
        ],
      ),
    );
  }

  void _playFile() {
    if (task.filePath != null) {
      OpenFile.open(task.filePath!);
    }
  }
}
