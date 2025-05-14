import 'package:beatsync_app/core/services/storage_service.dart';
import 'package:beatsync_app/core/settings/app_settings.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';

class AppSettingsCubit extends Cubit<AppSettings> {
  final StorageService _storageService;

  AppSettingsCubit(this._storageService) : super(const AppSettings()) {

    _loadAppSettings();
  }

  Future<void> _loadAppSettings() async {
    final themePreferenceName = await _storageService.getThemePreference();
    final languageCode = await _storageService.getLanguage();

    AppThemePreference themePreference = AppThemePreference.values.firstWhere(
      (e) => e.name == themePreferenceName,
      orElse: () => AppThemePreference.system,
    );

    AppLanguage language = AppLanguage.values.firstWhere(
      (e) => e.name == languageCode,
      orElse: () => AppLanguage.en,
    );
    emit(AppSettings(language: language, themePreference: themePreference));
  }

  Future<void> updateThemePreference(AppThemePreference preference) async {
    await _storageService.setThemePreference(preference.name);
    emit(state.copyWith(themePreference: preference));
  }

  Future<void> updateLanguage(AppLanguage language) async {
    await _storageService.saveLanguage(language.name);
    emit(state.copyWith(language: language));
  }
}
