import '../../domain/entities/sensor_data.dart';
import 'ppg_data_model.dart';

class SensorDataModel extends SensorData {
  const SensorDataModel({
    required List<PPGDataModel> super.data,
    required super.timestamp,
    required super.userId,
    super.deviceId,
    required super.bpm,

  });





  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'bpm': bpm,
      'data': data
          .map((d) => PPGDataModel(timestamp: d.timestamp, value: d.value).toJson())
          .toList(), 
      'timestamp': timestamp.toUtc().toIso8601String(), 
      'user_id': userId,

    };
    if (deviceId != null) {
      jsonMap['device_id'] = deviceId;
    }
    return jsonMap;
  }
}
