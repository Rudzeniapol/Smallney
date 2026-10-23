import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers.dart';

part 'app_preferences.g.dart';

/// Device-level preferences (not synced): theme and language.
class AppPreferences {
  const AppPreferences({this.themeMode = ThemeMode.system, this.locale});

  final ThemeMode themeMode;

  /// Null = follow the system (Russian when the system language is not supported).
  final Locale? locale;
}

@Riverpod(keepAlive: true)
class Preferences extends _$Preferences {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';

  @override
  AppPreferences build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final theme = ThemeMode.values.asNameMap()[prefs.getString(_themeKey)] ?? ThemeMode.system;
    final locale = prefs.getString(_localeKey);
    return AppPreferences(themeMode: theme, locale: locale == null ? null : Locale(locale));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ref.read(sharedPreferencesProvider).setString(_themeKey, mode.name);
    state = AppPreferences(themeMode: mode, locale: state.locale);
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
    state = AppPreferences(themeMode: state.themeMode, locale: locale);
  }
}
