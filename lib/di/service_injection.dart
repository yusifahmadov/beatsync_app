import 'package:beatsync_app/core/services/camera_service.dart';
import 'package:beatsync_app/core/services/ppg_processor_service.dart';
import 'package:get_it/get_it.dart';

void registerServices(GetIt sl) {

  sl.registerLazySingleton<CameraService>(() => CameraServiceImpl());


  sl.registerFactory<PpgProcessorService>(() => PpgProcessorServiceImpl());
}
