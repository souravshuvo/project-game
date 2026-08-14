import 'dart:async';

import 'package:flutter/services.dart';

enum SignalReefFeedbackCue {
  tap,
  validAction,
  invalidAction,
  score,
  reward,
  damage,
  win,
  loss,
}

class SignalReefFeedbackSettings {
  const SignalReefFeedbackSettings({
    required this.soundEnabled,
    required this.hapticsEnabled,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
}

abstract interface class SignalReefFeedback {
  void play(SignalReefFeedbackCue cue, SignalReefFeedbackSettings settings);
}

final class PlatformSignalReefFeedback implements SignalReefFeedback {
  const PlatformSignalReefFeedback();

  @override
  void play(SignalReefFeedbackCue cue, SignalReefFeedbackSettings settings) {
    if (settings.hapticsEnabled) {
      unawaited(_playHaptic(cue));
    }

    if (settings.soundEnabled) {
      unawaited(_playSound(cue));
    }
  }

  Future<void> _playHaptic(SignalReefFeedbackCue cue) async {
    try {
      switch (cue) {
        case SignalReefFeedbackCue.tap:
        case SignalReefFeedbackCue.score:
          await HapticFeedback.selectionClick();
          return;
        case SignalReefFeedbackCue.validAction:
        case SignalReefFeedbackCue.reward:
          await HapticFeedback.lightImpact();
          return;
        case SignalReefFeedbackCue.invalidAction:
        case SignalReefFeedbackCue.damage:
          await HapticFeedback.mediumImpact();
          return;
        case SignalReefFeedbackCue.win:
          await HapticFeedback.heavyImpact();
          return;
        case SignalReefFeedbackCue.loss:
          await HapticFeedback.vibrate();
          return;
      }
    } on Object {
      return;
    }
  }

  Future<void> _playSound(SignalReefFeedbackCue cue) async {
    try {
      final sound = switch (cue) {
        SignalReefFeedbackCue.invalidAction ||
        SignalReefFeedbackCue.damage ||
        SignalReefFeedbackCue.loss ||
        SignalReefFeedbackCue.win => SystemSoundType.alert,
        _ => SystemSoundType.click,
      };

      await SystemSound.play(sound);
    } on Object {
      return;
    }
  }
}
