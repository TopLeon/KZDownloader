import 'package:kzdownloader/core/services/llm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_service.g.dart';

// Manages application settings using SharedPreferences.
class SettingsService {
  static const String _keyDownloadPath = 'download_path';
  static const String _keyDefaultFormat = 'default_format';
  static const String _keyDefaultAudioFormat = 'default_audio_format';
  static const String _keyDefaultQuality = 'default_quality';
  static const String _keyQualityMode = 'quality_mode';
  static const String _keyLanguage = 'language';
  static const String _keyThemeMode = 'theme_mode';
  static const String _aiModelKey = 'ai_selected_model';
  static const String _aiProviderKey = 'ai_provider';
  static const String _keyMaxConcurrentDownloads = 'max_concurrent_downloads';
  static const String _keyMaxCharactersForAI = 'max_characters_for_ai';
  static const String _keySummaryAnimationsEnabled =
      'summary_animations_enabled';
  static const String _keyMaxConcurrentGlobalDownloads =
      'max_concurrent_global_downloads';

  // Gets whether summary animations are enabled.
  Future<bool> getSummaryAnimationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySummaryAnimationsEnabled) ?? true;
  }

  // Sets whether summary animations are enabled.
  Future<void> setSummaryAnimationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySummaryAnimationsEnabled, enabled);
  }

  // Gets the maximum number of characters to use for AI summary/chat.
  Future<int> getMaxCharactersForAI() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMaxCharactersForAI) ?? 25000;
  }

  // Sets the maximum number of characters to use for AI summary/chat.
  Future<void> setMaxCharactersForAI(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaxCharactersForAI, count);
  }

  // Gets the currently selected AI Provider (e.g., 'ollama', 'openai').
  Future<String> getAiProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_aiProviderKey) ?? 'ollama';
  }

  // Sets the selected AI Provider.
  Future<void> setAiProvider(String provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiProviderKey, provider);
  }

  // Gets the currently selected AI Model name.
  Future<String?> get selectedAiModel async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_aiModelKey);
  }

  // Sets the selected AI Model and updates the LlmService immediately.
  Future<void> setAiModel(String modelName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiModelKey, modelName);
    LlmService().setModel(modelName);
  }

  // Gets the user selected theme mode (light, dark, system).
  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode);
  }

  // Sets the theme mode.
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  // Gets the selected language code.
  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  // Sets the selected language code.
  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, langCode);
  }

  // Gets the download directory path.
  Future<String?> getDownloadPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDownloadPath);
  }

  // Sets the download directory path.
  Future<void> setDownloadPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDownloadPath, path);
  }

  // Gets the default download format.
  Future<DownloadFormat> getDefaultFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyDefaultFormat);
    return DownloadFormat.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DownloadFormat.mp4,
    );
  }

  // Sets the default download format.
  Future<void> setDefaultFormat(DownloadFormat format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultFormat, format.name);
  }

  // Gets the default audio download format.
  Future<DownloadFormat> getDefaultAudioFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyDefaultAudioFormat);
    return DownloadFormat.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DownloadFormat.mp3,
    );
  }

  // Sets the default audio download format.
  Future<void> setDefaultAudioFormat(DownloadFormat format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultAudioFormat, format.name);
  }

  // Gets the default download quality.
  Future<DownloadQuality> getDefaultQuality() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyDefaultQuality);
    return DownloadQuality.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DownloadQuality.best,
    );
  }

  // Sets the default download quality.
  Future<void> setDefaultQuality(DownloadQuality quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultQuality, quality.name);
  }

  // Gets the quality mode (simple or expert).
  Future<QualityMode> getQualityMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyQualityMode);
    return QualityMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => QualityMode.simple,
    );
  }

  // Sets the quality mode.
  Future<void> setQualityMode(QualityMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyQualityMode, mode.name);
  }

  // Gets the maximum number of concurrent downloads for playlists.
  Future<int> getMaxConcurrentDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMaxConcurrentDownloads) ?? 3;
  }

  // Sets the maximum number of concurrent downloads for playlists.
  Future<void> setMaxConcurrentDownloads(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaxConcurrentDownloads, count);
  }

  // Gets the maximum number of concurrent global downloads.
  Future<int> getMaxConcurrentGlobalDownloads() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMaxConcurrentGlobalDownloads) ?? 3;
  }

  // Sets the maximum number of concurrent global downloads.
  Future<void> setMaxConcurrentGlobalDownloads(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaxConcurrentGlobalDownloads, count);
  }
}

// Supported download formats.
enum DownloadFormat { mp4, mkv, mp3, m4a, ogg }

// Supported download qualities.
enum DownloadQuality { best, high, medium, low, p2160, p1440, p1080, p720, p480 }

// Quality mode selection (simple or expert).
enum QualityMode { simple, expert }

@Riverpod(keepAlive: true)
SettingsService settingsService(Ref ref) {
  return SettingsService();
}
