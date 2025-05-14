import 'package:flutter/material.dart'; 

enum AppLanguage { en, tr }



enum AppThemePreference { light, dark, system }

class AppSettings {
  final AppLanguage language;
  final AppThemePreference themePreference;

  const AppSettings({
    this.language = AppLanguage.en,
    this.themePreference = AppThemePreference.system,
  });

  AppSettings copyWith({
    AppLanguage? language,
    AppThemePreference? themePreference,
  }) {
    return AppSettings(
      language: language ?? this.language,
      themePreference: themePreference ?? this.themePreference,
    );
  }


  ThemeMode get themeMode {
    switch (themePreference) {
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.system:
      default:
        return ThemeMode.system;
    }
  }
}
