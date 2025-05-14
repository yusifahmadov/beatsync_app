import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:camera/camera.dart';


class BPMResult {
  final int? bpm;
  final bool isFullBuffer; 
  final List<double> signalData; 
  final List<int> peakIndices; 
  final List<double> rrIntervalsMs; 

  BPMResult({
    this.bpm,
    required this.isFullBuffer,
    required this.signalData,
    required this.peakIndices,
    required this.rrIntervalsMs,
  });
}


class PpgProcessingOutput {
  final List<EmaSensorValue> emaValues;
  final int? bpm;
  final List<int> peakIndices;
  final List<double> rrIntervalsMs;
  final EmaSensorValue? latestEmaValue; 
  final double? currentBufferProgress; 

  PpgProcessingOutput({
    required this.emaValues,
    this.bpm,
    required this.peakIndices,
    required this.rrIntervalsMs,
    this.latestEmaValue,
    this.currentBufferProgress,
  });
}


class EmaSensorValue {
  final DateTime time;
  final double value;
  EmaSensorValue(this.time, this.value);

  @override
  String toString() {
    return 'EmaSensorValue(time: $time, value: $value)';
  }
}

abstract class PpgProcessorService {

  Future<PpgProcessingOutput?> processImage(CameraImage image);
  void reset();
  void updateProcessingSettings({int? targetFps, int? windowSeconds});
  bool get isFingerDetected;
  Stream<bool> get fingerDetectionStream;
  int get currentSignalBufferLength;
  int get targetSignalBufferLength;
  void dispose();
}

class PpgProcessorServiceImpl implements PpgProcessorService {
  static const String _tag = 'PpgProcessorServiceImpl';

  static const double _EMA_ALPHA = 0.6;




  int _TARGET_FPS = 15;



  int _PROCESSING_WINDOW_SECONDS = 45;




  late int _bufferSize;

  final ListQueue<double> _signalBuffer = ListQueue<double>();
  DateTime?
      _firstSampleTime; 


  static const int _FINGER_DETECTION_STABILITY_WINDOW = 7; 
  static const double _FINGER_DETECTION_THRESHOLD_GREEN_MIN =
      60.0; 
  static const double _FINGER_DETECTION_GREEN_STD_DEV_MAX =
      15.0; 

  final ListQueue<double> _fingerStabilityBuffer =
      ListQueue<double>(_FINGER_DETECTION_STABILITY_WINDOW);
  bool _isFingerDetected = false;
  final StreamController<bool> _fingerDetectionStreamController =
      StreamController<bool>.broadcast();


  static const int _MOVING_AVERAGE_WINDOW_SIZE = 5; 


  static const double _PEAK_DETECTION_THRESHOLD_K = 0.1; 
  static const int _MIN_PEAK_DISTANCE_SAMPLES =
      10; 









  static const double _MIN_RR_INTERVAL_MS = 250.0; 
  static const double _MAX_RR_INTERVAL_MS = 2000.0; 

  EmaSensorValue? _previousEmaValue; 

  PpgProcessorServiceImpl() {
    _bufferSize = _TARGET_FPS * _PROCESSING_WINDOW_SECONDS;
    developer.log(
        'PpgProcessorService initialized with buffer size: $_bufferSize (FPS: $_TARGET_FPS, Window: $_PROCESSING_WINDOW_SECONDS s)',
        name: _tag);
  }

  @override
  void updateProcessingSettings({int? targetFps, int? windowSeconds}) {
    bool changed = false;
    if (targetFps != null && targetFps != _TARGET_FPS) {
      _TARGET_FPS = targetFps;
      changed = true;
    }
    if (windowSeconds != null && windowSeconds != _PROCESSING_WINDOW_SECONDS) {
      _PROCESSING_WINDOW_SECONDS = windowSeconds;
      changed = true;
    }
    if (changed) {
      _bufferSize = _TARGET_FPS * _PROCESSING_WINDOW_SECONDS;
      developer.log(
          'PpgProcessorService settings updated. New buffer size: $_bufferSize (FPS: $_TARGET_FPS, Window: $_PROCESSING_WINDOW_SECONDS s)',
          name: _tag);
      reset(); 
    }
  }


