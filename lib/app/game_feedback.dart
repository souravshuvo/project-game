import 'package:flutter/services.dart';

import 'player_settings.dart';

enum GameFeedbackType { tap, valid, invalid, reward, complete }

class GameFeedback {
  const GameFeedback(this.settings);

  final PlayerSettings settings;

  Future<void> play(GameFeedbackType type) async {
    await Future.wait([
      if (settings.hapticsEnabled) _playHaptic(type),
      if (settings.soundEnabled) _playSound(type),
    ]);
  }

  Future<void> _playHaptic(GameFeedbackType type) async {
    try {
      switch (type) {
        case GameFeedbackType.tap:
          await HapticFeedback.selectionClick();
        case GameFeedbackType.valid:
          await HapticFeedback.lightImpact();
        case GameFeedbackType.invalid:
          await HapticFeedback.mediumImpact();
        case GameFeedbackType.reward:
          await HapticFeedback.mediumImpact();
        case GameFeedbackType.complete:
          await HapticFeedback.heavyImpact();
      }
    } on Object {
      return;
    }
  }

  Future<void> _playSound(GameFeedbackType type) async {
    try {
      final sound = switch (type) {
        GameFeedbackType.invalid => SystemSoundType.alert,
        GameFeedbackType.complete => SystemSoundType.alert,
        _ => SystemSoundType.click,
      };
      await SystemSound.play(sound);
    } on Object {
      return;
    }
  }
}
