import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

class FirebaseRuntimeOptions {
  static const bool analyticsEnabled = bool.fromEnvironment(
    'ANALYTICS_ENABLED',
    defaultValue: true,
  );

  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const String iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');

  static FirebaseOptions? get currentPlatform {
    if (!analyticsEnabled) {
      return null;
    }

    final appId = Platform.isIOS ? iosAppId : androidAppId;
    if (apiKey.isEmpty ||
        appId.isEmpty ||
        projectId.isEmpty ||
        messagingSenderId.isEmpty) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      iosBundleId: Platform.isIOS ? 'com.childhood.rooftopcurve' : null,
    );
  }
}