  List<double> _applyEmaFilter(List<double> signal, double alpha) {
    if (signal.isEmpty) {
      return [];
    }
    List<double> emaSignal = List.filled(signal.length, 0.0);
    emaSignal[0] = signal[0]; 
    for (int i = 1; i < signal.length; i++) {
      emaSignal[i] = alpha * signal[i] + (1 - alpha) * emaSignal[i - 1];
    }
    return emaSignal;
  }


  List<DateTime> _generateTimestamps(int signalLength, DateTime startTime, double fps) {
    List<DateTime> timestamps = [];
    if (fps <= 0) return timestamps; 

    for (int i = 0; i < signalLength; i++) {
      int millisecondsOffset = (i / fps * 1000).round();
      timestamps.add(startTime.add(Duration(milliseconds: millisecondsOffset)));
    }
    return timestamps;
  }

  @override
  Future<PpgProcessingOutput?> processImage(CameraImage image) async {
    final double? currentSignalValue = _extractSignalValue(image);

    if (currentSignalValue == null) {
      _updateFingerDetection(null);
      _previousEmaValue = null; 
      return null;
    }

    _updateFingerDetection(currentSignalValue);

    if (!_isFingerDetected) {
      developer.log(
          'PPG Service: Finger not detected or signal unstable. Clearing buffer.',
          name: _tag);
      _signalBuffer.clear();
      _firstSampleTime = null;
      _previousEmaValue = null; 

      return PpgProcessingOutput(
          emaValues: [],
          peakIndices: [],
          rrIntervalsMs: [],
          currentBufferProgress: 0.0,
          latestEmaValue: null);
    }

    _firstSampleTime ??= DateTime.now();
    _signalBuffer.add(currentSignalValue);


    EmaSensorValue currentEmaPoint;
    if (_previousEmaValue == null || _signalBuffer.isEmpty) {

      currentEmaPoint = EmaSensorValue(DateTime.now(), currentSignalValue);
    } else {
      double newEma =
          _EMA_ALPHA * currentSignalValue + (1 - _EMA_ALPHA) * _previousEmaValue!.value;
      currentEmaPoint = EmaSensorValue(DateTime.now(), newEma);
    }
    _previousEmaValue = currentEmaPoint; 

    double progress = _signalBuffer.length / _bufferSize.toDouble();
    if (progress > 1.0) progress = 1.0;

    if (_signalBuffer.length < _bufferSize) {

      if (_signalBuffer.length > _bufferSize)
        _signalBuffer
            .removeFirst(); 
      return PpgProcessingOutput(
          emaValues: [], 
          latestEmaValue: currentEmaPoint,
          currentBufferProgress: progress,
          peakIndices: [],
          rrIntervalsMs: []);
    }

    developer.log(
        'PPG Service: Buffer full. Proceeding to full EMA, BPM calc. Length: ${_signalBuffer.length}',
        name: _tag);

    final DateTime processingStartTime = _firstSampleTime ?? DateTime.now();
    final List<double> signalCopyToProcess = List<double>.from(_signalBuffer);

    final List<double> emaFilteredSignalValues =
        _applyEmaFilter(signalCopyToProcess, _EMA_ALPHA);
    final List<DateTime> timestamps = _generateTimestamps(
        emaFilteredSignalValues.length, processingStartTime, _TARGET_FPS.toDouble());
    List<EmaSensorValue> fullEmaSensorValues = [];
    for (int i = 0; i < emaFilteredSignalValues.length; i++) {
      if (i < timestamps.length) {
        fullEmaSensorValues
            .add(EmaSensorValue(timestamps[i], emaFilteredSignalValues[i]));
      }
    }


    final List<int> peakIndices = _detectPeaks(emaFilteredSignalValues);
    int? calculatedBpm;
    List<double> finalRrIntervalsMs = [];
    if (peakIndices.length < 2) {

    } else {
      final List<double> rrIntervalsMs =
          _calculateRrIntervals(peakIndices, _TARGET_FPS.toDouble());
      final List<double> filteredRrIntervalsMs = _filterRrIntervals(rrIntervalsMs);
      finalRrIntervalsMs = filteredRrIntervalsMs;
      if (filteredRrIntervalsMs.isNotEmpty) {
        final double averageRrInterval =
            filteredRrIntervalsMs.reduce((a, b) => a + b) / filteredRrIntervalsMs.length;
        if (averageRrInterval > 0) {
          calculatedBpm = (60000 / averageRrInterval).round();
        }
      }
    }



    _signalBuffer.clear();
    _firstSampleTime = null;
    _previousEmaValue = null; 

    return PpgProcessingOutput(
      emaValues: fullEmaSensorValues,
      bpm: calculatedBpm,
      peakIndices: peakIndices,
      rrIntervalsMs: finalRrIntervalsMs,
      latestEmaValue: fullEmaSensorValues.isNotEmpty
          ? fullEmaSensorValues.last
          : null, 
      currentBufferProgress: 1.0,
    );
  }



