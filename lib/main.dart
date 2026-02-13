import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kzdownloader/src/rust/frb_generated.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kzdownloader/views/chat/screens/chat_screen.dart';
import 'package:kzdownloader/core/utils/binary_manager.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kzdownloader/core/theme/app_theme.dart';
import 'package:kzdownloader/core/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/core/providers/locale_provider.dart';
import 'package:kzdownloader/core/services/llm_service.dart';
import 'package:kzdownloader/core/services/secure_storage_service.dart';

// Entry point of the application.
// Initializes bindings, Rust library, and window options.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await BinaryManager().ensureInitialized();

  await RustLib.init();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1120, 705),
    minimumSize: Size(1120, 705),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: KzDownloaderApp()));
}

// The root widget of the application.
// Sets up the theme, localization, and providers.
class KzDownloaderApp extends ConsumerWidget {
  const KzDownloaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeProvider);
    final localeAsync = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeAsync.when(
        data: (locale) => locale,
        loading: () => null,
        error: (_, __) => null,
      ),
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeModeAsync.when(
        data: (mode) => mode,
        loading: () => ThemeMode.system,
        error: (_, __) => ThemeMode.system,
      ),
      home: const StartupScreen(),
    );
  }
}

// The initial screen shown while the app performs checks and initialization.
class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  String _statusMessage = '';
  bool _showRetry = false;
  bool _showLanguageSelection = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_statusMessage.isEmpty) {
      _statusMessage = AppLocalizations.of(context)!.initialization;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
          const Duration(milliseconds: 500), () => _checkLanguageAndInit());
    });
  }

  // Checks if a language has been selected. If not, shows the selection screen.
  Future<void> _checkLanguageAndInit() async {
    final settings = SettingsService();
    final lang = await settings.getLanguage();
    final aiModel = await settings.selectedAiModel;

    if (lang == null) {
      setState(() {
        _showLanguageSelection = true;
      });
    } else if (aiModel == null) {
      await _showAiConfiguration();
      _init();
    } else {
      _init();
    }
  }

  // Sets the application language and proceeds with initialization.
  Future<void> _setLanguage(String langCode) async {
    await ref.read(localeProvider.notifier).setLocale(Locale(langCode));
    setState(() {
      _showLanguageSelection = false;
    });
    await _showAiConfiguration();
    _init();
  }

  // Shows AI configuration dialog, customized based on Ollama availability.
  Future<void> _showAiConfiguration() async {
    if (!mounted) return;

    final llmService = LlmService();
    final isOllamaAvailable = await llmService.isOllamaAvailable();

    await _showAiProviderChoice(isOllamaAvailable: isOllamaAvailable);
  }

  // Shows dialog to choose between OpenAI, installing Ollama, or skipping.
  Future<void> _showAiProviderChoice({bool isOllamaAvailable = false}) async {
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.psychology_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.aiConfiguration,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOllamaAvailable
                  ? AppLocalizations.of(context)!.ollamaDetected
                  : AppLocalizations.of(context)!.configureAiFeatures,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 28),
            _buildAiOptionCard(
              context,
              icon: Icons.storage_rounded,
              title: AppLocalizations.of(context)!.useOllama,
              description: isOllamaAvailable
                  ? AppLocalizations.of(context)!.ollamaLocalFree
                  : AppLocalizations.of(context)!.ollamaNeedsInstall,
            ),
            const SizedBox(height: 16),
            _buildAiOptionCard(
              context,
              icon: Icons.cloud_outlined,
              title: AppLocalizations.of(context)!.useOpenAI,
              description: AppLocalizations.of(context)!.openAiDescription,
            ),
            const SizedBox(height: 16),
            _buildAiOptionCard(
              context,
              icon: Icons.auto_awesome,
              title: AppLocalizations.of(context)!.useGoogleAI,
              description: AppLocalizations.of(context)!.googleAiDescription,
            ),
            const SizedBox(height: 16),
            _buildAiOptionCard(
              context,
              icon: Icons.block_outlined,
              title: AppLocalizations.of(context)!.skipForNow,
              description: AppLocalizations.of(context)!.configureInSettings,
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'ollama'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.useOllama),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'openai'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.openAi),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'google'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.useGoogle),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'skip'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.skip),
          ),
        ],
      ),
    );

    if (choice == 'ollama') {
      if (isOllamaAvailable) {
        await _configureOllamaWithModels();
      } else {
        await _showOllamaInstallInstructions();
        await SettingsService().setAiProvider('ollama');
      }
    } else if (choice == 'openai') {
      await _configureOpenAI();
    } else if (choice == 'google') {
      await _configureGoogleAI();
    }
  }

  // Configures Ollama when it's available - shows model selection or installation.
  Future<void> _configureOllamaWithModels() async {
    const defaultModel = "hf.co/unsloth/gemma-3-4b-it-qat-int4-GGUF:Q4_K_M";
    final llmService = LlmService();
    final settings = SettingsService();

    try {
      final models = await llmService.fetchAvailableModels();

      if (models.isNotEmpty && mounted) {
        final selectedModel = await _showModelSelectionDialog(
          models,
          defaultModel: defaultModel,
          title: AppLocalizations.of(context)!.chooseModel,
        );

        if (selectedModel != null) {
          await settings.setAiProvider('ollama');
          await settings.setAiModel(selectedModel);
          llmService.setProvider(LlmProvider.ollama);
          llmService.setModel(selectedModel);
        }
      } else {
        final shouldInstall = await _showInstallModelDialog(defaultModel);

        if (shouldInstall == true) {
          await _installDefaultModel(defaultModel);
        } else {
          await settings.setAiProvider('ollama');
        }
      }
    } catch (e) {
      debugPrint("Error configuring Ollama: $e");
    }
  }

  // Shows a dialog to select from available models.
  Future<String?> _showModelSelectionDialog(
    List<OllamaModelInfo> models, {
    required String defaultModel,
    required String title,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.model_training,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.selectAiModel,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 24),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: models.length,
                  itemBuilder: (context, index) {
                    final model = models[index];
                    final isRecommended = model.name == defaultModel;
                    final theme = Theme.of(context);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => Navigator.pop(context, model.name),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isRecommended
                                ? theme.colorScheme.primaryContainer
                                    .withOpacity(0.3)
                                : theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isRecommended
                                  ? theme.colorScheme.primary.withOpacity(0.5)
                                  : theme.colorScheme.outlineVariant
                                      .withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isRecommended
                                      ? theme.colorScheme.primaryContainer
                                          .withOpacity(0.5)
                                      : theme
                                          .colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.memory,
                                  color: isRecommended
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: isRecommended
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${model.size} - ${model.details}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isRecommended)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.recommended,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shows a dialog suggesting to install a model.
  Future<bool?> _showInstallModelDialog(String modelName) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.installAiModel,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.installModelMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.sd_storage_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.sizeLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.skip),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.download_rounded, size: 20),
              label: Text(AppLocalizations.of(context)!.installGemma),
            ),
          ],
        );
      },
    );
  }

  // Orchestrates the initialization process: checks binaries, download path, and AI models.
  Future<void> _init() async {
    try {
      setState(
        () => _statusMessage = AppLocalizations.of(context)!.checkingComponents,
      );
      final binaryManager = BinaryManager();

      if (!await binaryManager.isYtDlpInstalled()) {
        setState(() =>
            _statusMessage = AppLocalizations.of(context)!.downloadingYtDlp);
        await binaryManager.downloadYtDlp();
      }

      if (!await binaryManager.isFfmpegInstalled()) {
        setState(() =>
            _statusMessage = AppLocalizations.of(context)!.downloadingFfmpeg);
        await binaryManager.downloadFfmpeg();
      }

      if (!await binaryManager.isDenoInstalled()) {
        setState(() =>
            _statusMessage = AppLocalizations.of(context)!.downloadingDeno);
        await binaryManager.downloadDeno();
      }

      setState(() =>
          _statusMessage = AppLocalizations.of(context)!.checkingDownloadPath);
      final settings = SettingsService();
      String? path = await settings.getDownloadPath();

      if (path == null) {
        if (mounted) {
          await _promptForDownloadPath();
        }
      }

      setState(
          () => _statusMessage = AppLocalizations.of(context)!.loadingAiConfig);

      final providerStr = await settings.getAiProvider();
      String? apiKey;
      if (providerStr == 'openai') {
        apiKey = await ref
            .read(secureStorageServiceProvider)
            .readSecureData(StorageKeys.openAiApiKey);
      } else if (providerStr == 'google') {
        apiKey = await ref
            .read(secureStorageServiceProvider)
            .readSecureData(StorageKeys.googleApiKey);
      }

      LlmProvider provider = LlmProvider.ollama;
      if (providerStr == 'openai') {
        provider = LlmProvider.openai;
      } else if (providerStr == 'google') {
        provider = LlmProvider.google;
      }

      LlmService().setProvider(provider, apiKey: apiKey);

      final selectedModel = await settings.selectedAiModel;
      if (selectedModel != null) {
        LlmService().setModel(selectedModel);
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage =
            AppLocalizations.of(context)!.startupError(e.toString());
        _showRetry = true;
      });
    }
  }

  // A widget for AI Model Selection
  Widget _buildAiOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for language selection buttons
  Widget _buildLanguageButton(
    BuildContext context, {
    required String flag,
    required String label,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Configure OpenAI API Key
  Future<void> _configureOpenAI() async {
    final controller = TextEditingController();

    final apiKey = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.key,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.openAiApiKeyTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.enterOpenAiKey,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                obscureText: true,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.apiKeyLabel,
                  hintText: AppLocalizations.of(context)!.openAiApiKeyHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.vpn_key_rounded),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('https://platform.openai.com/api-keys');
                  if (Platform.isMacOS) {
                    await Process.run('open', [uri.toString()]);
                  }
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(AppLocalizations.of(context)!.getApiKeyOpenAI),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.btnCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );

    if (apiKey != null && apiKey.isNotEmpty) {
      await ref
          .read(secureStorageServiceProvider)
          .writeSecureData(StorageKeys.openAiApiKey, apiKey);
      await SettingsService().setAiProvider('openai');
      await SettingsService().setAiModel('gpt-4o-mini');
      LlmService().setProvider(LlmProvider.openai, apiKey: apiKey);
      LlmService().setModel('gpt-4o-mini');
    }
  }

  // Configure Google API Key
  Future<void> _configureGoogleAI() async {
    final controller = TextEditingController();

    final apiKey = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.googleAiApiKeyTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.enterGoogleKey,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                obscureText: true,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.apiKeyLabel,
                  hintText: AppLocalizations.of(context)!.googleAiApiKeyHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.vpn_key_rounded),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  final uri =
                      Uri.parse('https://aistudio.google.com/app/apikey');
                  if (Platform.isMacOS) {
                    await Process.run('open', [uri.toString()]);
                  }
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(AppLocalizations.of(context)!.getApiKeyGoogle),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.btnCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );

    if (apiKey != null && apiKey.isNotEmpty) {
      await ref
          .read(secureStorageServiceProvider)
          .writeSecureData(StorageKeys.googleApiKey, apiKey);
      await SettingsService().setAiProvider('google');
      await SettingsService().setAiModel('gemini-2.5-flash');
      LlmService().setProvider(LlmProvider.google, apiKey: apiKey);
      LlmService().setModel('gemini-2.5-flash');
    }
  }

  // Show a dialog with instructions to install Ollama
  Future<void> _showOllamaInstallInstructions() async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.install_desktop,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.installOllamaTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.installOllamaMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTerminalStep(
                    '1',
                    AppLocalizations.of(context)!.visitOllama,
                  ),
                  const SizedBox(height: 12),
                  _buildTerminalStep(
                    '2',
                    AppLocalizations.of(context)!.downloadInstall,
                  ),
                  const SizedBox(height: 12),
                  _buildTerminalStep(
                    '3',
                    AppLocalizations.of(context)!.restartApp,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                if (Platform.isMacOS) {
                  await Process.run('open', ['https://ollama.com']);
                }
              },
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.open_in_browser_rounded, size: 20),
              label: Text(AppLocalizations.of(context)!.openOllamaWebsite),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  // Helper widget for terminal steps
  Widget _buildTerminalStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Colors.greenAccent,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // Install the default Ollama model
  Future<void> _installDefaultModel(String modelName) async {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.terminal,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.installingAiModel,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.openingTerminal,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: SelectableText(
                'ollama run $modelName',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      if (Platform.isMacOS) {
        await Process.run('open', ['-a', 'Terminal', 'ollama run $modelName']);
      }

      await SettingsService().setAiModel(modelName);
      LlmService().setModel(modelName);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Could not open terminal: $e");
      if (mounted) Navigator.pop(context);
    }
  }

  // Prompts the user to select a directory for downloads.
  Future<void> _promptForDownloadPath() async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.folder_special_rounded,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.initialConfiguration,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.selectDownloadFolderMessage,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          FilledButton.icon(
            onPressed: () async {
              String? selectedDirectory =
                  await FilePicker.platform.getDirectoryPath();

              if (selectedDirectory != null) {
                await SettingsService().setDownloadPath(selectedDirectory);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.create_new_folder_rounded, size: 20),
            label: Text(AppLocalizations.of(context)!.chooseFolder),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_showLanguageSelection) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.selectLanguageTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    _buildLanguageButton(
                      context,
                      flag: "🇺🇸",
                      label: AppLocalizations.of(context)!.english,
                      onPressed: () => _setLanguage('en'),
                    ),
                    const SizedBox(height: 12),
                    _buildLanguageButton(
                      context,
                      flag: "🇮🇹",
                      label: AppLocalizations.of(context)!.italiano,
                      onPressed: () => _setLanguage('it'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                "KzDownloader",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 40),
              if (!_showRetry) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                  letterSpacing: 0.1,
                ),
              ),
              if (_showRetry) ...[
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _showRetry = false;
                      _statusMessage = AppLocalizations.of(context)!.retrying;
                    });
                    _init();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
