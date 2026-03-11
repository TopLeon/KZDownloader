import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/core/providers/theme_provider.dart';

import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/core/providers/locale_provider.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/views/chat/widgets/header.dart';
import 'package:kzdownloader/views/chat/widgets/headers/category_header.dart';
import 'package:kzdownloader/core/services/llm_service.dart';
import 'package:kzdownloader/core/services/secure_storage_service.dart';
import 'package:kzdownloader/views/widgets/confirm_dialog.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

class _StyledInputContainer extends StatelessWidget {
  final Widget child;
  const _StyledInputContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: child,
    );
  }
}

class _StyledLabel extends StatelessWidget {
  final String label;
  const _StyledLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style:
            GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 13),
      ),
    );
  }
}

class OllamaModelSelector extends ConsumerStatefulWidget {
  const OllamaModelSelector({super.key});

  @override
  ConsumerState<OllamaModelSelector> createState() =>
      _OllamaModelSelectorState();
}

class _OllamaModelSelectorState extends ConsumerState<OllamaModelSelector> {
  List<OllamaModelInfo> _models = [];
  bool _loading = false;
  String? _error;
  String _currentProvider = 'ollama';
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;
  final SettingsService _settingsService = SettingsService();
  int _maxCharactersForAI = 25000;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final settings = ref.read(settingsServiceProvider);
    final provider = await settings.getAiProvider();
    final maxChars = await _settingsService.getMaxCharactersForAI();

    String? apiKey;
    if (provider == 'openai') {
      apiKey = await ref
          .read(secureStorageServiceProvider)
          .readSecureData(StorageKeys.openAiApiKey);
      if (apiKey != null) _apiKeyController.text = apiKey;
    } else if (provider == 'google') {
      apiKey = await ref
          .read(secureStorageServiceProvider)
          .readSecureData(StorageKeys.googleApiKey);
      if (apiKey != null) _apiKeyController.text = apiKey;
    }

    setState(() {
      _currentProvider = provider;
      _maxCharactersForAI = maxChars;
    });

