enum GameMode { singlePlayer, passAndPlay }

extension GameModeLabel on GameMode {
  String get label {
    switch (this) {
      case GameMode.singlePlayer:
        return 'Single Player';
      case GameMode.passAndPlay:
        return 'Pass & Play';
    }
  }
}

enum GameRole {
  king('king', 'King / Raja', '👑', 1000),
  minister('minister', 'Minister / Mantri', '🧙‍♂️', 800),
  police('police', 'Police', '👮‍♂️', 500),
  thief('thief', 'Thief / Chor', '🥷', 500);

  const GameRole(this.id, this.label, this.emoji, this.maxPoints);

  final String id;
  final String label;
  final String emoji;
  final int maxPoints;
}

class GamePlayer {
  const GamePlayer({
    required this.id,
    required this.name,
    required this.seatIndex,
    required this.isBot,
  });

  final String id;
  final String name;
  final int seatIndex;
  final bool isBot;
}

class Accusation {
  const Accusation({
    required this.policePlayerId,
    required this.accusedPlayerId,
  });

  final String policePlayerId;
  final String accusedPlayerId;
}

class RoundResult {
  const RoundResult({
    required this.policePlayerId,
    required this.accusedPlayerId,
    required this.thiefPlayerId,
    required this.wasCorrect,
  });

  final String policePlayerId;
  final String accusedPlayerId;
  final String thiefPlayerId;
  final bool wasCorrect;
}

class ScoreEntry {
  const ScoreEntry({
    required this.playerId,
    required this.role,
    required this.points,
    required this.totalAfterRound,
  });

  final String playerId;
  final GameRole role;
  final int points;
  final int totalAfterRound;
}

class RoundScore {
  const RoundScore({required this.result, required this.entries});

  final RoundResult result;
  final List<ScoreEntry> entries;
}

class GameRound {
  const GameRound({
    required this.roundNumber,
    required this.assignments,
    required this.accusation,
    required this.result,
    required this.scoreEntries,
  });

  final int roundNumber;
  final Map<String, GameRole> assignments;
  final Accusation accusation;
  final RoundResult result;
  final List<ScoreEntry> scoreEntries;
}
