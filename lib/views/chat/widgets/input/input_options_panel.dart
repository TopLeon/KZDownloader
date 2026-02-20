import 'package:flutter/material.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

// Widget for selecting video/audio options and quality
class InputOptionsPanel extends StatelessWidget {
  final bool showVideoOptions;
  final String selectedQuality;
  final bool isAudio;
  final bool summarizeOnly;
  final QualityMode qualityMode;
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
    required this.qualityMode,
    required this.onQualityChanged,
    required this.onIsAudioChanged,
    required this.onSummarizeOnlyChanged,
    required this.l10n,
    this.isGeneric = false,
    this.expectedChecksum = '',
    this.checksumAlgorithm = 'MD5',
    this.onChecksumChanged,
    this.onAlgorithmChanged,
  });

  final bool isGeneric;
  final String expectedChecksum;
  final String checksumAlgorithm;
  final ValueChanged<String>? onChecksumChanged;
  final ValueChanged<String>? onAlgorithmChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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

                          // Quality Selector
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
                              children: qualityMode == QualityMode.simple
                                  ? [
                                      Expanded(
                                        child: _buildQualityOption(
                                          context,
                                          value: 'Best',
                                          icon: Icons.workspace_premium,
                                          label: l10n.qualityBest,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _buildQualityOption(
                                          context,
                                          value: 'High',
                                          icon: Icons.high_quality,
                                          label: l10n.qualityHigh,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _buildQualityOption(
                                          context,
                                          value: 'Medium',
                                          icon: Icons.ondemand_video,
                                          label: l10n.qualityMedium,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _buildQualityOption(
                                          context,
                                          value: 'Low',
                                          icon: Icons.sd_storage_rounded,
                                          label: l10n.qualityLow,
                                        ),
                                      ),
                                    ]
                                  : [
                                      Expanded(
                                        child: _buildQualityOption(
                                          context,
                                          value: '2160p',
                                          icon: Icons.four_k,
                                          label: '2160p',
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _buildQualityOption(
                                          context,
                                          value: '1440p',
                                          icon: Icons.video_settings,
                                          label: '1440p',
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _buildQualityOption(
                                          context,
                                          value: '1080p',
                                          icon: Icons.hd,
                                          label: '1080p',
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
                          ),
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

  Widget _buildQualityOption(
    BuildContext context, {
    required String value,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedQuality == value;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onQualityChanged(value),
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
