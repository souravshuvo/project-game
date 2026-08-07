import 'package:flutter/services.dart';

abstract interface class LetterAudioCue {
  Future<void> playLetterA();

  Future<void> playSuccess();
}

/// A deliberately temporary, offline-safe cue for the engineering slice.
///
/// Replace this with a reviewed and licensed bundled pronunciation recording
/// before expanding beyond the letter-A usability build.
class SystemLetterAudioCue implements LetterAudioCue {
  const SystemLetterAudioCue({required this.isEnabled});

  final bool Function() isEnabled;

  @override
  Future<void> playLetterA() => _play(SystemSoundType.click);

  @override
  Future<void> playSuccess() => _play(SystemSoundType.alert);

  Future<void> _play(SystemSoundType type) async {
    if (!isEnabled()) {
      return;
    }
    await SystemSound.play(type);
  }
}
