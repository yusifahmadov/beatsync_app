import 'package:beatsync_app/core/interceptors/auth_interceptor.dart';
import 'package:beatsync_app/features/heart_rate/data/datasources/heart_rate_remote_data_source.dart';
import 'package:beatsync_app/features/heart_rate/data/datasources/heart_rate_remote_data_source_impl.dart';
import 'package:beatsync_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../core/auth/auth_token_provider.dart';
import '../core/services/dio_http_client_service.dart'; 
import '../features/authentication/data/datasources/auth_local_data_source.dart';
import '../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../features/statistics/data/datasources/statistics_remote_data_source.dart';

void registerDatasources(GetIt sl) {
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('BASE_URL'),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors
        .add(sl<AuthInterceptor>()); 
    return dio;
  });
  sl.registerLazySingleton<DioHttpClientService>(() => DioHttpClientService(sl<Dio>()));
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => SecureStorageAuthLocalDataSource(secureStorage: sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<AuthTokenProvider>(
      () => sl<AuthLocalDataSource>() as SecureStorageAuthLocalDataSource);
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(httpClientService: sl<DioHttpClientService>()),
  );

  sl.registerLazySingleton<StatisticsRemoteDataSource>(
    () => StatisticsRemoteDataSourceImpl(dio: sl(), authRepository: sl()),
  );


  sl.registerLazySingleton<HeartRateRemoteDataSource>(
    () => HeartRateRemoteDataSourceImpl(dio: sl(), authRepository: sl()),
  );

  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      statisticsRemoteDataSource: sl(),
    ),
  );
}
