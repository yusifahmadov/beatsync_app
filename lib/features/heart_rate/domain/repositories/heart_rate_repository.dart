import 'package:beatsync_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/sensor_data.dart';

abstract class HeartRateRepository {
  Future<Either<Failure, void>> saveSensorData(SensorData data);
}
