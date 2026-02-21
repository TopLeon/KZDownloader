import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kzdownloader/views/chat/screens/chat_screen.dart';
import 'package:kzdownloader/core/utils/binary_manager.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:kzdownloader/core/theme/app_theme.dart';
import 'package:kzdownloader/core/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/core/providers/locale_provider.dart';
import 'package:kzdownloader/core/services/llm_service.dart';
import 'package:kzdownloader/core/services/secure_storage_service.dart';
import 'package:rhttp_plus/rhttp_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Entry point of the application.
// Initializes bindings, HTTP client, and window options.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  JustAudioMediaKit.ensureInitialized(); // For windows

  await Rhttp.init();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1220, 770),
    minimumSize: Size(1220, 770),
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

// =====================================================
// Startup flow step + AI-choice enums
// =====================================================
enum _StartupStep { language, aiProvider, aiDetail, downloadPath, progress }

enum _AiChoice { ollama, openai, google, skip }

class _StartupScreenState extends ConsumerState<StartupScreen> {
  // ── Step tracking ──────────────────────────────────
  List<_StartupStep> _stepSequence = [];
  _StartupStep _step = _StartupStep.progress;
  bool _initialized = false;

  // ── AI configuration ───────────────────────────────
  _AiChoice? _aiChoice;
  bool _aiDetailLoading = false;
  bool _isOllamaAvailable = false;
  List<OllamaModelInfo> _ollamaModels = [];
  String? _selectedOllamaModel;
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;

  // ── Download path ──────────────────────────────────
  String? _downloadPath;

  // ── Binary download tracking ───────────────────────
  Future<void>? _binariesFuture;
  final Map<String, double> _binaryProgress = {
    'ytdlp': 0.0,
    'ffmpeg': 0.0,
    'deno': 0.0,
  };
  final Map<String, bool> _binaryDone = {
    'ytdlp': false,
    'ffmpeg': false,
    'deno': false,
  };
  String? _binaryError;
  bool _allBinariesDone = false;
  bool _navigationTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  // Determines which setup steps are needed and starts background binary downloads.
  Future<void> _initialize() async {
    final settings = SettingsService();
    final lang = await settings.getLanguage();
    final aiModel = await settings.selectedAiModel;
    final path = await settings.getDownloadPath();

    _startBinaries(); // Begin downloading in background immediately.

    final sequence = <_StartupStep>[];
    if (lang == null) sequence.add(_StartupStep.language);
    if (aiModel == null) {
      sequence.add(_StartupStep.aiProvider);
      sequence.add(_StartupStep.aiDetail);
    }
    if (path == null) sequence.add(_StartupStep.downloadPath);
    sequence.add(_StartupStep.progress);

    setState(() {
      _stepSequence = sequence;
      _step = sequence.first;
      _downloadPath = path;
      _initialized = true;
    });

    if (sequence.length == 1) _onReachedProgressStep();
  }

  // Starts background binary downloads (idempotent).
  void _startBinaries() {
    _binariesFuture ??= _doDownloadBinaries();
  }

  Future<void> _doDownloadBinaries() async {
    final bm = BinaryManager();
    try {
      await Future.wait([
        _conditionalDownload(
          check: bm.isYtDlpInstalled,
          download: bm.downloadYtDlp,
          key: 'ytdlp',
        ),
        _conditionalDownload(
          check: bm.isFfmpegInstalled,
          download: bm.downloadFfmpeg,
          key: 'ffmpeg',
        ),
        _conditionalDownload(
          check: bm.isDenoInstalled,
          download: bm.downloadDeno,
          key: 'deno',
        ),
      ]);
    } catch (e) {
      if (mounted) setState(() => _binaryError = e.toString());
    }
  }

  Future<void> _conditionalDownload({
    required Future<bool> Function() check,
    required Future<void> Function({Function(double)? onProgress}) download,
    required String key,
  }) async {
    if (!await check()) {
      await download(
        onProgress: (p) {
          if (mounted) setState(() => _binaryProgress[key] = p);
        },
      );
    }
    if (mounted) {
      setState(() {
        _binaryDone[key] = true;
        _binaryProgress[key] = 1.0;
      });
    }
  }

