import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_runtime_options.dart';

class AnalyticsEvents {
  static const appOpen = 'rc_app_open';
  static const sessionStart = 'rc_session_start';
  static const sessionPause = 'rc_session_pause';
  static const sessionResume = 'rc_session_resume';
  static const screenOpen = 'rc_screen_open';
  static const menuAction = 'rc_menu_action';
  static const challengeStart = 'rc_challenge_start';
  static const challengeResult = 'rc_challenge_result';
  static const retry = 'rc_retry';
  static const nextChallenge = 'rc_next_challenge';
  static const progressReset = 'rc_progress_reset';
  static const adRequest = 'rc_ad_request';
  static const adLoaded = 'rc_ad_loaded';
  static const adFailed = 'rc_ad_failed';
  static const adSkipped = 'rc_ad_skipped';
  static const adCapped = 'rc_ad_capped';
  static const adShow = 'rc_ad_show';
  static const adDismiss = 'rc_ad_dismiss';
  static const adImpression = 'rc_ad_impression';
  static const adClick = 'rc_ad_click';
}

class AnalyticsService {
  AnalyticsService({bool disabled = false}) : _disabled = disabled;

  AnalyticsService.disabled() : _disabled = true;

  final bool _disabled;
  FirebaseAnalytics? _firebase;
  bool _remoteReady = false;
  DateTime _sessionStartedAt = DateTime.now();

  bool get remoteReady => _remoteReady;

  Future<void> initialize() async {
    if (_disabled) {
      return;
    }

    final options = FirebaseRuntimeOptions.currentPlatform;
    if (options == null) {
      _debug('Firebase Analytics disabled: runtime options are missing.');
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
      _firebase = FirebaseAnalytics.instance;
      await _firebase?.setAnalyticsCollectionEnabled(true);
      _remoteReady = true;
    } catch (error) {
      _remoteReady = false;
      _debug('Firebase Analytics disabled: $error');
    }
  }

  Future<void> logAppOpen() async {
    _sessionStartedAt = DateTime.now();
    await logEvent(AnalyticsEvents.appOpen);
    await logEvent(AnalyticsEvents.sessionStart);
  }

  Future<void> logSessionPause() {
    return logEvent(AnalyticsEvents.sessionPause, {
      'session_seconds': _sessionSeconds,
    });
  }

  Future<void> logSessionResume() {
    _sessionStartedAt = DateTime.now();
    return logEvent(AnalyticsEvents.sessionResume);
  }

  Future<void> logScreen(String screen) {
    return logEvent(AnalyticsEvents.screenOpen, {'screen': screen});
  }

  Future<void> logMenuAction(String action) {
    return logEvent(AnalyticsEvents.menuAction, {'action': action});
  }

  Future<void> logChallengeStart({
    required int challengeId,
    required int challengeNumber,
    required int totalChallenges,
    required String challengeName,
  }) {
    return logEvent(AnalyticsEvents.challengeStart, {
      'challenge_id': challengeId,
      'challenge_number': challengeNumber,
      'total_challenges': totalChallenges,
      'challenge_name': challengeName,
    });
  }

  Future<void> logChallengeResult({
    required int challengeId,
    required int challengeNumber,
    required String result,
    required int attempts,
    required int stars,
    required int completedCount,
    required int totalStars,
  }) {
    return logEvent(AnalyticsEvents.challengeResult, {
      'challenge_id': challengeId,
      'challenge_number': challengeNumber,
      'result': result,
      'attempts': attempts,
      'stars': stars,
      'completed_count': completedCount,
      'total_stars': totalStars,
    });
  }

  Future<void> logRetry({
    required int challengeNumber,
    required String source,
    required String previousResult,
  }) {
    return logEvent(AnalyticsEvents.retry, {
      'challenge_number': challengeNumber,
      'source': source,
      'previous_result': previousResult,
    });
  }

  Future<void> logNextChallenge({
    required int fromChallengeNumber,
    required int completedCount,
  }) {
    return logEvent(AnalyticsEvents.nextChallenge, {
      'from_challenge_number': fromChallengeNumber,
      'completed_count': completedCount,
    });
  }

  Future<void> logProgressReset({
    required int completedCount,
    required int totalStars,
  }) {
    return logEvent(AnalyticsEvents.progressReset, {
      'completed_count': completedCount,
      'total_stars': totalStars,
    });
  }

  Future<void> logAdEvent(
    String name, {
    required String format,
    required String placement,
    String? reason,
    int? challengeNumber,
    int? completedCount,
    int? errorCode,
    String? errorMessage,
  }) {
    return logEvent(name, {
      'ad_format': format,
      'placement': placement,
      if (reason != null) 'reason': reason,
      if (challengeNumber != null) 'challenge_number': challengeNumber,
      if (completedCount != null) 'completed_count': completedCount,
      if (errorCode != null) 'error_code': errorCode,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  Future<void> logEvent(
    String name, [
    Map<String, Object?> parameters = const {},
  ]) async {
    if (_disabled) {
      return;
    }

    final cleaned = _cleanParameters(parameters);
    _debug('$name $cleaned');

    if (!_remoteReady) {
      return;
    }

    try {
      await _firebase?.logEvent(name: name, parameters: cleaned);
    } catch (error) {
      _remoteReady = false;
      _debug('Firebase Analytics event failed: $error');
    }
  }

  int get _sessionSeconds {
    return DateTime.now().difference(_sessionStartedAt).inSeconds;
  }

  Map<String, Object> _cleanParameters(Map<String, Object?> parameters) {
    final cleaned = <String, Object>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }
      if (value is String) {
        if (value.isNotEmpty) {
          cleaned[entry.key] = value.length > 100
              ? value.substring(0, 100)
              : value;
        }
      } else if (value is bool) {
        cleaned[entry.key] = value ? 1 : 0;
      } else if (value is num) {
        cleaned[entry.key] = value;
      }
    }
    return cleaned;
  }

  void _debug(String message) {
    if (kDebugMode) {
      debugPrint('analytics: $message');
    }
  }
}
