import 'package:beatsync_app/features/home/domain/repositories/home_repository.dart';
import 'package:beatsync_app/features/home/domain/usecases/get_latest_today_analysis_usecase.dart';
import 'package:beatsync_app/features/statistics/domain/usecases/get_user_analysis_usecase.dart';
import 'package:get_it/get_it.dart';

import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/get_auth_status_usecase.dart';
import '../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../features/authentication/domain/usecases/login_usecase.dart';
import '../features/authentication/domain/usecases/logout_usecase.dart';
import '../features/authentication/domain/usecases/register_usecase.dart';

void registerUseCases(GetIt sl) {
  sl.registerLazySingleton(() => GetAuthStatusUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LoginUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetLatestTodayAnalysisUseCase(sl<HomeRepository>()));

  sl.registerLazySingleton(() => GetUserAnalysisUseCase(sl()));
}
