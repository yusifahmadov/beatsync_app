import 'package:beatsync_app/core/services/camera_service.dart';
import 'package:beatsync_app/core/services/ppg_processor_service.dart';
import 'package:beatsync_app/features/authentication/domain/repositories/auth_repository.dart'; 
import 'package:beatsync_app/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:beatsync_app/features/authentication/domain/usecases/login_usecase.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/login_cubit/login_cubit.dart';
import 'package:beatsync_app/features/heart_rate/domain/repositories/heart_rate_repository.dart'; 
import 'package:beatsync_app/features/heart_rate/presentation/cubit/heart_rate_cubit.dart'; 
import 'package:beatsync_app/features/home/domain/usecases/get_latest_today_analysis_usecase.dart';
import 'package:beatsync_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:beatsync_app/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:get_it/get_it.dart';

import '../features/authentication/domain/usecases/get_auth_status_usecase.dart';
import '../features/authentication/domain/usecases/logout_usecase.dart';
import '../features/authentication/domain/usecases/register_usecase.dart';
import '../features/authentication/presentation/cubit/auth_cubit.dart';
import '../features/authentication/presentation/cubit/registration_cubit/registration_cubit.dart';

void registerCubits(GetIt sl) {

  final bool isEmulator = sl<bool>(instanceName: 'isEmulator');

  sl.registerLazySingleton(
    () => AuthCubit(
      getAuthStatusUsecase: sl<GetAuthStatusUsecase>(),
      logoutUsecase: sl<LogoutUsecase>(),
      getCurrentUserUsecase: sl<GetCurrentUserUsecase>(),
    ),
  );
  sl.registerLazySingleton(
    () => RegisterCubit(
      sl<RegisterUsecase>(),
    ),
  );

  sl.registerFactory(
    () => LoginCubit(
      loginUsecase: sl<LoginUsecase>(),
      authCubit: sl<AuthCubit>(),
    ),
  );

  sl.registerFactory(() => HomeCubit(
        getLatestTodayAnalysisUseCase: sl<GetLatestTodayAnalysisUseCase>(),
        authRepository: sl<AuthRepository>(),
      ));


  sl.registerFactory(() => StatisticsCubit(getUserAnalysisUseCase: sl()));


  sl.registerFactory(
    () => HeartRateCubit(
      useFakePpgOverride: isEmulator,
      heartRateRepository: sl<HeartRateRepository>(),
      authRepository: sl<AuthRepository>(),
      cameraService: sl<CameraService>(),
      ppgProcessorService: sl<PpgProcessorService>(),
    ),
  );





}
