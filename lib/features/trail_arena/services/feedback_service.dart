import 'package:flutter/services.dart';

import '../domain/game_settings.dart';

enum FeedbackCue { tap, validAction, invalidAction, score, reward, win, loss }

class FeedbackService {
  const FeedbackService();

  Future<void> play(FeedbackCue cue, GameSettings settings) async {
    await Future.wait([
      if (settings.soundEnabled) _playSound(cue),
      if (settings.hapticsEnabled) _playHaptic(cue),
    ]);
  }

  Future<void> _playSound(FeedbackCue cue) async {
    try {
      final sound = switch (cue) {
        FeedbackCue.invalidAction || FeedbackCue.loss => SystemSoundType.alert,
        _ => SystemSoundType.click,
      };
      await SystemSound.play(sound);
    } catch (_) {
      // Feedback should never interrupt play on devices that ignore it.
    }
  }

  Future<void> _playHaptic(FeedbackCue cue) async {
    try {
      switch (cue) {
        case FeedbackCue.tap:
          await HapticFeedback.selectionClick();
        case FeedbackCue.validAction:
        case FeedbackCue.score:
          await HapticFeedback.lightImpact();
        case FeedbackCue.invalidAction:
        case FeedbackCue.reward:
          await HapticFeedback.mediumImpact();
        case FeedbackCue.win:
        case FeedbackCue.loss:
          await HapticFeedback.heavyImpact();
      }
    } catch (_) {
      // Some platforms do not support haptics; gameplay must continue.
    }
  }
}
