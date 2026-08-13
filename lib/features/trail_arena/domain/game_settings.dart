class GameSettings {
  const GameSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.controlSensitivity = 1,
  });

  static const defaults = GameSettings();

  final bool soundEnabled;
  final bool hapticsEnabled;
  final double controlSensitivity;

  GameSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    double? controlSensitivity,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      controlSensitivity: controlSensitivity ?? this.controlSensitivity,
    );
  }
}
