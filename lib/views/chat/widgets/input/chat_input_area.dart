import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/views/chat/widgets/input/input_options_panel.dart';
import 'package:kzdownloader/core/utils/utils.dart';
import 'package:kzdownloader/models/download_task.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/views/chat/widgets/rainbow.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/ri.dart';

// Provider selector popup menu item data
class ProviderOption {
  final String value;
  final String label;
  final IconData icon;
  final String? description;

  const ProviderOption({
    required this.value,
    required this.label,
    required this.icon,
    this.description,
  });
}

// Floating input area with provider selection, text field, and video options
class ChatInputArea extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String selectedProvider;
  final bool showVideoOptions;
  final String selectedQuality;
  final bool isAudio;
  final bool summarizeOnly;
  final bool isCentered;
  final QualityMode qualityMode;
  final VoidCallback onSubmit;
  final ValueChanged<String> onProviderChanged;
  final ValueChanged<String> onQualityChanged;
  final ValueChanged<bool> onIsAudioChanged;
  final ValueChanged<bool> onSummarizeOnlyChanged;
  final ValueChanged<bool>? onPrefetchStateChanged;
  final VoidCallback? onMetadataFetched;
  final String expectedChecksum;
  final String checksumAlgorithm;
  final ValueChanged<String>? onChecksumChanged;
  final ValueChanged<String>? onAlgorithmChanged;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.selectedProvider,
    required this.showVideoOptions,
    required this.selectedQuality,
    required this.isAudio,
    required this.summarizeOnly,
    this.isCentered = false,
    required this.qualityMode,
    required this.onSubmit,
    required this.onProviderChanged,
    required this.onQualityChanged,
    required this.onIsAudioChanged,
    required this.onSummarizeOnlyChanged,
    this.onPrefetchStateChanged,
    this.onMetadataFetched,
    this.expectedChecksum = '',
    this.checksumAlgorithm = 'MD5',
    this.onChecksumChanged,
    this.onAlgorithmChanged,
  });

  @override
  ConsumerState<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends ConsumerState<ChatInputArea> {
  bool _isVideoLink = false;
  String _lastPrefetchedUrl = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _onTextChanged();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final category = UrlUtils.detectCategory(text);
    final isVideo = category != TaskCategory.generic;

    if (isVideo != _isVideoLink) {
      setState(() {
        _isVideoLink = isVideo;
      });
    }

    // Prefetch metadata for all URLs (both generic and video)
    final isUrl = text.startsWith('http://') || text.startsWith('https://');

    // Only prefetch if URL has actually changed
    if (_lastPrefetchedUrl == text) {
      return;
    }

    // Update _lastPrefetchedUrl BEFORE scheduling callback to prevent duplicates
    if (isUrl) {
      _lastPrefetchedUrl = text;
    } else if (text.isEmpty) {
      _lastPrefetchedUrl = '';
    }

    // Use post-frame callback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isUrl) {
        // Notify parent that prefetch is starting
        widget.onPrefetchStateChanged?.call(true);

        if (!isVideo) {
          // Generic file - use existing prefetch
          ref.read(downloadListProvider.notifier).prefetchMetadata(text);
        } else {
          // Video link - prefetch with yt-dlp
          ref.read(downloadListProvider.notifier).prefetchVideoMetadata(text);
        }

        // After a delay, mark prefetch as completed
        // (yt-dlp metadata fetching typically takes 1-3 seconds)
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && widget.controller.text == text) {
            // Notify parent that prefetch is completed
            widget.onPrefetchStateChanged?.call(false);

            // Need to notify completion separately - we'll do this via a second callback
            if (widget.onMetadataFetched != null) {
              widget.onMetadataFetched!();
            }
          }
        });
      } else if (text.isEmpty) {
        // URL cleared - notify parent
        widget.onPrefetchStateChanged?.call(false);
      }
    });
  }

  List<ProviderOption> getGenericProviders(AppLocalizations l10n) => [
        ProviderOption(
          value: 'Auto',
          label: l10n.providerAuto,
          icon: Icons.auto_awesome,
          description: l10n.providerAutoDesc,
        ),
        ProviderOption(
          value: 'Standard',
          label: 'Standard',
          icon: Icons.downloading,
          description: l10n.providerStandardDesc,
        ),
        ProviderOption(
          value: 'Pro',
          label: 'Pro',
          icon: Icons.speed,
          description: l10n.providerProDesc,
        ),
      ];

  // Returns true if the video is a youtube link
  bool _isYouTubeLink(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    return host.contains('youtube.com') ||
        host.contains('youtu.be') ||
        host.contains('youtube-nocookie.com');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    final showProviderSelector = !_isVideoLink &&
        (widget.controller.text.startsWith('http://') ||
            widget.controller.text.startsWith('https://'));

    final isGeneric = showProviderSelector && !widget.summarizeOnly;

    final showVideoOptionsPanel = (_isVideoLink && widget.showVideoOptions) ||
        (widget.summarizeOnly && widget.controller.text.isNotEmpty) ||
        (isGeneric && widget.controller.text.isNotEmpty);

    Widget inputArea = Container(
      width: widget.isCentered ? 600 : null,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Provider Selector
              if (showProviderSelector && !widget.summarizeOnly) ...[
                _buildProviderSelector(
                  context,
                  colorScheme,
                  isLightTheme,
                  l10n,
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Icon(
                    Icons.link,
                    size: 20,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.9),
                  ),
                ),

              // Text Field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  cursorHeight: 15,
                  style: GoogleFonts.montserrat(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: widget.summarizeOnly
                        ? l10n.pasteLinkSummaryHint
                        : l10n.pasteLinkHint,
                    hintStyle: GoogleFonts.montserrat(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.9),
                    ),
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => widget.onSubmit(),
                ),
              ),

              // Send Button
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: widget.onSubmit,
                  icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: FIcon(
                        widget.summarizeOnly
                            ? RI.RiBardLine
                            : RI.RiDownloadLine,
                        color: Theme.of(context).colorScheme.onPrimary,
                        key: ValueKey(widget.summarizeOnly),
                        size: 20,
                      )),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.all(10),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),

          // Video Options Panel
          if (showVideoOptionsPanel)
            InputOptionsPanel(
              showVideoOptions: widget.showVideoOptions,
              selectedQuality: widget.selectedQuality,
              isAudio: widget.isAudio,
              summarizeOnly: widget.summarizeOnly,
              qualityMode: widget.qualityMode,
              onQualityChanged: widget.onQualityChanged,
              onIsAudioChanged: widget.onIsAudioChanged,
              onSummarizeOnlyChanged: widget.onSummarizeOnlyChanged,
              l10n: l10n,
              isGeneric: isGeneric,
              expectedChecksum: widget.expectedChecksum,
              checksumAlgorithm: widget.checksumAlgorithm,
              onChecksumChanged: widget.onChecksumChanged,
              onAlgorithmChanged: widget.onAlgorithmChanged,
            ),
          if (widget.summarizeOnly)
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12),
              child: Text(
                l10n.aiNotAvailableForNonYoutube,
                style:
                    TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            )
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mode Selector (Download / Summary)
        if (widget.isCentered &&
            widget.showVideoOptions &&
            _isYouTubeLink(widget.controller.text) &&
            !UrlUtils.isYouTubePlaylist(widget.controller.text))
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.tertiary,
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.15),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IntrinsicWidth(
                child: Stack(
                  children: [
                    // Animated background indicator
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: widget.summarizeOnly
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    // Tabs
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ModeTab(
                          label: l10n.modeDownload,
                          isSelected: !widget.summarizeOnly,
                          onTap: () => widget.onSummarizeOnlyChanged(false),
                        ),
                        _ModeTab(
                          label: l10n.modeSummary,
                          isSelected: widget.summarizeOnly,
                          onTap: () => widget.onSummarizeOnlyChanged(true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (showVideoOptionsPanel || showProviderSelector) ...[
          Padding(
            padding: const EdgeInsets.all(2),
            child: RainbowAnimatedBorderForever(
              disabled: false,
              borderRadius: 30,
              child: inputArea,
            ),
          )
        ] else ...[
          inputArea
        ]
      ],
    );
  }

  Widget _buildProviderSelector(
    BuildContext context,
    ColorScheme colorScheme,
    bool isLightTheme,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 0),
      child: PopupMenuButton<String>(
        initialValue: widget.selectedProvider,
        tooltip: l10n.selectProvider,
        offset: const Offset(0, -120),
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: widget.onProviderChanged,
        itemBuilder: (context) => getGenericProviders(l10n).map((p) {
          return PopupMenuItem<String>(
            value: p.value,
            child: Row(
              children: [
                Icon(p.icon, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.label,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (p.description != null)
                      Text(
                        p.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.tertiary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4),
              Text(
                widget.selectedProvider,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant.withOpacity(0.9),
              ),
            ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        color: Colors.transparent,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.montserrat(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
