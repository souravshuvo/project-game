import 'dart:math' as math;

class ScoreSystem {
  int score = 0;
  int bestScore = 0;

  void resetRun() {
    score = 0;
  }

  void setBestScore(int value) {
    bestScore = math.max(bestScore, value);
  }

  void updateHeight({
    required double startPlatformTop,
    required double playerY,
  }) {
    final heightScore = ((startPlatformTop - playerY) / 10).floor();
    score = math.max(score, math.max(0, heightScore));
  }

  bool finishRun() {
    if (score > bestScore) {
      bestScore = score;
      return true;
    }

    return false;
  }
}
