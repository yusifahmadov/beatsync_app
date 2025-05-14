import 'package:beatsync_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:beatsync_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:beatsync_app/features/home/domain/repositories/home_repository.dart';
import 'package:beatsync_app/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:beatsync_app/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:get_it/get_it.dart';

import '../features/authentication/data/datasources/auth_local_data_source.dart';
import '../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/heart_rate/data/datasources/heart_rate_remote_data_source.dart';
import '../features/heart_rate/data/repositories/heart_rate_repository_impl.dart';
import '../features/heart_rate/domain/repositories/heart_rate_repository.dart';

void registerRepositories(GetIt sl) {

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl<HomeRemoteDataSource>()),
  );

  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(remoteDataSource: sl()),
  );


  sl.registerLazySingleton<HeartRateRepository>(
    () => HeartRateRepositoryImpl(
      remoteDataSource: sl<HeartRateRemoteDataSource>(),
    ),
  );
}