  // ── Navigation helpers ─────────────────────────────

  void _navigateToStep(_StartupStep step) {
    setState(() => _step = step);
    if (step == _StartupStep.progress) _onReachedProgressStep();
  }

  void _goNext() {
    final idx = _stepSequence.indexOf(_step);
    var next = idx + 1;
    while (next < _stepSequence.length) {
      if (_stepSequence[next] == _StartupStep.aiDetail &&
          _aiChoice == _AiChoice.skip) {
        next++;
        continue;
      }
      break;
    }
    if (next < _stepSequence.length) _navigateToStep(_stepSequence[next]);
  }

  // ── Language step ──────────────────────────────────

  Future<void> _selectLanguage(String langCode) async {
    await ref.read(localeProvider.notifier).setLocale(Locale(langCode));
    _goNext();
  }

  // ── AI provider step ───────────────────────────────

  void _selectAiChoice(_AiChoice choice) {
    setState(() => _aiChoice = choice);
  }

  Future<void> _continueFromAiProvider() async {
    if (_aiChoice == null) return;
    if (_aiChoice == _AiChoice.ollama) {
      setState(() => _aiDetailLoading = true);
      try {
        _isOllamaAvailable = await LlmService().isOllamaAvailable();
        if (_isOllamaAvailable) {
          _ollamaModels = await LlmService().fetchAvailableModels();
          if (_ollamaModels.isNotEmpty) {
            _selectedOllamaModel = _ollamaModels.first.name;
          }
        }
      } catch (_) {}
      setState(() => _aiDetailLoading = false);
    }
    _goNext();
  }

  Future<void> _continueFromAiDetail() async {
    final settings = SettingsService();
    if (_aiChoice == _AiChoice.ollama) {
      await settings.setAiProvider('ollama');
      if (_selectedOllamaModel != null) {
        await settings.setAiModel(_selectedOllamaModel!);
        LlmService().setProvider(LlmProvider.ollama);
        LlmService().setModel(_selectedOllamaModel!);
      } else {
        await settings.setAiModel('none');
      }
    } else if (_aiChoice == _AiChoice.openai) {
      final key = _apiKeyController.text.trim();
      if (key.isEmpty) return;
      await ref
          .read(secureStorageServiceProvider)
          .writeSecureData(StorageKeys.openAiApiKey, key);
      await settings.setAiProvider('openai');
      await settings.setAiModel('gpt-4o-mini');
      LlmService().setProvider(LlmProvider.openai, apiKey: key);
      LlmService().setModel('gpt-4o-mini');
    } else if (_aiChoice == _AiChoice.google) {
      final key = _apiKeyController.text.trim();
      if (key.isEmpty) return;
      await ref
          .read(secureStorageServiceProvider)
          .writeSecureData(StorageKeys.googleApiKey, key);
      await settings.setAiProvider('google');
      await settings.setAiModel('gemini-2.5-flash');
      LlmService().setProvider(LlmProvider.google, apiKey: key);
      LlmService().setModel('gemini-2.5-flash');
    }
    _goNext();
  }

