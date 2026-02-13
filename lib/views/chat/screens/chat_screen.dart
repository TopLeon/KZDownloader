import 'dart:io';
import 'dart:ui' as ui;
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kzdownloader/core/providers/quality_provider.dart';
import 'package:kzdownloader/core/services/audio_player_service.dart';
import 'package:kzdownloader/core/services/llm_service.dart';
import 'package:kzdownloader/views/chat/providers/video_chat_provider.dart';
import 'package:kzdownloader/views/chat/widgets/audio_widgets.dart';
import 'package:kzdownloader/views/chat/widgets/header.dart';
import 'package:kzdownloader/views/chat/widgets/video_qna_view.dart';
import 'package:kzdownloader/views/widgets/confirm_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/rx.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/views/chat/widgets/cards/download_card.dart';
import 'package:kzdownloader/views/chat/widgets/cards/playlist_card.dart'
    as ytplaylist;
import 'package:kzdownloader/views/chat/widgets/sidebar.dart';
import 'package:kzdownloader/views/chat/widgets/input/chat_input_area.dart';
import 'package:kzdownloader/views/chat/widgets/headers/category_header.dart';
import 'package:kzdownloader/core/utils/utils.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/views/settings/screens/settings_screen.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/views/chat/widgets/media_detail_pane.dart';
import 'package:kzdownloader/core/download/providers/playlist_provider.dart';
import 'package:kzdownloader/models/playlist.dart';
import 'package:kzdownloader/views/chat/widgets/music_playlist_detail_pane.dart';
import 'package:kzdownloader/views/chat/widgets/playlist_detail_pane.dart'
    as ytplaylistdetail;
import 'package:kzdownloader/views/chat/widgets/window_button.dart';
import 'package:kzdownloader/views/chat/widgets/music_table_row.dart';

