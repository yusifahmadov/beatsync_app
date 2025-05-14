import 'package:equatable/equatable.dart';

class HrvAnalysisResult extends Equatable {
  final String analysisId;
  final DateTime analysisTime; 
  final double rmssd;
  final double sdnn;
  final double lfHfRatio;
  final int bpm;



  const HrvAnalysisResult({
    required this.analysisId,
    required this.analysisTime,
    required this.rmssd,
    required this.sdnn,
    required this.lfHfRatio,
    required this.bpm,
  });

  @override
  List<Object?> get props => [analysisId, analysisTime, rmssd, sdnn, lfHfRatio];
}
