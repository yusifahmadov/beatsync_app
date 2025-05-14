import 'package:beatsync_app/core/errors/exceptions.dart';
import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:beatsync_app/features/home/domain/repositories/home_repository.dart';
import 'package:beatsync_app/features/statistics/data/models/hrv_analysis_result_model.dart';
import 'package:beatsync_app/features/statistics/domain/entities/hrv_analysis_result.dart';
import 'package:dartz/dartz.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, HrvAnalysisResult?>> getLatestTodayAnalysis() async {
    try {
      final todayAnalysesModels = await remoteDataSource.getTodayUserAnalysis();

      if (todayAnalysesModels.isEmpty) {
        return const Right(null);
      }

      final sortedAnalyses = List<HrvAnalysisResultModel>.from(todayAnalysesModels);
      sortedAnalyses.sort((a, b) => b.analysisTime.compareTo(a.analysisTime));

      return Right(sortedAnalyses.first);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on CacheException catch (e, s) {
      return Left(CacheFailure(e.message, s));
    } on FormatException catch (e, s) {
      return Left(ParsingFailure("Error parsing latest analysis data: ${e.message}", s));
    } catch (e, s) {
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}', s));
    }
  }
}
