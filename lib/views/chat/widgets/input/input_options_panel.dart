import 'package:flutter/material.dart';
import 'package:kzdownloader/core/services/settings_service.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: (showVideoOptions)
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
                                        icon: Icons.high_quality,
                                        label: l10n.qualityBest,
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
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
