import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:beatsync_app/core/services/camera_service.dart';
import 'package:beatsync_app/core/services/ppg_processor_service.dart'; 
import 'package:beatsync_app/features/authentication/domain/repositories/auth_repository.dart'; 
import 'package:beatsync_app/features/heart_rate/domain/repositories/heart_rate_repository.dart'; 
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/ppg_data.dart'; 
import '../../domain/entities/sensor_data.dart';

part 'heart_rate_state.dart'; 

class HeartRateCubit extends Cubit<HeartRateState> {
  final CameraService _cameraService;
  final PpgProcessorService _ppgProcessorService;
  final AuthRepository _authRepository; 
  final HeartRateRepository _heartRateRepository; 

  Timer? _measurementTimer;
  Timer? _fakeDataTimer;

  List<EmaSensorValue> _currentLiveChartPoints = []; 

  final bool _useFakePpgSource;

  static const String _tag = 'HeartRateCubit';
  static const Duration measurementDuration = Duration(seconds: 55);
  static const Duration fakeMeasurementDuration = Duration(seconds: 5);

  HeartRateCubit({
    required CameraService cameraService,
    required PpgProcessorService ppgProcessorService,
    required AuthRepository authRepository, 
    required HeartRateRepository heartRateRepository, 

    bool useFakePpgOverride =
        const bool.fromEnvironment('USE_FAKE_PPG', defaultValue: false),
  })  : _cameraService = cameraService,
        _ppgProcessorService = ppgProcessorService,
        _authRepository = authRepository, 
        _heartRateRepository = heartRateRepository, 
        _useFakePpgSource = useFakePpgOverride, 
        super(HeartRateInitial(
          isFakeMode: useFakePpgOverride,
        ));

  static Duration _getEffectiveMeasurementDuration(
      bool isFakeMode, Duration realDuration, Duration fakeDuration) {
    return isFakeMode ? fakeDuration : realDuration;
  }

