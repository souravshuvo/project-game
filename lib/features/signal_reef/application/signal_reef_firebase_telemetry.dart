import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import 'signal_reef_telemetry.dart';

final class SignalReefFirebaseConfig {
  const SignalReefFirebaseConfig._();

  static const enabled = bool.fromEnvironment(
    'SIGNAL_REEF_FIREBASE_ANALYTICS_ENABLED',
  );
  static const apiKey = String.fromEnvironment('SIGNAL_REEF_FIREBASE_API_KEY');
  static const appId = String.fromEnvironment('SIGNAL_REEF_FIREBASE_APP_ID');
  static const messagingSenderId = String.fromEnvironment(
    'SIGNAL_REEF_FIREBASE_MESSAGING_SENDER_ID',
  );
  static const projectId = String.fromEnvironment(
    'SIGNAL_REEF_FIREBASE_PROJECT_ID',
  );

  static bool get isConfigured {
    return enabled &&
        apiKey.isNotEmpty &&
        appId.isNotEmpty &&
        messagingSenderId.isNotEmpty &&
        projectId.isNotEmpty;
  }

  static FirebaseOptions get options {
    return const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
    );
  }
}

final class FirebaseSignalReefTelemetry implements SignalReefTelemetry {
  const FirebaseSignalReefTelemetry._(this._analytics);

  final FirebaseAnalytics _analytics;

  static Future<SignalReefTelemetry> create() async {
    if (!SignalReefFirebaseConfig.isConfigured) {
      return const NoOpSignalReefTelemetry();
    }

    try {
      await Firebase.initializeApp(options: SignalReefFirebaseConfig.options);
      return FirebaseSignalReefTelemetry._(FirebaseAnalytics.instance);
    } on Object {
      return const NoOpSignalReefTelemetry();
    }
  }

  @override
  void track(SignalReefTelemetryEvent event) {
    unawaited(_track(event));
  }

  Future<void> _track(SignalReefTelemetryEvent event) async {
    try {
      await _analytics.logEvent(
        name: event.name,
        parameters: _firebaseSafeParameters(event.parameters),
      );
    } on Object {
      return;
    }
  }

  Map<String, Object> _firebaseSafeParameters(Map<String, Object> parameters) {
    return parameters.map((key, value) {
      final safeValue = switch (value) {
        bool() => value ? 1 : 0,
        int() || double() || String() => value,
        _ => value.toString(),
      };

      return MapEntry(key, safeValue);
    });
  }
}
