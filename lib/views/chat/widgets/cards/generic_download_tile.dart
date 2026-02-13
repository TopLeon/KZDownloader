import 'package:flutter/material.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:open_file/open_file.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';

class GenericDownloadTile extends StatelessWidget {
  final DownloadTask task;
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  const GenericDownloadTile(
      {super.key, required this.task, this.onPause, this.onResume});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.status == 'paused'
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(task.title ?? ''),
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),

          // Info and Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File Name
                Text(
                  task.title ?? AppLocalizations.of(context)!.unknownFile,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),

                // Thin Progress Bar
                if (task.status == 'downloading')
                  LinearProgressIndicator(
                    value: task.progress / 100,
                    borderRadius: BorderRadius.circular(2),
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    minHeight: 4,
                  ),

                // Metadata (Size • Speed)
                if (task.status != 'downloading')
                  Text(
                    "${task.totalSize} • ${task.status}",
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Compact Actions
          _buildActionData(context),
        ],
      ),
    );
  }

  IconData _getFileIcon(String filename) {
    if (filename.endsWith('.zip')) return Icons.folder_zip;
    if (filename.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (filename.endsWith('.exe') || filename.endsWith('.dmg')) {
      return Icons.apps;
    }
    return Icons.insert_drive_file;
  }

  Widget _buildActionData(BuildContext context) {
    if (task.status == 'completed') {
      return IconButton(
        icon: const FIcon(RI.RiFolderOpenLine),
        onPressed: () {
          OpenFile.open(task.dirPath);
        },
      );
    } else {
      return IconButton(
        icon: FIcon(
            task.status == 'downloading' ? RI.RiPauseLine : RI.RiPlayLine),
        onPressed: task.status == 'downloading' ? onPause : onResume,
      );
    }
  }
}
