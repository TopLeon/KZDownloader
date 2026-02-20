import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/views/chat/providers/video_chat_provider.dart';
import 'package:kzdownloader/views/chat/widgets/cards/download_card.dart';
import 'package:kzdownloader/views/chat/widgets/cards/playlist_card.dart'
    as ytplaylist;
import 'package:kzdownloader/views/chat/widgets/header.dart';
import 'package:kzdownloader/views/chat/widgets/headers/category_header.dart';
import 'package:kzdownloader/views/chat/widgets/media_detail_pane.dart';
import 'package:kzdownloader/views/chat/widgets/playlist_detail_pane.dart'
    as ytplaylistdetail;
import 'package:kzdownloader/views/chat/widgets/video_qna_view.dart';
import 'package:kzdownloader/views/chat/screens/sort_options.dart';

class ContentListScreen extends ConsumerStatefulWidget {
  final TaskCategory? category;
  final String searchQuery;
  final SortOption selectedSortOption;
  final DownloadTask? selectedTask;
  final Function(String) onSearchChanged;
  final Function(SortOption) onSortChanged;
  final Function(DownloadTask) onTaskSelected;
  final VoidCallback? onExpandSummary;
  final VoidCallback? onChatPressed;

  const ContentListScreen({
    super.key,
    required this.category,
    required this.searchQuery,
    required this.selectedSortOption,
    this.selectedTask,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onTaskSelected,
    this.onExpandSummary,
    this.onChatPressed,
  });

  @override
  ConsumerState<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends ConsumerState<ContentListScreen> {
  bool _showQnAPanel = false;
  bool _startQnAWithChat = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final downloadListAsync = ref.watch(downloadListProvider);

    return downloadListAsync.when(
      data: (allTasks) {
        final tasks = _sortTasks(
            _filterTasks(allTasks, widget.category, widget.searchQuery),
            widget.selectedSortOption);

        final groupedItems = <dynamic>[];
        if (tasks.isNotEmpty) {
          String? lastDate;
          for (var task in tasks) {
            final dateStr =
                DateFormat.yMMMMd(Localizations.localeOf(context).toString())
                    .format(task.createdAt);
            if (lastDate != dateStr) {
              groupedItems.add(dateStr);
              lastDate = dateStr;
            }
            groupedItems.add(task);
          }
        }

        // Different layout for macOS vs Windows/Linux
        if (Platform.isMacOS) {
          // macOS: CategoryHeader inside left column
          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CategoryHeader(
                      category: widget.category ?? TaskCategory.generic,
                      onSearchChanged: widget.onSearchChanged,
                      onTaskAdded: widget.onTaskSelected,
                    ),
                    Expanded(
                      child: tasks.isEmpty
                          ? Center(
                              child: Text(
                              l10n.noResultsFound,
                              style: const TextStyle(fontSize: 14),
                            ))
                          : ListView(
                              shrinkWrap: true,
                              children: [
                                _buildSectionHeader(colorScheme, l10n),
                                _buildTaskList(groupedItems, colorScheme, l10n),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
              _buildDetailPane(allTasks, l10n),
            ],
          );
        } else {
          // Windows/Linux: CategoryHeader on top, panes below it
          return Column(
            children: [
              CategoryHeader(
                category: widget.category ?? TaskCategory.generic,
                onSearchChanged: widget.onSearchChanged,
                onTaskAdded: widget.onTaskSelected,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: tasks.isEmpty
                          ? Center(
                              child: Text(
                              l10n.noResultsFound,
                              style: const TextStyle(fontSize: 14),
                            ))
                          : ListView(
                              children: [
                                _buildSectionHeader(colorScheme, l10n),
                                _buildTaskList(groupedItems, colorScheme, l10n),
                              ],
                            ),
                    ),
                    _buildDetailPane(allTasks, l10n),
                  ],
                ),
              ),
            ],
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('${l10n.errorPrefix}$err')),
    );
  }

