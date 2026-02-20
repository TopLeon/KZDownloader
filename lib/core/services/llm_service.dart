import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:langchain_google/langchain_google.dart';

enum LlmProvider { ollama, openai, google }

// Represents basic information about an AI model.
class OllamaModelInfo {
  final String name;
  final String size;
  final String details;

  OllamaModelInfo(
      {required this.name, required this.size, required this.details});
}

// Represents a message exchanged with the LLM.
class LlmMsg {
  final String role;
  final String content;
  LlmMsg({required this.role, required this.content});
}

// Internal class to represent a queued request.
class _QueuedRequest {
  final List<LlmMsg> messages;
  final int maxTokens;
  final Completer<Stream<String>> completer;

  _QueuedRequest({
    required this.messages,
    required this.maxTokens,
    required this.completer,
  });
}

// Service that handles interactions with the Ollama LLM.
class LlmService {
  static final LlmService _instance = LlmService._internal();
  factory LlmService() => _instance;
  LlmService._internal();

  String? _selectedModelName;
  LlmProvider _activeProvider = LlmProvider.ollama;
  String? _apiKey;
  
  // Request queue to handle concurrent requests sequentially.
  final Queue<_QueuedRequest> _requestQueue = Queue<_QueuedRequest>();
  bool _isProcessing = false;

  static const String _ollamaBaseUrl = 'http://localhost:11434';

  // Sets the model to be used for inference.
  void setModel(String modelName) {
    _selectedModelName = modelName;
    debugPrint("🤖 [LlmService] Model set: $_selectedModelName");
  }

  // Configures the provider and API key.
  void setProvider(LlmProvider provider, {String? apiKey}) {
    _activeProvider = provider;
    if (apiKey != null) {
      _apiKey = apiKey;
    }
    debugPrint("🤖 [LlmService] Provider set: ${_activeProvider.name}");
  }

  String? get currentModel => _selectedModelName;
  LlmProvider get currentProvider => _activeProvider;