  double? _extractSignalValue(CameraImage image) {
    try {
      switch (image.format.group) {
        case ImageFormatGroup.yuv420:



          if (image.planes.isNotEmpty) {
            final plane = image.planes[0];
            final bytes = plane.bytes;
            double sumY = 0;
            for (int i = 0; i < bytes.length; i++) {
              sumY += bytes[i];
            }
            return bytes.isNotEmpty ? sumY / bytes.length : 0.0;
          }
          developer.log('_extractSignalValue (YUV): Image planes empty.', name: _tag);
          return null;
        case ImageFormatGroup.bgra8888:


          if (image.planes.isNotEmpty) {
            final plane = image.planes[0];
            final bytes = plane.bytes;
            double sumGreen = 0;
            int pixelCount = 0;
            for (int i = 0; i < bytes.length; i += 4) {
              sumGreen += bytes[i + 1]; 
              pixelCount++;
            }
            return pixelCount > 0 ? sumGreen / pixelCount : 0.0;
          }
          developer.log('_extractSignalValue (BGRA): Image planes empty.', name: _tag);
          return null;
        default:
          developer.log(
              'Unsupported image format group: ${image.format.group} in _extractSignalValue',
              name: _tag);
          return null;
      }
    } catch (e, stackTrace) {
      developer.log('Error extracting signal value: $e',
          name: _tag, error: e, stackTrace: stackTrace);
      return null;
    }
    developer.log('_extractSignalValue: Fell through switch, returning null.',
        name: _tag);
    return null;
  }

  void _updateFingerDetection(double? currentSignalValue) {
    if (currentSignalValue == null) {





    } else {
      if (_fingerStabilityBuffer.length == _FINGER_DETECTION_STABILITY_WINDOW) {
        _fingerStabilityBuffer.removeFirst();
      }
      _fingerStabilityBuffer.add(currentSignalValue);
    }

    bool previousDetectionStatus = _isFingerDetected;

    if (_fingerStabilityBuffer.length < _FINGER_DETECTION_STABILITY_WINDOW) {
      _isFingerDetected = false; 
    } else {

      double mean =
          _fingerStabilityBuffer.reduce((a, b) => a + b) / _fingerStabilityBuffer.length;
      double variance =
          _fingerStabilityBuffer.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
              _fingerStabilityBuffer.length;
      double stdDev = sqrt(variance);



      if (mean >= _FINGER_DETECTION_THRESHOLD_GREEN_MIN &&
          stdDev <= _FINGER_DETECTION_GREEN_STD_DEV_MAX) {
        _isFingerDetected = true;
      } else {
        _isFingerDetected = false;
      }

      developer.log(
          'Finger detection stats: mean=$mean, stdDev=$stdDev. Thresholds: minGreen=$_FINGER_DETECTION_THRESHOLD_GREEN_MIN, maxStdDev=$_FINGER_DETECTION_GREEN_STD_DEV_MAX. Detected=$_isFingerDetected',
          name: _tag);
    }

    if (previousDetectionStatus != _isFingerDetected) {
      _fingerDetectionStreamController.add(_isFingerDetected);
      developer.log('Finger detection status changed: $_isFingerDetected', name: _tag);
    }





  }

