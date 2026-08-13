import 'package:flutter/services.dart';

class GameFeedbackService {
  bool soundEnabled = true;
  bool hapticsEnabled = true;

  void setEnabled({required bool sound, required bool haptics}) {
    soundEnabled = sound;
    hapticsEnabled = haptics;
  }

  Future<void> tap() {
    return _play(haptic: HapticFeedback.selectionClick);
  }

  Future<void> validMove() {
    return _play(haptic: HapticFeedback.lightImpact);
  }

  Future<void> score() {
    return _play(haptic: HapticFeedback.selectionClick);
  }

  Future<void> reward() {
    return _play(haptic: HapticFeedback.mediumImpact);
  }

  Future<void> invalidAction() {
    return _play(haptic: HapticFeedback.heavyImpact);
  }

  Future<void> loss() {
    return _play(sound: SystemSoundType.alert, haptic: HapticFeedback.vibrate);
  }

  Future<void> _play({
    SystemSoundType sound = SystemSoundType.click,
    Future<void> Function()? haptic,
  }) async {
    final futures = <Future<void>>[];

    if (soundEnabled) {
      futures.add(SystemSound.play(sound));
    }

    if (hapticsEnabled && haptic != null) {
      futures.add(haptic());
    }

    for (final future in futures) {
      try {
        await future;
      } on Object {
        // Platform feedback is best-effort and must never block play.
      }
    }
  }
}
