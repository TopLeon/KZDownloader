import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/core/services/db_service.dart';
import 'package:kzdownloader/core/services/llm_service.dart';
import 'package:kzdownloader/core/download/logic/yt_dlp_service.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/models/download_task.dart';

part 'video_chat_provider.g.dart';

// Represents the state of the video chat.
class VideoChatState {
  final DownloadTask? currentVideo;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? cachedSystemPrompt;

  VideoChatState({
    this.currentVideo,
    this.messages = const [],
    this.isLoading = false,
    this.cachedSystemPrompt,
  });

  VideoChatState copyWith({
    DownloadTask? currentVideo,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? cachedSystemPrompt,
  }) {
    return VideoChatState(
      currentVideo: currentVideo ?? this.currentVideo,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      cachedSystemPrompt: cachedSystemPrompt ?? this.cachedSystemPrompt,
    );
  }
}

// A chat message in the video chat.
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Notifier for managing video chat logic.
@Riverpod(keepAlive: true)
class VideoChatNotifier extends _$VideoChatNotifier {
  final _llmService = LlmService();
  late final DbService _dbService;
  StreamSubscription<String>? _currentSubscription;

  @override
  VideoChatState build() {
    _dbService = ref.read(dbServiceProvider);

    ref.onDispose(() {
      _currentSubscription?.cancel();
    });

    Future.microtask(() => _loadInitialVideo());

    return VideoChatState();
  }

  Future<void> _loadInitialVideo() async {
    try {
      final tasks = await _dbService.getAllTasks();
      if (tasks.isEmpty) return;

      final tasksWithSummary = tasks
          .where((t) => t.summary != null && t.summary!.isNotEmpty)
          .toList();

      if (tasksWithSummary.isNotEmpty) {
        selectVideo(tasksWithSummary.last);
      } else {
        selectVideo(tasks.last);
      }
    } catch (e) {
      debugPrint("Error loading initial video: $e");
    }
  }

  // Selects a video for the chat session and loads its history.
  void selectVideo(DownloadTask video) {
    if (state.currentVideo?.id == video.id) {
      state = state.copyWith(currentVideo: video);
      return;
    }

    final history = <ChatMessage>[];
    if (video.qaHistory != null) {
      for (var qa in video.qaHistory!) {
        if (qa.question != null) {
          history.add(ChatMessage(
            text: qa.question!,
            isUser: true,
            timestamp: qa.timestamp ?? DateTime.now(),
          ));
        }
        if (qa.answer != null) {
          history.add(ChatMessage(
            text: qa.answer!,
            isUser: false,
            timestamp: qa.timestamp ?? DateTime.now(),
          ));
        }
      }
    }

    state = VideoChatState(
      currentVideo: video,
      messages: history,
      cachedSystemPrompt: null,
    );
  }

  // Refreshes the current video from the database to get the latest data
  Future<void> refreshCurrentVideo() async {
    if (state.currentVideo == null) return;

    try {
      final freshTask = await _dbService.getTask(state.currentVideo!.id);
      if (freshTask != null) {
        state = state.copyWith(currentVideo: freshTask);
      }
    } catch (e) {
      debugPrint("Error refreshing current video: $e");
    }
  }

  // Generates a deep detailed report of the video.
  Future<void> generateDeepReport() async {
    if (state.currentVideo == null) return;

    final settings = ref.read(settingsServiceProvider);
    final langCode = await settings.getLanguage() ?? 'en';

    final prompts = {
      'it': "Analizza il contesto fornito e genera un Report Completo del video. "
          "Struttura: Riassunto Esecutivo, Punti Chiave (elenco), Dettagli Tecnici, Conclusioni. "
          "Usa Markdown.",
      'en': "Analyze the provided context and generate a Full Video Report. "
          "Structure: Executive Summary, Key Points (list), Technical Details, Conclusions. "
          "Use Markdown.",
    };

    final prompt = prompts[langCode] ?? prompts['en']!;

    await _sendLlmRequest(prompt, useHistory: false);
  }

  // Sends a message to the LLM and updates the chat state.
  Future<void> sendMessage(String text) async {
    await _sendLlmRequest(text, useHistory: false);
  }