  List<double> _applyMovingAverageFilter(List<double> signal) {
    if (signal.length < _MOVING_AVERAGE_WINDOW_SIZE) {
      return List<double>.from(signal); 
    }

    List<double> filteredSignal = [];
    ListQueue<double> window = ListQueue<double>();

    for (int i = 0; i < signal.length; i++) {
      window.add(signal[i]);
      if (window.length > _MOVING_AVERAGE_WINDOW_SIZE) {
        window.removeFirst();
      }
      if (window.length == _MOVING_AVERAGE_WINDOW_SIZE) {
        filteredSignal.add(window.reduce((a, b) => a + b) / _MOVING_AVERAGE_WINDOW_SIZE);
      } else {















        filteredSignal.add(window.reduce((a, b) => a + b) / window.length);
      }
    }



    return filteredSignal;
  }

  List<int> _detectPeaks(List<double> filteredSignal) {
    if (filteredSignal.isEmpty) return [];

    List<int> peakIndices = [];
    if (filteredSignal.length < 3)
      return peakIndices; 


    double mean = filteredSignal.reduce((a, b) => a + b) / filteredSignal.length;
    double variance =
        filteredSignal.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
            filteredSignal.length;
    double stdDev = sqrt(variance);


    double threshold = mean + _PEAK_DETECTION_THRESHOLD_K * stdDev;


    for (int i = 1; i < filteredSignal.length - 1; i++) {
      double prevValue = filteredSignal[i - 1];
      double currentValue = filteredSignal[i];
      double nextValue = filteredSignal[i + 1];

      bool isPeak = currentValue > prevValue && currentValue > nextValue;


      if (isPeak && currentValue > threshold) {

        if (peakIndices.isNotEmpty) {
          if ((i - peakIndices.last) < _MIN_PEAK_DISTANCE_SAMPLES) {


            if (currentValue > filteredSignal[peakIndices.last]) {

              peakIndices.removeLast();
              peakIndices.add(i);
            } else {

            }
            continue;
          }
        }
        peakIndices.add(i);

      }
    }

    return peakIndices;
  }

  List<double> _calculateRrIntervals(List<int> peakIndices, double fps) {
    List<double> rrIntervalsMs = [];
    if (peakIndices.length < 2) {
      return rrIntervalsMs;
    }

    for (int i = 0; i < peakIndices.length - 1; i++) {
      int diffSamples = peakIndices[i + 1] - peakIndices[i];
      double rrIntervalSeconds = diffSamples / fps;
      double rrIntervalMs = rrIntervalSeconds * 1000;

      rrIntervalsMs.add(rrIntervalMs);
    }

    return rrIntervalsMs;
  }

  List<double> _filterRrIntervals(List<double> rrIntervalsMs) {

    List<double> filteredIntervals = rrIntervalsMs.where((rr) {
      bool keep = rr >= _MIN_RR_INTERVAL_MS && rr <= _MAX_RR_INTERVAL_MS;
      if (!keep) {

      }
      return keep;
    }).toList();

    return filteredIntervals;
  }

  @override
  void reset() {
    _signalBuffer.clear();
    _fingerStabilityBuffer.clear();
    _isFingerDetected = false;
    _firstSampleTime = null;

    if (!_fingerDetectionStreamController.isClosed) {
      _fingerDetectionStreamController.add(_isFingerDetected);
    }
    developer.log('PpgProcessorService reset.', name: _tag);
  }

  @override
  bool get isFingerDetected => _isFingerDetected;

  @override
  Stream<bool> get fingerDetectionStream => _fingerDetectionStreamController.stream;

  @override
  int get currentSignalBufferLength => _signalBuffer.length;

  @override
  int get targetSignalBufferLength => _bufferSize;



  @override
  void dispose() {
    _fingerDetectionStreamController.close();
  }
}
