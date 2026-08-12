import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/features/game/domain/game_content.dart';
import 'package:rapid_jump/features/game/domain/game_models.dart';
import 'package:rapid_jump/features/game/domain/game_progress.dart';
import 'package:rapid_jump/features/game/logic/game_progress_store.dart';

void main() {
  const players = <GamePlayer>[
    GamePlayer(id: 'p1', name: 'You', seatIndex: 0, isBot: false),
    GamePlayer(id: 'p2', name: 'Bot Mira', seatIndex: 1, isBot: true),
    GamePlayer(id: 'p3', name: 'Bot Nilu', seatIndex: 2, isBot: true),
    GamePlayer(id: 'p4', name: 'Bot Rafi', seatIndex: 3, isBot: true),
  ];

  test('records match history and unlocks relevant challenges', () {
    final update = recordCompletedMatch(
      current: GameProgress.empty(),
      players: players,
      rounds: <GameRound>[
        _round(
          roundNumber: 1,
          humanRole: GameRole.king,
          thiefPlayerId: 'p3',
          accusedPlayerId: 'p2',
        ),
        _round(
          roundNumber: 2,
          humanRole: GameRole.police,
          thiefPlayerId: 'p2',
          accusedPlayerId: 'p2',
          policePlayerId: 'p1',
        ),
        _round(
          roundNumber: 3,
          humanRole: GameRole.thief,
          thiefPlayerId: 'p1',
          accusedPlayerId: 'p2',
        ),
      ],
      totals: const <String, int>{'p1': 4000, 'p2': 1000, 'p3': 800, 'p4': 0},
      humanPlayerId: 'p1',
      preset: matchPresets.first,
      botGuessStyle: BotGuessStyle.scoreWatcher,
      completedAt: DateTime(2026, 1, 2),
    );

    expect(update.progress.matchesPlayed, 1);
    expect(update.progress.matchesWon, 1);
    expect(update.progress.roundsPlayed, 3);
    expect(update.progress.quickWins, 1);
    expect(update.progress.humanPoliceCorrect, 1);
    expect(update.progress.humanThiefEscapes, 1);
    expect(update.progress.history, hasLength(1));
    expect(update.progress.history.single.humanScore, 4000);

    final unlockedIds = update.newUnlocks.map((challenge) => challenge.id);
    expect(unlockedIds, contains('first_table'));
    expect(unlockedIds, contains('first_win'));
    expect(unlockedIds, contains('quick_crown'));
    expect(unlockedIds, contains('first_catch'));
    expect(unlockedIds, contains('first_escape'));
    expect(unlockedIds, contains('big_score'));
  });

  test('progress JSON round-trips saved match history', () {
    final progress = GameProgress.empty().copyWith(
      matchesPlayed: 2,
      bestMatchScore: 3200,
      unlockedChallengeIds: const <String>{'first_table', 'big_score'},
      history: <MatchHistoryEntry>[
        MatchHistoryEntry(
          completedAt: DateTime(2026, 1, 2),
          presetId: 'quick',
          presetLabel: 'Quick',
          rounds: 5,
          botStyleId: BotGuessStyle.fairRandom.id,
          botStyleLabel: BotGuessStyle.fairRandom.label,
          humanScore: 3200,
          winnerName: 'You',
          humanRank: 1,
          policeCorrectGuesses: 1,
          policeAttempts: 2,
        ),
      ],
    );

    final decoded = decodeGameProgress(encodeGameProgress(progress));

    expect(decoded.matchesPlayed, 2);
    expect(decoded.bestMatchScore, 3200);
    expect(decoded.unlockedChallengeIds, contains('big_score'));
    expect(decoded.history.single.winnerName, 'You');
  });
}

GameRound _round({
  required int roundNumber,
  required GameRole humanRole,
  required String thiefPlayerId,
  required String accusedPlayerId,
  String policePlayerId = 'p4',
}) {
  final assignments = _assignmentsFor(
    humanRole: humanRole,
    thiefPlayerId: thiefPlayerId,
    policePlayerId: policePlayerId,
  );

  return GameRound(
    roundNumber: roundNumber,
    assignments: assignments,
    accusation: Accusation(
      policePlayerId: policePlayerId,
      accusedPlayerId: accusedPlayerId,
    ),
    result: RoundResult(
      policePlayerId: policePlayerId,
      accusedPlayerId: accusedPlayerId,
      thiefPlayerId: thiefPlayerId,
      wasCorrect: accusedPlayerId == thiefPlayerId,
    ),
    scoreEntries: const <ScoreEntry>[],
  );
}

Map<String, GameRole> _assignmentsFor({
  required GameRole humanRole,
  required String thiefPlayerId,
  required String policePlayerId,
}) {
  final assignments = <String, GameRole>{'p1': humanRole};
  final usedRoles = <GameRole>{humanRole};

  if (!assignments.containsKey(policePlayerId)) {
    assignments[policePlayerId] = GameRole.police;
    usedRoles.add(GameRole.police);
  }
  if (!assignments.containsKey(thiefPlayerId)) {
    assignments[thiefPlayerId] = GameRole.thief;
    usedRoles.add(GameRole.thief);
  }

  for (final playerId in <String>['p2', 'p3', 'p4']) {
    assignments.putIfAbsent(playerId, () {
      return GameRole.values.firstWhere((role) => !usedRoles.contains(role));
    });
    usedRoles.add(assignments[playerId]!);
  }

  return assignments;
}