  Future<void> startMeasurement() async {
    developer.log('Starting measurement... Fake mode: $_useFakePpgSource', name: _tag);
    _ppgProcessorService.reset(); 
    _currentLiveChartPoints = []; 

    final effectiveMeasurementDuration = _getEffectiveMeasurementDuration(
        _useFakePpgSource, measurementDuration, fakeMeasurementDuration);

    if (_useFakePpgSource) {
      final FingerDetectionStatus initialFingerStatus = FingerDetectionStatus.goodSignal;

      emit(HeartRateLoading(
        0.0, 
        countdownValue: effectiveMeasurementDuration.inSeconds,
        isFakeMode: _useFakePpgSource,
        liveChartData: _currentLiveChartPoints,
        fingerDetectionStatus: initialFingerStatus,
      ));
      _fakeDataTimer?.cancel();
      int ticks = 0;
      const int ticksPerSecond = 10; 
      final int totalTicksToRun = effectiveMeasurementDuration.inSeconds * ticksPerSecond;

      final List<EmaSensorValue> allFakePointsForSession = _generateFakePpgOutput(
              durationSeconds: effectiveMeasurementDuration.inSeconds, fps: 2.0)
          .emaValues;
      int pointsPerUpdate = (allFakePointsForSession.length / totalTicksToRun).ceil();
      if (pointsPerUpdate == 0 && allFakePointsForSession.isNotEmpty) {
        pointsPerUpdate = 1;
      }
      int currentPointIndex = 0;

      _fakeDataTimer =
          Timer.periodic(Duration(milliseconds: 1000 ~/ ticksPerSecond), (timer) {
        if (ticks >= totalTicksToRun) {
          timer.cancel();
          _currentLiveChartPoints = allFakePointsForSession;
          final currentState = state;
          bool currentFingerDetected = false;
          if (currentState is HeartRateLoading) {
            currentFingerDetected = currentState.isFingerDetected;
          }

          emit(HeartRateDataReady(
            progress: 1.0, 
            isFakeMode: _useFakePpgSource,
            emaValues: _currentLiveChartPoints,
            bpm: _generateFakePpgOutput(
                    durationSeconds: effectiveMeasurementDuration.inSeconds, fps: 1.0)
                .bpm,
            isFingerDetected: currentFingerDetected,
          ));
          return;
        }

        int endRange = currentPointIndex + pointsPerUpdate;
        if (endRange > allFakePointsForSession.length) {
          endRange = allFakePointsForSession.length;
        }
        if (currentPointIndex < endRange) {
          _currentLiveChartPoints
              .addAll(allFakePointsForSession.getRange(currentPointIndex, endRange));
        }
        currentPointIndex = endRange;

        const int maxLivePointsDisplay =
            150; 
        if (_currentLiveChartPoints.length > maxLivePointsDisplay) {
          _currentLiveChartPoints = _currentLiveChartPoints
              .sublist(_currentLiveChartPoints.length - maxLivePointsDisplay);
        }

        ticks++;
        int remainingSeconds = (totalTicksToRun - ticks) ~/ ticksPerSecond;
        if (remainingSeconds < 0) remainingSeconds = 0;

        double currentProgress = ticks / totalTicksToRun.toDouble();
        currentProgress = currentProgress.clamp(0.0, 1.0);

        if (state is HeartRateLoading) {
          emit((state as HeartRateLoading).copyWith(
            countdownValue: remainingSeconds,
            liveChartData: List.from(_currentLiveChartPoints),
            progress: currentProgress,

          ));
        }
      });

    } else {

      final cameraPermissionStatus = await Permission.camera.status;
      if (!cameraPermissionStatus.isGranted) {
        developer.log('Camera permission not granted before starting measurement.',
            name: _tag);
        emit(HeartRateFailure(
          'Camera permission not granted. Please grant permission in app settings.',
          isFakeMode: _useFakePpgSource,
          isFingerDetected: false, 
        ));
        return;
      }

      final FingerDetectionStatus initialFingerStatus = FingerDetectionStatus.noFinger;
      emit(HeartRateLoading(
        0.0, 
        countdownValue: effectiveMeasurementDuration.inSeconds,
        isFakeMode: _useFakePpgSource,
        liveChartData: _currentLiveChartPoints,
        fingerDetectionStatus: initialFingerStatus, 
        isFingerDetected: false, 
      ));
      try {
        await _cameraService.initializeController();
        await _cameraService.setFlashMode(FlashMode.torch);
        developer.log('Camera initialized and flash turned on by Cubit.', name: _tag);

        final DateTime measurementStartTime = DateTime.now();

        await _cameraService.startImageStream((image) async {
          if (!(state is HeartRateLoading || state is HeartRateDataReady)) {
            return;
          }

          final PpgProcessingOutput? ppgOutput =
              await _ppgProcessorService.processImage(image);
          final bool currentFingerIsDetectedBool = _ppgProcessorService.isFingerDetected;


          if (ppgOutput == null && !currentFingerIsDetectedBool) {
            developer.log(
                'PPGService returned null output AND finger not detected. Signal extraction might be failing.',
                name: _tag);
          }


          FingerDetectionStatus currentFingerStatusEnum = FingerDetectionStatus.noFinger;
          if (currentFingerIsDetectedBool) {


            currentFingerStatusEnum = FingerDetectionStatus.goodSignal;
          }

          if (state is HeartRateLoading) {
            final HeartRateLoading currentLoadingState = state as HeartRateLoading;
            if (ppgOutput != null) {
              if (ppgOutput.emaValues.isNotEmpty && ppgOutput.bpm != null) {
                developer.log(
                    'HeartRateCubit: Full data ready. EMA: ${ppgOutput.emaValues.length}, BPM: ${ppgOutput.bpm}',
                    name: _tag);
                _currentLiveChartPoints = ppgOutput.emaValues;
                emit(HeartRateDataReady(
                  progress: 1.0, 
                  isFakeMode: _useFakePpgSource,
                  emaValues: _currentLiveChartPoints,
                  bpm: ppgOutput.bpm,
                  isFingerDetected: currentFingerIsDetectedBool,
                ));
                _stopMeasurementProcess(
                    manualStop: false, reason: 'PPG data processed with BPM');
              } else if (ppgOutput.latestEmaValue != null) {
                _currentLiveChartPoints.add(ppgOutput.latestEmaValue!);
                const int maxLivePoints = 225;
                if (_currentLiveChartPoints.length > maxLivePoints) {
                  _currentLiveChartPoints = _currentLiveChartPoints
                      .sublist(_currentLiveChartPoints.length - maxLivePoints);
                }

                final int elapsedSeconds =
                    DateTime.now().difference(measurementStartTime).inSeconds;
                final int currentCountdown =
                    (effectiveMeasurementDuration.inSeconds - elapsedSeconds)
                        .clamp(0, effectiveMeasurementDuration.inSeconds);

                double currentProgress =
                    elapsedSeconds / effectiveMeasurementDuration.inSeconds.toDouble();
                currentProgress = currentProgress.clamp(0.0, 1.0);

                emit(currentLoadingState.copyWith(
                  liveChartData: List.from(_currentLiveChartPoints),
                  fingerDetectionStatus: currentFingerStatusEnum,
                  isFingerDetected: currentFingerIsDetectedBool,
                  countdownValue: currentCountdown,
                  progress: currentProgress,
                  statusMessage: "Hold steady...",
                ));
              } else if (!currentFingerIsDetectedBool) {

                _currentLiveChartPoints = []; 
                emit(currentLoadingState.copyWith(
                  liveChartData: _currentLiveChartPoints,
                  fingerDetectionStatus: FingerDetectionStatus.noFinger,
                  isFingerDetected: false,
                  statusMessage: "Finger lost. Place finger on camera.",

                ));
              }
            }
          }
        });

        _startMeasurementTimers(measurementStartTime);
        developer.log('Image stream started and measurement timers initiated.',
            name: _tag);
      } catch (e, stackTrace) {
        developer.log('Error starting measurement: $e',
            name: _tag, error: e, stackTrace: stackTrace);
        await _cameraService
            .setFlashMode(FlashMode.off)
            .catchError((e) => developer.log("Error turning off flash: $e", name: _tag));


        final bool fingerDetectedAtFailure = (state is HeartRateLoading)
            ? (state as HeartRateLoading).isFingerDetected
            : false;

        emit(HeartRateFailure(
          'Failed to start measurement: ${e.toString()}',
          isFakeMode: _useFakePpgSource,
          isFingerDetected: fingerDetectedAtFailure,


        ));
      }
    }
  }

