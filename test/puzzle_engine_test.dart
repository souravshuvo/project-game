import 'package:signal_reef_space_shooter/features/arrow_puzzle/data/local_level_pack.dart';
import 'package:signal_reef_space_shooter/features/arrow_puzzle/domain/board_position.dart';
import 'package:signal_reef_space_shooter/features/arrow_puzzle/domain/puzzle_board.dart';
import 'package:signal_reef_space_shooter/features/arrow_puzzle/domain/puzzle_engine.dart';
import 'package:signal_reef_space_shooter/features/arrow_puzzle/domain/puzzle_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = PuzzleEngine();

  test('rejects non-rectangular levels', () {
    expect(
      () => PuzzleBoard.fromRows(['R.', '...']),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects unsupported symbols', () {
    expect(() => PuzzleBoard.fromRows(['R#']), throwsA(isA<FormatException>()));
  });

  test('rejects empty-arrow levels', () {
    expect(
      () => PuzzleBoard.fromRows(['..', '..']),
      throwsA(isA<FormatException>()),
    );
  });

  test('clear right arrow is valid', () {
    final board = PuzzleBoard.fromRows(['R..']);

    expect(engine.canRemove(board, const BoardPosition(0, 0)), isTrue);
  });

  test('blocked right arrow is invalid', () {
    final board = PuzzleBoard.fromRows(['R.L']);

    expect(engine.canRemove(board, const BoardPosition(0, 0)), isFalse);
  });

  test('valid tap removes arrow', () {
    final board = PuzzleBoard.fromRows(['R..']);
    final next = engine.remove(board, const BoardPosition(0, 0));

    expect(next.toRows(), ['...']);
  });

  test('invalid tap does not mutate board state', () {
    final board = PuzzleBoard.fromRows(['R.L']);
    final next = engine.remove(board, const BoardPosition(0, 0));

    expect(next.toRows(), ['R.L']);
  });

  test('win condition is true when board is empty', () {
    final board = PuzzleBoard.fromRows(['R']);
    final next = engine.remove(board, const BoardPosition(0, 0));

    expect(next.isCleared, isTrue);
  });

  test(
    'stuck condition is true when arrows remain but no valid moves exist',
    () {
      final board = PuzzleBoard.fromRows(['RL']);

      expect(engine.isStuck(board), isTrue);
    },
  );

  test('sample levels pass solvability validation', () {
    for (final level in localLevelPack) {
      expect(
        engine.isSolvable(level),
        isTrue,
        reason: 'Level ${level.id} ${level.name} should be solvable.',
      );
    }
  });

  test('sample levels use unique ids', () {
    final ids = localLevelPack.map((level) => level.id).toSet();

    expect(ids.length, localLevelPack.length);
  });

  test('sample levels use sequential ids', () {
    final ids = localLevelPack.map((level) => level.id).toList();

    expect(ids, List.generate(localLevelPack.length, (index) => index + 1));
  });

  test('all levels contain at least one valid first move', () {
    for (final level in localLevelPack) {
      final board = engine.parse(level);

      expect(
        engine.validMoves(board),
        isNotEmpty,
        reason: 'Level ${level.id} ${level.name} needs a first move.',
      );
    }
  });

  test('custom level can be parsed through engine', () {
    const level = PuzzleLevel(
      id: 99,
      name: 'Test',
      rows: ['R.'],
      lesson: 'Test lesson.',
    );

    expect(engine.parse(level).toRows(), ['R.']);
  });
}
