import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/download/providers/download_provider.dart';
import 'package:kzdownloader/core/download/providers/prefetched_metadata.dart';
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
  final FocusNode? focusNode;
  final String selectedProvider;
  final bool showVideoOptions;
  final String selectedQuality;
  final bool isAudio;
  final bool summarizeOnly;
  final bool isCentered;
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
  final ValueChanged<int>? onM3U8VariantIndexChanged;
  final ValueChanged<int>? onParallelDownloadsChanged;
  final ValueChanged<Set<int>>? onSelectedVideoIndicesChanged;
  final ValueChanged<String?>? onAdvancedDownloadPathChanged;
  final ValueChanged<int?>? onAdvancedSpeedLimitKbpsChanged;

  const ChatInputArea({
    super.key,
    required this.controller,
    this.focusNode,
    required this.selectedProvider,
    required this.showVideoOptions,
    required this.selectedQuality,
    required this.isAudio,
    required this.summarizeOnly,
    this.isCentered = false,
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
    this.onM3U8VariantIndexChanged,
    this.onParallelDownloadsChanged,
    this.onSelectedVideoIndicesChanged,
    this.onAdvancedDownloadPathChanged,
    this.onAdvancedSpeedLimitKbpsChanged,
  });

  @override
  ConsumerState<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends ConsumerState<ChatInputArea>
    with SingleTickerProviderStateMixin {
  bool _isVideoLink = false;
  String _lastPrefetchedUrl = '';
  int _selectedM3U8VariantIndex = 0;
  int _parallelDownloads = 3;
  Set<int> _selectedVideoIndices = {};
  String? _advancedDownloadPath;
  int? _advancedSpeedLimitKbps;
  bool _isFocused = false;
  FocusNode? _ownFocusNode;

  FocusNode get _activeFocusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  // For the send button scale animation
  late final AnimationController _sendBtnController;
  late final Animation<double> _sendBtnScale;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _onTextChanged();
    _activeFocusNode.addListener(_handleFocusChange);

    _sendBtnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _sendBtnScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sendBtnController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _activeFocusNode.removeListener(_handleFocusChange);
    _ownFocusNode?.dispose();
    _sendBtnController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() => _isFocused = _activeFocusNode.hasFocus);
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

    final isUrl = text.startsWith('http://') || text.startsWith('https://');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_lastPrefetchedUrl == text && isUrl) {
        ref
            .read(prefetchStatusProvider.notifier)
            .setStatus(PrefetchStatus.ready);
        return;
      }

      if (isUrl) {
        _lastPrefetchedUrl = text;
      } else if (text.isEmpty) {
        _lastPrefetchedUrl = '';
      }

      if (isUrl) {
        ref
            .read(prefetchStatusProvider.notifier)
            .setStatus(PrefetchStatus.loading);
        widget.onPrefetchStateChanged?.call(true);

        if (UrlUtils.isM3U8Playlist(text)) {
          ref.read(downloadListProvider.notifier).prefetchM3U8Metadata(text);
        } else if (!isVideo) {
          ref.read(downloadListProvider.notifier).prefetchMetadata(text);
        } else {
          ref.read(downloadListProvider.notifier).prefetchVideoMetadata(text);
        }
      } else if (text.isEmpty) {
        widget.onPrefetchStateChanged?.call(false);
        ref
            .read(prefetchStatusProvider.notifier)
            .setStatus(PrefetchStatus.idle);
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

  bool _isYouTubeLink(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    return host.contains('youtube.com') ||
        host.contains('youtu.be') ||
        host.contains('youtube-nocookie.com');
  }

  // Compute max workers based on provider: Standard → 1
  int? get _maxWorkers => widget.selectedProvider == 'Standard' ? 1 : null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final showProviderSelector = !_isVideoLink &&
        (widget.controller.text.startsWith('http://') ||
            widget.controller.text.startsWith('https://'));

    final isGeneric = showProviderSelector && !widget.summarizeOnly;

    final showVideoOptionsPanel = (_isVideoLink && widget.showVideoOptions) ||
        (widget.summarizeOnly && widget.controller.text.isNotEmpty) ||
        (isGeneric && widget.controller.text.isNotEmpty);

    final prefetchStatus = ref.watch(prefetchStatusProvider);
    final prefetchedMap = ref.watch(prefetchedMetadataProvider);
    final currentUrl = widget.controller.text;
    final prefetchedData = prefetchedMap[currentUrl];

    // Drive the send button scale animation
    final shouldShowSend =
        prefetchStatus == PrefetchStatus.ready && currentUrl.isNotEmpty;
    if (shouldShowSend) {
      _sendBtnController.forward();
    } else {
      _sendBtnController.reverse();
    }

    ref.listen(prefetchStatusProvider, (prev, next) {
      if (next == PrefetchStatus.loading) {
        widget.onPrefetchStateChanged?.call(true);
      } else if (next == PrefetchStatus.ready || next == PrefetchStatus.error) {
        widget.onPrefetchStateChanged?.call(false);
        if (next == PrefetchStatus.ready) {
          widget.onMetadataFetched?.call();
        }
      }
    });

    Widget inputArea = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: widget.isCentered ? 600 : null,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _isFocused ? colorScheme.primary.withOpacity(0.2) : colorScheme.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? colorScheme.shadow.withOpacity(0.10)
                : colorScheme.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Provider Selector
              if (showProviderSelector && !widget.summarizeOnly) ...[
                _buildProviderSelector(context, colorScheme, l10n),
              ] else
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Icon(
                    Icons.link,
                    size: 22,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.9),
                  ),
                ),

              // Text Field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _activeFocusNode,
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

              // Send Button — spring scale animation
              ScaleTransition(
                scale: _sendBtnScale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: shouldShowSend
                        ? colorScheme.primary
                        : colorScheme.primary.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: widget.onSubmit,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                      child: FIcon(
                        widget.summarizeOnly
                            ? RI.RiBardLine
                            : RI.RiDownloadLine,
                        color: Theme.of(context).colorScheme.onPrimary,
                        key: ValueKey(widget.summarizeOnly),
                        size: 20,
                      ),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.all(10),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Loading shimmer / options panel
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              );
            },
            child: prefetchStatus == PrefetchStatus.loading
                ? _buildLoadingRow(colorScheme, l10n,
                    key: const ValueKey('loading'))
                : (showVideoOptionsPanel &&
                        prefetchStatus == PrefetchStatus.ready)
                    ? InputOptionsPanel(
                        key: const ValueKey('options'),
                        showVideoOptions: widget.showVideoOptions,
                        selectedQuality: widget.selectedQuality,
                        isAudio: widget.isAudio,
                        summarizeOnly: widget.summarizeOnly,
                        onQualityChanged: widget.onQualityChanged,
                        onIsAudioChanged: widget.onIsAudioChanged,
                        onSummarizeOnlyChanged: widget.onSummarizeOnlyChanged,
                        l10n: l10n,
                        isGeneric: isGeneric,
                        expectedChecksum: widget.expectedChecksum,
                        checksumAlgorithm: widget.checksumAlgorithm,
                        onChecksumChanged: widget.onChecksumChanged,
                        onAlgorithmChanged: widget.onAlgorithmChanged,
                        prefetchedData: prefetchedData,
                        selectedM3U8VariantIndex: _selectedM3U8VariantIndex,
                        onM3U8VariantChanged: (idx) {
                          setState(() => _selectedM3U8VariantIndex = idx);
                          widget.onM3U8VariantIndexChanged?.call(idx);
                        },
                        isPlaylistUrl:
                            UrlUtils.isYouTubePlaylist(widget.controller.text),
                        parallelDownloads: _parallelDownloads,
                        onParallelDownloadsChanged: (val) {
                          setState(() => _parallelDownloads = val);
                          widget.onParallelDownloadsChanged?.call(val);
                        },
                        selectedVideoIndices: _selectedVideoIndices,
                        onSelectedVideoIndicesChanged: (indices) {
                          setState(() => _selectedVideoIndices = indices);
                          widget.onSelectedVideoIndicesChanged?.call(indices);
                        },
                        advancedDownloadPath: _advancedDownloadPath,
                        onAdvancedDownloadPathChanged: (path) {
                          setState(() => _advancedDownloadPath = path);
                          widget.onAdvancedDownloadPathChanged?.call(path);
                        },
                        advancedSpeedLimitKbps: _advancedSpeedLimitKbps,
                        onAdvancedSpeedLimitKbpsChanged: (kbps) {
                          setState(() => _advancedSpeedLimitKbps = kbps);
                          widget.onAdvancedSpeedLimitKbpsChanged?.call(kbps);
                        },
                        maxWorkers: _maxWorkers,
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
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
        // Mode Selector (Download / Summary) — Claude-style animated tab
        if (widget.isCentered &&
            widget.showVideoOptions &&
            _isYouTubeLink(widget.controller.text) &&
            !UrlUtils.isYouTubePlaylist(widget.controller.text))
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildModeSelector(colorScheme, l10n),
          ),

        if (prefetchStatus == PrefetchStatus.loading ||
            showVideoOptionsPanel ||
            showProviderSelector) ...[
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

  // ── Mode selector (Download / Summary) — Claude-inspired pill ────────────

  Widget _buildModeSelector(ColorScheme cs, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.tertiary,
        border: Border.all(color: cs.primary.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IntrinsicWidth(
        child: Stack(
          children: [
            // Animated sliding pill background
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: widget.summarizeOnly
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
    );
  }

  // ── Loading row ───────────────────────────────────────────────────────────

  Widget _buildLoadingRow(ColorScheme cs, AppLocalizations l10n, {Key? key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, color: cs.outlineVariant.withOpacity(0.4)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ThreeDotsLoader(color: cs.primary),
              const SizedBox(width: 10),
              Text(
                l10n.downloadingMetadata,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Provider selector ─────────────────────────────────────────────────────

  Widget _buildProviderSelector(
    BuildContext context,
    ColorScheme colorScheme,
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

// ── Mode tab ──────────────────────────────────────────────────────────────────

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
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
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

// ── Three staggered pulsing dots (loading indicator) ─────────────────────────

class _ThreeDotsLoader extends StatefulWidget {
  final Color color;
  const _ThreeDotsLoader({required this.color});

  @override
  State<_ThreeDotsLoader> createState() => _ThreeDotsLoaderState();
}

class _ThreeDotsLoaderState extends State<_ThreeDotsLoader>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _anims = _controllers
        .map((c) => Tween<double>(begin: 0.25, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: FadeTransition(
            opacity: _anims[i],
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
