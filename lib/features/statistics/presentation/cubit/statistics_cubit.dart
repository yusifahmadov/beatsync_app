import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/features/statistics/domain/entities/hrv_analysis_result.dart';
import 'package:beatsync_app/features/statistics/domain/usecases/get_user_analysis_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final GetUserAnalysisUseCase _getUserAnalysisUseCase;

  StatisticsCubit({
    required GetUserAnalysisUseCase getUserAnalysisUseCase,
  })  : _getUserAnalysisUseCase = getUserAnalysisUseCase,
        super(StatisticsInitial());

  Future<void> fetchUserAnalysisData() async {
    emit(StatisticsLoading(
      selectedStartDate: state.selectedStartDate,
      selectedEndDate: state.selectedEndDate,
      selectedPresetRange: state.selectedPresetRange,
    ));
    try {
      final params = GetUserAnalysisParams(
        startDate: state.selectedStartDate,
        endDate: state.selectedEndDate,
      );
      final failureOrAnalysis = await _getUserAnalysisUseCase(params);

      failureOrAnalysis.fold(
        (failure) => emit(StatisticsError(
          message: _mapFailureToMessage(failure),
          selectedStartDate: state.selectedStartDate,
          selectedEndDate: state.selectedEndDate,
          selectedPresetRange: state.selectedPresetRange,
        )),
        (analysisResults) {
          final sortedResults = List<HrvAnalysisResult>.from(analysisResults)
            ..sort((a, b) => a.analysisTime.compareTo(b.analysisTime));

          emit(StatisticsLoaded(
            analysisResults: sortedResults,
            selectedStartDate: state.selectedStartDate,
            selectedEndDate: state.selectedEndDate,
            selectedPresetRange: state.selectedPresetRange,
          ));
        },
      );
    } catch (e, s) {
      emit(StatisticsError(
        message: "An unexpected error occurred: ${e.toString()}",
        selectedStartDate: state.selectedStartDate,
        selectedEndDate: state.selectedEndDate,
        selectedPresetRange: state.selectedPresetRange,
      ));
      print("Error fetching statistics: $e\n$s");
    }
  }

  Future<void> setDateRange(DateTime startDate, DateTime endDate) async {
    final newState = StatisticsLoading(
      selectedStartDate: startDate,
      selectedEndDate: endDate,
      selectedPresetRange: PresetRange.Custom,
    );
    emit(newState);
    await fetchUserAnalysisData();
  }

  Future<void> setPresetRange(PresetRange range) async {
    DateTime startDate;
    DateTime endDate;
    final now = DateTime.now();

    switch (range) {
      case PresetRange.Today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case PresetRange.SevenDays:
        startDate =
            DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case PresetRange.ThirtyDays:
        startDate =
            DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case PresetRange.Last90Days:
        startDate =
            DateTime(now.year, now.month, now.day).subtract(const Duration(days: 89));
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case PresetRange.Custom:
        if (state.selectedPresetRange == PresetRange.Custom) return;
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
    }

    final newState = StatisticsLoading(
      selectedStartDate: startDate,
      selectedEndDate: endDate,
      selectedPresetRange: range,
    );
    emit(newState);
    await fetchUserAnalysisData();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.statusCode != null
          ? 'Server Error (${failure.statusCode}): ${failure.message}'
          : 'Server Error: ${failure.message}';
    } else if (failure is CacheFailure) {
      return 'Cache Error: ${failure.message}';
    } else if (failure is ParsingFailure) {
      return 'Data Error: ${failure.message}';
    } else {
      return 'Error: ${failure.message}';
    }
  }
}
