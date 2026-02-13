import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kzdownloader/core/services/settings_service.dart';

part 'theme_provider.g.dart';

// Provider for managing the application's theme mode.
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  Future<ThemeMode> build() async {
    final settings = SettingsService();
    final modeStr = await settings.getThemeMode();
    return _parseThemeMode(modeStr);
  }

  // Parses the theme mode string to a ThemeMode enum.
  ThemeMode _parseThemeMode(String? mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  // Sets the application theme mode and persists it.
  Future<void> setThemeMode(ThemeMode mode) async {
    final settings = SettingsService();
    await settings.setThemeMode(mode.name);
    state = AsyncData(mode);
  }
}
