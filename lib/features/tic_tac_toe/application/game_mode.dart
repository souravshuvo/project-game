enum GameMode {
  localTwoPlayer,
  vsAi;

  String get label {
    return switch (this) {
      GameMode.localTwoPlayer => 'Two Players',
      GameMode.vsAi => 'Vs AI',
    };
  }

  String get analyticsName {
    return switch (this) {
      GameMode.localTwoPlayer => 'local_two_player',
      GameMode.vsAi => 'vs_ai',
    };
  }
}
