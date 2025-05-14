import 'package:beatsync_app/core/errors/exceptions.dart';
import 'package:beatsync_app/core/errors/failures.dart';

import 'package:beatsync_app/features/statistics/data/datasources/statistics_remote_data_source.dart';
import 'package:beatsync_app/features/statistics/domain/entities/hrv_analysis_result.dart';
import 'package:beatsync_app/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:dartz/dartz.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;


  StatisticsRepositoryImpl({
    required this.remoteDataSource,

  });

  @override
  Future<Either<Failure, List<HrvAnalysisResult>>> getUserAnalysis({
    required DateTime startDate,
    required DateTime endDate,
  }) async {

    try {
      final remoteAnalysis = await remoteDataSource.getUserAnalysis(
        startDate: startDate,
        endDate: endDate,
      );


      return Right(remoteAnalysis);
    } on ServerException catch (e, s) {

      return Left(ServerFailure(e.message, statusCode: e.statusCode, stackTrace: s));
    } on CacheException catch (e, s) {

      return Left(CacheFailure(e.message, s));
    } on FormatException catch (e, s) {

      return Left(ParsingFailure("Error parsing analysis data: ${e.message}", s));
    } catch (e, s) {

      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}', s));
    }
  }
}
