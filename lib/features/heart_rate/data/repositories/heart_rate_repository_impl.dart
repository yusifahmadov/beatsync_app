import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/repositories/heart_rate_repository.dart';
import '../datasources/heart_rate_remote_data_source.dart';
import '../models/ppg_data_model.dart'; 
import '../models/sensor_data_model.dart';

class HeartRateRepositoryImpl implements HeartRateRepository {
  final HeartRateRemoteDataSource remoteDataSource;

  HeartRateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> saveSensorData(SensorData data) async {

    final sensorDataModel = SensorDataModel(
      bpm: data.bpm,
      data: data.data
          .map((d) => PPGDataModel(timestamp: d.timestamp, value: d.value))
          .toList(),
      timestamp: data.timestamp,
      userId: data.userId,
      deviceId: data.deviceId,
    );

    try {
      await remoteDataSource.saveSensorData(sensorDataModel);
      return const Right(null);
    } on ServerException catch (e) {
      print('ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      print('Unexpected error: ${e.toString()}');
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
