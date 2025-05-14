import 'package:equatable/equatable.dart';

class PPGData extends Equatable {
  final DateTime timestamp;
  final double value; 

  const PPGData({
    required this.timestamp,
    required this.value,
  });

  @override
  List<Object?> get props => [timestamp, value];
}
