class GameSettings {
  const GameSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.controlSensitivity = 1,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final double controlSensitivity;
}