  Widget _buildSectionHeader(ColorScheme colorScheme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: SectionHeader(
                title: _getSectionTitle(widget.category, l10n),
                icon: _getSectionIcon(widget.category)),
          ),
          Positioned(
              right: 0,
              top: 16,
              child: SizedBox(
                width: 155,
                child: CustomDropdown<SortOption>(
                  hintText: getSortOptionLabel(widget.selectedSortOption, l10n),
                  items: getAvailableSortOptionsForCategory(widget.category),
                  closedHeaderPadding:
                      const EdgeInsets.only(top: 4, bottom: 4, right: 4),
                  expandedHeaderPadding:
                      const EdgeInsets.only(top: 4, bottom: 4, right: 4),
                  initialItem: widget.selectedSortOption,
                  decoration: CustomDropdownDecoration(
                    closedFillColor: Colors.transparent,
                    expandedFillColor: colorScheme.surface,
                    closedBorderRadius: BorderRadius.circular(8),
                    expandedBorderRadius: BorderRadius.circular(8),
                    expandedBorder: Border.all(
                      color: colorScheme.primary.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  listItemBuilder: (context, item, isSelected, onItemSelect) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        getSortOptionLabel(item, l10n),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                  headerBuilder: (context, selectedItem, isOpen) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getSortOptionIcon(selectedItem),
                            size: 18,
                            color: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            getSortOptionLabel(selectedItem, l10n),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onChanged: (value) {
                    if (value != null) {
                      widget.onSortChanged(value);
                    }
                  },
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildTaskList(List<dynamic> groupedItems, ColorScheme colorScheme,
      AppLocalizations l10n) {
    return ListView.builder(
      key: ValueKey('task_list_${groupedItems.length}'),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 16),
      itemCount: groupedItems.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index >= groupedItems.length) {
          return const SizedBox.shrink();
        }
        final item = groupedItems[index];

        if (item is String) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            child: Row(
              children: [
                Text(
                  item,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Divider(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        } else if (item is DownloadTask) {
          final task = item;
          final isSelected = widget.selectedTask?.id == task.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: task.isPlaylistContainer
                ? ytplaylist.YouTubePlaylistCard(
                    playlist: task,
                    isSelected: isSelected,
                    onTap: () => widget.onTaskSelected(task),
                  )
                : InkWell(
                    onTap: () {
                      ref.read(videoChatProvider.notifier).selectVideo(task);
                      widget.onTaskSelected(task);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: DownloadCard(
                      task: task,
                      hideActions: true,
                      isSelected: isSelected,
                    ),
                  ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDetailPane(List<DownloadTask> allTasks, AppLocalizations l10n) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: widget.selectedTask != null
          ? (_showQnAPanel
              ? _buildQnAPanel(l10n)
              : _buildTaskDetailPane(allTasks, l10n))
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }

  Widget _buildQnAPanel(AppLocalizations l10n) {
    return Container(
      key: const ValueKey('qna_panel'),
      width: MediaQuery.of(context).size.width * 0.35 < 600
          ? MediaQuery.of(context).size.width * 0.35
          : 600,
      decoration: BoxDecoration(
        border: Border(
            left: BorderSide(
                color:
                    Theme.of(context).colorScheme.primary.withOpacity(0.15))),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        children: [
          Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _showQnAPanel = false),
                  tooltip: l10n.btnBackToDetails,
                ),
                const SizedBox(width: 8),
                Text(
                    _startQnAWithChat ? l10n.chatWithVideo : l10n.videoAnalysis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: VideoQnAView(
              startWithChat: _startQnAWithChat,
              task: widget.selectedTask!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetailPane(
      List<DownloadTask> allTasks, AppLocalizations l10n) {
    if (widget.selectedTask!.isPlaylistContainer) {
      return ytplaylistdetail.YouTubePlaylistDetailPane(
        key: ValueKey('playlist_${widget.selectedTask!.id}'),
        playlist: widget.selectedTask!,
      );
    }

    return MediaDetailPane(
      key: ValueKey('detail_${widget.selectedTask!.id}'),
      task: allTasks.firstWhere((t) => t.id == widget.selectedTask!.id,
          orElse: () => widget.selectedTask!),
      onExpandSummary: () {
        setState(() {
          _showQnAPanel = true;
          _startQnAWithChat = false;
        });
      },
      onChatPressed: () {
        setState(() {
          _showQnAPanel = true;
          _startQnAWithChat = true;
        });
      },
    );
  }

  List<DownloadTask> _filterTasks(
      List<DownloadTask> allTasks, TaskCategory? category, String searchQuery) {
    final tasksWithoutChildren =
        allTasks.where((t) => t.playlistParentId == null).toList();

    return tasksWithoutChildren.where((t) {
      if (category != null) {
        if (category == TaskCategory.inprogress) {
          return t.downloadStatus == WorkStatus.running &&
                  t.playlistParentId == null ||
              t.summaryStatus.isActive;
        } else if (category == TaskCategory.failed) {
          return t.downloadStatus == WorkStatus.failed;
        } else if (category == TaskCategory.home) {
          return false;
        } else {
          if (t.category != category && category != TaskCategory.summary) {
            return false;
          }
          if (category == TaskCategory.summary &&
              (t.summary == null || t.summary!.isEmpty)) {
            return false;
          }
        }
      }

      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final title = t.title?.toLowerCase() ?? '';
        return title.contains(query);
      }
      return true;
    }).toList();
  }

  String _getSectionTitle(TaskCategory? category, AppLocalizations l10n) {
    switch (category) {
      case TaskCategory.video:
        return l10n.videoSection;
      case TaskCategory.generic:
        return l10n.genericSection;
      case TaskCategory.inprogress:
        return l10n.inprogressSection;
      case TaskCategory.failed:
        return l10n.failedSection;
      case TaskCategory.summary:
        return l10n.summarySection;
      case TaskCategory.playlist:
        return l10n.playlistSection;
      default:
        return l10n.videoSection;
    }
  }

  IconData _getSectionIcon(TaskCategory? category) {
    switch (category) {
      case TaskCategory.video:
        return Icons.video_library;
      case TaskCategory.generic:
        return Icons.file_download;
      case TaskCategory.inprogress:
        return Icons.downloading;
      case TaskCategory.failed:
        return Icons.error_outline;
      case TaskCategory.summary:
        return Icons.auto_awesome;
      case TaskCategory.playlist:
        return Icons.playlist_play;
      default:
        return Icons.video_library;
    }
  }

  List<DownloadTask> _sortTasks(List<DownloadTask> tasks, SortOption option) {
    final sortedTasks = List<DownloadTask>.from(tasks);

    switch (option) {
      case SortOption.recent:
        sortedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.downloaded:
        sortedTasks.sort((a, b) {
          final aCompleted = a.downloadStatus.isSuccess ? 1 : 0;
          final bCompleted = b.downloadStatus.isSuccess ? 1 : 0;
          if (aCompleted != bCompleted) {
            return bCompleted.compareTo(aCompleted);
          }
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      case SortOption.summaries:
        sortedTasks.sort((a, b) {
          final aHasSummary =
              (a.summary != null && a.summary!.trim().isNotEmpty) ? 1 : 0;
          final bHasSummary =
              (b.summary != null && b.summary!.trim().isNotEmpty) ? 1 : 0;
          if (aHasSummary != bHasSummary) {
            return bHasSummary.compareTo(aHasSummary);
          }
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      case SortOption.playlists:
        sortedTasks.sort((a, b) {
          final aIsPlaylist = a.isPlaylistContainer ? 1 : 0;
          final bIsPlaylist = b.isPlaylistContainer ? 1 : 0;
          if (aIsPlaylist != bIsPlaylist) {
            return bIsPlaylist.compareTo(aIsPlaylist);
          }
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
    }

    return sortedTasks;
  }
}
