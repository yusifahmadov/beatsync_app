import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/features/statistics/domain/entities/hrv_analysis_result.dart';
import 'package:dartz/dartz.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, List<HrvAnalysisResult>>> getUserAnalysis({
    required DateTime startDate,
    required DateTime endDate,
  });
}
