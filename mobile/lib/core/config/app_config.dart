import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

/// Where the API lives. Build-time default via `--dart-define=API_BASE_URL=...`, changeable on the sign-in screen.
class AppConfig {
  AppConfig(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'api_base_url';
  static const _fromEnvironment = String.fromEnvironment('API_BASE_URL');

  /// Android emulators reach the host machine at 10.0.2.2.
  static String get defaultBaseUrl {
    if (_fromEnvironment.isNotEmpty) return _fromEnvironment;
    return Platform.isAndroid ? 'http://10.0.2.2:5080' : 'http://localhost:5080';
  }

  String get baseUrl => _prefs.getString(_key) ?? defaultBaseUrl;

  Future<void> setBaseUrl(String url) async {
    final trimmed = url.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty || trimmed == defaultBaseUrl) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, trimmed);
    }
  }
}