  // Checks if Ollama is installed and running.
  Future<bool> isOllamaAvailable() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);

      final request =
          await client.getUrl(Uri.parse('$_ollamaBaseUrl/api/tags'));
      final response = await request.close();

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Fetches the list of available models.
  Future<List<OllamaModelInfo>> fetchAvailableModels() async {
    if (_activeProvider == LlmProvider.openai) {
      return [
        OllamaModelInfo(name: 'gpt-3.5-turbo', size: '-', details: 'OpenAI'),
        OllamaModelInfo(name: 'gpt-4', size: '-', details: 'OpenAI'),
        OllamaModelInfo(name: 'gpt-4o', size: '-', details: 'OpenAI'),
        OllamaModelInfo(name: 'gpt-4o-mini', size: '-', details: 'OpenAI'),
      ];
    }

    if (_activeProvider == LlmProvider.google) {
      if (_apiKey == null || _apiKey!.isEmpty) {
        throw Exception("Google API Key is missing.");
      }

      try {
        final client = HttpClient();
        final request = await client.getUrl(
          Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey'),
        );
        final response = await request.close();

        if (response.statusCode != 200) {
          throw Exception("Google API error: ${response.statusCode}");
        }

        final jsonString = await response.transform(utf8.decoder).join();
        final data = jsonDecode(jsonString);

        List<OllamaModelInfo> models = [];
        if (data['models'] != null) {
          for (var m in data['models']) {
            // Use 'name' field for API (e.g., "models/gemini-1.5-pro")
            // Use 'displayName' for UI display (e.g., "Gemini 1.5 Pro")
            final String modelName = m['name'] ?? '';
            final String displayName = m['displayName'] ?? modelName;

            final supportedMethods = m['supportedGenerationMethods'] as List?;
            if (supportedMethods != null &&
                supportedMethods.contains('generateContent')) {
              models.add(OllamaModelInfo(
                name: modelName,
                size: '-',
                details: displayName,
              ));
            }
          }
        }

        return models;
      } catch (e) {
        return [
          OllamaModelInfo(name: 'models/gemini-2.5-pro', size: '-', details: 'Gemini 2.5 Pro'),
          OllamaModelInfo(name: 'models/gemini-2.5-flash', size: '-', details: 'Gemini 2.5 Flash'),
        ];
      }
    }

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);

      final request =
          await client.getUrl(Uri.parse('$_ollamaBaseUrl/api/tags'));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception("Ollama replied with error: ${response.statusCode}");
      }

      final jsonString = await response.transform(utf8.decoder).join();
      final data = jsonDecode(jsonString);

      if (data['models'] == null) return [];

      List<OllamaModelInfo> models = [];
      for (var m in data['models']) {
        final int sizeBytes = m['size'] ?? 0;
        final String sizeGb =
            "${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";

        models.add(OllamaModelInfo(
          name: m['name'],
          size: sizeGb,
          details: m['details']?['family'] ?? 'Unknown',
        ));
      }
      return models;
    } catch (e) {
      throw Exception(
          "Unable to connect to Ollama. Make sure the app is running.");
    }
  }

  // Internal method to configure the LangChain instance.
  BaseChatModel _getChatModel() {
    if (_selectedModelName == null || _selectedModelName!.isEmpty) {
      throw Exception("No AI model selected. Please select one in Settings.");
    }

    switch (_activeProvider) {
      case LlmProvider.openai:
        if (_apiKey == null || _apiKey!.isEmpty) {
          throw Exception(
              "OpenAI API Key is missing. Please set it in Settings.");
        }
        return ChatOpenAI(
          apiKey: _apiKey!,
          defaultOptions: ChatOpenAIOptions(
            model: _selectedModelName!,
            temperature: 0.7,
          ),
        );

      case LlmProvider.google:
        if (_apiKey == null || _apiKey!.isEmpty) {
          throw Exception(
              "Google API Key is missing. Please set it in Settings.");
        }
        // Remove "models/" prefix if present (Google API returns "models/gemini-1.5-pro")
        // Also handle old format (display names like "Gemini 1.5 Pro")
        String modelName = _selectedModelName!;
        if (modelName.startsWith('models/')) {
          modelName = modelName.substring(7); // Remove "models/" prefix
        } else if (!modelName.contains('-')) {
          // Old format detected (e.g., "Gemini 1.5 Pro"), use default
          modelName = 'gemini-2.5-flash';
          debugPrint('⚠️ Old model format detected, using default: $modelName');
        }
        return ChatGoogleGenerativeAI(
          apiKey: _apiKey!,
          defaultOptions: ChatGoogleGenerativeAIOptions(
            model: modelName,
            temperature: 0.7,
          ),
        );

      case LlmProvider.ollama:
        return ChatOllama(
          baseUrl: '$_ollamaBaseUrl/api',
          defaultOptions: ChatOllamaOptions(
            model: _selectedModelName!,
            temperature: 0.7,
            numCtx: 4096,
          ),
        );
    }
  }

  // Streams the chat response from the LLM.
  // Requests are queued and processed sequentially to avoid conflicts.
  Future<Stream<String>> streamChat(List<LlmMsg> messages,
      {int maxTokens = 2048}) async {
    final completer = Completer<Stream<String>>();
    
    // Add request to queue.
    _requestQueue.add(_QueuedRequest(
      messages: messages,
      maxTokens: maxTokens,
      completer: completer,
    ));

    // Process queue if not already processing.
    _processQueue();

    return completer.future;
  }

  // Processes the request queue sequentially.
  Future<void> _processQueue() async {
    if (_isProcessing || _requestQueue.isEmpty) return;
    
    _isProcessing = true;

    while (_requestQueue.isNotEmpty) {
      final request = _requestQueue.removeFirst();
      
      try {
        final stream = await _executeStreamChat(request.messages, request.maxTokens);
        request.completer.complete(stream);
      } catch (e) {
        request.completer.completeError(e);
      }

      // Wait for the current stream to complete before processing next request.
      if (request.completer.isCompleted) {
        try {
          final stream = await request.completer.future;
          await stream.last.catchError((_) => ''); // Wait for stream completion
        } catch (_) {
          // Stream error already handled in completer
        }
      }
    }

    _isProcessing = false;
  }

  // Internal method that executes a single chat request.
  Future<Stream<String>> _executeStreamChat(List<LlmMsg> messages, int maxTokens) async {
    final controller = StreamController<String>();

    try {
      final chatModel = _getChatModel();
      final List<ChatMessage> langchainMessages = [];
      String? pendingSystemInstruction;

      for (var m in messages) {
        if (m.role == 'system') {
          pendingSystemInstruction = m.content;
        } else if (m.role == 'user') {
          if (pendingSystemInstruction != null) {
            final combinedContent = """
### INSTRUCTIONS:
$pendingSystemInstruction

### CONTEXT/INPUT:
${m.content}

### REQURESTED ANSWER:
""";
            langchainMessages.add(ChatMessage.humanText(combinedContent));
            pendingSystemInstruction = null;
          } else {
            langchainMessages.add(ChatMessage.humanText(m.content));
          }
        } else if (m.role == 'assistant') {
          langchainMessages.add(ChatMessage.ai(m.content));
        }
      }

      if (pendingSystemInstruction != null) {
        langchainMessages.add(ChatMessage.humanText(pendingSystemInstruction));
      }

      final stream = chatModel.stream(PromptValue.chat(langchainMessages));

      stream.listen(
        (ChatResult res) {
          final chunk = res.output.content;
          controller.add(chunk);
        },
        onDone: () {
          controller.close();
        },
        onError: (e) {
          if (!controller.isClosed) controller.addError(e);
        },
      );
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
        controller.close();
      }
    }

    return controller.stream;
  }

  // Generates a summary for the given video content.
  Future<Stream<String>> generateSummary({
    required String subtitleText,
    required String videoTitle,
    String videoDescription = '',
    String targetLanguageName = 'English',
    int maxCharacters = 15000,
  }) async {
    String safeSubtitle = subtitleText;
    if (safeSubtitle.length > maxCharacters) {
      safeSubtitle =
          "${safeSubtitle.substring(0, maxCharacters)}\n[...TRUNCATED...]";
    }

    final contextBase = '''
CONTEXT SECTION

Video Title: 
"""
$videoTitle
"""
Video Description: 
"""
$videoDescription
"""
Video Transcript:
"""
$safeSubtitle
"""
''';

    String taskDescription = targetLanguageName == 'Italian'
        ? "Genera un riassunto RIASSUNTO del video basandoti sul contesto, evidenziando i punti chiave."
        : "Generate a SUMMARY of the video based on the context, highlighting key points.";

    final prompt = """
TASK:
Analyze the transcript provided in the context and answer the user's request.

USER REQUEST:
"$taskDescription"

RESPONSE INSTRUCTIONS:
1. Answer exclusively in language: $targetLanguageName.
2. Do not repeat instructions. Go straight to the point.
3. Do not start with any introductory phrases or title. Write only the summary.
4. Do not use Markdown formatting, tables, or bullet points. The text should be plain and easy to read.

RESPONSE:
""";

    final messages = [
      LlmMsg(role: 'system', content: contextBase),
      LlmMsg(role: 'user', content: prompt),
    ];

    return streamChat(messages, maxTokens: 2048);
  }
}
