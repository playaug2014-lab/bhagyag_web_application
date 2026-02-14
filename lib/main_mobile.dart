import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

Future<void> initializeAppCheck() async {
  AppleProvider appleProvider;

  if (kDebugMode) {
    appleProvider = AppleProvider.debug;
    print('🔧 DEBUG MODE - Using Debug App Check provider');
  } else {
    appleProvider = AppleProvider.deviceCheck;
    print('🚀 RELEASE MODE - Using DeviceCheck App Check provider');
  }

  await FirebaseAppCheck.instance.activate(
    appleProvider: appleProvider,
    androidProvider: AndroidProvider.debug,
  );

  print('✅ Firebase App Check activated');
}