import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_streaming_text_markdown/flutter_streaming_text_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/views/chat/providers/video_chat_provider.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';

class VideoQnAView extends ConsumerStatefulWidget {
  const VideoQnAView(
      {super.key, this.startWithChat = false, required this.task});
  final bool startWithChat;
  final DownloadTask task;

  @override
  ConsumerState<VideoQnAView> createState() => _VideoQnAViewState();
}

class _VideoQnAViewState extends ConsumerState<VideoQnAView> {
  final ScrollController _chatScrollController = ScrollController();
  late bool _isSummaryMode;
  bool _isCopied = false;
  bool _summaryAnimationsEnabled = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _isSummaryMode = !widget.startWithChat;
    super.initState();
    _loadAnimationSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoChatProvider.notifier).selectVideo(widget.task);
    });
  }

  Future<void> _loadAnimationSettings() async {
    final enabled = await SettingsService().getSummaryAnimationsEnabled();
    if (mounted) {
      setState(() {
        _summaryAnimationsEnabled = enabled;
      });
    }
  }

  Future<void> _copyToClipboard(DownloadTask task) async {
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
  void dispose() {
    _chatScrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    ref.read(videoChatProvider.notifier).sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(videoChatProvider);
    final downloadListAsync = ref.watch(downloadListProvider);

    // Get the most up-to-date task from the download list
    DownloadTask currentTask = chatState.currentVideo ?? widget.task;
    downloadListAsync.whenData((tasks) {
      final updatedTask = tasks.firstWhere(
        (t) => t.id == currentTask.id,
        orElse: () => currentTask,
      );
      // If the task has been updated (e.g., summary was generated), refresh the provider
      if (updatedTask.summary != currentTask.summary ||
          updatedTask.cachedTranscript != currentTask.cachedTranscript) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(videoChatProvider.notifier).selectVideo(updatedTask);
        });
        currentTask = updatedTask;
      }
    });

    final l10n = AppLocalizations.of(context)!;
    // debugPrint(widget.task.cachedTranscript.toString());

    return Column(
      children: [
        Expanded(
          child: SelectionArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSummaryMode
                  ? _buildFullSummaryView(context, currentTask)
                  : _buildChatView(context, chatState.messages),
            ),
          ),
        ),
        if (!_isSummaryMode) ...[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.15)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chips above input bar
                _SuggestionChipsBar(
                  onSuggestionSelected: (text) {
                    ref.read(videoChatProvider.notifier).sendMessage(text);
                  },
                  // Connect callback to provider method
                  onReportSelected: () {
                    ref.read(videoChatProvider.notifier).generateDeepReport();
                  },
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 14, bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .shadow
                                    .withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: l10n.askSomethingAboutVideo,
                              hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.9),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            onSubmitted: _sendMessage,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded),
                        onPressed: () => _sendMessage(_controller.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  // Summary View
  Widget _buildFullSummaryView(BuildContext context, DownloadTask task) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      key: const ValueKey('SummaryView'),
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor, // Full background
      child: Stack(
        fit: StackFit.expand,
        children: [
          ListView(
              padding: const EdgeInsets.all(24),
              cacheExtent: 2000,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.fullSummary,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _summaryAnimationsEnabled
                    ? StreamingTextMarkdown.chatGPT(
                        text: task.summary ?? l10n.noSummaryAvailable,
                        padding: EdgeInsets.zero,
                      )
                    : MarkdownBody(
                        data: task.summary ?? l10n.noSummaryAvailable,
                        selectable: true,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(Theme.of(context))
                                .copyWith(
                          p: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.4,
                            letterSpacing: 0.2,
                          ),
                          h1: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                                height: 1.4,
                              ),
                          h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.4,
                              ),
                          code: TextStyle(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            fontFamily: 'monospace',
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          codeblockPadding: const EdgeInsets.all(12),
                          blockquoteDecoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                                left: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 4)),
                          ),
                          blockquotePadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                const SizedBox(height: 80),
              ]),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15))),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _copyToClipboard(task),
                      icon: FIcon(
                        _isCopied ? RI.RiCheckLine : RI.RiFileCopyLine,
                        size: 18,
                        color: Colors.green[400],
                      ),
                      label: Text(l10n.copyText),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.green[400]),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  // Chat View
  Widget _buildChatView(BuildContext context, List<ChatMessage> messages) {
    final l10n = AppLocalizations.of(context)!;
    if (messages.isEmpty) {
      return Center(
        key: const ValueKey('EmptyChat'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined,
                size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(l10n.chatEmptyState),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const ValueKey('ChatList'),
      controller: _chatScrollController,
      cacheExtent: 2000,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return _MessageBubble(message: messages[index]);
      },
    );
  }
}

class _SuggestionChipsBar extends StatelessWidget {
  final Function(String) onSuggestionSelected;
  // Add specific callback for report
  final VoidCallback onReportSelected;

  const _SuggestionChipsBar({
    required this.onSuggestionSelected,
    required this.onReportSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(l10n.fullReport),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              labelStyle: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 12,
              ),
              avatar: const SizedBox.shrink(),
              avatarBoxConstraints: BoxConstraints.loose(Size.zero),
              side: BorderSide(color: colorScheme.primary.withOpacity(0.15)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onPressed: onReportSelected, // Call dedicated function
            ),
          ),
          ...[l10n.keyPoints, l10n.goals, l10n.conclusions].map((s) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text(s),
                avatar: const SizedBox.shrink(),
                avatarBoxConstraints: BoxConstraints.loose(Size.zero),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                side: BorderSide(color: colorScheme.primary.withOpacity(0.15)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => onSuggestionSelected(s),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Message Bubble
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8),
            decoration: BoxDecoration(
              color: isUser ? colorScheme.primary : colorScheme.tertiary,
              border: Border.all(
                color: isUser
                    ? Colors.transparent
                    : colorScheme.primary.withOpacity(0.15),
                width: 1,
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
            ),
            child: MarkdownBody(
              data: message.text,
              selectable: true,
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: GoogleFonts.montserrat(
                  fontSize: 15,
                  color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                  height: 1.4,
                  letterSpacing: 0.2,
                ),
                h1: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: isUser
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontSize: 18,
                      height: 1.4,
                    ),
                h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isUser
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      height: 1.4,
                    ),
                code: TextStyle(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  fontFamily: 'monospace',
                  color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                  fontSize: 14,
                  height: 1.5,
                ),
                codeblockDecoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                codeblockPadding: const EdgeInsets.all(12),
                blockquoteDecoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                      left: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 4)),
                ),
                blockquotePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            )));
  }
}
