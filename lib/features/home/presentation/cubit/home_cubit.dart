import 'package:beatsync_app/core/usecases/usecase.dart'; 
import 'package:beatsync_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:beatsync_app/features/home/domain/usecases/get_latest_today_analysis_usecase.dart';
import 'package:beatsync_app/features/statistics/domain/entities/hrv_analysis_result.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetLatestTodayAnalysisUseCase _getLatestTodayAnalysisUseCase;
  final AuthRepository _authRepository;

  HomeCubit({
    required GetLatestTodayAnalysisUseCase getLatestTodayAnalysisUseCase,
    required AuthRepository authRepository,
  })  : _getLatestTodayAnalysisUseCase = getLatestTodayAnalysisUseCase,
        _authRepository = authRepository,
        super(HomeInitial());

  Future<void> loadHomeScreenData() async {
    final currentUser = await _authRepository.getCurrentUser();
    currentUser.fold(
      (failure) {
        emit(HomeError(errorMessage: "Failed to load user: ${failure.message}"));
      },
      (user) async {
        try {
          emit(HomeLoading());

          final String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

          final failureOrAnalysis = await _getLatestTodayAnalysisUseCase(NoParams());

          failureOrAnalysis.fold(
            (failure) {
              emit(HomeError(
                  errorMessage: "Failed to load analysis data: ${failure.message}"));
            },
            (HrvAnalysisResult? analysisResult) {
              if (analysisResult != null) {
                emit(HomeLoaded(
                  userName: user?.firstName ?? "",
                  currentDate: currentDate,
                  heartRateData: {
                    'value': analysisResult.bpm.toStringAsFixed(1),
                    'unit': 'bpm',
                    'timestamp': DateFormat('h:mm a')
                        .format(analysisResult.analysisTime.toLocal()),
                  },
                  rmssdData: {
                    'value': analysisResult.rmssd.toStringAsFixed(1),
                    'unit': 'ms'
                  },
                  sdnnData: {
                    'value': analysisResult.sdnn.toStringAsFixed(1),
                    'unit': 'ms'
                  },
                  lfhfData: {
                    'value': analysisResult.lfHfRatio.toStringAsFixed(2),
                    'unit': ''
                  },
                ));
              } else {
                emit(
                  HomeLoaded(
                    userName: user?.firstName ?? "",
                    currentDate: currentDate,
                    heartRateData: {
                      'value': null,
                      'unit': 'bpm',
                      'timestamp': null,
                    },
                    rmssdData: {
                      'value': null,
                      'unit': 'ms',
                      'timestamp': null,
                    },
                    sdnnData: {
                      'value': null,
                      'unit': 'ms',
                      'timestamp': null,
                    },
                    lfhfData: {
                      'value': null,
                      'unit': '',
                      'timestamp': null,
                    },
                  ),
                );
              }
            },
          );
        } catch (e) {
          emit(HomeError(errorMessage: "An unexpected error occurred: ${e.toString()}"));
        }
      },
    );
  }
}
