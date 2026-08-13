import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class AnalyticsService {
  const AnalyticsService();

  static FirebaseAnalytics? _analytics;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp().timeout(const Duration(seconds: 4));
      _analytics = FirebaseAnalytics.instance;
      await _analytics?.logAppOpen();
    } catch (_) {
      _analytics = null;
    }
  }

  void appOpened({required int bestScore, required int completedRoutes}) {
    _log('app_ready', <String, Object>{
      'best_score': bestScore,
      'completed_routes': completedRoutes,
    });
  }

  void runStarted({
    required int bestScoreBefore,
    required int routeNumber,
    required int completedRoutes,
  }) {
    _log('run_started', <String, Object>{
      'best_score_before': bestScoreBefore,
      'route_number': routeNumber,
      'completed_routes': completedRoutes,
    });
  }

  void runEnded({
    required int score,
    required int bestScore,
    required String deathReason,
    required int durationSeconds,
    required int landings,
    required int pickups,
    required int routeNumber,
    required bool routeCompleted,
    required int revivesUsed,
  }) {
    _log('run_ended', <String, Object>{
      'score': score,
      'best_score': bestScore,
      'death_reason': deathReason,
      'duration_seconds': durationSeconds,
      'landings': landings,
      'pickups': pickups,
      'route_number': routeNumber,
      'route_completed': routeCompleted ? 1 : 0,
      'revives_used': revivesUsed,
    });
  }

  void routeCompleted({
    required int routeNumber,
    required int completedRoutes,
    required int score,
  }) {
    _log('route_completed', <String, Object>{
      'route_number': routeNumber,
      'completed_routes': completedRoutes,
      'score': score,
    });
  }

  void restartTapped({required int previousScore}) {
    _log('restart_tapped', <String, Object>{'previous_score': previousScore});
  }

  void pauseOpened({required int score}) {
    _log('pause_opened', <String, Object>{'score': score});
  }

  void resumeTapped({required int score}) {
    _log('resume_tapped', <String, Object>{'score': score});
  }

  void homeTapped({required int score, required String phase}) {
    _log('home_tapped', <String, Object>{'score': score, 'phase': phase});
  }

  void helpOpened({required String phase}) {
    _log('help_opened', <String, Object>{'phase': phase});
  }

  void settingsOpened({required String phase}) {
    _log('settings_opened', <String, Object>{'phase': phase});
  }

  void feedbackSettingChanged({
    required String setting,
    required bool enabled,
  }) {
    _log('feedback_setting_changed', <String, Object>{
      'setting': setting,
      'enabled': enabled ? 1 : 0,
    });
  }

  void adEvent({
    required String format,
    required String placement,
    required String result,
    int? runCount,
    bool? routeCompleted,
  }) {
    _log('ad_event', <String, Object>{
      'format': format,
      'placement': placement,
      'result': result,
      if (runCount != null) 'run_count': runCount,
      if (routeCompleted != null) 'route_completed': routeCompleted ? 1 : 0,
    });
  }

  void _log(String name, Map<String, Object> parameters) {
    final analytics = _analytics;
    if (analytics == null) {
      return;
    }

    unawaited(
      analytics.logEvent(name: name, parameters: parameters).catchError((
        Object _,
      ) {
        return;
      }),
    );
  }
}