  // ── Download path step ────────────────────────────

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) setState(() => _downloadPath = result);
  }

  Future<void> _continueFromDownloadPath() async {
    if (_downloadPath == null) return;
    await SettingsService().setDownloadPath(_downloadPath!);
    _goNext();
  }

  // ── Progress step ──────────────────────────────────

  Future<void> _onReachedProgressStep() async {
    if (_navigationTriggered) return;
    _navigationTriggered = true;

    await _loadSavedAiConfig();

    try {
      await _binariesFuture;
    } catch (e) {
      if (mounted) setState(() => _binaryError = e.toString());
      return;
    }

    if (mounted) {
      setState(() => _allBinariesDone = true);
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
      }
    }
  }

  Future<void> _loadSavedAiConfig() async {
    final settings = SettingsService();
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
    if (providerStr == 'openai') provider = LlmProvider.openai;
    if (providerStr == 'google') provider = LlmProvider.google;
    LlmService().setProvider(provider, apiKey: apiKey);
    final model = await settings.selectedAiModel;
    if (model != null && model != 'none' && model != 'skip') {
      LlmService().setModel(model);
    }
  }

  // ══════════════════════════════════════════════════
  //  Shared UI helpers
  // ══════════════════════════════════════════════════

  Widget _buildAppBrand(ThemeData theme) {
    return SizedBox(
      width: 300,
      child: Image.asset('assets/logo.png'),
    );
  }

  Widget _buildStepDots(ThemeData theme) {
    if (_stepSequence.length <= 1) return const SizedBox.shrink();
    final visible = _stepSequence
        .where(
            (s) => !(s == _StartupStep.aiDetail && _aiChoice == _AiChoice.skip))
        .toList();
    int currentIdx = 0;
    for (int i = 0; i < visible.length; i++) {
      if (visible[i] == _step) {
        currentIdx = i;
        break;
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(visible.length, (i) {
        final active = i == currentIdx;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildCard(ThemeData theme, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStepHeader({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildOptionCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String description,
    required bool selected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer.withOpacity(0.25)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.6)
                : theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.primary.withOpacity(0.15)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton({
    required ThemeData theme,
    required String label,
    required bool enabled,
    required bool loading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled && !loading ? onPressed : null,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  //  Step builders
  // ══════════════════════════════════════════════════

  Widget _buildCurrentStep(ThemeData theme) {
    return switch (_step) {
      _StartupStep.language => _buildLanguageStep(theme),
      _StartupStep.aiProvider => _buildAiProviderStep(theme),
      _StartupStep.aiDetail => _buildAiDetailStep(theme),
      _StartupStep.downloadPath => _buildDownloadPathStep(theme),
      _StartupStep.progress => _buildProgressStep(theme),
    };
  }

  // ── Language ───────────────────────────────────────

  Widget _buildLanguageStep(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepHeader(
            theme: theme,
            icon: Icons.language_rounded,
            title: l10n.selectLanguageTitle,
            subtitle: l10n.selectLanguage,
          ),
          _buildOptionCard(
            theme: theme,
            icon: Icons.flag_rounded,
            title: l10n.english,
            description: 'English',
            selected: false,
            onTap: () => _selectLanguage('en'),
          ),
          const SizedBox(height: 10),
          _buildOptionCard(
            theme: theme,
            icon: Icons.flag_rounded,
            title: l10n.italiano,
            description: 'Italiano',
            selected: false,
            onTap: () => _selectLanguage('it'),
          ),
        ],
      ),
    );
  }

  // ── AI provider ────────────────────────────────────

  Widget _buildAiProviderStep(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepHeader(
            theme: theme,
            icon: Icons.psychology_rounded,
            title: l10n.aiConfiguration,
            subtitle: l10n.configureAiFeatures,
          ),
          _buildOptionCard(
            theme: theme,
            icon: Icons.computer_rounded,
            title: l10n.useOllama,
            description: l10n.ollamaNeedsInstall,
            selected: _aiChoice == _AiChoice.ollama,
            onTap: () => _selectAiChoice(_AiChoice.ollama),
            badge: 'Free',
          ),
          const SizedBox(height: 10),
          _buildOptionCard(
            theme: theme,
            icon: Icons.cloud_rounded,
            title: l10n.useOpenAI,
            description: l10n.openAiDescription,
            selected: _aiChoice == _AiChoice.openai,
            onTap: () => _selectAiChoice(_AiChoice.openai),
          ),
          const SizedBox(height: 10),
          _buildOptionCard(
            theme: theme,
            icon: Icons.auto_awesome_rounded,
            title: l10n.useGoogleAI,
            description: l10n.googleAiDescription,
            selected: _aiChoice == _AiChoice.google,
            onTap: () => _selectAiChoice(_AiChoice.google),
          ),
          const SizedBox(height: 10),
          _buildOptionCard(
            theme: theme,
            icon: Icons.do_not_disturb_rounded,
            title: l10n.skipForNow,
            description: l10n.configureInSettings,
            selected: _aiChoice == _AiChoice.skip,
            onTap: () => _selectAiChoice(_AiChoice.skip),
          ),
          const SizedBox(height: 24),
          _buildContinueButton(
            theme: theme,
            label: l10n.btnContinue,
            enabled: _aiChoice != null && !_aiDetailLoading,
            loading: _aiDetailLoading,
            onPressed: _continueFromAiProvider,
          ),
        ],
      ),
    );
  }

  // ── AI detail ──────────────────────────────────────

  Widget _buildAiDetailStep(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    if (_aiChoice == _AiChoice.ollama) {
      return _buildOllamaDetailStep(theme, l10n);
    } else if (_aiChoice == _AiChoice.openai) {
      return _buildApiKeyStep(
        theme: theme,
        l10n: l10n,
        title: l10n.openAiApiKeyTitle,
        subtitle: l10n.enterOpenAiKey,
        icon: Icons.key_rounded,
        hint: l10n.openAiApiKeyHint,
        helpUrl: 'https://platform.openai.com/api-keys',
        helpLabel: l10n.getApiKeyOpenAI,
      );
    } else if (_aiChoice == _AiChoice.google) {
      return _buildApiKeyStep(
        theme: theme,
        l10n: l10n,
        title: l10n.googleAiApiKeyTitle,
        subtitle: l10n.enterGoogleKey,
        icon: Icons.vpn_key_rounded,
        hint: l10n.googleAiApiKeyHint,
        helpUrl: 'https://aistudio.google.com/app/apikey',
        helpLabel: l10n.getApiKeyGoogle,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildOllamaDetailStep(ThemeData theme, AppLocalizations l10n) {
    if (!_isOllamaAvailable) {
      // Ollama not installed — show install instructions.
      return _buildCard(
        theme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStepHeader(
              theme: theme,
              icon: Icons.install_desktop_rounded,
              title: l10n.installOllamaTitle,
              subtitle: l10n.installOllamaMessage,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTerminalRow('1', l10n.visitOllama),
                  const SizedBox(height: 10),
                  _buildTerminalRow('2', l10n.downloadInstall),
                  const SizedBox(height: 10),
                  _buildTerminalRow('3', l10n.restartApp),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await launchUrl(
                    Uri.parse('https://ollama.com'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(l10n.openOllamaWebsite),
              ),
            ),
            const SizedBox(height: 24),
            _buildContinueButton(
              theme: theme,
              label: l10n.btnContinue,
              enabled: true,
              loading: false,
              onPressed: _continueFromAiDetail,
            ),
          ],
        ),
      );
    } else if (_ollamaModels.isEmpty) {
      // Ollama installed but no models — show install command.
      const defaultModel = 'hf.co/unsloth/gemma-3-4b-it-qat-int4-GGUF:Q4_K_M';
      return _buildCard(
        theme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStepHeader(
              theme: theme,
              icon: Icons.model_training_rounded,
              title: l10n.installAiModel,
              subtitle: l10n.installModelMessage,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const SelectableText(
                'ollama pull $defaultModel',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildContinueButton(
              theme: theme,
              label: l10n.btnContinue,
              enabled: true,
              loading: false,
              onPressed: () async {
                setState(() => _selectedOllamaModel = null);
                await _continueFromAiDetail();
              },
            ),
          ],
        ),
      );
    } else {
      // Ollama installed + models available — show model selection.
      return _buildCard(
        theme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStepHeader(
              theme: theme,
              icon: Icons.model_training_rounded,
              title: l10n.selectAiModel,
              subtitle: l10n.chooseModel,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _ollamaModels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final model = _ollamaModels[i];
                  return _buildOptionCard(
                    theme: theme,
                    icon: Icons.memory_rounded,
                    title: model.name,
                    description:
                        model.size.isNotEmpty ? model.size : model.details,
                    selected: _selectedOllamaModel == model.name,
                    onTap: () =>
                        setState(() => _selectedOllamaModel = model.name),
                    badge: i == 0 ? l10n.recommended : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildContinueButton(
              theme: theme,
              label: l10n.btnContinue,
              enabled: _selectedOllamaModel != null,
              loading: false,
              onPressed: _continueFromAiDetail,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildApiKeyStep({
    required ThemeData theme,
    required AppLocalizations l10n,
    required String title,
    required String subtitle,
    required IconData icon,
    required String hint,
    required String helpUrl,
    required String helpLabel,
  }) {
    return _buildCard(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepHeader(
            theme: theme,
            icon: icon,
            title: title,
            subtitle: subtitle,
          ),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            style:
                theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: hint,
              labelText: l10n.apiKeyLabel,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
              prefixIcon: const Icon(Icons.vpn_key_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscureApiKey
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded),
                onPressed: () =>
                    setState(() => _obscureApiKey = !_obscureApiKey),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              await launchUrl(
                Uri.parse(helpUrl),
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: Text(helpLabel),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(height: 24),
          _buildContinueButton(
            theme: theme,
            label: l10n.save,
            enabled: true,
            loading: false,
            onPressed: _continueFromAiDetail,
          ),
        ],
      ),
    );
  }

  // ── Download path ──────────────────────────────────

  Widget _buildDownloadPathStep(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepHeader(
            theme: theme,
            icon: Icons.folder_special_rounded,
            title: l10n.initialConfiguration,
            subtitle: l10n.selectDownloadFolderMessage,
          ),
          // Selected path display
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _downloadPath != null
                  ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                  : theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _downloadPath != null
                    ? theme.colorScheme.primary.withOpacity(0.4)
                    : theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _downloadPath != null
                      ? Icons.check_rounded
                      : Icons.folder_outlined,
                  color: _downloadPath != null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _downloadPath ?? l10n.folderNotSelected,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _downloadPath != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontFamily: _downloadPath != null ? 'monospace' : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickFolder,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.create_new_folder_rounded, size: 18),
              label: Text(l10n.chooseFolder),
            ),
          ),
          const SizedBox(height: 24),
          _buildContinueButton(
            theme: theme,
            label: l10n.btnContinue,
            enabled: _downloadPath != null,
            loading: false,
            onPressed: _continueFromDownloadPath,
          ),
        ],
      ),
    );
  }

  // ── Progress ───────────────────────────────────────

  Widget _buildProgressStep(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepHeader(
            theme: theme,
            icon: _allBinariesDone
                ? Icons.check_circle_rounded
                : Icons.downloading_rounded,
            title:
                _allBinariesDone ? l10n.statusReady : l10n.checkingComponents,
            subtitle: _allBinariesDone ? l10n.almostReady : l10n.initialization,
          ),
          _buildBinaryRow(
              theme, l10n, 'ytdlp', 'yt-dlp', Icons.video_library_rounded),
          const SizedBox(height: 12),
          _buildBinaryRow(
              theme, l10n, 'ffmpeg', 'FFmpeg', Icons.settings_rounded),
          const SizedBox(height: 12),
          _buildBinaryRow(theme, l10n, 'deno', 'Deno', Icons.code_rounded),
          if (_binaryError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: theme.colorScheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _binaryError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBinaryRow(ThemeData theme, AppLocalizations l10n, String key,
      String label, IconData icon) {
    final done = _binaryDone[key] ?? false;
    final progress = _binaryProgress[key] ?? 0.0;
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: done
                ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            done ? Icons.check_rounded : icon,
            size: 18,
            color: done
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  Text(
                    done
                        ? l10n.statusReady
                        : (progress > 0
                            ? '${(progress * 100).toStringAsFixed(0)}%'
                            : l10n.statusInitializing),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: done
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: done ? 1.0 : (progress > 0 ? progress : null),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    done
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.6),
                  ),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTerminalRow(String step, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
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

  // ══════════════════════════════════════════════════
  //  Build
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_initialized) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_step == _StartupStep.language) _buildAppBrand(theme),
                  const SizedBox(height: 36),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: animation, curve: Curves.easeOut));
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _buildCurrentStep(theme),
                    ),
                  ),
                  if (_step != _StartupStep.progress) ...[
                    const SizedBox(height: 28),
                    _buildStepDots(theme),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
