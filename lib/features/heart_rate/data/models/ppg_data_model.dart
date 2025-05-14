import '../../domain/entities/ppg_data.dart';

class PPGDataModel extends PPGData {
  const PPGDataModel({
    required super.timestamp,
    required super.value,
  });

  factory PPGDataModel.fromJson(Map<String, dynamic> json) {
    return PPGDataModel(

      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toUtc().toIso8601String(),
      'value': value,
    };
  }
}
