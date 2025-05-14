import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

class SharedPreferencesStorageService implements StorageService {
  static const String _themePreferenceKey = 'app_theme_preference';
  static const String _languageKey = 'app_language';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<String?> getThemePreference() async {
    final prefs = await _prefs;
    return prefs.getString(_themePreferenceKey);
  }

  @override
  Future<void> setThemePreference(String themePreferenceName) async {
    final prefs = await _prefs;
    await prefs.setString(_themePreferenceKey, themePreferenceName);
  }

  @override
  Future<String?> getLanguage() async {
    final prefs = await _prefs;
    return prefs.getString(_languageKey);
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    final prefs = await _prefs;
    await prefs.setString(_languageKey, languageCode);
  }
}
