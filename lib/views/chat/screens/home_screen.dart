import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kzdownloader/core/providers/quality_provider.dart';
import 'package:kzdownloader/l10n/arb/app_localizations.dart';
import 'package:kzdownloader/views/chat/widgets/input/chat_input_area.dart';
import 'package:kzdownloader/views/chat/widgets/window_button.dart';
import 'package:ultimate_flutter_icons/ficon.dart';
import 'package:ultimate_flutter_icons/icons/rx.dart';
import 'package:window_manager/window_manager.dart';

class HomeScreen extends ConsumerWidget {
  final TextEditingController controller;
  final String selectedProvider;
  final bool showVideoOptions;
  final bool isAudio;
  final bool isSummaryMode;
  final bool isPrefetchingMetadata;
  final bool metadataFetchCompleted;
  final bool showInitialAnimation;
  final VoidCallback onSubmit;
  final Function(String) onProviderChanged;
  final Function(bool) onIsAudioChanged;
  final Function(bool) onSummarizeOnlyChanged;
  final Function(bool) onPrefetchStateChanged;
  final VoidCallback onMetadataFetched;
  final String expectedChecksum;
  final String checksumAlgorithm;
  final Function(String)? onChecksumChanged;
  final Function(String)? onAlgorithmChanged;

  const HomeScreen({
    super.key,
    required this.controller,
    required this.selectedProvider,
    required this.showVideoOptions,
    required this.isAudio,
    required this.isSummaryMode,
    required this.isPrefetchingMetadata,
    required this.metadataFetchCompleted,
    required this.showInitialAnimation,
    required this.onSubmit,
    required this.onProviderChanged,
    required this.onIsAudioChanged,
    required this.onSummarizeOnlyChanged,
    required this.onPrefetchStateChanged,
    required this.onMetadataFetched,
    this.expectedChecksum = '',
    this.checksumAlgorithm = 'MD5',
    this.onChecksumChanged,
    this.onAlgorithmChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final qualitySettingsAsync = ref.watch(qualitySettings_Provider);

    return MouseRegion(
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: Stack(
                children: [
                  Positioned(
                    bottom: size.height * 0.15,
                    left: size.width * 0.15,
                    child: _buildGlowBlob(
                      color: const Color(0xFF3B82F6),
                      isLightTheme: isLightTheme,
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.15,
                    right: size.width * 0.15,
                    child: _buildGlowBlob(
                      color: const Color(0xFF06B6D4),
                      isLightTheme: isLightTheme,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.32),
                  Center(child: _buildBrandLogo(isLightTheme, colorScheme)),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          (!showVideoOptions ? 0.075 : 0.05)),
                  Center(
                    child: SizedBox(
                      width: 620,
                      child: qualitySettingsAsync.when(
                        data: (qualitySettings) => ChatInputArea(
                          controller: controller,
                          selectedProvider: selectedProvider,
                          showVideoOptions: showVideoOptions,
                          selectedQuality: qualitySettings.toDisplayString(),
                          isAudio: isAudio,
                          summarizeOnly: isSummaryMode,
                          isCentered: true,
                          qualityMode: qualitySettings.mode,
                          onSubmit: onSubmit,
                          onProviderChanged: onProviderChanged,
                          onQualityChanged: (value) async {
                            // Convert display string back to quality enum
                            DownloadQuality newQuality;
                            if (qualitySettings.mode == QualityMode.simple) {
                              if (value == 'Best') {
                                newQuality = DownloadQuality.best;
                              } else if (value == 'High') {
                                newQuality = DownloadQuality.high;
                              } else if (value == 'Medium') {
                                newQuality = DownloadQuality.medium;
                              } else {
                                newQuality = DownloadQuality.low;
                              }
                            } else {
                              if (value == '2160p') {
                                newQuality = DownloadQuality.p2160;
                              } else if (value == '1440p') {
                                newQuality = DownloadQuality.p1440;
                              } else if (value == '1080p') {
                                newQuality = DownloadQuality.p1080;
                              } else if (value == '720p') {
                                newQuality = DownloadQuality.p720;
                              } else {
                                newQuality = DownloadQuality.p480;
                              }
                            }
                            await ref
                                .read(qualitySettings_Provider.notifier)
                                .setQuality(newQuality);
                          },
                          onIsAudioChanged: onIsAudioChanged,
                          onSummarizeOnlyChanged: onSummarizeOnlyChanged,
                          onPrefetchStateChanged: onPrefetchStateChanged,
                          onMetadataFetched: onMetadataFetched,
                          expectedChecksum: expectedChecksum,
                          checksumAlgorithm: checksumAlgorithm,
                          onChecksumChanged: onChecksumChanged != null
                              ? (val) => onChecksumChanged!(val)
                              : null,
                          onAlgorithmChanged: onAlgorithmChanged != null
                              ? (val) => onAlgorithmChanged!(val)
                              : null,
                        ),
                        loading: () => ChatInputArea(
                          controller: controller,
                          selectedProvider: selectedProvider,
                          showVideoOptions: showVideoOptions,
                          selectedQuality: 'Best',
                          isAudio: isAudio,
                          summarizeOnly: isSummaryMode,
                          isCentered: true,
                          qualityMode: QualityMode.simple,
                          onSubmit: onSubmit,
                          onProviderChanged: (value) => {},
                          onQualityChanged: (value) {},
                          onIsAudioChanged: (value) {},
                          onSummarizeOnlyChanged: (value) {},
                        ),
                        error: (_, __) => ChatInputArea(
                          controller: controller,
                          selectedProvider: selectedProvider,
                          showVideoOptions: showVideoOptions,
                          selectedQuality: 'Best',
                          isAudio: isAudio,
                          summarizeOnly: isSummaryMode,
                          isCentered: true,
                          qualityMode: QualityMode.simple,
                          onSubmit: onSubmit,
                          onProviderChanged: (value) => {},
                          onQualityChanged: (value) {},
                          onIsAudioChanged: (value) {},
                          onSummarizeOnlyChanged: (value) {},
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: _buildStatusIndicator(
                      context,
                      colorScheme,
                      showInitialAnimation,
                      isPrefetchingMetadata,
                      metadataFetchCompleted,
                      controller.text,
                      showVideoOptions,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Window Control Buttons (Windows & Linux only)
          if (!Platform.isMacOS) ...[
            Positioned(
              top: 20,
              right: 16,
              child: Row(
                children: [
                  WindowButton(
                    icon: Icons.remove,
                    onPressed: () => windowManager.minimize(),
                  ),
                  const SizedBox(width: 2),
                  WindowButton(
                    icon: Icons.crop_square,
                    onPressed: () async {
                      if (await windowManager.isMaximized()) {
                        windowManager.unmaximize();
                      } else {
                        windowManager.maximize();
                      }
                    },
                  ),
                  const SizedBox(width: 2),
                  WindowButton(
                    icon: Icons.close,
                    isClose: true,
                    onPressed: () => windowManager.close(),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildGlowBlob({required Color color, required bool isLightTheme}) {
    final opacity = isLightTheme ? 0.0 : 0.1;

    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: color.withOpacity(opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildBrandLogo(bool isLightTheme, ColorScheme colorScheme) {
    if (isLightTheme) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.125),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 2),
              )
            ]),
        child: Image.asset('assets/banner.png', height: 80),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 12,
          right: 20,
          left: 18,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: colorScheme.tertiary,
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
            ]),
        child: Image.asset('assets/logo.png', height: 50),
      );
    }
  }

  Widget _buildStatusIndicator(
    BuildContext context,
    ColorScheme colorScheme,
    bool showInitialAnimation,
    bool isPrefetchingMetadata,
    bool metadataFetchCompleted,
    String controllerText,
    bool showVideoOptions,
  ) {
    final l10n = AppLocalizations.of(context)!;
    dynamic icon;
    String text;

    if (showInitialAnimation) {
      icon = Icons.hourglass_empty;
      text = l10n.almostReady;
    } else if (isPrefetchingMetadata && controllerText.isNotEmpty) {
      icon = Icons.downloading;
      text = l10n.downloadingMetadata;
    } else if (metadataFetchCompleted && controllerText.isNotEmpty) {
      icon = Icons.check_circle_outline;
      text = l10n.metadataReady;
    } else {
      icon = RX.RxRocket;
      text = l10n.readyToDownload;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Stack(
        key: ValueKey<String>('${icon.toString()}-$text'),
        children: [
          Container(
            decoration: BoxDecoration(
                color: colorScheme.tertiary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                    left: BorderSide(
                        color: colorScheme.primary.withOpacity(0.15)),
                    right: BorderSide(
                        color: colorScheme.primary.withOpacity(0.15)),
                    bottom: BorderSide(
                        color: colorScheme.primary.withOpacity(0.15))),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                  )
                ]),
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                icon is FIconObject
                    ? FIcon(
                        icon,
                        color: colorScheme.primary,
                        size: 20,
                      )
                    : Icon(
                        icon,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                const SizedBox(width: 8),
                Text(text),
              ],
            ),
          ),
          if (showVideoOptions)
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                        Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.0),
                        Theme.of(context).scaffoldBackgroundColor
                      ],
                          begin: Alignment.bottomCenter,
                          end: AlignmentGeometry.topCenter)),
                ))
        ],
      ),
    );
  }
}
