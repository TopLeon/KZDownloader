import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kzdownloader/core/services/settings_service.dart';

// Export enums from settings_service for convenience
export 'package:kzdownloader/core/services/settings_service.dart'
    show DownloadQuality, QualityMode;

part 'quality_provider.g.dart';

// Data class to hold quality settings
class QualitySettings {
  final DownloadQuality quality;
  final QualityMode mode;

  const QualitySettings({
    required this.quality,
    required this.mode,
  });

  // Convert to simple quality string (Best, High, Medium, Low)
  String toSimpleString() {
    switch (quality) {
      case DownloadQuality.best:
        return 'Best';
      case DownloadQuality.high:
        return 'High';
      case DownloadQuality.medium:
        return 'Medium';
      case DownloadQuality.low:
        return 'Low';
      case DownloadQuality.p2160:
      case DownloadQuality.p1440:
        return 'Best'; // Fallback for expert qualities
      case DownloadQuality.p1080:
        return 'High';
      case DownloadQuality.p720:
        return 'Medium';
      case DownloadQuality.p480:
        return 'Low';
    }
  }

  // Convert to expert quality string (2160p, 1440p, 1080p, 720p, 480p)
  String toExpertString() {
    switch (quality) {
      case DownloadQuality.p2160:
        return '2160p';
      case DownloadQuality.p1440:
        return '1440p';
      case DownloadQuality.p1080:
        return '1080p';
      case DownloadQuality.p720:
        return '720p';
      case DownloadQuality.p480:
        return '480p';
      case DownloadQuality.best:
        return '2160p'; // Fallback for simple qualities
      case DownloadQuality.high:
        return '1080p';
      case DownloadQuality.medium:
        return '720p';
      case DownloadQuality.low:
        return '480p';
    }
  }

  // Get the appropriate quality string based on current mode
  String toDisplayString() {
    return mode == QualityMode.simple ? toSimpleString() : toExpertString();
  }

  QualitySettings copyWith({
    DownloadQuality? quality,
    QualityMode? mode,
  }) {
    return QualitySettings(
      quality: quality ?? this.quality,
      mode: mode ?? this.mode,
    );
  }
}

// Provider for managing quality settings
@riverpod
class QualitySettings_ extends _$QualitySettings_ {
  @override
  Future<QualitySettings> build() async {
    final settings = SettingsService();
    final quality = await settings.getDefaultQuality();
    final mode = await settings.getQualityMode();
    return QualitySettings(quality: quality, mode: mode);
  }

  // Updates the quality setting
  Future<void> setQuality(DownloadQuality quality) async {
    final settings = SettingsService();
    await settings.setDefaultQuality(quality);
    final currentSettings = await future;
    state = AsyncData(currentSettings.copyWith(quality: quality));
  }

  // Updates the quality mode
  Future<void> setMode(QualityMode mode) async {
    final settings = SettingsService();
    await settings.setQualityMode(mode);
    final currentSettings = await future;
    state = AsyncData(currentSettings.copyWith(mode: mode));
  }

  // Updates both quality and mode
  Future<void> setQualityAndMode(
      DownloadQuality quality, QualityMode mode) async {
    final settings = SettingsService();
    await settings.setDefaultQuality(quality);
    await settings.setQualityMode(mode);
    state = AsyncData(QualitySettings(quality: quality, mode: mode));
  }
}
