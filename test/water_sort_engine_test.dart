import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/data/local_water_level_pack.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/pour_move.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/pour_result.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/water_board.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/water_sort_engine.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/water_tube.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = WaterSortEngine();

  test('valid pour transfers the top connected color group', () {
    final board = WaterBoard([
      WaterTube.fromSymbols('RMM', capacity: 4),
      WaterTube.fromSymbols('M', capacity: 4),
    ]);

    final result = engine.pour(
      board,
      const PourMove(sourceIndex: 0, destinationIndex: 1),
    );

    expect(result.isValid, isTrue);
    expect(result.layersMoved, 2);
    expect(result.board.toSymbolRows(), ['R', 'MMM']);
    expect(board.toSymbolRows(), ['RMM', 'M']);
  });

  test('pour is capped by destination capacity', () {
    final board = WaterBoard([
      WaterTube.fromSymbols('SRR', capacity: 4),
      WaterTube.fromSymbols('RRR', capacity: 4),
    ]);

    final result = engine.pour(
      board,
      const PourMove(sourceIndex: 0, destinationIndex: 1),
    );

    expect(result.isValid, isTrue);
    expect(result.layersMoved, 1);
    expect(result.board.toSymbolRows(), ['SR', 'RRRR']);
  });

  test('rejects pours onto a different top color', () {
    final board = WaterBoard([
      WaterTube.fromSymbols('R', capacity: 4),
      WaterTube.fromSymbols('S', capacity: 4),
    ]);

    final result = engine.pour(
      board,
      const PourMove(sourceIndex: 0, destinationIndex: 1),
    );

    expect(result.isValid, isFalse);
    expect(result.invalidReason, PourInvalidReason.colorMismatch);
    expect(result.board.toSymbolRows(), ['R', 'S']);
  });

  test('rejects pours from an empty source', () {
    final board = WaterBoard([
      WaterTube.empty(4),
      WaterTube.fromSymbols('S', capacity: 4),
    ]);

    final result = engine.pour(
      board,
      const PourMove(sourceIndex: 0, destinationIndex: 1),
    );

    expect(result.isValid, isFalse);
    expect(result.invalidReason, PourInvalidReason.sourceEmpty);
  });

  test('rejects pours into a full destination', () {
    final board = WaterBoard([
      WaterTube.fromSymbols('R', capacity: 4),
      WaterTube.fromSymbols('SSSS', capacity: 4),
    ]);

    final result = engine.pour(
      board,
      const PourMove(sourceIndex: 0, destinationIndex: 1),
    );

    expect(result.isValid, isFalse);
    expect(result.invalidReason, PourInvalidReason.destinationFull);
  });

  test('rejects same-tube moves', () {
    final board = WaterBoard([WaterTube.fromSymbols('R', capacity: 4)]);

    final result = engine.pour(
      board,
      const PourMove(sourceIndex: 0, destinationIndex: 0),
    );

    expect(result.isValid, isFalse);
    expect(result.invalidReason, PourInvalidReason.sameTube);
  });

  test(
    'win detection requires every non-empty tube to be one unique color',
    () {
      final solved = WaterBoard([
        WaterTube.fromSymbols('RRRR', capacity: 4),
        WaterTube.fromSymbols('SSSS', capacity: 4),
        WaterTube.empty(4),
      ]);
      final mixed = WaterBoard([
        WaterTube.fromSymbols('RRS', capacity: 4),
        WaterTube.empty(4),
      ]);
      final duplicate = WaterBoard([
        WaterTube.fromSymbols('RR', capacity: 4),
        WaterTube.fromSymbols('RR', capacity: 4),
      ]);

      expect(engine.isSolved(solved), isTrue);
      expect(engine.isSolved(mixed), isFalse);
      expect(engine.isSolved(duplicate), isFalse);
    },
  );

  test('prototype level has a known winning sequence', () {
    var board = engine.parse(localWaterLevelPack.single);

    const moves = [
      PourMove(sourceIndex: 0, destinationIndex: 3),
      PourMove(sourceIndex: 2, destinationIndex: 0),
      PourMove(sourceIndex: 1, destinationIndex: 2),
      PourMove(sourceIndex: 1, destinationIndex: 3),
      PourMove(sourceIndex: 0, destinationIndex: 1),
      PourMove(sourceIndex: 2, destinationIndex: 0),
      PourMove(sourceIndex: 2, destinationIndex: 3),
      PourMove(sourceIndex: 1, destinationIndex: 2),
      PourMove(sourceIndex: 0, destinationIndex: 1),
      PourMove(sourceIndex: 0, destinationIndex: 3),
    ];

    for (final move in moves) {
      final result = engine.pour(board, move);
      expect(result.isValid, isTrue, reason: 'Move $move should be valid.');
      board = result.board;
    }

    expect(board.toSymbolRows(), ['', 'SSSS', 'MMMM', 'RRRR', '']);
    expect(engine.isSolved(board), isTrue);
  });
}
