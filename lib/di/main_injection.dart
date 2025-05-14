import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../core/auth/auth_token_provider.dart';
import '../core/interceptors/auth_interceptor.dart';
import '../core/interceptors/error_handling_interceptor.dart';
import '../core/interceptors/logging_interceptor.dart';
import '../core/services/dio_http_client_service.dart';
import '../core/services/http_client_service.dart';
import '../core/services/shared_preferences_storage_service.dart';
import '../core/services/storage_service.dart';
import '../core/settings/app_settings_cubit.dart';
import './cubit_injection.dart';

import './datasource_injection.dart';
import './repository_injection.dart';
import './service_injection.dart';
import './usecase_injection.dart';

final sl = GetIt.instance;

Future<void> initCoreDependencies() async {
  registerServices(sl);
  registerDatasources(sl);
  registerRepositories(sl);
  registerUseCases(sl);
  registerCubits(sl);
  sl.registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(sl.get<AuthTokenProvider>()));
  sl.registerLazySingleton<ErrorHandlingInterceptor>(() => ErrorHandlingInterceptor());
  sl.registerLazySingleton<LoggingInterceptor>(() => LoggingInterceptor());

  sl.registerLazySingleton<HttpClientService>(() => DioHttpClientService(sl<Dio>()));

  sl.registerLazySingleton<StorageService>(() => SharedPreferencesStorageService());

  sl.registerLazySingleton<AppSettingsCubit>(
      () => AppSettingsCubit(sl<StorageService>()));
}