  void _startMeasurementTimers(DateTime measurementStartTime) {
    final effectiveMeasurementDuration = _getEffectiveMeasurementDuration(
        _useFakePpgSource, measurementDuration, fakeMeasurementDuration);

    if (_useFakePpgSource) {
      developer.log(
          'Fake mode: Skipping real measurement timer setup in _startMeasurementTimers.',
          name: _tag);
      _measurementTimer?.cancel();
      _measurementTimer = null;
      return;
    }
    _measurementTimer?.cancel();
    _measurementTimer = Timer(effectiveMeasurementDuration, () {
      developer.log('Measurement duration elapsed. Auto-stopping...', name: _tag);
      if (state is HeartRateLoading) {
        final currentLoadingState = state as HeartRateLoading;
        _stopMeasurementProcess(manualStop: false, reason: 'Duration elapsed');
        emit(HeartRateFailure(
          'Measurement timed out. No data processed.',
          isFakeMode: _useFakePpgSource,
          isFingerDetected: currentLoadingState.isFingerDetected,
          bpm: currentLoadingState.bpm,

        ));
      }
    });
  }

  Future<void> stopMeasurement(
      {bool manualStop = true, String reason = 'Manual stop'}) async {
    developer.log(
        '[HeartRateCubit] stopMeasurement called. manualStop: $manualStop, Fake: $_useFakePpgSource, Current state: ${state.runtimeType}, Reason: $reason',
        name: _tag);

    _fakeDataTimer?.cancel();
    _fakeDataTimer = null;
    _measurementTimer?.cancel();
    _measurementTimer = null;


    if (!_useFakePpgSource) {
      await _stopMeasurementProcess(manualStop: manualStop, reason: reason);
    } else {
      developer.log('Fake mode: Skipping camera/PPG service stop procedures.',
          name: _tag);
    }


    if (manualStop ||
        !(state is HeartRateDataReady ||
            state is HeartRateSavingEmaData || 
            state is HeartRateEmaDataSaveSuccess)) {
      emit(HeartRateInitial(
        isFakeMode: _useFakePpgSource,
      ));
    } else {
      developer.log(
          'stopMeasurement: Auto-stop, current state ${state.runtimeType} is considered final for this phase.',
          name: _tag);
    }
  }

  Future<void> _stopMeasurementProcess({required bool manualStop, String? reason}) async {
    developer.log(
        'Executing _stopMeasurementProcess (Real Mode Cleanup)... Manual: $manualStop, Reason: $reason',
        name: _tag);
    try {
      await _cameraService.stopImageStream();
      developer.log('Image stream stopped via CameraService call.', name: _tag);
    } catch (e) {
      developer.log('Error stopping image stream via CameraService: $e', name: _tag);
    }
    try {
      await _cameraService.setFlashMode(FlashMode.off);
      developer.log('Flash mode set to off by Cubit.', name: _tag);
    } catch (e) {
      developer.log('Error setting flash mode to off: $e', name: _tag);
    }
    developer.log('Internal real measurement processes stopped.', name: _tag);
  }

