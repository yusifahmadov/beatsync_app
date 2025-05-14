part of 'statistics_cubit.dart';

enum PresetRange {
  Today,
  SevenDays,
  ThirtyDays,
  Last90Days,
  Custom,
}

abstract class StatisticsState extends Equatable {
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final PresetRange selectedPresetRange;

  const StatisticsState({
    required this.selectedStartDate,
    required this.selectedEndDate,
    required this.selectedPresetRange,
  });

  @override
  List<Object> get props => [selectedStartDate, selectedEndDate, selectedPresetRange];


  static DateTime get _initialStartDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }


  static DateTime get _initialEndDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }
}

class StatisticsInitial extends StatisticsState {
  StatisticsInitial()
      : super(
          selectedStartDate: StatisticsState._initialStartDate,
          selectedEndDate: StatisticsState._initialEndDate,
          selectedPresetRange: PresetRange.Today,
        );
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading({
    required super.selectedStartDate,
    required super.selectedEndDate,
    required super.selectedPresetRange,
  });
}

class StatisticsLoaded extends StatisticsState {
  final List<HrvAnalysisResult> analysisResults;

  const StatisticsLoaded({
    required this.analysisResults,
    required super.selectedStartDate,
    required super.selectedEndDate,
    required super.selectedPresetRange,
  });

  @override
  List<Object> get props => super.props..addAll([analysisResults]);
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError({
    required this.message,
    required super.selectedStartDate,
    required super.selectedEndDate,
    required super.selectedPresetRange,
  });

  @override
  List<Object> get props => super.props..addAll([message]);
}
