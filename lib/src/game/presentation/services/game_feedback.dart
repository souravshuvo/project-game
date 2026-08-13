import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../settings/game_settings.dart';

enum GameFeedbackCue {
  tap,
  select,
  validMove,
  invalid,
  capture,
  restart,
  win,
  loss,
}

class GameFeedback {
  const GameFeedback._();

  static void play(BuildContext context, GameFeedbackCue cue) {
    final settings = GameSettingsScope.read(context);

    if (settings.hapticsEnabled) {
      switch (cue) {
        case GameFeedbackCue.tap:
          _fire(HapticFeedback.selectionClick());
          break;
        case GameFeedbackCue.select:
          _fire(HapticFeedback.selectionClick());
          break;
        case GameFeedbackCue.validMove:
          _fire(HapticFeedback.lightImpact());
          break;
        case GameFeedbackCue.invalid:
          _fire(HapticFeedback.mediumImpact());
          break;
        case GameFeedbackCue.capture:
          _fire(HapticFeedback.mediumImpact());
          break;
        case GameFeedbackCue.restart:
          _fire(HapticFeedback.lightImpact());
          break;
        case GameFeedbackCue.win:
          _fire(HapticFeedback.heavyImpact());
          break;
        case GameFeedbackCue.loss:
          _fire(HapticFeedback.vibrate());
          break;
      }
    }

    if (settings.soundEnabled) {
      final sound = switch (cue) {
        GameFeedbackCue.invalid ||
        GameFeedbackCue.win ||
        GameFeedbackCue.loss => SystemSoundType.alert,
        GameFeedbackCue.tap ||
        GameFeedbackCue.select ||
        GameFeedbackCue.validMove ||
        GameFeedbackCue.capture ||
        GameFeedbackCue.restart => SystemSoundType.click,
      };
      _fire(SystemSound.play(sound));
    }
  }

  static void _fire(Future<void> feedback) {
    unawaited(feedback.catchError((_) {}));
  }
}