  Future<void> sendEmaDataToBackend() async {
    if (state is! HeartRateDataReady) {
      developer.log(
          'sendEmaDataToBackend called in an invalid state: ${state.runtimeType}',
          name: _tag);
      return;
    }

    final dataReadyState = state as HeartRateDataReady;

    emit(HeartRateSavingEmaData(
      bpm: dataReadyState.bpm,
      isFakeMode: dataReadyState.isFakeMode,
      emaValuesForRetry: dataReadyState.emaValues, 
      isFingerDetected: dataReadyState.isFingerDetected,
    ));

    try {
      final userResult = await _authRepository.getCurrentUser();

      await userResult.fold(
        (authFailure) async {
          developer.log('Failed to fetch user: ${authFailure.toString()}', name: _tag);
          emit(HeartRateEmaDataSaveFailure(
            specificErrorMessage: "User not logged in. Please log in to save data.",
            emaValuesForRetry: dataReadyState.emaValues,
            bpm: dataReadyState.bpm,
            isFakeMode: dataReadyState.isFakeMode,
            isFingerDetected: dataReadyState.isFingerDetected,
          ));
        },
        (currentUser) async {
          if (currentUser == null) {
            developer.log(
                'Current user is null after successful fetch, this should not happen.',
                name: _tag);
            emit(HeartRateEmaDataSaveFailure(
              specificErrorMessage: "User information not available.",
              emaValuesForRetry: dataReadyState.emaValues,
              bpm: dataReadyState.bpm,
              isFakeMode: dataReadyState.isFakeMode,
              isFingerDetected: dataReadyState.isFingerDetected,
            ));
            return;
          }
          developer.log('User fetched: ${currentUser.id}', name: _tag);


          final sensorData = SensorData(
            userId: currentUser.id, 
            timestamp: DateTime.now(),

            data: dataReadyState.emaValues
                .map((e) => PPGData(timestamp: e.time, value: e.value))
                .toList(),
            bpm: dataReadyState.bpm ?? 0,

          );


          developer.log(
              'Attempting to save sensor data for user ${sensorData.userId}, BPM: ${sensorData.bpm}',
              name: _tag);

          final saveDataResult = await _heartRateRepository.saveSensorData(sensorData);

          saveDataResult.fold(
            (saveFailure) {
              developer.log('Failed to save sensor data: ${saveFailure.toString()}',
                  name: _tag);
              emit(HeartRateEmaDataSaveFailure(
                specificErrorMessage: "Failed to save data: ${saveFailure.message}",
                emaValuesForRetry: dataReadyState.emaValues,
                bpm: dataReadyState.bpm,
                isFakeMode: dataReadyState.isFakeMode,
                isFingerDetected: dataReadyState.isFingerDetected,
              ));
            },
            (_) {
              developer.log('Sensor data saved successfully for user ${currentUser.id}',
                  name: _tag);
              emit(HeartRateEmaDataSaveSuccess(
                bpm: dataReadyState.bpm,
                isFakeMode: dataReadyState.isFakeMode,
                isFingerDetected: dataReadyState.isFingerDetected,
              ));


              emit(HeartRateInitial(
                isFakeMode: _useFakePpgSource,
              ));
            },
          );
        },
      );
    } catch (e, stackTrace) {
      developer.log('Error saving EMA data: $e',
          name: _tag, error: e, stackTrace: stackTrace);
      emit(HeartRateEmaDataSaveFailure(
        specificErrorMessage: "An unexpected error occurred: ${e.toString()}",
        emaValuesForRetry: dataReadyState.emaValues, 
        bpm: dataReadyState.bpm,
        isFakeMode: dataReadyState.isFakeMode,
        isFingerDetected: dataReadyState.isFingerDetected,
      ));
    }
  }

  void discardEmaData() {
    emit(HeartRateInitial(isFakeMode: _useFakePpgSource));
  }

  @override
  Future<void> close() {
    developer.log('Closing HeartRateCubit...', name: _tag);
    _measurementTimer?.cancel();

    _fakeDataTimer?.cancel();

    _cameraService.stopImageStream().catchError((e) {
      developer.log('Error stopping image stream during cubit close: $e', name: _tag);
    });
    _cameraService.setFlashMode(FlashMode.off).catchError((e) {
      developer.log('Error setting flash off during cubit close: $e', name: _tag);
    });
    _cameraService.disposeController(); 
    _ppgProcessorService.dispose(); 
    developer.log('HeartRateCubit closed and resources disposed.', name: _tag);
    return super.close();
  }

  PpgProcessingOutput _generateFakePpgOutput(
      {int durationSeconds = 10, double fps = 15.0}) {
    List<EmaSensorValue> fakeEmas = [];
    DateTime startTime = DateTime.now().subtract(Duration(seconds: durationSeconds));
    double amplitude = 5.0;
    double frequency = 1.2; 
    int samples = (fps * durationSeconds).toInt();
    double phase = Random().nextDouble() * pi * 2;

    for (int i = 0; i < samples; i++) {
      double timeOffsetSeconds = i / fps;
      DateTime timestamp = 
          startTime.add(Duration(milliseconds: (timeOffsetSeconds * 1000).round()));
      double value = 60 + amplitude * sin(2 * pi * frequency * timeOffsetSeconds + phase);

      fakeEmas.add(EmaSensorValue(
          timestamp, value)); 
    }

    int fakeBpm = (frequency * 60).round();

    return PpgProcessingOutput(
      emaValues: fakeEmas,
      bpm: fakeBpm,
      peakIndices: [],
      rrIntervalsMs: [],


    );
  }




}