    _configureLlmService(provider, apiKey);
    _loadModels(provider);
  }

  void _configureLlmService(String providerName, String? apiKey) {
    LlmProvider provider;
    switch (providerName) {
      case 'openai':
        provider = LlmProvider.openai;
        break;
      case 'google':
        provider = LlmProvider.google;
        break;
      case 'ollama':
      default:
        provider = LlmProvider.ollama;
        break;
    }
    LlmService().setProvider(provider, apiKey: apiKey);
  }

  Future<void> _loadModels(String provider) async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final models = await LlmService().fetchAvailableModels();
      setState(() {
        _models = models;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isNotEmpty) {
      if (_currentProvider == 'openai') {
        await ref
            .read(secureStorageServiceProvider)
            .writeSecureData(StorageKeys.openAiApiKey, key);
        LlmService().setProvider(LlmProvider.openai, apiKey: key);
      } else if (_currentProvider == 'google') {
        await ref
            .read(secureStorageServiceProvider)
            .writeSecureData(StorageKeys.googleApiKey, key);
        LlmService().setProvider(LlmProvider.google, apiKey: key);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.apiKeySaved),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = ref.watch(settingsServiceProvider);
    final currentModelFetch = settingsService.selectedAiModel;
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder(
        future: currentModelFetch,
        builder: (context, asyncSnapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StyledLabel(l10n.aiProvider),
                        CustomDropdown<String>(
                          decoration: CustomDropdownDecoration(
                              closedFillColor: colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.3),
                              expandedFillColor: colorScheme.surface,
                              closedBorder: Border.all(
                                  color: colorScheme.outlineVariant
                                      .withOpacity(0.5)),
                              expandedBorder: Border.all(
                                  color: colorScheme.primary.withOpacity(0.15)),
                              closedBorderRadius: BorderRadius.circular(8),
                              expandedBorderRadius: BorderRadius.circular(8),
                              listItemDecoration: ListItemDecoration(
                                splashColor:
                                    colorScheme.primary.withOpacity(0.05),
                                highlightColor:
                                    colorScheme.primary.withOpacity(0.05),
                              )),
                          items: [
                            l10n.aiProviderOllama,
                            l10n.aiProviderOpenAI,
                            l10n.aiProviderGoogle,
                          ],
                          headerBuilder: (context, selectedItem, enabled) {
                            FIconObject icon;
                            if (selectedItem == l10n.aiProviderOllama) {
                              icon = RI.RiChatAiFill;
                            } else if (selectedItem == l10n.aiProviderOpenAI) {
                              icon = RI.RiOpenaiFill;
                            } else {
                              icon = RI.RiGeminiFill;
                            }
                            return Row(
                              children: [
                                FIcon(icon),
                                const SizedBox(width: 8),
                                Text(selectedItem)
                              ],
                            );
                          },
                          listItemBuilder:
                              (context, item, isSelected, onItemSelect) {
                            FIconObject icon;
                            if (item == l10n.aiProviderOllama) {
                              icon = RI.RiChatAiLine;
                            } else if (item == l10n.aiProviderOpenAI) {
                              icon = RI.RiOpenaiLine;
                            } else {
                              icon = RI.RiGeminiLine;
                            }
                            return Row(
                              children: [
                                FIcon(icon),
                                const SizedBox(width: 8),
                                Text(item)
                              ],
                            );
                          },
                          initialItem: _currentProvider == 'ollama'
                              ? l10n.aiProviderOllama
                              : _currentProvider == 'openai'
                                  ? l10n.aiProviderOpenAI
                                  : l10n.aiProviderGoogle,
                          onChanged: (val) async {
                            if (val != null) {
                              final providerValue = val == l10n.aiProviderOllama
                                  ? 'ollama'
                                  : val == l10n.aiProviderOpenAI
                                      ? 'openai'
                                      : 'google';
                              setState(() {
                                _currentProvider = providerValue;
                              });
                              await settingsService
                                  .setAiProvider(providerValue);

                              String? apiKey;
                              if (providerValue == 'openai') {
                                apiKey = await ref
                                    .read(secureStorageServiceProvider)
                                    .readSecureData(StorageKeys.openAiApiKey);
                                _apiKeyController.text = apiKey ?? '';
                              } else if (providerValue == 'google') {
                                apiKey = await ref
                                    .read(secureStorageServiceProvider)
                                    .readSecureData(StorageKeys.googleApiKey);
                                _apiKeyController.text = apiKey ?? '';
                              }

                              _configureLlmService(providerValue, apiKey);
                              _loadModels(providerValue);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_currentProvider == 'openai' ||
                      _currentProvider == 'google')
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StyledLabel(_currentProvider == 'openai'
                              ? l10n.openAiApiKey
                              : l10n.googleAiApiKey),
                          _StyledInputContainer(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: TextField(
                                      controller: _apiKeyController,
                                      obscureText: _obscureApiKey,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: _currentProvider == 'openai'
                                            ? l10n.openAiApiKeyHint
                                            : l10n.googleAiApiKeyHint,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: FIcon(
                                    _obscureApiKey
                                        ? RI.RiEyeLine
                                        : RI.RiEyeOffLine,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscureApiKey = !_obscureApiKey),
                                ),
                                IconButton(
                                  icon: FIcon(
                                    RI.RiSaveLine,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                  onPressed: _saveApiKey,
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Spacer(flex: 2),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StyledLabel(l10n.selectModel),
                        if (_loading)
                          const Center(
                              child: LinearProgressIndicator(minHeight: 2))
                        else if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                                color:
                                    colorScheme.errorContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: colorScheme.error),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(_error!,
                                        style: const TextStyle(fontSize: 13))),
                                IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () =>
                                        _loadModels(_currentProvider))
                              ],
                            ),
                          )
                        else if (_models.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline),
                                const SizedBox(width: 8),
                                Expanded(child: Text(l10n.noModelsFound)),
                                IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () =>
                                        _loadModels(_currentProvider))
                              ],
                            ),
                          )
                        else
                          CustomDropdown<OllamaModelInfo>(
                            decoration: CustomDropdownDecoration(
                                closedFillColor: colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.3),
                                expandedFillColor: colorScheme.surface,
                                closedBorder: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withOpacity(0.5)),
                                expandedBorder: Border.all(
                                    color:
                                        colorScheme.primary.withOpacity(0.15)),
                                closedBorderRadius: BorderRadius.circular(8),
                                expandedBorderRadius: BorderRadius.circular(8),
                                listItemDecoration: ListItemDecoration(
                                  splashColor:
                                      colorScheme.primary.withOpacity(0.05),
                                  highlightColor:
                                      colorScheme.primary.withOpacity(0.05),
                                )),
                            hintText: l10n.selectModel,
                            items: _models,
                            initialItem:
                                _models.any((m) => m.name == asyncSnapshot.data)
                                    ? _models.firstWhere(
                                        (m) => m.name == asyncSnapshot.data)
                                    : null,
                            listItemBuilder:
                                (context, item, isSelected, onItemSelect) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.details,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? colorScheme.primary
                                              : null,
                                        ),
                                      ),
                                    ),
                                    if (item.size != '-')
                                      Text(
                                        item.size,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                            headerBuilder: (context, selectedItem, c) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedItem.details,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (selectedItem.size != '-')
                                    Text(
                                      selectedItem.size,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              );
                            },
                            onChanged: (val) {
                              if (val != null) {
                                ref
                                    .read(settingsServiceProvider)
                                    .setAiModel(val.name);
                                LlmService().setModel(val.name);
                                setState(() {});
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StyledLabel(l10n.maxCharactersForAI),
                        CustomDropdown<int>(
                          decoration: CustomDropdownDecoration(
                              closedFillColor: colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.3),
                              expandedFillColor: colorScheme.surface,
                              closedBorder: Border.all(
                                  color: colorScheme.outlineVariant
                                      .withOpacity(0.5)),
                              expandedBorder: Border.all(
                                  color: colorScheme.primary.withOpacity(0.15)),
                              closedBorderRadius: BorderRadius.circular(8),
                              expandedBorderRadius: BorderRadius.circular(8),
                              listItemDecoration: ListItemDecoration(
                                splashColor:
                                    colorScheme.primary.withOpacity(0.05),
                                highlightColor:
                                    colorScheme.primary.withOpacity(0.05),
                              )),
                          items: const [5000, 25000, 50000, 75000, 100000],
                          initialItem: _maxCharactersForAI,
                          headerBuilder: (context, selectedItem, c) {
                            return Row(
                              children: [
                                const FIcon(RI.RiText, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  '${(selectedItem / 1000).toStringAsFixed(0)}k',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                          listItemBuilder:
                              (context, item, isSelected, onItemSelect) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Text(
                                '${(item / 1000).toStringAsFixed(0)}k',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isSelected ? colorScheme.primary : null,
                                ),
                              ),
                            );
                          },
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() => _maxCharactersForAI = newValue);
                              _settingsService.setMaxCharactersForAI(newValue);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Spacer(),
                ],
              ),
            ],
          );
        });
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onAddUrl;

  const SettingsScreen({super.key, this.onAddUrl});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _downloadPath;
  DownloadFormat _format = DownloadFormat.mp4;
  DownloadFormat _audioFormat = DownloadFormat.mp3;
  int _maxConcurrentDownloads = 3;
  int _maxConcurrentGlobalDownloads = 3;
  String _defaultQuality = 'best';

  bool _summaryAnimationsEnabled = true;
  final SettingsService _settingsService = SettingsService();

  // Advanced options state
  bool _proxyEnabled = false;
  String _proxyType = 'http';
  bool _speedGraphEnabled = true;
  final TextEditingController _speedLimitController = TextEditingController();
  final TextEditingController _proxyHostController = TextEditingController();
  final TextEditingController _proxyPortController = TextEditingController();
  final TextEditingController _proxyUsernameController =
      TextEditingController();
  final TextEditingController _proxyPasswordController =
      TextEditingController();
  final TextEditingController _userAgentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _speedLimitController.dispose();
    _proxyHostController.dispose();
    _proxyPortController.dispose();
    _proxyUsernameController.dispose();
    _proxyPasswordController.dispose();
    _userAgentController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final path = await _settingsService.getDownloadPath();
    final format = await _settingsService.getDefaultFormat();
    final audioFormat = await _settingsService.getDefaultAudioFormat();
    final maxConcurrent = await _settingsService.getMaxConcurrentDownloads();
    final summaryAnimations =
        await _settingsService.getSummaryAnimationsEnabled();
    final maxConcurrentGlobal =
        await _settingsService.getMaxConcurrentGlobalDownloads();
    final defaultQuality = await _settingsService.getDefaultQuality();

    // Advanced settings
    final proxyEnabled = await _settingsService.getProxyEnabled();
    final proxyType = await _settingsService.getProxyType();
    final proxyHost = await _settingsService.getProxyHost();
    final proxyPort = await _settingsService.getProxyPort();
    final proxyUsername = await _settingsService.getProxyUsername();
    final proxyPassword = await _settingsService.getProxyPassword();
    final speedLimitBps = await _settingsService.getGlobalSpeedLimitBps();
    final customUserAgent = await _settingsService.getCustomUserAgent();
    final speedGraphEnabled = await _settingsService.getSpeedGraphEnabled();

    if (mounted) {
      setState(() {
        _downloadPath = path;
        _format = format;
        _audioFormat = audioFormat;
        _maxConcurrentDownloads = maxConcurrent;
        _maxConcurrentGlobalDownloads = maxConcurrentGlobal;
        _summaryAnimationsEnabled = summaryAnimations;
        _defaultQuality = defaultQuality;

        _proxyEnabled = proxyEnabled;
        _proxyType = proxyType;
        _speedGraphEnabled = speedGraphEnabled;
        if (proxyHost.isNotEmpty) _proxyHostController.text = proxyHost;
        if (proxyPort > 0) _proxyPortController.text = proxyPort.toString();
        if (proxyUsername.isNotEmpty)
          _proxyUsernameController.text = proxyUsername;
        if (proxyPassword.isNotEmpty)
          _proxyPasswordController.text = proxyPassword;
        if (speedLimitBps > 0)
          _speedLimitController.text = (speedLimitBps ~/ 1024).toString();
        if (customUserAgent != null && customUserAgent.isNotEmpty) {
          _userAgentController.text = customUserAgent;
        }
      });
    }
  }

  Future<void> _pickDownloadPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      await _settingsService.setDownloadPath(selectedDirectory);
      if (mounted) {
        setState(() {
          _downloadPath = selectedDirectory;
        });
      }
    }
  }

  void _showClearHistoryDialog() {
    final l10n = AppLocalizations.of(context)!;
    showConfirmDialog(
      context,
      title: l10n.clearHistoryTitle,
      content: l10n.clearHistoryContent,
      confirmText: l10n.clear,
      cancelText: l10n.btnCancel,
      onConfirm: () {
        ref.read(downloadListProvider.notifier).clearHistory();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.historyCleared),
            width: 200,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8))));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final localeAsync = ref.watch(localeProvider);
    final currentLocale = localeAsync.asData?.value;

    return Column(children: [
      CategoryHeader(
        category: TaskCategory.settings,
        onAddUrl: widget.onAddUrl,
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
          children: [
            SectionHeader(title: l10n.settingsGeneral, icon: Icons.tune),
            const SizedBox(height: 8),

            // Download Path
            _StyledLabel(l10n.downloadPath),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        _downloadPath ?? l10n.defaultDownloadPath,
                        style: TextStyle(
                            color: colorScheme.onSurface, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _pickDownloadPath,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: colorScheme.outlineVariant
                                    .withOpacity(0.3))),
                      ),
                      child: FIcon(
                        RI.RiFolderOpenLine,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.downloadPathDescription,
              style:
                  TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),

            const SizedBox(height: 20),

            // Format & Quality Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StyledLabel(l10n.defaultFormat),
                      CustomDropdown<DownloadFormat>(
                        decoration: CustomDropdownDecoration(
                            closedFillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            expandedFillColor: colorScheme.surface,
                            closedBorder: Border.all(
                                color: colorScheme.outlineVariant
                                    .withOpacity(0.5)),
                            expandedBorder: Border.all(
                                color: colorScheme.primary.withOpacity(0.15)),
                            closedBorderRadius: BorderRadius.circular(8),
                            expandedBorderRadius: BorderRadius.circular(8),
                            listItemDecoration: ListItemDecoration(
                              splashColor:
                                  colorScheme.primary.withOpacity(0.05),
                              highlightColor:
                                  colorScheme.primary.withOpacity(0.05),
                            )),
                        items: DownloadFormat.values
                            .where((x) =>
                                x != DownloadFormat.mp3 &&
                                x != DownloadFormat.m4a &&
                                x != DownloadFormat.ogg)
                            .toList(),
                        initialItem: _format,
                        headerBuilder: (context, selectedItem, c) {
                          return Row(
                            children: [
                              const FIcon(RI.RiVideoFill, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                selectedItem.name.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                        listItemBuilder:
                            (context, item, isSelected, onItemSelect) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Text(
                              item.name.toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? colorScheme.primary : null,
                              ),
                            ),
                          );
                        },
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => _format = newValue);
                            _settingsService.setDefaultFormat(newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StyledLabel(l10n.defaultAudioFormat),
                      CustomDropdown<DownloadFormat>(
                        decoration: CustomDropdownDecoration(
                            closedFillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            expandedFillColor: colorScheme.surface,
                            closedBorder: Border.all(
                                color: colorScheme.outlineVariant
                                    .withOpacity(0.5)),
                            expandedBorder: Border.all(
                                color: colorScheme.primary.withOpacity(0.15)),
                            closedBorderRadius: BorderRadius.circular(8),
                            expandedBorderRadius: BorderRadius.circular(8),
                            listItemDecoration: ListItemDecoration(
                              splashColor:
                                  colorScheme.primary.withOpacity(0.05),
                              highlightColor:
                                  colorScheme.primary.withOpacity(0.05),
                            )),
                        items: DownloadFormat.values
                            .where((x) =>
                                x == DownloadFormat.mp3 ||
                                x == DownloadFormat.m4a ||
                                x == DownloadFormat.ogg)
                            .toList(),
                        initialItem: _audioFormat,
                        headerBuilder: (context, selectedItem, c) {
                          return Row(
                            children: [
                              const FIcon(RI.RiMusicFill, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                selectedItem.name.toUpperCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                        listItemBuilder:
                            (context, item, isSelected, onItemSelect) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Text(
                              item.name.toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? colorScheme.primary : null,
                              ),
                            ),
                          );
                        },
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => _audioFormat = newValue);
                            _settingsService.setDefaultAudioFormat(newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StyledLabel(l10n.defaultQuality),
                      CustomDropdown<String>(
                        decoration: CustomDropdownDecoration(
                            closedFillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            expandedFillColor: colorScheme.surface,
                            closedBorder: Border.all(
                                color: colorScheme.outlineVariant
                                    .withOpacity(0.5)),
                            expandedBorder: Border.all(
                                color: colorScheme.primary.withOpacity(0.15)),
                            closedBorderRadius: BorderRadius.circular(8),
                            expandedBorderRadius: BorderRadius.circular(8),
                            listItemDecoration: ListItemDecoration(
                              splashColor:
                                  colorScheme.primary.withOpacity(0.05),
                              highlightColor:
                                  colorScheme.primary.withOpacity(0.05),
                            )),
                        items: const [
                          'best',
                          '1080p',
                          '720p',
                          '480p',
                        ],
                        initialItem: _defaultQuality,
                        headerBuilder: (context, selectedItem, c) {
                          String displayText;
                          switch (selectedItem) {
                            case 'best':
                              displayText = l10n.qualityBest;
                              break;
                            case '1080p':
                              displayText = '1080p';
                              break;
                            case '720p':
                              displayText = '720p';
                              break;
                            case '480p':
                              displayText = '480p';
                              break;
                            default:
                              displayText = selectedItem;
                          }
                          return Row(
                            children: [
                              const FIcon(RI.RiHdFill, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                displayText,
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                        listItemBuilder:
                            (context, item, isSelected, onItemSelect) {
                          String displayText;
                          switch (item) {
                            case 'best':
                              displayText = l10n.qualityBest;
                              break;
                            default:
                              displayText = item;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Text(
                              displayText,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? colorScheme.primary : null,
                              ),
                            ),
                          );
                        },
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => _defaultQuality = newValue);
                            _settingsService.setDefaultQuality(newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Settings Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StyledLabel(l10n.concurrentDownloadsPlaylist),
                      CustomDropdown<int>(
                        decoration: CustomDropdownDecoration(
                            closedFillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            expandedFillColor: colorScheme.surface,
                            closedBorder: Border.all(
                                color: colorScheme.outlineVariant
                                    .withOpacity(0.5)),
                            expandedBorder: Border.all(
                                color: colorScheme.primary.withOpacity(0.15)),
                            closedBorderRadius: BorderRadius.circular(8),
                            expandedBorderRadius: BorderRadius.circular(8),
                            listItemDecoration: ListItemDecoration(
                              splashColor:
                                  colorScheme.primary.withOpacity(0.05),
                              highlightColor:
                                  colorScheme.primary.withOpacity(0.05),
                            )),
                        items: const [1, 2, 3, 4, 5, 6, 8, 10],
                        initialItem: _maxConcurrentDownloads,
                        headerBuilder: (context, selectedItem, c) {
                          return Row(
                            children: [
                              const FIcon(RI.RiDownloadFill, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '$selectedItem',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                        listItemBuilder:
                            (context, item, isSelected, onItemSelect) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Text(
                              '$item',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? colorScheme.primary : null,
                              ),
                            ),
                          );
                        },
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => _maxConcurrentDownloads = newValue);
                            _settingsService
                                .setMaxConcurrentDownloads(newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StyledLabel(l10n.concurrentDownloadsGlobal),
                      CustomDropdown<int>(
                        decoration: CustomDropdownDecoration(
                            closedFillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            expandedFillColor: colorScheme.surface,
                            closedBorder: Border.all(
                                color: colorScheme.outlineVariant
                                    .withOpacity(0.5)),
                            expandedBorder: Border.all(
                                color: colorScheme.primary.withOpacity(0.15)),
                            closedBorderRadius: BorderRadius.circular(8),
                            expandedBorderRadius: BorderRadius.circular(8),
                            listItemDecoration: ListItemDecoration(
                              splashColor:
                                  colorScheme.primary.withOpacity(0.05),
                              highlightColor:
                                  colorScheme.primary.withOpacity(0.05),
                            )),
                        items: const [1, 2, 3, 4, 5, 6, 8, 10],
                        initialItem: _maxConcurrentGlobalDownloads,
                        headerBuilder: (context, selectedItem, c) {
                          return Row(
                            children: [
                              const FIcon(RI.RiDownloadFill, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '$selectedItem',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                        listItemBuilder:
                            (context, item, isSelected, onItemSelect) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Text(
                              '$item',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? colorScheme.primary : null,
                              ),
                            ),
                          );
                        },
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(
                                () => _maxConcurrentGlobalDownloads = newValue);
                            _settingsService
                                .setMaxConcurrentGlobalDownloads(newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StyledLabel(l10n.language),
                      CustomDropdown<String>(
                        decoration: CustomDropdownDecoration(
                            closedFillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            expandedFillColor: colorScheme.surface,
                            closedBorder: Border.all(
                                color: colorScheme.outlineVariant
                                    .withOpacity(0.5)),
                            expandedBorder: Border.all(
                                color: colorScheme.primary.withOpacity(0.15)),
                            closedBorderRadius: BorderRadius.circular(8),
                            expandedBorderRadius: BorderRadius.circular(8),
                            listItemDecoration: ListItemDecoration(
                              splashColor:
                                  colorScheme.primary.withOpacity(0.05),
                              highlightColor:
                                  colorScheme.primary.withOpacity(0.05),
                            )),
                        items: const ['English', 'Italiano'],
                        initialItem: currentLocale?.languageCode == 'it'
                            ? 'Italiano'
                            : 'English',
                        headerBuilder: (context, selectedItem, c) {
                          return Row(
                            children: [
                              const FIcon(RI.RiTranslate, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                selectedItem,
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          );
                        },
                        listItemBuilder:
                            (context, item, isSelected, onItemSelect) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Text(
                              item,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w400,
                                color: isSelected ? colorScheme.primary : null,
                              ),
                            ),
                          );
                        },
                        onChanged: (val) {
                          if (val != null) {
                            final locale = val == 'Italiano' ? 'it' : 'en';
                            ref
                                .read(localeProvider.notifier)
                                .setLocale(Locale(locale));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            SectionHeader(title: l10n.advancedOptions, icon: Icons.build),
            const SizedBox(height: 8),

            // Speed Limit
            _StyledLabel(l10n.globalSpeedLimit),
            _StyledInputContainer(
              child: TextField(
                controller: _speedLimitController,
                decoration: InputDecoration(
                  hintText: l10n.speedLimitHint,
                  suffixText: 'KB/s',
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                style: GoogleFonts.montserrat(fontSize: 13),
                onChanged: (val) {
                  final kbps = int.tryParse(val) ?? 0;
                  _settingsService.setGlobalSpeedLimitBps(kbps * 1024);
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.speedLimitDescription,
              style:
                  TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),

            const SizedBox(height: 20),

            // Proxy Settings
            _StyledLabel(l10n.proxySettings),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.enableProxy,
                          style: GoogleFonts.montserrat(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      Switch(
                        value: _proxyEnabled,
                        onChanged: (val) {
                          setState(() => _proxyEnabled = val);
                          _settingsService.setProxyEnabled(val);
                        },
                      ),
                    ],
                  ),
                  if (_proxyEnabled) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StyledLabel(l10n.proxyType),
                              CustomDropdown<String>(
                                decoration: CustomDropdownDecoration(
                                    closedFillColor: colorScheme
                                        .surfaceContainerHighest
                                        .withOpacity(0.3),
                                    expandedFillColor: colorScheme.surface,
                                    closedBorder: Border.all(
                                        color: colorScheme.outlineVariant
                                            .withOpacity(0.5)),
                                    expandedBorder: Border.all(
                                        color: colorScheme.primary
                                            .withOpacity(0.15)),
                                    closedBorderRadius:
                                        BorderRadius.circular(8),
                                    expandedBorderRadius:
                                        BorderRadius.circular(8),
                                    listItemDecoration: ListItemDecoration(
                                      splashColor:
                                          colorScheme.primary.withOpacity(0.05),
                                      highlightColor:
                                          colorScheme.primary.withOpacity(0.05),
                                    )),
                                items: const ['http', 'socks5'],
                                initialItem: _proxyType,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _proxyType = val);
                                    _settingsService.setProxyType(val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StyledLabel(l10n.proxyHost),
                              _StyledInputContainer(
                                child: TextField(
                                  controller: _proxyHostController,
                                  decoration: InputDecoration(
                                    hintText: '127.0.0.1',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  style: GoogleFonts.montserrat(fontSize: 13),
                                  onChanged: (val) =>
                                      _settingsService.setProxyHost(val),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StyledLabel(l10n.proxyPort),
                              _StyledInputContainer(
                                child: TextField(
                                  controller: _proxyPortController,
                                  decoration: InputDecoration(
                                    hintText: '8080',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.montserrat(fontSize: 13),
                                  onChanged: (val) {
                                    final port = int.tryParse(val) ?? 0;
                                    _settingsService.setProxyPort(port);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StyledLabel(l10n.proxyUsername),
                              _StyledInputContainer(
                                child: TextField(
                                  controller: _proxyUsernameController,
                                  decoration: InputDecoration(
                                    hintText: l10n.optional,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  style: GoogleFonts.montserrat(fontSize: 13),
                                  onChanged: (val) =>
                                      _settingsService.setProxyUsername(val),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StyledLabel(l10n.proxyPassword),
                              _StyledInputContainer(
                                child: TextField(
                                  controller: _proxyPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: l10n.optional,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  style: GoogleFonts.montserrat(fontSize: 13),
                                  onChanged: (val) =>
                                      _settingsService.setProxyPassword(val),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Custom User-Agent
            _StyledLabel(l10n.customUserAgent),
            _StyledInputContainer(
              child: TextField(
                controller: _userAgentController,
                decoration: InputDecoration(
                  hintText: l10n.userAgentHint,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: GoogleFonts.montserrat(fontSize: 13),
                onChanged: (val) => _settingsService.setCustomUserAgent(val),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.userAgentDescription,
              style:
                  TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),

            const SizedBox(height: 20),

            // Speed Graph Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.speedGraph,
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(l10n.speedGraphDescription,
                          style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  Switch(
                    value: _speedGraphEnabled,
                    onChanged: (val) {
                      setState(() => _speedGraphEnabled = val);
                      _settingsService.setSpeedGraphEnabled(val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            SectionHeader(title: l10n.settingsAI, icon: Icons.psychology),
            const SizedBox(height: 8),
            const OllamaModelSelector(),

            const SizedBox(height: 48),

            SectionHeader(title: l10n.settingsAppearance, icon: Icons.palette),
            const SizedBox(height: 8),

            // _StyledLabel(l10n.theme),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.selectThemeTitle,
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      Text(l10n.settingsAppearanceSubtitle,
                          style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ThemeButton(
                          icon: RI.RiMagicLine,
                          mode: ThemeMode.system,
                          current: ref.watch(themeProvider).asData?.value ??
                              ThemeMode.system,
                          onTap: (m) =>
                              ref.read(themeProvider.notifier).setThemeMode(m),
                        ),
                        const SizedBox(width: 4),
                        _ThemeButton(
                          icon: RI.RiSunLine,
                          mode: ThemeMode.light,
                          current: ref.watch(themeProvider).asData?.value ??
                              ThemeMode.system,
                          onTap: (m) =>
                              ref.read(themeProvider.notifier).setThemeMode(m),
                        ),
                        const SizedBox(width: 4),
                        _ThemeButton(
                          icon: RI.RiMoonLine,
                          mode: ThemeMode.dark,
                          current: ref.watch(themeProvider).asData?.value ??
                              ThemeMode.system,
                          onTap: (m) =>
                              ref.read(themeProvider.notifier).setThemeMode(m),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Summary Animations Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.summaryAnimations,
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500, fontSize: 13)),
                        Text(l10n.summaryAnimationsSubtitle,
                            style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _summaryAnimationsEnabled,
                      onChanged: (value) async {
                        await _settingsService
                            .setSummaryAnimationsEnabled(value);
                        setState(() {
                          _summaryAnimationsEnabled = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            SectionHeader(title: l10n.settingsDataStorage, icon: Icons.storage),
            const SizedBox(height: 8),

            InkWell(
              onTap: _showClearHistoryDialog,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(
                      Theme.of(context).brightness == Brightness.dark
                          ? 0.1
                          : 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    FIcon(
                      RI.RiDeleteBinLine,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.clearDownloadHistory,
                            style: GoogleFonts.montserrat(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            l10n.clearDownloadHistorySubtitle,
                            style: GoogleFonts.montserrat(
                              color: colorScheme.error.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        color: colorScheme.error.withOpacity(0.5)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Version info
            Center(
              child: Column(
                children: [
                  Text(
                    l10n.versionInfo,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.copyright,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    ]);
  }
}

class _ThemeButton extends StatelessWidget {
  final FIconObject icon;
  final ThemeMode mode;
  final ThemeMode current;
  final Function(ThemeMode) onTap;

  const _ThemeButton({
    required this.icon,
    required this.mode,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == current;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onTap(mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.tertiary : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: colorScheme.primary.withOpacity(0.15))
              : null,
        ),
        child: FIcon(
          icon,
          size: 20,
          color:
              isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
