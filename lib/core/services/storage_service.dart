


abstract class StorageService {
  Future<void> setThemePreference(String themePreferenceName);
  Future<String?> getThemePreference();
  Future<void> saveLanguage(String languageCode);
  Future<String?> getLanguage();

}
