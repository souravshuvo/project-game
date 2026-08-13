import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../domain/models.dart';
import '../../presentation/progress/match_history.dart';

class GameAnalytics {
  GameAnalytics._({required FirebaseAnalytics? firebaseAnalytics})
    : _firebaseAnalytics = firebaseAnalytics;

  final FirebaseAnalytics? _firebaseAnalytics;

  bool get isEnabled => _firebaseAnalytics != null;

  factory GameAnalytics.disabled() {
    return GameAnalytics._(firebaseAnalytics: null);
  }

  static Future<GameAnalytics> initialize() async {
    try {
      await Firebase.initializeApp();
      final analytics = FirebaseAnalytics.instance;
      await analytics.setAnalyticsCollectionEnabled(true);
      return GameAnalytics._(firebaseAnalytics: analytics);
    } catch (error, stackTrace) {
      debugPrint('Analytics disabled: $error');
      debugPrintStack(stackTrace: stackTrace, label: 'Firebase init failed');
      return GameAnalytics._(firebaseAnalytics: null);
    }
  }

  Future<void> logAppOpen() {
    return _log('game_app_open');
  }

  Future<void> logAppResume() {
    return _log('game_app_resume');
  }

  Future<void> logSessionStart() {
    return _log('game_session_start');
  }

  Future<void> logSessionEnd() {
    return _log('game_session_end');
  }

  Future<void> logScreenView(String screenName) async {
    final analytics = _firebaseAnalytics;
    if (analytics == null) {
      return;
    }
    try {
      await analytics.logScreenView(screenName: screenName);
    } catch (error) {
      debugPrint('Analytics screen_view failed: $error');
    }
  }

  Future<void> logMenuAction(String action) {
    return _log('menu_action', {'action': action});
  }

  Future<void> logSettingsChanged(String setting, bool enabled) {
    return _log('settings_changed', {'setting': setting, 'enabled': enabled});
  }

  Future<void> logMatchStart(MatchSetup setup) {
    return _log('match_start', _setupParameters(setup));
  }

  Future<void> logMove({
    required MatchSetup setup,
    required GameMove move,
    required int moveCount,
    required int captureCount,
    required String actor,
  }) {
    return _log('move_committed', {
      ..._setupParameters(setup),
      'actor': actor,
      'move_kind': move.isCapture ? 'capture' : 'normal',
      'move_count': moveCount,
      'capture_count': captureCount,
      'from_node': move.from,
      'to_node': move.to,
      if (move.capturedNode != null) 'captured_node': move.capturedNode!,
    });
  }

  Future<void> logCaptureChain({
    required MatchSetup setup,
    required String action,
    required String actor,
  }) {
    return _log('capture_chain', {
      ..._setupParameters(setup),
      'action': action,
      'actor': actor,
    });
  }

  Future<void> logInvalidAction({
    required MatchSetup setup,
    required String reason,
  }) {
    return _log('invalid_action', {
      ..._setupParameters(setup),
      'reason': reason,
    });
  }

  Future<void> logMatchFinish(MatchHistoryEntry entry) {
    return _log('match_finish', {
      'mode': entry.mode.name,
      if (entry.botDifficulty != null)
        'bot_difficulty': entry.botDifficulty!.name,
      'winner': entry.winner?.name ?? 'draw',
      'reason': entry.reason.name,
      'move_count': entry.moveCount,
      'capture_count': entry.captureCount,
      'player1_beads': entry.player1Beads,
      'player2_beads': entry.player2Beads,
    });
  }

  Future<void> logAdEvent({
    required String action,
    required String placement,
    required String adFormat,
    String? reason,
    String? error,
  }) {
    return _log('ad_event', {
      'action': action,
      'placement': placement,
      'ad_format': adFormat,
      if (reason != null) 'reason': reason,
      if (error != null) 'error': error,
    });
  }

  Map<String, Object> _setupParameters(MatchSetup setup) {
    return {
      'mode': setup.mode.name,
      if (setup.botDifficulty != null)
        'bot_difficulty': setup.botDifficulty!.name,
    };
  }

  Future<void> _log(String name, [Map<String, Object?> parameters = const {}]) {
    final analytics = _firebaseAnalytics;
    if (analytics == null) {
      return Future<void>.value();
    }

    return analytics
        .logEvent(name: name, parameters: _sanitize(parameters))
        .catchError((Object error) {
          debugPrint('Analytics event "$name" failed: $error');
        });
  }

  Map<String, Object> _sanitize(Map<String, Object?> parameters) {
    return {
      for (final entry in parameters.entries)
        if (entry.value != null) entry.key: _analyticsValue(entry.value!),
    };
  }

  Object _analyticsValue(Object value) {
    if (value is String || value is num) {
      return value;
    }
    if (value is bool) {
      return value ? 1 : 0;
    }
    return value.toString();
  }
}

class GameAnalyticsScope extends InheritedWidget {
  const GameAnalyticsScope({
    super.key,
    required this.analytics,
    required super.child,
  });

  final GameAnalytics analytics;

  static GameAnalytics read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<GameAnalyticsScope>()
        ?.widget;
    final analyticsScope = scope as GameAnalyticsScope?;
    assert(analyticsScope != null, 'GameAnalyticsScope is missing.');
    return analyticsScope!.analytics;
  }

  @override
  bool updateShouldNotify(GameAnalyticsScope oldWidget) {
    return analytics != oldWidget.analytics;
  }
}

class GameAnalyticsNavigatorObserver extends NavigatorObserver {
  GameAnalyticsNavigatorObserver(this.analytics);

  final GameAnalytics analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _log(previousRoute);
    }
    super.didPop(route, previousRoute);
  }

  void _log(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) {
      return;
    }
    unawaited(analytics.logScreenView(name));
  }
}
