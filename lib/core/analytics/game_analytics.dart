import 'dart:async';

abstract interface class GameAnalytics {
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  });
}

class NoopGameAnalytics implements GameAnalytics {
  const NoopGameAnalytics();

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {}
}

extension GameAnalyticsEvents on GameAnalytics {
  void appSessionStart({
    required String analyticsMode,
    required String adMode,
    required String packageName,
  }) {
    _fireAndForget(
      'app_session_start',
      parameters: <String, Object?>{
        'analytics_mode': analyticsMode,
        'ad_mode': adMode,
        'package_name': packageName,
      },
    );
  }

  void appLifecycleChanged(String state) {
    _fireAndForget(
      'app_lifecycle',
      parameters: <String, Object?>{'state': state},
    );
  }

  void gameStarted({
    required String gameId,
    required String title,
    required int completedGames,
    required int totalGames,
  }) {
    _fireAndForget(
      'game_start',
      parameters: <String, Object?>{
        'game_id': gameId,
        'game_title': title,
        'completed_games': completedGames,
        'total_games': totalGames,
      },
    );
  }

  void gameCompleted({
    required String gameId,
    required String title,
    required int durationMs,
    required int completedGames,
    required int totalGames,
  }) {
    _fireAndForget(
      'game_complete',
      parameters: <String, Object?>{
        'game_id': gameId,
        'game_title': title,
        'duration_ms': durationMs,
        'completed_games': completedGames,
        'total_games': totalGames,
      },
    );
  }

  void gameExited({
    required String gameId,
    required String title,
    required bool completed,
    required int durationMs,
  }) {
    _fireAndForget(
      'game_exit',
      parameters: <String, Object?>{
        'game_id': gameId,
        'game_title': title,
        'completed': completed ? 1 : 0,
        'duration_ms': durationMs,
      },
    );
  }

  void contentStarted({
    required String gameId,
    required String contentId,
    required int contentIndex,
    required int contentTotal,
  }) {
    _fireAndForget(
      'content_start',
      parameters: <String, Object?>{
        'game_id': gameId,
        'content_id': contentId,
        'content_index': contentIndex,
        'content_total': contentTotal,
      },
    );
  }

  void contentCompleted({
    required String gameId,
    required String contentId,
    required int contentIndex,
    required int contentTotal,
  }) {
    _fireAndForget(
      'content_complete',
      parameters: <String, Object?>{
        'game_id': gameId,
        'content_id': contentId,
        'content_index': contentIndex,
        'content_total': contentTotal,
      },
    );
  }

  void feedbackPlayed({required String gameId, required String feedbackType}) {
    _fireAndForget(
      'game_feedback',
      parameters: <String, Object?>{
        'game_id': gameId,
        'feedback_type': feedbackType,
      },
    );
  }

  void adOpportunity({
    required String placement,
    required String format,
    required String adMode,
    required String decision,
    required String reason,
    String? gameId,
  }) {
    _fireAndForget(
      'ad_opportunity',
      parameters: <String, Object?>{
        'placement': placement,
        'format': format,
        'ad_mode': adMode,
        'decision': decision,
        'reason': reason,
        if (gameId != null) 'game_id': gameId,
      },
    );
  }

  void adEvent({
    required String event,
    required String placement,
    required String format,
    required String adMode,
    String? gameId,
    String? reason,
  }) {
    _fireAndForget(
      'ad_$event',
      parameters: <String, Object?>{
        'placement': placement,
        'format': format,
        'ad_mode': adMode,
        if (gameId != null) 'game_id': gameId,
        if (reason != null) 'reason': reason,
      },
    );
  }

  void _fireAndForget(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) {
    unawaited(logEvent(name, parameters: parameters).catchError((Object _) {}));
  }
}

String normalizeAnalyticsName(String value, {int maxLength = 40}) {
  final buffer = StringBuffer();
  for (final codeUnit in value.trim().codeUnits) {
    final isDigit = codeUnit >= 48 && codeUnit <= 57;
    final isUpper = codeUnit >= 65 && codeUnit <= 90;
    final isLower = codeUnit >= 97 && codeUnit <= 122;
    final isUnderscore = codeUnit == 95;
    buffer.writeCharCode(
      isDigit || isUpper || isLower || isUnderscore ? codeUnit : 95,
    );
  }

  var normalized = buffer.toString();
  if (normalized.isEmpty) {
    normalized = 'event';
  }
  final first = normalized.codeUnitAt(0);
  final startsWithLetter =
      (first >= 65 && first <= 90) || (first >= 97 && first <= 122);
  if (!startsWithLetter) {
    normalized = 'app_$normalized';
  }
  return normalized.length <= maxLength
      ? normalized
      : normalized.substring(0, maxLength);
}

Map<String, Object> normalizeAnalyticsParameters(
  Map<String, Object?> parameters,
) {
  final normalized = <String, Object>{};
  for (final entry in parameters.entries) {
    final key = normalizeAnalyticsName(entry.key);
    final value = entry.value;
    if (value == null) {
      continue;
    }
    if (value is String) {
      normalized[key] = value.length <= 100 ? value : value.substring(0, 100);
    } else if (value is num) {
      normalized[key] = value;
    } else if (value is bool) {
      normalized[key] = value ? 1 : 0;
    } else {
      final asString = value.toString();
      normalized[key] = asString.length <= 100
          ? asString
          : asString.substring(0, 100);
    }
  }
  return normalized;
}
