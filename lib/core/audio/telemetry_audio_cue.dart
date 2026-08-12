import 'dart:async';

import '../analytics/game_analytics.dart';
import 'letter_audio_cue.dart';

class TelemetryLetterAudioCue implements LetterAudioCue {
  const TelemetryLetterAudioCue({
    required this.delegate,
    required this.analytics,
    required this.gameId,
  });

  final LetterAudioCue delegate;
  final GameAnalytics analytics;
  final String gameId;

  @override
  Future<void> playLetterA() => _track('letter_prompt', delegate.playLetterA);

  @override
  Future<void> playSuccess() => _track('success', delegate.playSuccess);

  @override
  Future<void> playTap() => _track('tap', delegate.playTap);

  @override
  Future<void> playValidAction() =>
      _track('valid_action', delegate.playValidAction);

  @override
  Future<void> playInvalidAction() =>
      _track('invalid_action', delegate.playInvalidAction);

  @override
  Future<void> playReward() => _track('reward', delegate.playReward);

  @override
  Future<void> playWin() => _track('win', delegate.playWin);

  @override
  Future<void> playRestart() => _track('restart', delegate.playRestart);

  Future<void> _track(String feedbackType, Future<void> Function() play) async {
    unawaited(
      analytics
          .logEvent(
            'game_feedback',
            parameters: <String, Object?>{
              'game_id': gameId,
              'feedback_type': feedbackType,
            },
          )
          .catchError((Object _) {}),
    );
    await play();
  }
}
