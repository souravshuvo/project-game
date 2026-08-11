class ScoreSystem {
  int score = 0;
  double _survivalClock = 0;

  void reset() {
    score = 0;
    _survivalClock = 0;
  }

  void addFoodScore(int amount) {
    score += amount;
  }

  void addBotCrashBonus() {
    score += 25;
  }

  void updateSurvival(double dt) {
    _survivalClock += dt;
    while (_survivalClock >= 10) {
      score += 10;
      _survivalClock -= 10;
    }
  }
}
