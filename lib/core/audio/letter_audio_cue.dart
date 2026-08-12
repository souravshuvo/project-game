import 'package:flutter/services.dart';

abstract interface class LetterAudioCue {
  Future<void> playLetterA();

  Future<void> playSuccess();

  Future<void> playTap();

  Future<void> playValidAction();

  Future<void> playInvalidAction();

  Future<void> playReward();

  Future<void> playWin();

  Future<void> playRestart();
}

/// Lightweight, offline-safe gameplay feedback.
///
/// The letter-specific method names are kept for compatibility with the
/// original tracing slice, but this class now covers all KidsLand games.
class SystemLetterAudioCue implements LetterAudioCue {
  const SystemLetterAudioCue({
    required this.isSoundEnabled,
    required this.isHapticsEnabled,
  });

  final bool Function() isSoundEnabled;
  final bool Function() isHapticsEnabled;

  @override
  Future<void> playLetterA() => playTap();

  @override
  Future<void> playSuccess() => playWin();

  @override
  Future<void> playTap() => _play(
    sound: SystemSoundType.click,
    haptic: HapticFeedback.selectionClick,
  );

  @override
  Future<void> playValidAction() =>
      _play(sound: SystemSoundType.click, haptic: HapticFeedback.lightImpact);

  @override
  Future<void> playInvalidAction() =>
      _play(sound: SystemSoundType.alert, haptic: HapticFeedback.mediumImpact);

  @override
  Future<void> playReward() =>
      _play(sound: SystemSoundType.click, haptic: HapticFeedback.mediumImpact);

  @override
  Future<void> playWin() =>
      _play(sound: SystemSoundType.alert, haptic: HapticFeedback.heavyImpact);

  @override
  Future<void> playRestart() =>
      _play(sound: SystemSoundType.click, haptic: HapticFeedback.lightImpact);

  Future<void> _play({
    required SystemSoundType sound,
    required Future<void> Function() haptic,
  }) async {
    final futures = <Future<void>>[];
    if (_isEnabled(isHapticsEnabled)) {
      futures.add(_ignoreFailure(haptic()));
    }
    if (_isEnabled(isSoundEnabled)) {
      futures.add(_ignoreFailure(SystemSound.play(sound)));
    }
    await Future.wait(futures);
  }

  bool _isEnabled(bool Function() callback) {
    try {
      return callback();
    } on Object {
      return false;
    }
  }

  Future<void> _ignoreFailure(Future<void> future) async {
    try {
      await future;
    } on Object {
      // Device feedback is best-effort and must never block gameplay.
    }
  }
}
