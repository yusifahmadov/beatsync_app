import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/core/usecases/usecase.dart';
import 'package:beatsync_app/features/home/domain/repositories/home_repository.dart';
import 'package:beatsync_app/features/statistics/domain/entities/hrv_analysis_result.dart';
import 'package:dartz/dartz.dart';

class GetLatestTodayAnalysisUseCase implements UseCase<HrvAnalysisResult?, NoParams> {
  final HomeRepository repository;

  GetLatestTodayAnalysisUseCase(this.repository);

  @override
  Future<Either<Failure, HrvAnalysisResult?>> call(NoParams params) async {
    return await repository.getLatestTodayAnalysis();
  }
}
