import 'dart:math';

import '../domain/game_content.dart';
import '../domain/game_models.dart';

class GameEngine {
  GameEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  Map<String, GameRole> assignRoles(List<GamePlayer> players) {
    if (players.length != GameRole.values.length) {
      throw ArgumentError('Emoji Chor-Police requires exactly 4 players.');
    }

    final roles = List<GameRole>.of(GameRole.values)..shuffle(_random);
    return <String, GameRole>{
      for (var i = 0; i < players.length; i++) players[i].id: roles[i],
    };
  }

  String findPlayerWithRole(Map<String, GameRole> assignments, GameRole role) {
    return assignments.entries.singleWhere((entry) => entry.value == role).key;
  }

  List<String> validSuspectIds({
    required List<GamePlayer> players,
    required String policePlayerId,
  }) {
    return players
        .where((player) => player.id != policePlayerId)
        .map((player) => player.id)
        .toList(growable: false);
  }

  String chooseBotSuspect({
    required List<GamePlayer> players,
    required String policePlayerId,
    BotGuessStyle style = BotGuessStyle.fairRandom,
    Map<String, int> currentTotals = const <String, int>{},
    List<GameRound> history = const <GameRound>[],
  }) {
    final suspects = validSuspectIds(
      players: players,
      policePlayerId: policePlayerId,
    );

    switch (style) {
      case BotGuessStyle.fairRandom:
        return _randomId(suspects);
      case BotGuessStyle.scoreWatcher:
        return _highestPublicScore(suspects, currentTotals);
      case BotGuessStyle.tableMemory:
        return _mostOftenRevealedThief(suspects, history);
    }
  }

  String _randomId(List<String> ids) {
    return ids[_random.nextInt(ids.length)];
  }

  String _highestPublicScore(
    List<String> suspectIds,
    Map<String, int> currentTotals,
  ) {
    final bestScore = suspectIds.fold<int>(
      currentTotals[suspectIds.first] ?? 0,
      (best, id) => max(best, currentTotals[id] ?? 0),
    );
    final topSuspects = suspectIds
        .where((id) => (currentTotals[id] ?? 0) == bestScore)
        .toList(growable: false);
    return _randomId(topSuspects);
  }

  String _mostOftenRevealedThief(
    List<String> suspectIds,
    List<GameRound> history,
  ) {
    final thiefCounts = <String, int>{for (final id in suspectIds) id: 0};
    for (final round in history) {
      final thiefPlayerId = findPlayerWithRole(
        round.assignments,
        GameRole.thief,
      );
      if (thiefCounts.containsKey(thiefPlayerId)) {
        thiefCounts[thiefPlayerId] = thiefCounts[thiefPlayerId]! + 1;
      }
    }

    final bestCount = thiefCounts.values.fold<int>(0, max);
    if (bestCount == 0) {
      return _randomId(suspectIds);
    }

    final topSuspects = thiefCounts.entries
        .where((entry) => entry.value == bestCount)
        .map((entry) => entry.key)
        .toList(growable: false);
    return _randomId(topSuspects);
  }

  RoundScore scoreRound({
    required List<GamePlayer> players,
    required Map<String, GameRole> assignments,
    required Map<String, int> currentTotals,
    required Accusation accusation,
  }) {
    _validateAssignments(players, assignments);
    _validateAccusation(players, assignments, accusation);

    final thiefPlayerId = findPlayerWithRole(assignments, GameRole.thief);
    final wasCorrect = accusation.accusedPlayerId == thiefPlayerId;
    final entries = <ScoreEntry>[];

    for (final player in players) {
      final role = assignments[player.id]!;
      final points = _pointsFor(role: role, wasPoliceCorrect: wasCorrect);
      entries.add(
        ScoreEntry(
          playerId: player.id,
          role: role,
          points: points,
          totalAfterRound: (currentTotals[player.id] ?? 0) + points,
        ),
      );
    }

    return RoundScore(
      result: RoundResult(
        policePlayerId: accusation.policePlayerId,
        accusedPlayerId: accusation.accusedPlayerId,
        thiefPlayerId: thiefPlayerId,
        wasCorrect: wasCorrect,
      ),
      entries: entries,
    );
  }

  int _pointsFor({required GameRole role, required bool wasPoliceCorrect}) {
    switch (role) {
      case GameRole.king:
        return 1000;
      case GameRole.minister:
        return 800;
      case GameRole.police:
        return wasPoliceCorrect ? 500 : 0;
      case GameRole.thief:
        return wasPoliceCorrect ? 0 : 500;
    }
  }

  void _validateAssignments(
    List<GamePlayer> players,
    Map<String, GameRole> assignments,
  ) {
    final playerIds = players.map((player) => player.id).toSet();
    if (assignments.keys.toSet().difference(playerIds).isNotEmpty ||
        playerIds.difference(assignments.keys.toSet()).isNotEmpty) {
      throw ArgumentError('Assignments must match the active players.');
    }
    if (assignments.values.toSet().length != GameRole.values.length) {
      throw ArgumentError('Each role must appear exactly once.');
    }
  }

  void _validateAccusation(
    List<GamePlayer> players,
    Map<String, GameRole> assignments,
    Accusation accusation,
  ) {
    final playerIds = players.map((player) => player.id).toSet();
    if (!playerIds.contains(accusation.policePlayerId) ||
        !playerIds.contains(accusation.accusedPlayerId)) {
      throw ArgumentError('Accusation must reference active players.');
    }
    if (accusation.policePlayerId == accusation.accusedPlayerId) {
      throw ArgumentError('Police cannot accuse themselves.');
    }
    if (assignments[accusation.policePlayerId] != GameRole.police) {
      throw ArgumentError('Only the Police player can accuse.');
    }
  }
}
