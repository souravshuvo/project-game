import 'dart:async';

import 'package:flutter/services.dart';

class GameFeedbackSettings {
  const GameFeedbackSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;

  GameFeedbackSettings copyWith({bool? soundEnabled, bool? hapticsEnabled}) {
    return GameFeedbackSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}

class GameFeedbackController {
  GameFeedbackController({GameFeedbackSettings? settings})
    : _settings = settings ?? const GameFeedbackSettings();

  GameFeedbackSettings get settings => _settings;
  GameFeedbackSettings _settings;

  void update(GameFeedbackSettings settings) {
    _settings = settings;
  }

  void tap() {
    _playSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.selectionClick);
  }

  void validAction() {
    _playSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.lightImpact);
  }

  void invalidAction() {
    _playSound(SystemSoundType.alert);
    _playHaptic(HapticFeedback.vibrate);
  }

  void collision() {
    _playHaptic(HapticFeedback.mediumImpact);
  }

  void reward() {
    _playSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.mediumImpact);
  }

  void win() {
    _playSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.heavyImpact);
  }

  void loss() {
    _playSound(SystemSoundType.alert);
    _playHaptic(HapticFeedback.heavyImpact);
  }

  void _playSound(SystemSoundType type) {
    if (!_settings.soundEnabled) {
      return;
    }

    unawaited(SystemSound.play(type).catchError((_) {}));
  }

  void _playHaptic(Future<void> Function() feedback) {
    if (!_settings.hapticsEnabled) {
      return;
    }

    unawaited(feedback().catchError((_) {}));
  }
}