  Future<void> _sendLlmRequest(String userText,
      {required bool useHistory}) async {
    if (state.currentVideo == null || userText.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: userText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final aiMsgPlaceholder = ChatMessage(
      text: "",
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg, aiMsgPlaceholder],
      isLoading: true,
    );

    try {
      final lang =
          await ref.read(settingsServiceProvider).getLanguage() ?? 'it';

      String systemContent = state.cachedSystemPrompt ?? "";
      if (systemContent.isEmpty) {
        systemContent = await _buildSystemPrompt(state.currentVideo!);
        state = state.copyWith(cachedSystemPrompt: systemContent);
      }

      final llmMessages = <LlmMsg>[];
      llmMessages.add(LlmMsg(role: 'system', content: systemContent));

      if (useHistory) {
        final existingHistory = state.messages.length > 2
            ? state.messages.sublist(0, state.messages.length - 2)
            : <ChatMessage>[];

        final recentHistory = existingHistory.length > 4
            ? existingHistory.sublist(existingHistory.length - 4)
            : existingHistory;

        for (var m in recentHistory) {
          llmMessages.add(LlmMsg(
            role: m.isUser ? 'user' : 'assistant',
            content: m.text,
          ));
        }
      }

      final forcedPrompt = """
TASK:
Analyze the transcript provided in the context and answer the user's request.

USER REQUEST:
"$userText"

RESPONSE INSTRUCTIONS:
1. Answer exclusively in language: $lang.
2. If the user enters single words (e.g. "conclusions", "objectives"), provide a detailed summary of that specific topic based on the video.
3. Do not repeat instructions. Go straight to the point.
4. Use Markdown formatting for better readability.

RESPONSE:
""";

      llmMessages.add(LlmMsg(role: 'user', content: forcedPrompt));

      String fullResponse = "";
      final stream = await _llmService.streamChat(llmMessages, maxTokens: 2048);

      await _currentSubscription?.cancel();

      _currentSubscription = stream.listen(
        (chunk) {
          fullResponse += chunk;
          _updateLastMessage(fullResponse);
        },
        onDone: () async {
          _currentSubscription = null;
          state = state.copyWith(isLoading: false);
          if (state.currentVideo != null && fullResponse.isNotEmpty) {
            await _saveChatToDb(
                state.currentVideo!, userText, fullResponse.trim());
          }
        },
        onError: (e) {
          debugPrint("Chat Error: $e");
          state = state.copyWith(isLoading: false);
          _updateLastMessage("⚠️ Error: $e");
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _updateLastMessage("❌ Request error: $e");
    }
  }

  void _updateLastMessage(String text) {
    if (state.messages.isEmpty) return;
    final updatedMessages = List<ChatMessage>.from(state.messages);
    updatedMessages[updatedMessages.length - 1] = ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: updatedMessages);
  }

  Future<void> _saveChatToDb(
      DownloadTask task, String question, String answer) async {
    final newQA = QAItem()
      ..question = question
      ..answer = answer
      ..timestamp = DateTime.now();

    final updatedHistory = List<QAItem>.from(task.qaHistory ?? []);
    updatedHistory.add(newQA);

    task.qaHistory = updatedHistory;
    await _dbService.saveTask(task);

    state = state.copyWith(currentVideo: task);
  }

  Future<String> _buildSystemPrompt(DownloadTask video) async {
    String transcript = await _getTranscript(video);

    final settings = SettingsService();
    final maxChars = await settings.getMaxCharactersForAI();
    if (transcript.length > maxChars) {
      transcript = "${transcript.substring(0, maxChars)}\n[...TRUNCATED...]";
    }

    return '''
CONTEXT SECTION

Video Transcript:
"""
$transcript
"""
Video Description:
"""
${video.cachedDescription ?? "N/A"}
"""
Video Name: 
"""
${video.title ?? "N/A"}
"""
Channel Name:
"""
${video.channelName ?? "N/A"}
"""
''';
  }

  Future<String> _getTranscript(DownloadTask video) async {
    if (video.cachedTranscript != null && video.cachedTranscript!.isNotEmpty) {
      return video.cachedTranscript!;
    }

    try {
      final yt = YtDlpService();
      final t = await yt.fetchVideoSubtitles(video.url);
      video.cachedTranscript = t;
      await _dbService.saveTask(video);

      state = state.copyWith(currentVideo: video, cachedSystemPrompt: null);

      return t ?? "No transcript available.";
    } catch (e) {
      return video.cachedDescription ?? "No transcript available.";
    }
  }
}
