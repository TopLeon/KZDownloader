import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/core/utils/download_helper.dart';
import 'package:kzdownloader/core/services/memory_service.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';

class DownloadStatusWidget extends ConsumerWidget {
  final bool isMinimized;

  const DownloadStatusWidget({
    super.key,
    this.isMinimized = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(globalDownloadStatusProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (!status.hasActiveOrPaused) return const SizedBox.shrink();

    if (isMinimized) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Tooltip(
          message: status.allPaused
              ? l10n.pausedDownloads
              : l10n.activeDownloadsCount(status.totalActive.toString()),
          child: InkWell(
            onTap: () => ref
                .read(selectedCategoryProvider.notifier)
                .setCategory(TaskCategory.inprogress),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: status.allPaused
                        ? 0.0
                        : status.overallProgress.clamp(0.0, 1.0),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: colorScheme.primary,
                    strokeWidth: 2,
                  ),
                  FIcon(
                    status.allPaused
                        ? RI.RiPauseCircleLine
                        : RI.RiDownloadCloudLine,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Live speed aggregation
    final progressMap = ref.watch(activeDownloadProgressProvider);
    final speedStrings = progressMap.values
        .map((e) => e['downloadSpeed'] as String?)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toList();
    final speedDisplay = speedStrings.isEmpty
        ? null
        : speedStrings.length == 1
            ? speedStrings.first
            : DownloadHelper.formatBytes(
                speedStrings
                    .map(_parseSpeedToBytes)
                    .fold<double>(0, (a, b) => a + b)
                    .toInt(),
              ) +
                '/s';

    // RAM monitoring
    final memoryAsync = ref.watch(memoryUsageProvider);
    final memoryService = ref.watch(memoryServiceProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FIcon(
                  status.allPaused
                      ? RI.RiPauseCircleLine
                      : RI.RiDownloadCloudLine,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.allPaused
                          ? l10n.pausedDownloads
                          : (status.totalActive == 1
                              ? l10n
                                  .singleDownload(status.totalActive.toString())
                              : l10n.activeDownloadsCount(
                                  status.totalActive.toString())),
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status.allPaused
                          ? '--'
                          : l10n.downloadProgress((status.overallProgress * 100)
                              .toStringAsFixed(1)),
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: FAProgressBar(
              currentValue: status.allPaused
                  ? 0.0 * 100
                  : status.overallProgress.clamp(0.0, 1.0) * 100,
              size: 3,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              progressColor: colorScheme.primary,
            ),
          ),
          // Download speed display
          if (!status.allPaused && speedDisplay != null) ...[  
            const SizedBox(height: 8),
            Row(
              children: [
                FIcon(RI.RiSpeedLine,
                    size: 12,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(
                  speedDisplay,
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
          // RAM usage display
          const SizedBox(height: 8),
          memoryAsync.when(
            data: (mb) => Row(
              children: [
                FIcon(RI.RiCpuLine,
                    size: 12,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(
                  'RAM: $mb MB • Peak: ${memoryService.peakMb} MB',
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (status.allPaused)
                _buildActionButton(
                  icon: RI.RiPlayLine,
                  label: l10n.resumeAll,
                  color: colorScheme.primary,
                  onTap: () =>
                      ref.read(downloadListProvider.notifier).resumeAllTasks(),
                )
              else
                _buildActionButton(
                  icon: RI.RiPauseLine,
                  label: l10n.pauseAll,
                  color: colorScheme.onSurfaceVariant,
                  onTap: () =>
                      ref.read(downloadListProvider.notifier).pauseAllTasks(),
                ),
              Container(
                height: 16,
                width: 1,
                color: colorScheme.outlineVariant,
              ),
              _buildActionButton(
                icon: RI.RiCloseLine,
                label: l10n.cancelAll,
                color: colorScheme.error,
                onTap: () => _confirmCancelAll(context, ref, l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required FIconObject icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: FIcon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  /// Parses a formatted speed string like "10.50 MB/s" to bytes/sec.
  static double _parseSpeedToBytes(String s) {
    final clean = s.replaceFirst(RegExp(r'/s$'), '').trim();
    final parts = clean.split(' ');
    if (parts.length != 2) return 0;
    final value = double.tryParse(parts[0]) ?? 0;
    final unit = parts[1].toUpperCase();
    const units = {'B': 1, 'KB': 1024, 'MB': 1048576, 'GB': 1073741824};
    // also handle IEC units from yt-dlp (KiB, MiB, GiB)
    const iecUnits = {'KIB': 1024, 'MIB': 1048576, 'GIB': 1073741824};
    final multiplier =
        units[unit] ?? iecUnits[unit.replaceAll('I', '')] ?? 1;
    return value * multiplier;
  }

  Future<void> _confirmCancelAll(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(l10n.cancelAllConfirmTitle),
        content: Text(l10n.cancelAllConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.cancelAll),
          ),
        ],
      ),
    );

    if (result == true) {
      ref.read(downloadListProvider.notifier).cancelAllTasks();
    }
  }
}
