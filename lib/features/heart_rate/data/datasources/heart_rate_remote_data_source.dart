import '../models/sensor_data_model.dart';

abstract class HeartRateRemoteDataSource {
  Future<void> saveSensorData(SensorDataModel data);
}
