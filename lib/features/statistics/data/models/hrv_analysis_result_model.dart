import 'dart:developer'; 

import 'package:beatsync_app/features/statistics/domain/entities/hrv_analysis_result.dart';


class HrvAnalysisResultModel extends HrvAnalysisResult {
  const HrvAnalysisResultModel({
    required super.analysisId,
    required super.analysisTime,
    required super.rmssd,
    required super.sdnn,
    required super.lfHfRatio,
    required super.bpm,
  });

  factory HrvAnalysisResultModel.fromJson(Map<String, dynamic> json) {
    try {
      return HrvAnalysisResultModel(
        bpm: json['bpm'] as int,
        analysisId: json['analysis_id'] as String,
        analysisTime: DateTime.parse(json['analysis_time'] as String),
        rmssd: (json['rmssd'] as num).toDouble(),
        sdnn: (json['sdnn'] as num).toDouble(),
        lfHfRatio: (json['lf_hf_ratio'] as num).toDouble(),

      );
    } catch (e, stacktrace) {
      log('Error parsing HrvAnalysisResultModel: $e', stackTrace: stacktrace);

      throw FormatException('Failed to parse HrvAnalysisResultModel: $e');
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'analysis_id': analysisId,
      'analysis_time': analysisTime.toIso8601String(),
      'rmssd': rmssd,
      'sdnn': sdnn,
      'lf_hf_ratio': lfHfRatio,
    };
  }
}


class UserHrvAnalysisResponseModel {
  final List<HrvAnalysisResultModel> analysis;
  final int count;

  UserHrvAnalysisResponseModel({required this.analysis, required this.count});

  factory UserHrvAnalysisResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      var analysisList = <HrvAnalysisResultModel>[];
      if (json['analysis'] != null && json['analysis'] is List) {
        analysisList = (json['analysis'] as List)
            .map((item) => HrvAnalysisResultModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return UserHrvAnalysisResponseModel(
        analysis: analysisList,
        count: json['count'] as int? ?? 0, 
      );
    } catch (e, stacktrace) {
      log('Error parsing UserHrvAnalysisResponseModel: $e', stackTrace: stacktrace);
      throw FormatException('Failed to parse UserHrvAnalysisResponseModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis': analysis.map((item) => item.toJson()).toList(),
      'count': count,
    };
  }
}
