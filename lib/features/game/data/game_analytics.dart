import 'package:firebase_analytics/firebase_analytics.dart';

abstract class GameAnalytics {
  Future<void> logEvent(String name, Map<String, Object?> parameters);

  Future<void> logScreenView(String screenName) {
    return logEvent('screen_view', {'screen_name': screenName});
  }
}

class NoopGameAnalytics implements GameAnalytics {
  const NoopGameAnalytics();

  @override
  Future<void> logEvent(String name, Map<String, Object?> parameters) async {}

  @override
  Future<void> logScreenView(String screenName) {
    return logEvent('screen_view', {'screen_name': screenName});
  }
}

class FirebaseGameAnalytics implements GameAnalytics {
  const FirebaseGameAnalytics(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, Map<String, Object?> parameters) async {
    try {
      final safeParameters = _safeParameters(parameters);
      await _analytics.logEvent(
        name: name,
        parameters: safeParameters.isEmpty ? null : safeParameters,
      );
    } on Object {
      // Analytics must never block gameplay.
    }
  }

  @override
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } on Object {
      // Analytics must never block navigation.
    }
  }

  Map<String, Object> _safeParameters(Map<String, Object?> parameters) {
    final safe = <String, Object>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }

      safe[_safeKey(entry.key)] = switch (value) {
        bool() => value ? 1 : 0,
        int() => value,
        double() => value,
        num() => value.toDouble(),
        String() => value.length > 100 ? value.substring(0, 100) : value,
        _ => value.toString(),
      };
    }
    return safe;
  }

  String _safeKey(String key) {
    final normalized = key
        .replaceAll(RegExp('[^a-zA-Z0-9_]'), '_')
        .replaceAll(RegExp('_+'), '_');
    if (normalized.isEmpty) {
      return 'value';
    }
    if (normalized.length <= 40) {
      return normalized;
    }
    return normalized.substring(0, 40);
  }
}
