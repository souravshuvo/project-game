import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../application/tic_tac_toe_telemetry.dart';

final class FirebaseTicTacToeTelemetry implements TicTacToeTelemetry {
  FirebaseTicTacToeTelemetry._(this._analytics);

  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const _iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');

  final FirebaseAnalytics _analytics;

  static Future<TicTacToeTelemetry> createOrNoOp() async {
    final appId = _platformAppId;
    if (_apiKey.isEmpty ||
        _projectId.isEmpty ||
        _messagingSenderId.isEmpty ||
        appId.isEmpty) {
      return const NoOpTicTacToeTelemetry();
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: _apiKey,
            appId: appId,
            messagingSenderId: _messagingSenderId,
            projectId: _projectId,
          ),
        );
      }

      return FirebaseTicTacToeTelemetry._(FirebaseAnalytics.instance);
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('Firebase Analytics disabled: $error');
      }

      return const NoOpTicTacToeTelemetry();
    }
  }

  static String get _platformAppId {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidAppId,
      TargetPlatform.iOS => _iosAppId,
      _ => '',
    };
  }

  @override
  void track(TicTacToeTelemetryEvent event) {
    unawaited(
      _analytics
          .logEvent(
            name: event.name,
            parameters: _firebaseParameters(event.parameters),
          )
          .catchError((Object error, StackTrace stackTrace) {
            if (kDebugMode) {
              debugPrint('Firebase Analytics event failed: $error');
            }
          }),
    );
  }

  Map<String, Object> _firebaseParameters(Map<String, Object> parameters) {
    return parameters.map((key, value) {
      return MapEntry(key, switch (value) {
        bool boolValue => boolValue ? 1 : 0,
        int intValue => intValue,
        double doubleValue => doubleValue,
        _ => value.toString(),
      });
    });
  }
}
