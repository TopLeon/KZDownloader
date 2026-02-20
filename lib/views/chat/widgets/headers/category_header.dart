import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/views/widgets/add_url_dialog.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/views/chat/widgets/window_button.dart';
import 'package:window_manager/window_manager.dart';

class CategoryHeader extends ConsumerStatefulWidget {
  final TaskCategory category;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<DownloadTask>? onTaskAdded;

  const CategoryHeader({
    super.key,
    required this.category,
    this.onSearchChanged,
    this.onTaskAdded,
  });

  @override
  ConsumerState<CategoryHeader> createState() => _CategoryHeaderNewState();
}

class _CategoryHeaderNewState extends ConsumerState<CategoryHeader> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.category == TaskCategory.home) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return DragToMoveArea(
      child: Container(
        padding:
            const EdgeInsets.only(left: 20, right: 16, top: 10, bottom: 10),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: colorScheme.primary.withOpacity(0.15))),
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        ),
        child: Row(
          children: [
            // Search Bar
            Expanded(
              child: Container(
                height: 36,
                padding: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: colorScheme.primary.withOpacity(0.15)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                  cursorHeight: 14,
                  onChanged: widget.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: _buildPrompt(context, widget.category),
                    hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.9)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.9),
                      size: 18,
                    ),
                    border: InputBorder.none,
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Add URL Button
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.tertiary,
                border:
                    Border.all(color: colorScheme.primary.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final result = await showAddUrlDialog(
                      context,
                      category: widget.category,
                    );

                    if (result != null && context.mounted) {
                      final newTask = (await ref
                          .read(downloadListProvider.notifier)
                          .addTask(
                            result['url'],
                            result['provider'],
                            quality: result['quality'],
                            isAudio: result['isAudio'],
                            onlySummary: result['summarizeOnly'],
                          ))!;

                      widget.onTaskAdded?.call(newTask);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.add_link,
                            color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.btnAddUrl,
                          style: GoogleFonts.montserrat(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Window Control Buttons (Windows & Linux only)
            if (!Platform.isMacOS) ...[
              const SizedBox(width: 16),
              Row(
                children: [
                  WindowButton(
                    icon: Icons.remove,
                    onPressed: () => windowManager.minimize(),
                  ),
                  const SizedBox(width: 2),
                  WindowButton(
                    icon: Icons.crop_square,
                    onPressed: () async {
                      if (await windowManager.isMaximized()) {
                        windowManager.unmaximize();
                      } else {
                        windowManager.maximize();
                      }
                    },
                  ),
                  const SizedBox(width: 2),
                  WindowButton(
                    icon: Icons.close,
                    isClose: true,
                    onPressed: () => windowManager.close(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _buildPrompt(BuildContext context, TaskCategory category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case TaskCategory.music:
        return l10n.searchPromptMusic;
      case TaskCategory.video:
        return l10n.searchPromptVideo;
      case TaskCategory.playlist:
        return l10n.searchPromptPlaylist;
      case TaskCategory.generic:
        return l10n.searchPromptGeneric;
      default:
        return l10n.searchPromptDefault;
    }
  }
}
