import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kzdownloader/core/services/settings_service.dart';

part 'locale_provider.g.dart';

// Provider for managing the application's locale.
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Future<Locale?> build() async {
    final settings = SettingsService();
    final langCode = await settings.getLanguage();
    if (langCode != null) {
      return Locale(langCode);
    }
    return null; // System default
  }

  // Sets the application locale and persists it.
  Future<void> setLocale(Locale locale) async {
    final settings = SettingsService();
    await settings.setLanguage(locale.languageCode);
    state = AsyncData(locale);
  }
}
