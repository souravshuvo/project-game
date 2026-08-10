enum GameResultType { goal, saved, missed, blocked, tooWeak }

class GameResult {
  const GameResult({
    required this.type,
    required this.attempt,
    required this.challengeId,
  });

  final GameResultType type;
  final int attempt;
  final int challengeId;

  String get title {
    return switch (type) {
      GameResultType.goal => 'Goal!',
      GameResultType.saved => 'Saved',
      GameResultType.missed => 'Missed',
      GameResultType.blocked => 'Blocked',
      GameResultType.tooWeak => 'Too Weak',
    };
  }

  String get message {
    return switch (type) {
      GameResultType.goal =>
        'The ball crossed the line inside the rooftop goal.',
      GameResultType.saved =>
        'The keeper reached the shot before it crossed the line.',
      GameResultType.missed => 'The shot left the court outside the goal.',
      GameResultType.blocked => 'The training board stopped the ball.',
      GameResultType.tooWeak =>
        'The shot ran out of speed before reaching the goal.',
    };
  }
}
