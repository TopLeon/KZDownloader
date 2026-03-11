import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/download/providers/prefetched_metadata.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

// Widget for selecting video/audio options and quality
class InputOptionsPanel extends StatefulWidget {
  final bool showVideoOptions;
  final String selectedQuality;
  final bool isAudio;
  final bool summarizeOnly;
  final ValueChanged<String> onQualityChanged;
  final ValueChanged<bool> onIsAudioChanged;
  final ValueChanged<bool> onSummarizeOnlyChanged;
  final AppLocalizations l10n;
  final bool isGeneric;
  final String expectedChecksum;
  final String checksumAlgorithm;
  final ValueChanged<String>? onChecksumChanged;
  final ValueChanged<String>? onAlgorithmChanged;
  final PrefetchedData? prefetchedData;
  final int? selectedM3U8VariantIndex;
  final ValueChanged<int>? onM3U8VariantChanged;
  final bool isPlaylistUrl;
  final int parallelDownloads;
  final ValueChanged<int>? onParallelDownloadsChanged;
  final Set<int> selectedVideoIndices;
  final ValueChanged<Set<int>>? onSelectedVideoIndicesChanged;

  // Advanced options
  final String? advancedDownloadPath;
  final ValueChanged<String?>? onAdvancedDownloadPathChanged;
  final int? advancedSpeedLimitKbps;
  final ValueChanged<int?>? onAdvancedSpeedLimitKbpsChanged;

  /// Max parallel workers for Standard provider (null = unlimited)
  final int? maxWorkers;

  const InputOptionsPanel({
    super.key,
    required this.showVideoOptions,
    required this.selectedQuality,
    required this.isAudio,
    required this.summarizeOnly,
    required this.onQualityChanged,
    required this.onIsAudioChanged,
    required this.onSummarizeOnlyChanged,
    required this.l10n,
    this.isGeneric = false,
    this.expectedChecksum = '',
    this.checksumAlgorithm = 'MD5',
    this.onChecksumChanged,
    this.onAlgorithmChanged,
    this.prefetchedData,
    this.selectedM3U8VariantIndex,
    this.onM3U8VariantChanged,
    this.isPlaylistUrl = false,
    this.parallelDownloads = 3,
    this.onParallelDownloadsChanged,
    this.selectedVideoIndices = const {},
    this.onSelectedVideoIndicesChanged,
    this.advancedDownloadPath,
    this.onAdvancedDownloadPathChanged,
    this.advancedSpeedLimitKbps,
    this.onAdvancedSpeedLimitKbpsChanged,
    this.maxWorkers,
  });

  @override
  State<InputOptionsPanel> createState() => _InputOptionsPanelState();
}

