
import 'package:beatsync_app/core/errors/exceptions.dart';
import 'package:beatsync_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart'; 

import '../models/hrv_analysis_result_model.dart';

abstract class StatisticsRemoteDataSource {
  Future<List<HrvAnalysisResultModel>> getUserAnalysis({
    required DateTime startDate,
    required DateTime endDate,
  });
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final Dio dio;
  final AuthRepository authRepository;

  StatisticsRemoteDataSourceImpl({required this.dio, required this.authRepository});

  @override
  Future<List<HrvAnalysisResultModel>> getUserAnalysis({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final String startDateString =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";


    final DateTime apiExclusiveEndDate = endDate.add(const Duration(days: 1));

    final String endDateString =
        "${apiExclusiveEndDate.year}-${apiExclusiveEndDate.month.toString().padLeft(2, '0')}-${apiExclusiveEndDate.day.toString().padLeft(2, '0')}";

    try {
      final response = await dio.get(
        '/v1/user-analysis?start_date=$startDateString&end_date=$endDateString',
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          if (responseMap.containsKey('data')) {
            final nestedData = responseMap['data'];
            if (nestedData is Map<String, dynamic>) {
              final userAnalysisResponse =
                  UserHrvAnalysisResponseModel.fromJson(nestedData);
              print("Parsed Analysis: ${userAnalysisResponse.analysis.length} items");
              return userAnalysisResponse.analysis;
            } else {
              throw ServerException("Invalid format: 'data' field is not a Map.");
            }
          } else {
            throw ServerException("Invalid format: Response missing 'data' key.");
          }
        } else {
          throw ServerException("Invalid format: Response data is not a Map.");
        }
      } else {
        throw ServerException(
            "Failed to fetch analysis data. Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw ServerException("Network error: ${e.message ?? 'Unknown Dio error'}");
    } on ServerException {
      rethrow;
    } catch (e) {
      if (e is FormatException) {
        throw ServerException("Data parsing error: ${e.message}");
      }
      throw ServerException("An unexpected error occurred: ${e.toString()}");
    }
  }
}