enum SortOption {
  recent,
  downloaded,
  summaries,
  playlists,
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with WindowListener {
  final TextEditingController _controller = TextEditingController();
  String _selectedProvider = 'Auto';
  static const String _aiModelKey = 'ai_selected_model';

  bool _showVideoOptions = false;
  bool _isAudio = false;

  String _searchQuery = '';
  SortOption _selectedSortOption = SortOption.recent;

  bool _isSidebarOpen = true;
  bool _isSummaryMode = false;
  bool _isPrefetchingMetadata = false;
  bool _metadataFetchCompleted = false;
  bool _showInitialAnimation = true;

  DownloadTask? _selectedTask;
  Playlist? _selectedPlaylist;
  bool _showQnAPanel = false;
  bool _startQnAWithChat = false;
  final ValueNotifier<Offset> _mousePosNotifier = ValueNotifier(Offset.zero);

  int? _lastSelectedVideoId;
  int? _lastSelectedGenericId;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkFirstRun();
      ref
          .read(selectedCategoryProvider.notifier)
          .setCategory(TaskCategory.home);
      final prefs = await SharedPreferences.getInstance();
      final savedModel = prefs.getString(_aiModelKey);
      if (savedModel != null) {
        LlmService().setModel(savedModel);
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showInitialAnimation = false;
          });
        }
      });
    });
  }

  void _onTextChanged() {
    final text = _controller.text;
    final provider = UrlUtils.detectProvider(text);
    setState(() {
      _showVideoOptions = provider == 'yt-dlp' && text.isNotEmpty;
    });
  }

  @override
  void onWindowClose() async {
    final tasks = await ref.read(downloadListProvider.future);
    for (var task in tasks) {
      if (task.status == 'downloading') {
        await ref.read(downloadListProvider.notifier).pauseTask(task.id);
      }
    }

    super.onWindowClose();
  }

  Future<void> _checkFirstRun() async {
    final settings = SettingsService();
    final path = await settings.getDownloadPath();
    if (path == null) {
      if (mounted) {
        _showOnboardingDialog();
      }
    }
  }

  void _showOnboardingDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.onboardingTitle),
        content: Text(
          l10n.onboardingContent,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: Text(l10n.btnGoSettings),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _mousePosNotifier.dispose();

    super.dispose();
  }

  Future<void> _handleAction() async {
    final url = _controller.text;
    if (url.isEmpty) return;

    bool shouldSummarize = _isSummaryMode;

    String provider = _selectedProvider;
    if (provider == 'Auto') {
      provider = UrlUtils.detectProvider(url);
    }

    // Get quality from provider
    final qualitySettings = await ref.read(qualitySettings_Provider.future);
    final String q = qualitySettings
        .toDisplayString()
        .toLowerCase()
        .replaceAll('best', 'best')
        .replaceAll('medium', 'medium')
        .replaceAll('low', 'low');

    final newTask = await ref.read(downloadListProvider.notifier).addTask(
          url,
          provider,
          quality: q,
          isAudio: _isAudio,
          summarize: shouldSummarize,
          onlySummary: _isSummaryMode,
          summaryType: 'short',
        );

    ref.read(selectedCategoryProvider.notifier).setCategory(newTask.category);
    setState(() {
      _isSummaryMode = false;
      _isAudio = false;
    });

    _controller.clear();

    ref.read(videoChatProvider.notifier).selectVideo(newTask);
    setState(() {
      _selectedTask = newTask;
      if (newTask.category == TaskCategory.video) {
        _lastSelectedVideoId = newTask.id;
      } else if (newTask.category == TaskCategory.generic) {
        _lastSelectedGenericId = newTask.id;
      }
    });
  }

  void _showCreatePlaylistDialog(WidgetRef ref) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    showConfirmDialog(context,
        title: l10n.newPlaylistTitle,
        content: l10n.playlistNameEditHint, onConfirm: () {
      if (controller.text.isNotEmpty) {
        ref.read(playlistListProvider.notifier).createPlaylist(controller.text);
      }
    },
        confirmText: l10n.btnCreate,
        cancelText: l10n.btnCancel,
        icon: Icons.playlist_add,
        iconColor: Colors.blueAccent,
        hasInput: true,
        inputController: controller);
  }

  @override
  Widget build(BuildContext context) {
    final downloadListAsync = ref.watch(downloadListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final qualitySettingsAsync = ref.watch(qualitySettings_Provider);
    final colorScheme = Theme.of(context).colorScheme;
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    ref.listen(selectedCategoryProvider, (previous, next) {
      if (previous != next) {
        setState(() {
          _searchQuery = '';
          if (_selectedTask == null || _selectedTask!.category != next) {
            _selectedTask = null;
          }

          if (next == TaskCategory.home) {
            _showInitialAnimation = true;
            _metadataFetchCompleted = false;
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _showInitialAnimation = false;
                });
              }
            });
          }

          if (next == TaskCategory.video) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_selectedTask != null &&
                  _selectedTask!.category == TaskCategory.video) {
                return;
              }

              final allTasks =
                  ref.read(downloadListProvider).asData?.value ?? [];
              final videoTasks = allTasks
                  .where((t) =>
                      t.category == TaskCategory.video &&
                      t.playlistParentId == null)
                  .toList();

              if (videoTasks.isNotEmpty) {
                DownloadTask? videoToSelect;

                if (_lastSelectedVideoId != null) {
                  videoToSelect = videoTasks.firstWhere(
                    (t) => t.id == _lastSelectedVideoId,
                    orElse: () => videoTasks.first,
                  );
                  if (videoToSelect.id != _lastSelectedVideoId) {
                    videoTasks
                        .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    videoToSelect = videoTasks.first;
                  }
                } else {
                  videoTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  videoToSelect = videoTasks.first;
                }

                setState(() {
                  _selectedTask = videoToSelect;
                });

                if (!videoToSelect.isPlaylistContainer) {
                  ref
                      .read(videoChatProvider.notifier)
                      .selectVideo(videoToSelect);
                }
              }
            });
          }

          if (next == TaskCategory.generic) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_selectedTask != null &&
                  _selectedTask!.category == TaskCategory.generic) {
                return;
              }

              final allTasks =
                  ref.read(downloadListProvider).asData?.value ?? [];
              final genericTasks = allTasks
                  .where((t) =>
                      t.category == TaskCategory.generic &&
                      t.playlistParentId == null)
                  .toList();

              if (genericTasks.isNotEmpty) {
                DownloadTask? taskToSelect;

                if (_lastSelectedGenericId != null) {
                  taskToSelect = genericTasks.firstWhere(
                    (t) => t.id == _lastSelectedGenericId,
                    orElse: () => genericTasks.first,
                  );
                  if (taskToSelect.id != _lastSelectedGenericId) {
                    genericTasks
                        .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    taskToSelect = genericTasks.first;
                  }
                } else {
                  genericTasks
                      .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  taskToSelect = genericTasks.first;
                }

                setState(() {
                  _selectedTask = taskToSelect;
                });
              }
            });
          }
        });
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: Platform.isMacOS
            ? BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(color: Theme.of(context).scaffoldBackgroundColor),
              Positioned.fill(
                child: Row(
                  children: [
                    Sidebar(
                      onNewDownload: () {},
                      onToggle: () =>
                          setState(() => _isSidebarOpen = !_isSidebarOpen),
                      isMinimized: !_isSidebarOpen,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              color: Colors.transparent,
                              child: _buildBodyContent(
                                  context,
                                  selectedCategory,
                                  downloadListAsync,
                                  isLightTheme,
                                  colorScheme,
                                  qualitySettingsAsync),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!Platform.isMacOS)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Row(
                    children: [
                      WindowButton(
                        icon: Icons.remove,
                        onPressed: () => windowManager.minimize(),
                      ),
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
                      WindowButton(
                        icon: Icons.close,
                        isClose: true,
                        onPressed: () => windowManager.close(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(
      BuildContext context,
      TaskCategory? selectedCategory,
      AsyncValue<List<DownloadTask>> downloadListAsync,
      bool isLightTheme,
      ColorScheme colorScheme,
      AsyncValue<QualitySettings> qualitySettingsAsync) {
    if (selectedCategory == TaskCategory.settings) {
      return const SettingsScreen();
    } else if (selectedCategory == TaskCategory.home) {
      return _buildHomeLayout(context, downloadListAsync, isLightTheme,
          colorScheme, qualitySettingsAsync);
    } else if (selectedCategory == TaskCategory.music) {
      return _buildMusicLayout(context, downloadListAsync);
    } else {
      return _buildUnifiedLayout(context, downloadListAsync);
    }
  }

  Widget _buildMusicLayout(
      BuildContext context, AsyncValue<List<DownloadTask>> downloadListAsync) {
    final colorScheme = Theme.of(context).colorScheme;
    final playlists = ref.watch(playlistListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        downloadListAsync.when(
          data: (allTasks) {
            final musicTasks = _sortTasks(
                filterMusicTasks(allTasks, _searchQuery), _selectedSortOption);

            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(
                  children: [
                    CategoryHeader(
                        category: TaskCategory.music,
                        onSearchChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        onTaskAdded: (newTask) {
                          if (!newTask.isPlaylistContainer) {
                            ref
                                .read(videoChatProvider.notifier)
                                .selectVideo(newTask);
                          }
                          setState(() {
                            _selectedTask = newTask;
                            if (newTask.category == TaskCategory.video) {
                              _lastSelectedVideoId = newTask.id;
                            } else if (newTask.category ==
                                TaskCategory.generic) {
                              _lastSelectedGenericId = newTask.id;
                            }
                          });
                        }),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
                            child: SectionHeader(
                                title: l10n.playlistSection,
                                icon: Icons.playlist_play),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 8),
                            child: SizedBox(
                              height: 110,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                children: [
                                  ...playlists.map((playlist) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16),
                                        child: PlaylistCard(
                                          playlist: playlist,
                                          onTap: () => setState(() =>
                                              _selectedPlaylist = playlist),
                                          gradientColors: [
                                            Color(playlist.gradientColor1),
                                            Color(playlist.gradientColor2),
                                          ],
                                        ),
                                      )),
                                  buildNewMixCard(
                                    context,
                                    colorScheme.primary,
                                    onTap: () => _showCreatePlaylistDialog(ref),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 24),
                                  child: SectionHeader(
                                      title: l10n.musicSection,
                                      icon: Icons.music_note),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 16,
                                  child: SizedBox(
                                    width: 150,
                                    child: CustomDropdown<SortOption>(
                                      hintText: _getSortOptionLabel(
                                          _selectedSortOption, l10n),
                                      items: SortOption.values,
                                      closedHeaderPadding:
                                          const EdgeInsets.only(
                                              top: 4, bottom: 4, right: 4),
                                      expandedHeaderPadding:
                                          const EdgeInsets.only(
                                              top: 4, bottom: 4, right: 4),
                                      initialItem: _selectedSortOption,
                                      decoration: CustomDropdownDecoration(
                                        closedFillColor: Colors.transparent,
                                        expandedFillColor: colorScheme.surface,
                                        closedBorderRadius:
                                            BorderRadius.circular(8),
                                        expandedBorderRadius:
                                            BorderRadius.circular(8),
                                        closedBorder: Border.all(
                                          color: colorScheme.outline
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                        expandedBorder: Border.all(
                                          color: colorScheme.primary
                                              .withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      listItemBuilder: (context, item,
                                          isSelected, onItemSelect) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                          child: Text(
                                            _getSortOptionLabel(item, l10n),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurface,
                                            ),
                                          ),
                                        );
                                      },
                                      headerBuilder:
                                          (context, selectedItem, isOpen) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          child: Row(
                                            children: [
                                              Icon(
                                                _getSortOptionIcon(
                                                    selectedItem),
                                                size: 18,
                                                color: colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _getSortOptionLabel(
                                                    selectedItem, l10n),
                                                style: TextStyle(
                                                  fontSize: 13,
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
                                          setState(() {
                                            _selectedSortOption = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 56,
                                  child: Text(
                                    '#',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    l10n.titleColumn,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    l10n.artistColumn,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    l10n.albumColumn,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    l10n.durationColumn,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    l10n.formatColumn,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          musicTasks.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 80),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FIcon(
                                          RI.RiMusicLine,
                                          size: 64,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          l10n.noMusicFound,
                                          style: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 4, 16, 100),
                                  itemCount: musicTasks.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final task = musicTasks[index];
                                    final audioState =
                                        ref.watch(audioStateProvider);
                                    final isPlaying =
                                        audioState.currentTaskId == task.id &&
                                            audioState.isPlaying;

                                    return MusicTableRow(
                                      index: index + 1,
                                      task: task,
                                      isPlaying: isPlaying,
                                      colorScheme: colorScheme,
                                      onTap: () {
                                        ref
                                            .read(audioStateProvider.notifier)
                                            .playAudio(
                                              task.filePath!,
                                              thumbnail: task.thumbnail,
                                              title: task.title,
                                              channel: task.channelName,
                                              taskId: task.id,
                                            );
                                      },
                                      onDelete: () {
                                        ref
                                            .read(downloadListProvider.notifier)
                                            .deleteTask(task.id);
                                      },
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                  width: _selectedPlaylist != null
                      ? MediaQuery.of(context).size.width * 0.3
                      : 0,
                  curve: Curves.decelerate,
                  duration: const Duration(milliseconds: 300),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _selectedPlaylist != null
                          ? PlaylistDetailPane(
                              playlist: _selectedPlaylist!,
                              onClose: () =>
                                  setState(() => _selectedPlaylist = null),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ))
            ]);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('${l10n.errorPrefix}$err')),
        ),
      ],
    );
  }

  Widget _buildUnifiedLayout(
      BuildContext context, AsyncValue<List<DownloadTask>> downloadListAsync) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return downloadListAsync.when(
      data: (allTasks) {
        final tasks = _sortTasks(_filterTasks(allTasks), _selectedSortOption);

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

        return Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  CategoryHeader(
                    category: ref.watch(selectedCategoryProvider) ??
                        TaskCategory.generic,
                    onSearchChanged: (val) =>
                        setState(() => _searchQuery = val),
                    onTaskAdded: (newTask) {
                      if (!newTask.isPlaylistContainer) {
                        ref
                            .read(videoChatProvider.notifier)
                            .selectVideo(newTask);
                      }
                      setState(() {
                        _selectedTask = newTask;
                        if (newTask.category == TaskCategory.video) {
                          _lastSelectedVideoId = newTask.id;
                        } else if (newTask.category == TaskCategory.generic) {
                          _lastSelectedGenericId = newTask.id;
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: tasks.isEmpty
                        ? Center(child: Text(l10n.noResultsFound))
                        : ListView(
                            shrinkWrap: true,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 24, right: 24, top: 0),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: SectionHeader(
                                          title: _getSectionTitle(
                                              selectedCategory, l10n),
                                          icon: _getSectionIcon(
                                              selectedCategory)),
                                    ),
                                    Positioned(
                                        right: 0,
                                        top: 16,
                                        child: SizedBox(
                                          width: 150,
                                          child: CustomDropdown<SortOption>(
                                            hintText: _getSortOptionLabel(
                                                _selectedSortOption, l10n),
                                            items: SortOption.values,
                                            closedHeaderPadding:
                                                const EdgeInsets.only(
                                                    top: 4,
                                                    bottom: 4,
                                                    right: 4),
                                            expandedHeaderPadding:
                                                const EdgeInsets.only(
                                                    top: 4,
                                                    bottom: 4,
                                                    right: 4),
                                            initialItem: _selectedSortOption,
                                            decoration:
                                                CustomDropdownDecoration(
                                              closedFillColor:
                                                  Colors.transparent,
                                              expandedFillColor:
                                                  colorScheme.surface,
                                              closedBorderRadius:
                                                  BorderRadius.circular(8),
                                              expandedBorderRadius:
                                                  BorderRadius.circular(8),
                                              expandedBorder: Border.all(
                                                color: colorScheme.primary
                                                    .withOpacity(0.15),
                                                width: 1,
                                              ),
                                            ),
                                            listItemBuilder: (context, item,
                                                isSelected, onItemSelect) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                child: Text(
                                                  _getSortOptionLabel(
                                                      item, l10n),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                    color: isSelected
                                                        ? colorScheme.primary
                                                        : colorScheme.onSurface,
                                                  ),
                                                ),
                                              );
                                            },
                                            headerBuilder: (context,
                                                selectedItem, isOpen) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _getSortOptionIcon(
                                                          selectedItem),
                                                      size: 18,
                                                      color:
                                                          colorScheme.onSurface,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      _getSortOptionLabel(
                                                          selectedItem, l10n),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _selectedSortOption = value;
                                                });
                                              }
                                            },
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              ListView.builder(
                                padding: const EdgeInsets.only(
                                    left: 24, right: 24, top: 0, bottom: 16),
                                itemCount: groupedItems.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final item = groupedItems[index];

                                  if (item is String) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 12),
                                      child: Row(
                                        children: [
                                          Text(
                                            item,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
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
                                    final isSelected =
                                        _selectedTask?.id == task.id;

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: task.isPlaylistContainer
                                          ? ytplaylist.YouTubePlaylistCard(
                                              playlist: task,
                                              isSelected: isSelected,
                                              onTap: () {
                                                setState(() {
                                                  _selectedTask = task;
                                                  if (selectedCategory ==
                                                      TaskCategory.video) {
                                                    _lastSelectedVideoId =
                                                        task.id;
                                                  }
                                                });
                                              },
                                            )
                                          : InkWell(
                                              onTap: () {
                                                ref
                                                    .read(videoChatProvider
                                                        .notifier)
                                                    .selectVideo(task);
                                                setState(() {
                                                  _selectedTask = task;
                                                  if (selectedCategory ==
                                                      TaskCategory.video) {
                                                    _lastSelectedVideoId =
                                                        task.id;
                                                  } else if (selectedCategory ==
                                                      TaskCategory.generic) {
                                                    _lastSelectedGenericId =
                                                        task.id;
                                                  }
                                                });
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(16),
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
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
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
              child: _selectedTask != null
                  ? (_showQnAPanel
                      ? Container(
                          key: const ValueKey('qna_panel'),
                          width: MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.15))),
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 66,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.15),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () =>
                                          setState(() => _showQnAPanel = false),
                                      tooltip: l10n.btnBackToDetails,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        _startQnAWithChat
                                            ? l10n.chatWithVideo
                                            : l10n.videoAnalysis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: VideoQnAView(
                                  startWithChat: _startQnAWithChat,
                                  task: _selectedTask!,
                                ),
                              ),
                            ],
                          ),
                        )
                      : (_selectedTask!.isPlaylistContainer
                          ? ytplaylistdetail.YouTubePlaylistDetailPane(
                              key: ValueKey('playlist_${_selectedTask!.id}'),
                              playlist: _selectedTask!)
                          : MediaDetailPane(
                              key: ValueKey('detail_${_selectedTask!.id}'),
                              task: allTasks.firstWhere(
                                  (t) => t.id == _selectedTask!.id,
                                  orElse: () => _selectedTask!),
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
                            )))
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('${l10n.errorPrefix}$err')),
    );
  }

  List<DownloadTask> _filterTasks(List<DownloadTask> allTasks) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final tasksWithoutChildren =
        allTasks.where((t) => t.playlistParentId == null).toList();

    return tasksWithoutChildren.where((t) {
      if (selectedCategory != null) {
        if (selectedCategory == TaskCategory.inprogress) {
          final inProgressStatuses = [
            'downloading',
            'pending',
            'summarizing',
            'paused',
            'converting'
          ];
          if (!inProgressStatuses.contains(t.status)) return false;
        } else if (selectedCategory == TaskCategory.failed) {
          final failedStatuses = ['error', 'cancelled'];
          if (!failedStatuses.contains(t.status)) return false;
        } else if (selectedCategory == TaskCategory.home) {
          return false;
        } else {
          if (t.category != selectedCategory &&
              selectedCategory != TaskCategory.summary) {
            return false;
          }
          if (selectedCategory == TaskCategory.summary &&
              (t.summary == null || t.summary!.isEmpty)) {
            return false;
          }
        }
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
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

  Widget _buildHomeLayout(
      BuildContext context,
      AsyncValue<List<DownloadTask>> downloadListAsync,
      bool isLightTheme,
      ColorScheme colorScheme,
      AsyncValue<QualitySettings> qualitySettingsAsync) {
    final size = MediaQuery.of(context).size;
    return MouseRegion(
      onHover: (event) {
        _mousePosNotifier.value = event.localPosition;
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: Stack(
                children: [
                  Positioned(
                    bottom: size.height * 0.15,
                    left: size.width * 0.15,
                    child: _buildGlowBlob(
                      color: const Color(0xFF3B82F6),
                      isLightTheme: isLightTheme,
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.15,
                    right: size.width * 0.15,
                    child: _buildGlowBlob(
                      color: const Color(0xFF06B6D4),
                      isLightTheme: isLightTheme,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.32),
                  Center(child: _buildBrandLogo(isLightTheme, colorScheme)),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          (!_showVideoOptions ? 0.075 : 0.05)),
                  Center(
                    child: SizedBox(
                      width: 620,
                      child: qualitySettingsAsync.when(
                        data: (qualitySettings) => ChatInputArea(
                          controller: _controller,
                          selectedProvider: _selectedProvider,
                          showVideoOptions: _showVideoOptions,
                          selectedQuality: qualitySettings.toDisplayString(),
                          isAudio: _isAudio,
                          summarizeOnly: _isSummaryMode,
                          isCentered: true,
                          qualityMode: qualitySettings.mode,
                          onSubmit: _handleAction,
                          onProviderChanged: (value) =>
                              setState(() => _selectedProvider = value),
                          onQualityChanged: (value) async {
                            // Convert display string back to quality enum
                            DownloadQuality newQuality;
                            if (qualitySettings.mode == QualityMode.simple) {
                              if (value == 'Best') {
                                newQuality = DownloadQuality.best;
                              } else if (value == 'Medium') {
                                newQuality = DownloadQuality.medium;
                              } else {
                                newQuality = DownloadQuality.low;
                              }
                            } else {
                              if (value == '1080p') {
                                newQuality = DownloadQuality.p1080;
                              } else if (value == '720p') {
                                newQuality = DownloadQuality.p720;
                              } else {
                                newQuality = DownloadQuality.p480;
                              }
                            }
                            await ref
                                .read(qualitySettings_Provider.notifier)
                                .setQuality(newQuality);
                          },
                          onIsAudioChanged: (value) {
                            setState(() {
                              _isAudio = value;
                            });
                          },
                          onSummarizeOnlyChanged: (value) =>
                              setState(() => _isSummaryMode = value),
                          onPrefetchStateChanged: (isPrefetching) {
                            setState(() {
                              if (isPrefetching) {
                                _isPrefetchingMetadata = true;
                                _metadataFetchCompleted = false;
                              } else {
                                _isPrefetchingMetadata = false;
                                _metadataFetchCompleted = false;
                              }
                            });
                          },
                          onMetadataFetched: () {
                            setState(() {
                              _metadataFetchCompleted = true;
                            });
                          },
                        ),
                        loading: () => ChatInputArea(
                          controller: _controller,
                          selectedProvider: _selectedProvider,
                          showVideoOptions: _showVideoOptions,
                          selectedQuality: 'Best',
                          isAudio: _isAudio,
                          summarizeOnly: _isSummaryMode,
                          isCentered: true,
                          qualityMode: QualityMode.simple,
                          onSubmit: _handleAction,
                          onProviderChanged: (value) => {},
                          onQualityChanged: (value) {},
                          onIsAudioChanged: (value) {},
                          onSummarizeOnlyChanged: (value) {},
                        ),
                        error: (_, __) => ChatInputArea(
                          controller: _controller,
                          selectedProvider: _selectedProvider,
                          showVideoOptions: _showVideoOptions,
                          selectedQuality: 'Best',
                          isAudio: _isAudio,
                          summarizeOnly: _isSummaryMode,
                          isCentered: true,
                          qualityMode: QualityMode.simple,
                          onSubmit: _handleAction,
                          onProviderChanged: (value) => {},
                          onQualityChanged: (value) {},
                          onIsAudioChanged: (value) {},
                          onSummarizeOnlyChanged: (value) {},
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: _buildStatusIndicator(colorScheme),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowBlob({required Color color, required bool isLightTheme}) {
    final opacity = isLightTheme ? 0.0 : 0.1;

    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: color.withOpacity(opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // Build brand logo widget
  Widget _buildBrandLogo(bool isLightTheme, ColorScheme colorScheme) {
    if (isLightTheme) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.075),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              )
            ]),
        child: Image.asset('assets/banner.png', height: 80),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 12,
          right: 20,
          left: 18,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: colorScheme.tertiary,
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              )
            ]),
        child: Image.asset('assets/logo.png', height: 50),
      );
    }
  }

  // Build animated status indicator below the input area
  Widget _buildStatusIndicator(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    dynamic icon;
    String text;

    if (_showInitialAnimation) {
      icon = Icons.hourglass_empty;
      text = l10n.almostReady;
    } else if (_isPrefetchingMetadata && _controller.text.isNotEmpty) {
      icon = Icons.downloading;
      text = l10n.downloadingMetadata;
    } else if (_metadataFetchCompleted && _controller.text.isNotEmpty) {
      icon = Icons.check_circle_outline;
      text = l10n.metadataReady;
    } else {
      icon = RX.RxRocket;
      text = l10n.readyToDownload;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Stack(
        key: ValueKey<String>('${icon.toString()}-$text'),
        children: [
          Container(
            decoration: BoxDecoration(
                color: colorScheme.tertiary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                    left: BorderSide(
                        color: colorScheme.primary.withOpacity(0.15)),
                    right: BorderSide(
                        color: colorScheme.primary.withOpacity(0.15)),
                    bottom: BorderSide(
                        color: colorScheme.primary.withOpacity(0.15))),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  )
                ]),
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                icon is FIconObject
                    ? FIcon(
                        icon,
                        color: colorScheme.primary,
                        size: 20,
                      )
                    : Icon(
                        icon,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                const SizedBox(width: 8),
                Text(text),
              ],
            ),
          ),
          if (_showVideoOptions)
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                        Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.0),
                        Theme.of(context).scaffoldBackgroundColor
                      ],
                          begin: Alignment.bottomCenter,
                          end: AlignmentGeometry.topCenter)),
                ))
        ],
      ),
    );
  }

  String _getSortOptionLabel(SortOption option, AppLocalizations l10n) {
    switch (option) {
      case SortOption.recent:
        return l10n.recentSection;
      case SortOption.downloaded:
        return 'Scaricati';
      case SortOption.summaries:
        return 'Riassunti';
      case SortOption.playlists:
        return 'Playlist';
    }
  }

  IconData _getSortOptionIcon(SortOption option) {
    switch (option) {
      case SortOption.recent:
        return Icons.sort_rounded;
      case SortOption.downloaded:
        return Icons.download_done;
      case SortOption.summaries:
        return Icons.auto_awesome;
      case SortOption.playlists:
        return Icons.playlist_play;
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
          final aCompleted = a.status == 'completed' ? 1 : 0;
          final bCompleted = b.status == 'completed' ? 1 : 0;
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
