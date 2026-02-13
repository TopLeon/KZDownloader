import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/providers/quality_provider.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/views/chat/widgets/input/chat_input_area.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/core/utils/utils.dart';

// Dialog for adding a URL using ChatInputArea.
class AddUrlDialog extends ConsumerStatefulWidget {
  final TaskCategory category;

  const AddUrlDialog({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<AddUrlDialog> createState() => _AddUrlDialogState();
}

class _AddUrlDialogState extends ConsumerState<AddUrlDialog> {
  late TextEditingController _controller;
  String _selectedProvider = 'Auto';
  bool _showVideoOptions = false;
  bool _isAudio = false;
  bool _summarizeOnly = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final category = UrlUtils.detectCategory(text);
    final isVideo = category == TaskCategory.video ||
        category == TaskCategory.music ||
        category == TaskCategory.playlist;

    if (isVideo != _showVideoOptions) {
      setState(() {
        _showVideoOptions = isVideo;
      });
    }
  }

  bool _isYouTubeLink(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    return host.contains('youtube.com') ||
        host.contains('youtu.be') ||
        host.contains('youtube-nocookie.com');
  }

  void _handleSubmit() {
    final qualitySettings = ref.read(qualitySettings_Provider).asData?.value;
    if (_controller.text.trim().isNotEmpty && qualitySettings != null) {
      Navigator.of(context).pop({
        'url': _controller.text.trim(),
        'provider': _selectedProvider,
        'quality': qualitySettings.toDisplayString(),
        'isAudio': _isAudio,
        'summarizeOnly': _summarizeOnly,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final qualitySettingsAsync = ref.watch(qualitySettings_Provider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_link,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.btnAddUrl,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (_showVideoOptions &&
                    _isYouTubeLink(_controller.text) &&
                    !UrlUtils.isYouTubePlaylist(_controller.text))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: _ModeTab(
                              label: l10n.modeDownload,
                              isSelected: !_summarizeOnly,
                              onTap: () => setState(() {
                                _summarizeOnly = false;
                              }),
                            ),
                          ),
                          Expanded(
                            child: _ModeTab(
                              label: l10n.modeSummary,
                              isSelected: _summarizeOnly,
                              onTap: () => setState(() {
                                _summarizeOnly = true;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                qualitySettingsAsync.when(
                  data: (qualitySettings) => ChatInputArea(
                    controller: _controller,
                    selectedProvider: _selectedProvider,
                    showVideoOptions: _showVideoOptions,
                    selectedQuality: qualitySettings.toDisplayString(),
                    isAudio: _isAudio,
                    summarizeOnly: _summarizeOnly,
                    isCentered: false,
                    qualityMode: qualitySettings.mode,
                    onSubmit: _handleSubmit,
                    onProviderChanged: (value) {
                      setState(() {
                        _selectedProvider = value;
                      });
                    },
                    onQualityChanged: (value) async {
                      // Convert display string to DownloadQuality enum
                      DownloadQuality quality;
                      switch (value.toLowerCase()) {
                        case 'best':
                          quality = DownloadQuality.best;
                          break;
                        case 'medium':
                          quality = DownloadQuality.medium;
                          break;
                        case 'low':
                          quality = DownloadQuality.low;
                          break;
                        case '1080p':
                          quality = DownloadQuality.p1080;
                          break;
                        case '720p':
                          quality = DownloadQuality.p720;
                          break;
                        case '480p':
                          quality = DownloadQuality.p480;
                          break;
                        default:
                          quality = DownloadQuality.best;
                      }
                      await ref
                          .read(qualitySettings_Provider.notifier)
                          .setQuality(quality);
                    },
                    onIsAudioChanged: (value) {
                      setState(() {
                        _isAudio = value;
                      });
                    },
                    onSummarizeOnlyChanged: (value) {
                      setState(() {
                        _summarizeOnly = value;
                      });
                    },
                    onPrefetchStateChanged: (isPrefetching) {
                      //setState(() {
                      //_isPrefetching = isPrefetching;
                      //});
                    },
                    onMetadataFetched: () {
                      // Metadata fetched callback
                    },
                  ),
                  loading: () => ChatInputArea(
                    controller: _controller,
                    selectedProvider: _selectedProvider,
                    showVideoOptions: _showVideoOptions,
                    selectedQuality: 'Best',
                    isAudio: _isAudio,
                    summarizeOnly: _summarizeOnly,
                    isCentered: false,
                    qualityMode: QualityMode.simple,
                    onSubmit: _handleSubmit,
                    onProviderChanged: (value) {
                      setState(() {
                        _selectedProvider = value;
                      });
                    },
                    onQualityChanged: (_) {},
                    onIsAudioChanged: (value) {
                      setState(() {
                        _isAudio = value;
                      });
                    },
                    onSummarizeOnlyChanged: (value) {
                      setState(() {
                        _summarizeOnly = value;
                      });
                    },
                    onPrefetchStateChanged: (isPrefetching) {},
                    onMetadataFetched: () {},
                  ),
                  error: (error, stack) => ChatInputArea(
                    controller: _controller,
                    selectedProvider: _selectedProvider,
                    showVideoOptions: _showVideoOptions,
                    selectedQuality: 'Best',
                    isAudio: _isAudio,
                    summarizeOnly: _summarizeOnly,
                    isCentered: false,
                    qualityMode: QualityMode.simple,
                    onSubmit: _handleSubmit,
                    onProviderChanged: (value) {
                      setState(() {
                        _selectedProvider = value;
                      });
                    },
                    onQualityChanged: (_) {},
                    onIsAudioChanged: (value) {
                      setState(() {
                        _isAudio = value;
                      });
                    },
                    onSummarizeOnlyChanged: (value) {
                      setState(() {
                        _summarizeOnly = value;
                      });
                    },
                    onPrefetchStateChanged: (isPrefetching) {},
                    onMetadataFetched: () {},
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          l10n.btnCancel,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// Shows the dialog for adding a URL.
Future<Map<String, dynamic>?> showAddUrlDialog(
  BuildContext context, {
  required TaskCategory category,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) => AddUrlDialog(category: category),
  );
}
