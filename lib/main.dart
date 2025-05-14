import 'dart:io' show Platform;

import 'package:beatsync_app/app.dart';
import 'package:beatsync_app/di/main_injection.dart' as di;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/.env');

  bool isEmulator = false;
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      isEmulator = !androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      isEmulator = !iosInfo.isPhysicalDevice;
      print("isEmulator: $isEmulator");
    }
  } catch (e) {
    debugPrint('Error detecting emulator status: $e');
    isEmulator = false;
  }

  di.sl.registerSingleton<bool>(isEmulator, instanceName: 'isEmulator');

  await di.initCoreDependencies();
  runApp(const App());
}
