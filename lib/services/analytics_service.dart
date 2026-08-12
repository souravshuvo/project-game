import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class AppAnalytics {
  AppAnalytics() : _disabled = false;

  AppAnalytics.disabled() : _disabled = true;

  static const _demoProjectId = String.fromEnvironment(
    'FIREBASE_DEMO_PROJECT_ID',
  );

  final bool _disabled;
  FirebaseAnalytics? _analytics;
  var _available = false;

  Future<void> initialize() async {
    if (_disabled) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        if (_demoProjectId.isNotEmpty) {
          await Firebase.initializeApp(demoProjectId: _demoProjectId);
        } else {
          await Firebase.initializeApp();
        }
      }
      _analytics = FirebaseAnalytics.instance;
      _available = true;
      unawaited(logAppSessionStarted());
    } catch (_) {
      _available = false;
    }
  }

  Future<void> logAppSessionStarted() {
    return logEvent('app_session_start');
  }

  Future<void> logMainMenuViewed({required int historyCount}) {
    return logEvent('main_menu_view', {'history_count': historyCount});
  }

  Future<void> logSettingsChanged({
    required bool soundEnabled,
    required bool hapticsEnabled,
  }) {
    return logEvent('settings_change', {
      'sound_enabled': soundEnabled,
      'haptics_enabled': hapticsEnabled,
    });
  }

  Future<void> logMatchStarted({
    required String mode,
    required String grid,
    required int rows,
    required int columns,
    String? botDifficulty,
  }) {
    return logEvent('match_start', {
      'mode': mode,
      'grid': grid,
      'rows': rows,
      'columns': columns,
      'bot_difficulty': botDifficulty,
    });
  }

  Future<void> logLineDrawn({
    required String mode,
    required String grid,
    required String actor,
    required String axis,
    required int moveCount,
    required int boxesCompleted,
    required bool extraTurn,
  }) {
    return logEvent('line_drawn', {
      'mode': mode,
      'grid': grid,
      'actor': actor,
      'axis': axis,
      'move_count': moveCount,
      'boxes_completed': boxesCompleted,
      'extra_turn': extraTurn,
    });
  }

  Future<void> logInvalidMove({
    required String mode,
    required String grid,
    required String reason,
  }) {
    return logEvent('invalid_move', {
      'mode': mode,
      'grid': grid,
      'reason': reason,
    });
  }

  Future<void> logBoxCapture({
    required String mode,
    required String grid,
    required String actor,
    required int boxesCompleted,
  }) {
    return logEvent('box_capture', {
      'mode': mode,
      'grid': grid,
      'actor': actor,
      'boxes_completed': boxesCompleted,
    });
  }

  Future<void> logExtraTurn({
    required String mode,
    required String grid,
    required String actor,
  }) {
    return logEvent('extra_turn_awarded', {
      'mode': mode,
      'grid': grid,
      'actor': actor,
    });
  }

  Future<void> logMatchFinished({
    required String mode,
    required String grid,
    required int rows,
    required int columns,
    required String result,
    required int playerOneScore,
    required int playerTwoScore,
    required int moveCount,
    required int boxesCompleted,
    required int extraTurnCount,
    required int invalidMoveCount,
    required int durationSeconds,
    String? botDifficulty,
  }) {
    return logEvent('match_finish', {
      'mode': mode,
      'grid': grid,
      'rows': rows,
      'columns': columns,
      'result': result,
      'player_one_score': playerOneScore,
      'player_two_score': playerTwoScore,
      'move_count': moveCount,
      'boxes_completed': boxesCompleted,
      'extra_turn_count': extraTurnCount,
      'invalid_move_count': invalidMoveCount,
      'duration_seconds': durationSeconds,
      'bot_difficulty': botDifficulty,
    });
  }

  Future<void> logAdEvent(
    String name, {
    required String placement,
    required String reason,
    String? environment,
  }) {
    return logEvent(name, {
      'placement': placement,
      'reason': reason,
      'environment': environment,
    });
  }

  Future<void> logInterstitialShown({
    required String placement,
    required String environment,
  }) {
    return logEvent('ad_interstitial_show', {
      'placement': placement,
      'environment': environment,
    });
  }

  Future<void> logInterstitialDismissed({
    required String placement,
    required String environment,
  }) {
    return logEvent('ad_interstitial_close', {
      'placement': placement,
      'environment': environment,
    });
  }

  Future<void> logAdImpression({
    required String placement,
    required String adUnitId,
    required String environment,
  }) async {
    if (!_available || _analytics == null) {
      return;
    }

    try {
      await _analytics!.logAdImpression(
        adPlatform: 'admob',
        adSource: 'admob',
        adFormat: 'interstitial',
        adUnitName: adUnitId,
        parameters: _filterParameters({
          'placement': placement,
          'environment': environment,
        }),
      );
    } catch (_) {}
  }

  Future<void> logEvent(
    String name, [
    Map<String, Object?> parameters = const <String, Object?>{},
  ]) async {
    if (!_available || _analytics == null) {
      return;
    }

    try {
      await _analytics!.logEvent(
        name: name,
        parameters: _filterParameters(parameters),
      );
    } catch (_) {}
  }

  Map<String, Object> _filterParameters(Map<String, Object?> parameters) {
    final filtered = <String, Object>{};
    for (final entry in parameters.entries) {
      final value = _normalizeValue(entry.value);
      if (value != null) {
        filtered[entry.key] = value;
      }
    }
    return filtered;
  }

  Object? _normalizeValue(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is int || value is double || value is String) {
      return value;
    }
    if (value is Enum) {
      return value.name;
    }
    return value.toString();
  }
}
