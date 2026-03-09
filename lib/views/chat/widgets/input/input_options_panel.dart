import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/core/download/providers/prefetched_metadata.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

// Widget for selecting video/audio options and quality
class InputOptionsPanel extends StatelessWidget {
  final bool showVideoOptions;
  final String selectedQuality;
  final bool isAudio;
  final bool summarizeOnly;
  final ValueChanged<String> onQualityChanged;
  final ValueChanged<bool> onIsAudioChanged;
  final ValueChanged<bool> onSummarizeOnlyChanged;
  final AppLocalizations l10n;

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
  });

  final bool isGeneric;
  final String expectedChecksum;
  final String checksumAlgorithm;
  final ValueChanged<String>? onChecksumChanged;
  final ValueChanged<String>? onAlgorithmChanged;

  /// Prefetched metadata for the current URL (may be null if not yet fetched)
  final PrefetchedData? prefetchedData;

  /// Selected M3U8 variant index
  final int? selectedM3U8VariantIndex;
  final ValueChanged<int>? onM3U8VariantChanged;

  /// Whether the URL is a YouTube playlist
  final bool isPlaylistUrl;

  /// How many videos to download in parallel for playlist downloads
  final int parallelDownloads;
  final ValueChanged<int>? onParallelDownloadsChanged;

  /// Which video indices have been selected (empty = all selected)
  final Set<int> selectedVideoIndices;
  final ValueChanged<Set<int>>? onSelectedVideoIndicesChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine if we have M3U8 master data to show variant selection
    final m3u8Result = prefetchedData?.m3u8Result;
    final hasM3U8Variants = m3u8Result != null &&
        m3u8Result.isMasterPlaylist &&
        m3u8Result.variants.isNotEmpty;

    // Determine if we have yt-dlp format data
    final hasFormats =
        prefetchedData != null && prefetchedData!.formats.isNotEmpty;

    // Playlist videos from metadata
    final playlistVideos = prefetchedData?.playlistVideos;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: (showVideoOptions || isGeneric)
          ? Column(
              children: [
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isGeneric) ...[
                        Row(
                          children: [
                            // Algorithm Dropdown
                            SizedBox(
                              width: 110,
                              child: CustomDropdown<String>(
                                closedHeaderPadding: const EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 12),
                                decoration: CustomDropdownDecoration(
                                  closedFillColor: colorScheme.surface,
                                  expandedFillColor: colorScheme.surface,
                                  closedBorder: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withOpacity(0.3),
                                  ),
                                  expandedBorder: Border.all(
                                    color:
                                        colorScheme.primary.withOpacity(0.15),
                                  ),
                                  closedBorderRadius: BorderRadius.circular(12),
                                  expandedBorderRadius:
                                      BorderRadius.circular(12),
                                  headerStyle: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  listItemStyle: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                initialItem: checksumAlgorithm,
                                items: const ['MD5', 'SHA256'],
                                onChanged: (val) {
                                  if (val != null) {
                                    onAlgorithmChanged?.call(val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Checksum Input
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: TextField(
                                  cursorHeight: 12,
                                  controller: TextEditingController(
                                      text: expectedChecksum)
                                    ..selection = TextSelection.fromPosition(
                                        TextPosition(
                                            offset: expectedChecksum.length)),
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 12,
                                    color: colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: l10n.checksumHint,
                                    hintStyle: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  onChanged: onChecksumChanged,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Show M3U8 variant selection for generic M3U8 URLs
                        if (hasM3U8Variants) ...[
                          const SizedBox(height: 8),
                          _buildM3U8VariantSelector(context, colorScheme),
                        ],
                      ] else ...[
                        // ── Playlist options ────────────────────────────
                        if (isPlaylistUrl && !summarizeOnly) ...[
                          _buildPlaylistOptions(context, colorScheme, playlistVideos),
                        ] else ...[
                          // Audio/Video Toggle
                          if (!summarizeOnly) ...[
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildTypeOption(
                                      context,
                                      isAudioOption: false,
                                      icon: Icons.video_library,
                                      label: l10n.optionVideo,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: _buildTypeOption(
                                      context,
                                      isAudioOption: true,
                                      icon: Icons.music_note,
                                      label: l10n.optionAudio,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Quality Selector — dynamic from metadata if available
                            if (hasFormats)
                              _buildDynamicQualitySelector(context, colorScheme)
                            else if (hasM3U8Variants)
                              _buildM3U8VariantSelector(context, colorScheme)
                            else
                              _buildStaticQualitySelector(context, colorScheme),
                          ],
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  /// Builds the playlist-specific options section: parallel downloads + video selection.
  Widget _buildPlaylistOptions(
    BuildContext context,
    ColorScheme colorScheme,
    List<Map<String, dynamic>>? videos,
  ) {
    final allSelected = selectedVideoIndices.isEmpty;
    final videoCount = videos?.length ?? prefetchedData?.videoCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Parallel downloads stepper ──────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.swap_horiz_rounded,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Parallel downloads',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              _StepperButton(
                icon: Icons.remove,
                onTap: parallelDownloads > 1
                    ? () => onParallelDownloadsChanged?.call(parallelDownloads - 1)
                    : null,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 10),
              Text(
                '$parallelDownloads',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 10),
              _StepperButton(
                icon: Icons.add,
                onTap: parallelDownloads < 6
                    ? () => onParallelDownloadsChanged?.call(parallelDownloads + 1)
                    : null,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Video selection ─────────────────────────────────────────────
        if (videos != null && videos.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: "Select videos" + count/select-all link
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.list_alt_rounded,
                          size: 15, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Select videos',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        allSelected
                            ? 'All (${videos.length})'
                            : '${selectedVideoIndices.length}/${videos.length}',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                      if (!allSelected) ...[
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () =>
                              onSelectedVideoIndicesChanged?.call(const {}),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            child: Text(
                              'Select all',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withOpacity(0.3)),
                // Video list
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
                      final isChecked = allSelected ||
                          selectedVideoIndices.contains(idx);

                      return InkWell(
                        onTap: () {
                          final Set<int> newSet;
                          if (allSelected) {
                            newSet = Set<int>.from(
                                List<int>.generate(videos.length, (i) => i));
                          } else {
                            newSet = Set<int>.from(selectedVideoIndices);
                          }
                          if (isChecked) {
                            newSet.remove(idx);
                          } else {
                            newSet.add(idx);
                          }
                          // If all are selected → represent as empty (= all)
                          if (newSet.length == videos.length) {
                            onSelectedVideoIndicesChanged?.call(const {});
                          } else {
                            onSelectedVideoIndicesChanged?.call(newSet);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          child: Row(
                            children: [
                              Icon(
                                isChecked
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                size: 18,
                                color: isChecked
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant
                                        .withOpacity(0.5),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${idx + 1}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant
                                      .withOpacity(0.6),
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
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurfaceVariant
                                            .withOpacity(0.7),
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
                                    color: colorScheme.onSurfaceVariant
                                        .withOpacity(0.5),
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
          ),
        ] else if (videoCount > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt_rounded,
                    size: 15, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  '$videoCount videos in playlist',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Builds the static quality selector (fallback: Best/High/Medium/Low)
  Widget _buildStaticQualitySelector(
      BuildContext context, ColorScheme colorScheme) {
    final bool isBest = selectedQuality.toLowerCase() == 'best';
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQualityOption(
              context,
              value: '1080p',
              icon: Icons.hd,
              label: '1080p',
              isSelected: isBest || selectedQuality.toLowerCase() == '1080p',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildQualityOption(
              context,
              value: '720p',
              icon: Icons.high_quality,
              label: '720p',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildQualityOption(
              context,
              value: '480p',
              icon: Icons.sd,
              label: '480p',
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a dynamic quality selector from yt-dlp metadata formats
  Widget _buildDynamicQualitySelector(
      BuildContext context, ColorScheme colorScheme) {
    final formats = prefetchedData!.formats;

    // Filter & deduplicate video formats with height info
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

    // Sort by height descending
    final sortedKeys = bestByHeight.keys.toList()
      ..sort((a, b) {
        final ha = int.tryParse(a.replaceAll('p', '')) ?? 0;
        final hb = int.tryParse(b.replaceAll('p', '')) ?? 0;
        return hb.compareTo(ha);
      });

    // If no video formats found, fall back to static
    if (sortedKeys.isEmpty) {
      return _buildStaticQualitySelector(context, colorScheme);
    }

    final displayOptions = <_FormatOption>[];

    for (final key in sortedKeys) {
      final f = bestByHeight[key]!;
      final height = f['height'] as int;

      String label = '${height}p';

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
          value: '${height}p',
          label: label,
          icon: icon,
        ));
      }
    }

    // Remove duplicate entries
    final seen = <String>{};
    displayOptions.removeWhere((o) => !seen.add(o.value));

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: displayOptions.map((opt) {
          final isHighlight =
              selectedQuality.toLowerCase() == opt.value.toLowerCase() ||
                  (selectedQuality.toLowerCase() == 'best' &&
                      opt == displayOptions.first);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: opt != displayOptions.last ? 4 : 0,
              ),
              child: _buildQualityOption(
                context,
                value: opt.value,
                icon: opt.icon,
                label: opt.label,
                isSelected: isHighlight,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds M3U8 variant selector (radio-button style list)
  Widget _buildM3U8VariantSelector(
      BuildContext context, ColorScheme colorScheme) {
    final variants = prefetchedData!.m3u8Result!.variants;
    final selectedIdx = selectedM3U8VariantIndex ?? 0;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
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
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...List.generate(variants.length, (i) {
            final v = variants[i];
            final isSelected = i == selectedIdx;

            // Build label
            String label = v.resolution ?? 'Variant ${i + 1}';
            if (v.bandwidth != null) {
              final mbps = (v.bandwidth! / 1000000).toStringAsFixed(1);
              label += ' • ${mbps} Mbps';
            }
            if (v.frameRate != null) {
              label += ' • ${v.frameRate!.toStringAsFixed(0)}fps';
            }
            if (v.codecs != null) {
              label += ' • ${v.codecs}';
            }

            return InkWell(
              onTap: () => onM3U8VariantChanged?.call(i),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? colorScheme.tertiary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
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
    final bool active =
        isSelected ?? (selectedQuality.toLowerCase() == value.toLowerCase());
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onQualityChanged(value),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: active ? colorScheme.tertiary : colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 20,
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
              color:
                  active ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: active
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
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
    final isSelected = isAudio == isAudioOption;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onIsAudioChanged(isAudioOption),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.tertiary : colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for format option display
class _FormatOption {
  final String value;
  final String label;
  final IconData icon;

  const _FormatOption({
    required this.value,
    required this.label,
    required this.icon,
  });
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
        duration: const Duration(milliseconds: 100),
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
