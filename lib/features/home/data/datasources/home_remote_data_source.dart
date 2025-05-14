import 'package:beatsync_app/features/statistics/data/datasources/statistics_remote_data_source.dart';
import 'package:beatsync_app/features/statistics/data/models/hrv_analysis_result_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<HrvAnalysisResultModel>> getTodayUserAnalysis();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final StatisticsRemoteDataSource statisticsRemoteDataSource;
  HomeRemoteDataSourceImpl({required this.statisticsRemoteDataSource});

  static List<HrvAnalysisResultModel> _parseUserAnalysisResponse(dynamic jsonData) {
    if (jsonData == null) {
      throw FormatException("Received null data from API.");
    }

    if (jsonData is Map<String, dynamic>) {
      final responseMap = jsonData;
      if (responseMap.containsKey('data')) {
        final nestedData = responseMap['data'];
        if (nestedData is Map<String, dynamic> && nestedData.containsKey('analysis')) {
          final analysisList = nestedData['analysis'] as List;
          return analysisList
              .map(
                  (item) => HrvAnalysisResultModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (nestedData is List) {
          return nestedData
              .map(
                  (item) => HrvAnalysisResultModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          if (nestedData is Map<String, dynamic>) {
            final userAnalysisResponse =
                UserHrvAnalysisResponseModel.fromJson(nestedData);
            return userAnalysisResponse.analysis;
          } else {
            throw FormatException(
                "Invalid format: 'data' field is not a Map or List, or 'analysis' key missing.");
          }
        }
      } else {
        try {
          final userAnalysisResponse = UserHrvAnalysisResponseModel.fromJson(jsonData);
          return userAnalysisResponse.analysis;
        } catch (e) {
          throw FormatException(
              "Invalid format: Response missing 'data' key, not a direct list, and not parsable as UserHrvAnalysisResponseModel. Error: $e");
        }
      }
    } else if (jsonData is List) {
      final analysisList = jsonData;
      return analysisList
          .map((item) => HrvAnalysisResultModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw FormatException("Invalid format: Response data is not a Map or List.");
    }
  }

  @override
  Future<List<HrvAnalysisResultModel>> getTodayUserAnalysis() async {
    return statisticsRemoteDataSource.getUserAnalysis(
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
    );
  }
}

class UserHrvAnalysisResponseModel {
  final List<HrvAnalysisResultModel> analysis;
  final int? count;

  UserHrvAnalysisResponseModel({required this.analysis, this.count});

  factory UserHrvAnalysisResponseModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('analysis') && json['analysis'] is List) {
      var list = json['analysis'] as List;
      List<HrvAnalysisResultModel> analysisList = list
          .map((i) => HrvAnalysisResultModel.fromJson(i as Map<String, dynamic>))
          .toList();
      return UserHrvAnalysisResponseModel(
        analysis: analysisList,
        count: json['count'] as int?,
      );
    } else {
      print(
          "Warning: 'analysis' key missing or not a list in UserHrvAnalysisResponseModel.fromJson. JSON: $json");
      return UserHrvAnalysisResponseModel(analysis: [], count: json['count'] as int?);
    }
  }
}
