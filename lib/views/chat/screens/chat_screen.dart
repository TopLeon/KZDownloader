import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kzdownloader/core/providers/quality_provider.dart';
import 'package:kzdownloader/core/services/llm_service.dart';
import 'package:kzdownloader/views/chat/providers/video_chat_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/views/chat/widgets/sidebar.dart';
import 'package:kzdownloader/core/utils/utils.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/views/settings/screens/settings_screen.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/views/chat/screens/home_screen.dart';
import 'package:kzdownloader/views/chat/screens/music_screen.dart';
import 'package:kzdownloader/views/chat/screens/content_list_screen.dart';
import 'package:kzdownloader/views/chat/screens/sort_options.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with WindowListener {
  final TextEditingController _controller = TextEditingController();
  String _selectedProvider = 'Auto';
  static const String _aiModelKey = 'ai_selected_model';

  String _expectedChecksum = '';
  String _checksumAlgorithm = 'MD5';

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
      if (task.downloadStatus == WorkStatus.running) {
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

    final newTask = (await ref.read(downloadListProvider.notifier).addTask(
          url,
          provider,
          quality: q,
          isAudio: _isAudio,
          summarize: shouldSummarize,
          onlySummary: _isSummaryMode,
          summaryType: 'short',
          expectedChecksum: _expectedChecksum,
          checksumAlgorithm: _checksumAlgorithm,
        ))!;

    ref.read(selectedCategoryProvider.notifier).setCategory(newTask.category);
    setState(() {
      _isSummaryMode = false;
      _isSummaryMode = false;
      _isAudio = false;
      _expectedChecksum = '';
      _checksumAlgorithm = 'MD5';
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

  void _handleTaskSelected(DownloadTask newTask) {
    if (!newTask.isPlaylistContainer) {
      ref.read(videoChatProvider.notifier).selectVideo(newTask);
    }
    setState(() {
      _selectedTask = newTask;
      if (newTask.category == TaskCategory.video) {
        _lastSelectedVideoId = newTask.id;
      } else if (newTask.category == TaskCategory.generic) {
        _lastSelectedGenericId = newTask.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

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

          if (next == TaskCategory.inprogress) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final allTasks =
                  ref.read(downloadListProvider).asData?.value ?? [];
              final inprogressTasks = allTasks
                  .where((t) =>
                      t.downloadStatus == WorkStatus.running &&
                          t.playlistParentId == null ||
                      t.summaryStatus.isActive)
                  .toList();

              if (inprogressTasks.isNotEmpty) {
                inprogressTasks
                    .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                final taskToSelect = inprogressTasks.first;

                setState(() {
                  _selectedTask = taskToSelect;
                });

                if (!taskToSelect.isPlaylistContainer) {
                  ref
                      .read(videoChatProvider.notifier)
                      .selectVideo(taskToSelect);
                }
              }
            });
          }

          if (next == TaskCategory.failed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final allTasks =
                  ref.read(downloadListProvider).asData?.value ?? [];
              final failedTasks = allTasks
                  .where((t) => t.downloadStatus == WorkStatus.failed)
                  .toList();

              if (failedTasks.isNotEmpty) {
                failedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                final taskToSelect = failedTasks.first;

                setState(() {
                  _selectedTask = taskToSelect;
                });

                if (!taskToSelect.isPlaylistContainer) {
                  ref
                      .read(videoChatProvider.notifier)
                      .selectVideo(taskToSelect);
                }
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
                              child: _buildBodyContent(selectedCategory),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildBodyContent(TaskCategory? selectedCategory) {
    if (selectedCategory == TaskCategory.settings) {
      return const SettingsScreen();
    } else if (selectedCategory == TaskCategory.home) {
      return HomeScreen(
        controller: _controller,
        selectedProvider: _selectedProvider,
        showVideoOptions: _showVideoOptions,
        isAudio: _isAudio,
        isSummaryMode: _isSummaryMode,
        isPrefetchingMetadata: _isPrefetchingMetadata,
        metadataFetchCompleted: _metadataFetchCompleted,
        showInitialAnimation: _showInitialAnimation,
        onSubmit: _handleAction,
        onProviderChanged: (value) => setState(() => _selectedProvider = value),
        onIsAudioChanged: (value) => setState(() => _isAudio = value),
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
        expectedChecksum: _expectedChecksum,
        checksumAlgorithm: _checksumAlgorithm,
        onChecksumChanged: (val) => setState(() => _expectedChecksum = val),
        onAlgorithmChanged: (val) => setState(() => _checksumAlgorithm = val),
      );
    } else if (selectedCategory == TaskCategory.music) {
      return MusicScreen(
        searchQuery: _searchQuery,
        selectedSortOption: _selectedSortOption,
        onSearchChanged: (val) => setState(() => _searchQuery = val),
        onSortChanged: (option) => setState(() => _selectedSortOption = option),
        onTaskSelected: _handleTaskSelected,
      );
    } else {
      return ContentListScreen(
        category: selectedCategory,
        searchQuery: _searchQuery,
        selectedSortOption: _selectedSortOption,
        selectedTask: _selectedTask,
        onSearchChanged: (val) => setState(() => _searchQuery = val),
        onSortChanged: (option) => setState(() => _selectedSortOption = option),
        onTaskSelected: _handleTaskSelected,
      );
    }
  }
}
