import 'package:equatable/equatable.dart';

import 'ppg_data.dart';

class SensorData extends Equatable {
  final List<PPGData> data;
  final DateTime timestamp;
  final String userId;
  final int bpm;
  final String? deviceId; 

  const SensorData({
    required this.data,
    required this.timestamp,
    required this.userId,
    this.deviceId,
    required this.bpm,
  });

  @override
  List<Object?> get props => [data, timestamp, userId, deviceId];
}
