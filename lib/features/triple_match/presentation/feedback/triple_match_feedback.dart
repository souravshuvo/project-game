import 'package:flutter/services.dart';

import '../../application/triple_match_controller.dart';

class TripleMatchFeedback {
  const TripleMatchFeedback._();

  static Future<void> play(
    TripleMatchController controller,
    TripleMatchFeedbackCue cue,
  ) async {
    if (cue == TripleMatchFeedbackCue.none) {
      return;
    }

    if (controller.hapticsEnabled) {
      await _playHaptic(cue);
    }
    if (controller.soundEnabled) {
      await _playSound(cue);
    }
  }

  static Future<void> _playHaptic(TripleMatchFeedbackCue cue) {
    return switch (cue) {
      TripleMatchFeedbackCue.invalid ||
      TripleMatchFeedbackCue.loss => HapticFeedback.heavyImpact(),
      TripleMatchFeedbackCue.match ||
      TripleMatchFeedbackCue.warning ||
      TripleMatchFeedbackCue.win => HapticFeedback.mediumImpact(),
      TripleMatchFeedbackCue.select ||
      TripleMatchFeedbackCue.tap ||
      TripleMatchFeedbackCue.restart ||
      TripleMatchFeedbackCue.next ||
      TripleMatchFeedbackCue.toggle => HapticFeedback.selectionClick(),
      TripleMatchFeedbackCue.none => Future<void>.value(),
    };
  }

  static Future<void> _playSound(TripleMatchFeedbackCue cue) {
    final sound = switch (cue) {
      TripleMatchFeedbackCue.invalid ||
      TripleMatchFeedbackCue.loss => SystemSoundType.alert,
      _ => SystemSoundType.click,
    };
    return SystemSound.play(sound);
  }
}
