import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../game_content.dart';
import '../game_engine.dart';

class GameAnalytics {
  FirebaseAnalytics? _analytics;
  bool _available = false;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;
      _available = true;
      await logEvent('app_open');
    } catch (error) {
      _available = false;
      debugPrint('Analytics disabled: $error');
    }
  }

  Future<void> logMenuView(GameProgress progress) {
    return logEvent('menu_view', {
      'matches_played': progress.matchesPlayed,
      'completed_challenges': progress.completedChallengeCount,
      'best_practice_runs': progress.bestPracticeRuns,
      'best_chase_runs': progress.bestChaseRuns,
      'chase_wins': progress.targetChaseWins,
    });
  }

  Future<void> logSettingsChanged(String setting, bool enabled) {
    return logEvent('settings_changed', {
      'setting': setting,
      'enabled': enabled ? 1 : 0,
    });
  }

  Future<void> logPresetSelected(MatchPreset preset) {
    return logEvent('preset_selected', _presetParameters(preset));
  }

  Future<void> logChallengeLadderView(GameProgress progress) {
    return logEvent('challenge_ladder_view', {
      'completed_challenges': progress.completedChallengeCount,
      'total_challenges': kChallengeLadder.length,
    });
  }

  Future<void> logMatchStart(GameSetup setup) {
    final challenge = setup.challenge;
    final parameters = <String, Object?>{
      'mode': setup.mode.name,
      'preset_id': setup.preset.id,
      'preset_title': setup.preset.title,
      'max_overs': setup.rules.maxOvers,
      'max_wickets': setup.rules.maxWickets,
      'challenge_id': challenge?.id ?? 'none',
      'difficulty': challenge?.difficulty.label ?? 'free_play',
    };

    return logEvent('match_start', parameters);
  }

  Future<void> logSpinnerStart(GameSetup setup, MatchState state) {
    return logEvent('spinner_start', {
      'mode': setup.mode.name,
      'preset_id': setup.preset.id,
      'phase': state.phase.name,
      'innings': state.inningsNumber,
      'legal_balls': state.activeScore.legalBalls,
      'runs': state.activeScore.runs,
      'wickets': state.activeScore.wickets,
      'challenge_id': setup.challenge?.id ?? 'none',
    });
  }

  Future<void> logDeliveryResult({
    required GameSetup setup,
    required MatchState state,
    required DeliveryResult result,
  }) {
    return logEvent('delivery_result', {
      'mode': setup.mode.name,
      'preset_id': setup.preset.id,
      'phase_after': result.phaseAfter.name,
      'innings': state.inningsNumber,
      'outcome': result.outcome.name,
      'runs_added': result.runsAdded,
      'extras_added': result.extrasAdded,
      'legal_delivery': result.consumedLegalBall ? 1 : 0,
      'wicket': result.tookWicket ? 1 : 0,
      'score_runs': state.activeScore.runs,
      'score_wickets': state.activeScore.wickets,
      'legal_balls': state.activeScore.legalBalls,
      'challenge_id': setup.challenge?.id ?? 'none',
    });
  }

  Future<void> logMatchFinish({
    required GameSetup setup,
    required MatchState state,
    required Duration duration,
  }) async {
    final challenge = setup.challenge;
    final challengeComplete = challenge?.isComplete(state) ?? false;
    final score = setup.mode == GameMode.practiceInnings
        ? state.firstInnings
        : state.secondInnings;

    await logEvent('match_finish', {
      'mode': setup.mode.name,
      'preset_id': setup.preset.id,
      'result_type': _resultType(state),
      'result_text': state.matchResult ?? 'complete',
      'duration_seconds': duration.inSeconds,
      'score_runs': score.runs,
      'score_wickets': score.wickets,
      'legal_balls': score.legalBalls,
      'extras': score.extras,
      'target': state.target ?? 0,
      'deliveries': state.deliveries.length,
      'boundaries': _boundaryCount(state),
      'sixes': _sixCount(state),
      'challenge_id': challenge?.id ?? 'none',
      'difficulty': challenge?.difficulty.label ?? 'free_play',
      'challenge_complete': challengeComplete ? 1 : 0,
    });

    if (challenge != null) {
      await logEvent('challenge_finish', {
        'challenge_id': challenge.id,
        'difficulty': challenge.difficulty.label,
        'completed': challengeComplete ? 1 : 0,
        'preset_id': challenge.preset.id,
      });
    }
  }

  Future<void> logAdEvent(
    String name, {
    required String format,
    required String placement,
    String? reason,
    bool? testAds,
  }) {
    return logEvent(name, {
      'format': format,
      'placement': placement,
      if (reason != null) 'reason': reason,
      if (testAds != null) 'test_ads': testAds ? 1 : 0,
    });
  }

  Future<void> logEvent(
    String name, [
    Map<String, Object?> parameters = const <String, Object?>{},
  ]) async {
    final analytics = _analytics;
    if (!_available || analytics == null) {
      return;
    }

    try {
      await analytics.logEvent(
        name: name,
        parameters: _cleanParameters(parameters),
      );
    } catch (error) {
      debugPrint('Analytics event dropped ($name): $error');
    }
  }

  Map<String, Object> _presetParameters(MatchPreset preset) {
    return {
      'preset_id': preset.id,
      'preset_title': preset.title,
      'max_overs': preset.rules.maxOvers,
      'max_wickets': preset.rules.maxWickets,
    };
  }

  Map<String, Object> _cleanParameters(Map<String, Object?> parameters) {
    final clean = <String, Object>{};

    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }

      clean[entry.key] = switch (value) {
        bool boolValue => boolValue ? 1 : 0,
        int intValue => intValue,
        double doubleValue => doubleValue,
        num numValue => numValue.toDouble(),
        Enum enumValue => enumValue.name,
        String stringValue => stringValue.length > 100
            ? stringValue.substring(0, 100)
            : stringValue,
        _ => value.toString(),
      };
    }

    return clean;
  }

  String _resultType(MatchState state) {
    final result = state.matchResult ?? '';
    if (state.mode == GameMode.practiceInnings) {
      return 'practice_complete';
    }
    if (result.startsWith('Chase won')) {
      return 'chase_win';
    }
    if (result == 'Match tied') {
      return 'tie';
    }
    return 'defended';
  }

  int _boundaryCount(MatchState state) {
    return state.deliveries.where((delivery) {
      return delivery.outcome == DeliveryOutcome.four ||
          delivery.outcome == DeliveryOutcome.six;
    }).length;
  }

  int _sixCount(MatchState state) {
    return state.deliveries
        .where((delivery) => delivery.outcome == DeliveryOutcome.six)
        .length;
  }
}