class _InputOptionsPanelState extends State<InputOptionsPanel>
    with SingleTickerProviderStateMixin {
  bool _showAdvanced = false;
  late final AnimationController _advancedController;
  late final Animation<double> _advancedExpand;
  late final Animation<double> _advancedFade;
  late final TextEditingController _speedController;

  @override
  void initState() {
    super.initState();
    _advancedController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _advancedExpand = CurvedAnimation(
      parent: _advancedController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _advancedFade = CurvedAnimation(
      parent: _advancedController,
      curve: const Interval(0.3, 1, curve: Curves.easeOut),
      reverseCurve: const Interval(0, 0.5, curve: Curves.easeIn),
    );
    _speedController = TextEditingController(
      text: widget.advancedSpeedLimitKbps != null &&
              widget.advancedSpeedLimitKbps! > 0
          ? '${widget.advancedSpeedLimitKbps}'
          : '',
    );
  }

  @override
  void dispose() {
    _advancedController.dispose();
    _speedController.dispose();
    super.dispose();
  }

  void _toggleAdvanced() {
    setState(() => _showAdvanced = !_showAdvanced);
    if (_showAdvanced) {
      _advancedController.forward();
    } else {
      _advancedController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final m3u8Result = widget.prefetchedData?.m3u8Result;
    final hasM3U8Variants = m3u8Result != null &&
        m3u8Result.isMasterPlaylist &&
        m3u8Result.variants.isNotEmpty;

    final hasFormats = widget.prefetchedData != null &&
        widget.prefetchedData!.formats.isNotEmpty;

    final playlistVideos = widget.prefetchedData?.playlistVideos;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: (widget.showVideoOptions || widget.isGeneric)
          ? Column(
              children: [
                _buildDivider(colorScheme),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Main content area ──────────────────────────
                      if (widget.isGeneric) ...[
                        _buildGenericOptions(colorScheme, hasM3U8Variants),
                      ] else ...[
                        if (widget.isPlaylistUrl && !widget.summarizeOnly) ...[
                          _buildPlaylistOptions(
                              context, colorScheme, playlistVideos, hasFormats),
                        ] else ...[
                          if (!widget.summarizeOnly) ...[
                            _buildAudioVideoToggle(context, colorScheme),
                            const SizedBox(height: 8),
                            _buildQualityRow(context, colorScheme, hasFormats,
                                hasM3U8Variants),
                          ],
                        ],
                      ],

                      // ── Advanced options button ────────────────────
                      const SizedBox(height: 8),
                      _buildAdvancedButton(colorScheme),

                      // ── Advanced panel (animated) ──────────────────
                      SizeTransition(
                        sizeFactor: _advancedExpand,
                        axisAlignment: -1,
                        child: FadeTransition(
                          opacity: _advancedFade,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _buildAdvancedPanel(colorScheme),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildDivider(ColorScheme cs) => Divider(
        height: 1,
        color: cs.outlineVariant.withOpacity(0.4),
      );

  // ── Generic download options (checksum + optional M3U8 variants) ────────

  Widget _buildGenericOptions(ColorScheme cs, bool hasM3U8Variants) {
    return Column(
      children: [
        Row(
          children: [
            // Algorithm Dropdown
            SizedBox(
              width: 110,
              child: CustomDropdown<String>(
                closedHeaderPadding:
                    const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                decoration: CustomDropdownDecoration(
                  closedFillColor: cs.surface,
                  expandedFillColor: cs.surface,
                  closedBorder: Border.all(
                    color: cs.outlineVariant.withOpacity(0.3),
                  ),
                  expandedBorder: Border.all(
                    color: cs.primary.withOpacity(0.15),
                  ),
                  closedBorderRadius: BorderRadius.circular(12),
                  expandedBorderRadius: BorderRadius.circular(12),
                  headerStyle: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  listItemStyle: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: cs.onSurface,
                  ),
                ),
                initialItem: widget.checksumAlgorithm,
                items: const ['MD5', 'SHA256'],
                onChanged: (val) {
                  if (val != null) widget.onAlgorithmChanged?.call(val);
                },
              ),
            ),
            const SizedBox(width: 8),
            // Checksum Input
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cs.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  cursorHeight: 12,
                  controller: TextEditingController(
                      text: widget.expectedChecksum)
                    ..selection = TextSelection.fromPosition(
                        TextPosition(offset: widget.expectedChecksum.length)),
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    color: cs.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.l10n.checksumHint,
                    hintStyle: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: widget.onChecksumChanged,
                ),
              ),
            ),
          ],
        ),
        if (hasM3U8Variants) ...[
          const SizedBox(height: 8),
          _buildM3U8VariantSelector(context, cs),
        ],
      ],
    );
  }

  // ── Audio / Video toggle ──────────────────────────────────────────────────

  Widget _buildAudioVideoToggle(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption(context,
                isAudioOption: false,
                icon: Icons.video_library_rounded,
                label: widget.l10n.optionVideo),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: _buildTypeOption(context,
                isAudioOption: true,
                icon: Icons.music_note_rounded,
                label: widget.l10n.optionAudio),
          ),
        ],
      ),
    );
  }

  // ── Quality row (single video) ────────────────────────────────────────────

  Widget _buildQualityRow(BuildContext context, ColorScheme cs, bool hasFormats,
      bool hasM3U8Variants) {
    if (hasFormats) return _buildDynamicQualitySelector(context, cs);
    if (hasM3U8Variants) return _buildM3U8VariantSelector(context, cs);
    return _buildStaticQualitySelector(context, cs);
  }

  // ── Playlist options ──────────────────────────────────────────────────────

  Widget _buildPlaylistOptions(
    BuildContext context,
    ColorScheme cs,
    List<Map<String, dynamic>>? videos,
    bool hasFormats,
  ) {
    final allSelected = widget.selectedVideoIndices.isEmpty;
    final videoCount = videos?.length ?? widget.prefetchedData?.videoCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Audio/Video toggle (mirroring single video) ────────────
        _buildAudioVideoToggle(context, cs),
        const SizedBox(height: 8),

        // ── Quality selector ───────────────────────────────────────
        if (hasFormats)
          _buildDynamicQualitySelector(context, cs)
        else
          _buildStaticQualitySelector(context, cs),

        const SizedBox(height: 8),

        // ── Parallel downloads stepper ─────────────────────────────
        _buildParallelStepper(cs),

        const SizedBox(height: 8),

        // ── Video selection list ───────────────────────────────────
        if (videos != null && videos.isNotEmpty)
          _buildVideoList(cs, videos, allSelected)
        else if (videoCount > 0)
          _buildVideoCountBadge(cs, videoCount),
      ],
    );
  }

  Widget _buildParallelStepper(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.swap_horiz_rounded, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Parallel downloads',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.remove,
            onTap: widget.parallelDownloads > 1
                ? () => widget.onParallelDownloadsChanged
                    ?.call(widget.parallelDownloads - 1)
                : null,
            colorScheme: cs,
          ),
          const SizedBox(width: 10),
          Text(
            '${widget.parallelDownloads}',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          _StepperButton(
            icon: Icons.add,
            onTap: widget.parallelDownloads < 6
                ? () => widget.onParallelDownloadsChanged
                    ?.call(widget.parallelDownloads + 1)
                : null,
            colorScheme: cs,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList(
      ColorScheme cs, List<Map<String, dynamic>> videos, bool allSelected) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.list_alt_rounded,
                    size: 15, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select videos',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  allSelected
                      ? 'All (${videos.length})'
                      : '${widget.selectedVideoIndices.length}/${videos.length}',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.primary,
                  ),
                ),
                if (!allSelected) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () =>
                        widget.onSelectedVideoIndicesChanged?.call(const {}),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      child: Text(
                        'Select all',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withOpacity(0.3)),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: videos.length,
              itemBuilder: (context, idx) {
                final video = videos[idx];
                final title = video['title'] as String? ??
                    video['id'] as String? ??
                    'Video ${idx + 1}';
                final durationSecs = video['duration'] as int?;
                final isChecked =
                    allSelected || widget.selectedVideoIndices.contains(idx);

                return InkWell(
                  onTap: () {
                    final Set<int> newSet;
                    if (allSelected) {
                      newSet = Set<int>.from(
                          List<int>.generate(videos.length, (i) => i));
                    } else {
                      newSet = Set<int>.from(widget.selectedVideoIndices);
                    }
                    if (isChecked) {
                      newSet.remove(idx);
                    } else {
                      newSet.add(idx);
                    }
                    if (newSet.length == videos.length) {
                      widget.onSelectedVideoIndicesChanged?.call(const {});
                    } else {
                      widget.onSelectedVideoIndicesChanged?.call(newSet);
                    }
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            isChecked
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            key: ValueKey(isChecked),
                            size: 18,
                            color: isChecked
                                ? cs.primary
                                : cs.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${idx + 1}',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: cs.onSurfaceVariant.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: isChecked
                                  ? cs.onSurface
                                  : cs.onSurfaceVariant.withOpacity(0.7),
                              fontWeight: isChecked
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (durationSecs != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            _formatDuration(durationSecs),
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: cs.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCountBadge(ColorScheme cs, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.list_alt_rounded, size: 15, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$count videos in playlist',
            style: GoogleFonts.montserrat(
                fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ── Advanced options button ───────────────────────────────────────────────

  Widget _buildAdvancedButton(ColorScheme cs) {
    return GestureDetector(
      onTap: _toggleAdvanced,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              turns: _showAdvanced ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: cs.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Advanced options',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            if (widget.advancedDownloadPath != null ||
                (widget.advancedSpeedLimitKbps != null &&
                    widget.advancedSpeedLimitKbps! > 0)) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Advanced panel content ────────────────────────────────────────────────

  Widget _buildAdvancedPanel(ColorScheme cs) {
    final hasCustomPath = widget.advancedDownloadPath != null;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // ── Download folder ──────────────────────────────────────
          InkWell(
            onTap: () async {
              final result = await FilePicker.platform.getDirectoryPath();
              if (result != null) {
                widget.onAdvancedDownloadPathChanged?.call(result);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 16,
                    color: hasCustomPath ? cs.primary : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Download folder',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        if (hasCustomPath)
                          Text(
                            _shortenPath(widget.advancedDownloadPath!),
                            style: GoogleFonts.robotoMono(
                              fontSize: 10,
                              color: cs.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            'Using global default',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              color: cs.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasCustomPath)
                        GestureDetector(
                          onTap: () =>
                              widget.onAdvancedDownloadPathChanged?.call(null),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: cs.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Change',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: cs.outlineVariant.withOpacity(0.25)),

          // ── Speed limit ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.speed_rounded,
                  size: 16,
                  color: (widget.advancedSpeedLimitKbps != null &&
                          widget.advancedSpeedLimitKbps! > 0)
                      ? cs.primary
                      : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Max speed',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _speedController,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: '∞',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: cs.onSurfaceVariant.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      widget.onAdvancedSpeedLimitKbpsChanged
                          ?.call(parsed == 0 ? null : parsed);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'KB/s',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: cs.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
                if (widget.advancedSpeedLimitKbps != null &&
                    widget.advancedSpeedLimitKbps! > 0) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _speedController.clear();
                      widget.onAdvancedSpeedLimitKbpsChanged?.call(null);
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Quality selectors ─────────────────────────────────────────────────────

  Widget _buildStaticQualitySelector(BuildContext context, ColorScheme cs) {
    final bool isBest = widget.selectedQuality.toLowerCase() == 'best';
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
              child: _buildQualityOption(context,
                  value: '1080p',
                  icon: Icons.hd,
                  label: '1080p',
                  isSelected: isBest ||
                      widget.selectedQuality.toLowerCase() == '1080p')),
          const SizedBox(width: 3),
          Expanded(
              child: _buildQualityOption(context,
                  value: '720p', icon: Icons.high_quality, label: '720p')),
          const SizedBox(width: 3),
          Expanded(
              child: _buildQualityOption(context,
                  value: '480p', icon: Icons.sd, label: '480p')),
        ],
      ),
    );
  }

  Widget _buildDynamicQualitySelector(BuildContext context, ColorScheme cs) {
    final formats = widget.prefetchedData!.formats;

    final Map<String, Map<String, dynamic>> bestByHeight = {};
    for (final f in formats) {
      final height = f['height'];
      if (height == null || height is! int || height == 0) continue;
      final key = '${height}p';
      final existingBw = bestByHeight[key]?['tbr'] ?? 0;
      final currentBw = f['tbr'] ?? 0;
      if (!bestByHeight.containsKey(key) || currentBw > existingBw) {
        bestByHeight[key] = f;
      }
    }

    final sortedKeys = bestByHeight.keys.toList()
      ..sort((a, b) {
        final ha = int.tryParse(a.replaceAll('p', '')) ?? 0;
        final hb = int.tryParse(b.replaceAll('p', '')) ?? 0;
        return hb.compareTo(ha);
      });

    if (sortedKeys.isEmpty) return _buildStaticQualitySelector(context, cs);

    final displayOptions = <_FormatOption>[];
    for (final key in sortedKeys) {
      final f = bestByHeight[key]!;
      final height = f['height'] as int;
      IconData icon;
      if (height >= 2160) {
        icon = Icons.four_k;
      } else if (height >= 1080) {
        icon = Icons.hd;
      } else if (height >= 720) {
        icon = Icons.high_quality;
      } else {
        icon = Icons.sd;
      }
      if (height >= 480) {
        displayOptions.add(_FormatOption(
            value: '${height}p', label: '${height}p', icon: icon));
      }
    }

    final seen = <String>{};
    displayOptions.removeWhere((o) => !seen.add(o.value));

    if (displayOptions.isEmpty) return _buildStaticQualitySelector(context, cs);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: displayOptions.map((opt) {
          final isHighlight =
              widget.selectedQuality.toLowerCase() == opt.value.toLowerCase() ||
                  (widget.selectedQuality.toLowerCase() == 'best' &&
                      opt == displayOptions.first);
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: opt != displayOptions.last ? 3 : 0),
              child: _buildQualityOption(context,
                  value: opt.value,
                  icon: opt.icon,
                  label: opt.label,
                  isSelected: isHighlight),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildM3U8VariantSelector(BuildContext context, ColorScheme cs) {
    final variants = widget.prefetchedData!.m3u8Result!.variants;
    final selectedIdx = widget.selectedM3U8VariantIndex ?? 0;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'Select Quality',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          ...List.generate(variants.length, (i) {
            final v = variants[i];
            final isSelected = i == selectedIdx;
            String label = v.resolution ?? 'Variant ${i + 1}';
            if (v.bandwidth != null) {
              label += ' • ${(v.bandwidth! / 1000000).toStringAsFixed(1)} Mbps';
            }
            if (v.frameRate != null) {
              label += ' • ${v.frameRate!.toStringAsFixed(0)}fps';
            }
            if (v.codecs != null) label += ' • ${v.codecs}';

            return InkWell(
              onTap: () => widget.onM3U8VariantChanged?.call(i),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? cs.tertiary : cs.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        key: ValueKey(isSelected),
                        size: 16,
                        color: isSelected ? cs.primary : cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? cs.primary : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQualityOption(
    BuildContext context, {
    required String value,
    required IconData icon,
    required String label,
    bool? isSelected,
  }) {
    final bool active = isSelected ??
        (widget.selectedQuality.toLowerCase() == value.toLowerCase());
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => widget.onQualityChanged(value),
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: active ? cs.tertiary : cs.surface,
          borderRadius: BorderRadius.circular(11),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: active ? cs.primary : cs.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required bool isAudioOption,
    required IconData icon,
    required String label,
  }) {
    final isSelected = widget.isAudio == isAudioOption;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => widget.onIsAudioChanged(isAudioOption),
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.tertiary : cs.surface,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18, color: isSelected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _shortenPath(String path) {
    final parts = path.replaceAll('\\', '/').split('/');
    if (parts.length <= 3) return path;
    return '…/${parts.sublist(parts.length - 2).join('/')}';
  }
}

/// Helper class for format option display
class _FormatOption {
  final String value;
  final String label;
  final IconData icon;

  const _FormatOption(
      {required this.value, required this.label, required this.icon});
}

/// Compact icon button for the parallel downloads stepper.
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final ColorScheme colorScheme;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled
              ? colorScheme.primaryContainer.withOpacity(0.6)
              : colorScheme.onSurface.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.25),
        ),
      ),
    );
  }
}
