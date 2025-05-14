import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../models/sensor_data_model.dart';
import 'heart_rate_remote_data_source.dart';

class HeartRateRemoteDataSourceImpl implements HeartRateRemoteDataSource {
  final Dio dio;
  final AuthRepository authRepository;

  HeartRateRemoteDataSourceImpl({
    required this.dio,
    required this.authRepository,
  });

  @override
  Future<void> saveSensorData(SensorDataModel data) async {



    log('Saving sensor data: ${data.toJson()}');
    try {
      await dio.post(
        '/v1/sensor-data',
        data: data.toJson(),
      );
    } on DioException catch (e) {

      throw ServerException('Network error while saving sensor data: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error while saving sensor data: ${e.toString()}');
    }
  }
}
