// Generated-style Firebase options for the Weather Lab Sort Firebase project.
// Regenerate with `flutterfire configure` when the project becomes visible to
// FlutterFire project discovery.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => throw UnsupportedError(
        'Firebase is not configured for $defaultTargetPlatform.',
      ),
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFZNLenmQ7vSyfar9-c-rGYhmuqslSWvA',
    appId: '1:96319682520:android:a7f5d624c232d937e7a4ad',
    messagingSenderId: '96319682520',
    projectId: 'weather-lab-sort-dfbb7',
    storageBucket: 'weather-lab-sort-dfbb7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCEQ40Whh8kLzXrO6ZVYgGCd3o5S-kWrg8',
    appId: '1:96319682520:ios:bfd0ab0bdc8e6723e7a4ad',
    messagingSenderId: '96319682520',
    projectId: 'weather-lab-sort-dfbb7',
    storageBucket: 'weather-lab-sort-dfbb7.firebasestorage.app',
    iosBundleId: 'com.childhood.weatherlabsort',
  );
}
