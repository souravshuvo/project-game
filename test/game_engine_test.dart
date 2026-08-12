import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/features/game/domain/game_content.dart';
import 'package:rapid_jump/features/game/domain/game_models.dart';
import 'package:rapid_jump/features/game/logic/game_engine.dart';

void main() {
  const players = <GamePlayer>[
    GamePlayer(id: 'p1', name: 'Player 1', seatIndex: 0, isBot: false),
    GamePlayer(id: 'p2', name: 'Player 2', seatIndex: 1, isBot: false),
    GamePlayer(id: 'p3', name: 'Player 3', seatIndex: 2, isBot: false),
    GamePlayer(id: 'p4', name: 'Player 4', seatIndex: 3, isBot: false),
  ];

  test('assignRoles gives exactly one role to each of four players', () {
    final engine = GameEngine(random: Random(7));

    final assignments = engine.assignRoles(players);

    expect(assignments.keys.toSet(), {'p1', 'p2', 'p3', 'p4'});
    expect(assignments.values.toSet(), GameRole.values.toSet());
  });

  test('correct Police guess gives Police 500 and Thief 0', () {
    final engine = GameEngine(random: Random(1));
    final assignments = <String, GameRole>{
      'p1': GameRole.king,
      'p2': GameRole.minister,
      'p3': GameRole.police,
      'p4': GameRole.thief,
    };

    final score = engine.scoreRound(
      players: players,
      assignments: assignments,
      currentTotals: const <String, int>{'p1': 0, 'p2': 0, 'p3': 0, 'p4': 0},
      accusation: const Accusation(policePlayerId: 'p3', accusedPlayerId: 'p4'),
    );

    expect(score.result.wasCorrect, isTrue);
    expect(_pointsFor(score, 'p1'), 1000);
    expect(_pointsFor(score, 'p2'), 800);
    expect(_pointsFor(score, 'p3'), 500);
    expect(_pointsFor(score, 'p4'), 0);
  });

  test('wrong Police guess gives Police 0 and Thief 500', () {
    final engine = GameEngine(random: Random(1));
    final assignments = <String, GameRole>{
      'p1': GameRole.king,
      'p2': GameRole.minister,
      'p3': GameRole.police,
      'p4': GameRole.thief,
    };

    final score = engine.scoreRound(
      players: players,
      assignments: assignments,
      currentTotals: const <String, int>{'p1': 0, 'p2': 0, 'p3': 0, 'p4': 0},
      accusation: const Accusation(policePlayerId: 'p3', accusedPlayerId: 'p1'),
    );

    expect(score.result.wasCorrect, isFalse);
    expect(_pointsFor(score, 'p1'), 1000);
    expect(_pointsFor(score, 'p2'), 800);
    expect(_pointsFor(score, 'p3'), 0);
    expect(_pointsFor(score, 'p4'), 500);
  });

  test('Police cannot accuse themselves', () {
    final engine = GameEngine(random: Random(1));
    final assignments = <String, GameRole>{
      'p1': GameRole.king,
      'p2': GameRole.minister,
      'p3': GameRole.police,
      'p4': GameRole.thief,
    };

    expect(
      () => engine.scoreRound(
        players: players,
        assignments: assignments,
        currentTotals: const <String, int>{'p1': 0, 'p2': 0, 'p3': 0, 'p4': 0},
        accusation: const Accusation(
          policePlayerId: 'p3',
          accusedPlayerId: 'p3',
        ),
      ),
      throwsArgumentError,
    );
  });

  test('only the assigned Police player can accuse', () {
    final engine = GameEngine(random: Random(1));
    final assignments = <String, GameRole>{
      'p1': GameRole.king,
      'p2': GameRole.minister,
      'p3': GameRole.police,
      'p4': GameRole.thief,
    };

    expect(
      () => engine.scoreRound(
        players: players,
        assignments: assignments,
        currentTotals: const <String, int>{'p1': 0, 'p2': 0, 'p3': 0, 'p4': 0},
        accusation: const Accusation(
          policePlayerId: 'p1',
          accusedPlayerId: 'p4',
        ),
      ),
      throwsArgumentError,
    );
  });

  test('score watcher bot targets the public score leader', () {
    final engine = GameEngine(random: Random(1));

    final suspect = engine.chooseBotSuspect(
      players: players,
      policePlayerId: 'p4',
      style: BotGuessStyle.scoreWatcher,
      currentTotals: const <String, int>{
        'p1': 1000,
        'p2': 2500,
        'p3': 800,
        'p4': 0,
      },
    );

    expect(suspect, 'p2');
  });

  test('table memory bot uses earlier revealed thief history', () {
    final engine = GameEngine(random: Random(1));
    final history = <GameRound>[
      _roundWithThief('p1'),
      _roundWithThief('p2'),
      _roundWithThief('p2'),
    ];

    final suspect = engine.chooseBotSuspect(
      players: players,
      policePlayerId: 'p4',
      style: BotGuessStyle.tableMemory,
      history: history,
    );

    expect(suspect, 'p2');
  });
}

int _pointsFor(RoundScore score, String playerId) {
  return score.entries
      .singleWhere((entry) => entry.playerId == playerId)
      .points;
}

GameRound _roundWithThief(String thiefPlayerId) {
  final assignments = switch (thiefPlayerId) {
    'p1' => <String, GameRole>{
      'p1': GameRole.thief,
      'p2': GameRole.minister,
      'p3': GameRole.king,
      'p4': GameRole.police,
    },
    'p2' => <String, GameRole>{
      'p1': GameRole.king,
      'p2': GameRole.thief,
      'p3': GameRole.minister,
      'p4': GameRole.police,
    },
    _ => <String, GameRole>{
      'p1': GameRole.king,
      'p2': GameRole.minister,
      'p3': GameRole.thief,
      'p4': GameRole.police,
    },
  };

  return GameRound(
    roundNumber: 1,
    assignments: assignments,
    accusation: const Accusation(policePlayerId: 'p4', accusedPlayerId: 'p1'),
    result: RoundResult(
      policePlayerId: 'p4',
      accusedPlayerId: 'p1',
      thiefPlayerId: thiefPlayerId,
      wasCorrect: thiefPlayerId == 'p1',
    ),
    scoreEntries: const <ScoreEntry>[],
  );
}
