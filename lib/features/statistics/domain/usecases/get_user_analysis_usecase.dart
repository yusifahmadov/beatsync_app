import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/core/usecases/usecase.dart'; 
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart'; 

import '../entities/hrv_analysis_result.dart';
import '../repositories/statistics_repository.dart';


class GetUserAnalysisParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetUserAnalysisParams({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}


class GetUserAnalysisUseCase
    implements UseCase<List<HrvAnalysisResult>, GetUserAnalysisParams> {
  final StatisticsRepository repository;

  GetUserAnalysisUseCase(this.repository);

  @override
  Future<Either<Failure, List<HrvAnalysisResult>>> call(
      GetUserAnalysisParams params) async {

    return await repository.getUserAnalysis(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
