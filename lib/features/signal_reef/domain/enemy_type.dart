enum SignalEnemyType { driftNode, pulseSeed }

extension SignalEnemyTypeRules on SignalEnemyType {
  int get maxHull {
    return switch (this) {
      SignalEnemyType.driftNode => 1,
      SignalEnemyType.pulseSeed => 2,
    };
  }

  int get scoreValue {
    return switch (this) {
      SignalEnemyType.driftNode => 10,
      SignalEnemyType.pulseSeed => 30,
    };
  }

  double get baseSpeed {
    return switch (this) {
      SignalEnemyType.driftNode => 92,
      SignalEnemyType.pulseSeed => 68,
    };
  }
}
