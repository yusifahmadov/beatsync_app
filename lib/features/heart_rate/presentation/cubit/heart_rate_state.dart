part of 'heart_rate_cubit.dart';

enum FingerDetectionStatus {
  noFinger,
  poorSignal,
  goodSignal,
  notApplicable,
}

@immutable
abstract class HeartRateState extends Equatable {
  final double measurementProgress;
  final bool isFingerDetected;
  final String? statusMessage;
  final String? errorMessage;
  final int? bpm;
  final bool isFakeMode;
  final List<EmaSensorValue>? emaValuesForRetry;

  const HeartRateState({
    this.measurementProgress = 0.0,
    this.isFingerDetected = false,
    this.statusMessage,
    this.errorMessage,
    this.bpm,
    this.isFakeMode = false,
    this.emaValuesForRetry,
  });

  @override
  List<Object?> get props => [
        measurementProgress,
        isFingerDetected,
        statusMessage,
        errorMessage,
        bpm,
        isFakeMode,
        emaValuesForRetry
      ];
}

class HeartRateInitial extends HeartRateState {
  const HeartRateInitial({
    super.isFingerDetected = false,
    super.statusMessage,
    super.bpm,
    super.isFakeMode,
  });
}

class HeartRateLoading extends HeartRateState {
  final List<EmaSensorValue> liveChartData;
  final int countdownValue;
  final FingerDetectionStatus fingerDetectionStatus;

  const HeartRateLoading(
    double progress, {
    this.liveChartData = const [],
    required this.countdownValue,
    this.fingerDetectionStatus = FingerDetectionStatus.notApplicable,
    super.isFingerDetected,
    super.statusMessage = "Measuring...",
    super.bpm,
    super.isFakeMode,
  }) : super(measurementProgress: progress);

  @override
  List<Object?> get props =>
      super.props..addAll([liveChartData, countdownValue, fingerDetectionStatus]);

  @override
  HeartRateLoading copyWith({
    double? progress,
    List<EmaSensorValue>? liveChartData,
    int? countdownValue,
    FingerDetectionStatus? fingerDetectionStatus,
    bool? isFingerDetected,
    String? statusMessage,
    int? bpm,
    bool? isFakeMode,
  }) {
    return HeartRateLoading(
      progress ?? measurementProgress,
      liveChartData: liveChartData ?? this.liveChartData,
      countdownValue: countdownValue ?? this.countdownValue,
      fingerDetectionStatus: fingerDetectionStatus ?? this.fingerDetectionStatus,
      isFingerDetected: isFingerDetected ?? this.isFingerDetected,
      statusMessage: statusMessage ?? this.statusMessage,
      bpm: bpm ?? this.bpm,
      isFakeMode: isFakeMode ?? this.isFakeMode,
    );
  }
}

class HeartRateDataReady extends HeartRateState {
  final List<EmaSensorValue> emaValues;

  const HeartRateDataReady({
    required this.emaValues,
    required double progress,
    required super.isFingerDetected,
    super.bpm,
    super.isFakeMode,
  }) : super(
            measurementProgress: progress,
            statusMessage: "Data Ready. BPM: ${bpm ?? '--'}",
            emaValuesForRetry: emaValues);

  @override
  List<Object?> get props => super.props..addAll([emaValues]);
}

class HeartRateSavingEmaData extends HeartRateState {
  const HeartRateSavingEmaData({
    required super.isFingerDetected,
    super.emaValuesForRetry,
    super.bpm,
    super.isFakeMode,
    super.statusMessage = "Sending data...",
  }) : super(measurementProgress: 1.0);
}

class HeartRateEmaDataSaveSuccess extends HeartRateState {
  const HeartRateEmaDataSaveSuccess({
    required super.isFingerDetected,
    super.bpm,
    super.isFakeMode,
  }) : super(
            measurementProgress: 1.0,
            statusMessage: "Data sent successfully! BPM: ${bpm ?? '--'}");
}

class HeartRateEmaDataSaveFailure extends HeartRateState {
  const HeartRateEmaDataSaveFailure({
    required super.isFingerDetected,
    required String specificErrorMessage,
    required super.emaValuesForRetry,
    super.bpm,
    super.isFakeMode,
  }) : super(
            errorMessage: specificErrorMessage,
            measurementProgress: 1.0,
            statusMessage: "Failed to save data. BPM: ${bpm ?? '--'}");
}

class HeartRateSuccess extends HeartRateState {
  final int bpmValue;

  const HeartRateSuccess({
    required this.bpmValue,
    required super.isFingerDetected,
    super.statusMessage = "Measurement Complete (BPM available)",
    super.isFakeMode,
  }) : super(measurementProgress: 1.0, bpm: bpmValue);

  @override
  List<Object?> get props => super.props..addAll([bpmValue]);
}

class HeartRateError extends HeartRateState {
  const HeartRateError(String message,
      {super.isFingerDetected = false, super.bpm, super.isFakeMode})
      : super(errorMessage: message, statusMessage: "Error");
}

class HeartRateFailure extends HeartRateState {
  const HeartRateFailure(String message,
      {required super.isFingerDetected, super.bpm, super.isFakeMode})
      : super(errorMessage: message, statusMessage: "Measurement Failed");
}
