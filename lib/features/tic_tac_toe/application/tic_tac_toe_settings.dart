class TicTacToeSettings {
  const TicTacToeSettings({
    required this.soundEnabled,
    required this.hapticsEnabled,
  });

  const TicTacToeSettings.initial()
    : soundEnabled = true,
      hapticsEnabled = true;

  final bool soundEnabled;
  final bool hapticsEnabled;

  TicTacToeSettings copyWith({bool? soundEnabled, bool? hapticsEnabled}) {
    return TicTacToeSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}
