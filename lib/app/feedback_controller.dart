import 'package:flutter/services.dart';

import '../game/game_feedback.dart';
import 'game_settings.dart';

class FeedbackController {
  const FeedbackController(this.settings);

  final GameSettings settings;

  void play(GameFeedback feedback) {
    if (settings.soundEnabled) {
      _sound(feedback);
    }
    if (settings.hapticsEnabled) {
      _haptic(feedback);
    }
  }

  void _sound(GameFeedback feedback) {
    final type = switch (feedback) {
      GameFeedback.invalid ||
      GameFeedback.blocked ||
      GameFeedback.missed => SystemSoundType.alert,
      _ => SystemSoundType.click,
    };
    SystemSound.play(type);
  }

  void _haptic(GameFeedback feedback) {
    switch (feedback) {
      case GameFeedback.goal:
        HapticFeedback.mediumImpact();
      case GameFeedback.saved:
      case GameFeedback.blocked:
      case GameFeedback.missed:
      case GameFeedback.invalid:
        HapticFeedback.lightImpact();
      case GameFeedback.shot:
        HapticFeedback.selectionClick();
      case GameFeedback.tap:
      case GameFeedback.aimStart:
      case GameFeedback.retry:
      case GameFeedback.next:
        HapticFeedback.selectionClick();
    }
  }
}
