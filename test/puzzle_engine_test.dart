import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/data/local_level_pack.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/data/campaign_playbook.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/domain/board_position.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/domain/puzzle_board.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/domain/puzzle_engine.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/domain/puzzle_level.dart';
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

  test('production level pack reaches the v1 content target', () {
    expect(localLevelPack.length, 60);
  });

  test('campaign playbook partitions every level into ordered waves', () {
    final waves = buildCampaignWaves(totalLevels: localLevelPack.length);
    final allWaveLevels = <int>{};
    var expectedStart = 1;

    expect(waves.isNotEmpty, isTrue);
    for (final wave in waves) {
      final seenInWave = <int>{};

      expect(wave.startLevel, expectedStart);
      expect(wave.endLevel, greaterThanOrEqualTo(wave.startLevel));
      expect(wave.title.trim(), isNotEmpty);
      expect(wave.objective.trim(), isNotEmpty);
      expect(wave.reward.trim(), isNotEmpty);
      expect(wave.levelCount, wave.endLevel - wave.startLevel + 1);
      for (var level = wave.startLevel; level <= wave.endLevel; level++) {
        expect(wave.containsLevel(level), isTrue);
        expect(seenInWave.add(level), isTrue);
        expect(allWaveLevels.add(level), isTrue);
      }
      expectedStart = wave.endLevel + 1;
    }
    expect(allWaveLevels.length, localLevelPack.length);
    expect(expectedStart, localLevelPack.length + 1);
    expect(allWaveLevels, equals(List.generate(localLevelPack.length, (i) => i + 1).toSet()));
  });

  test('campaign wave helper counts completed levels only inside the wave', () {
    final firstWave = campaignWaveForLevel(levelNumber: 1, totalLevels: 18);
    expect(firstWave, isNotNull);
    expect(
      completedLevelCountInWave(
        firstWave!,
        {1, 2, 5, 7, 8, 10, 13, 17},
      ),
      5,
    );

    final secondWave = campaignWaveForLevel(levelNumber: 7, totalLevels: 18);
    expect(secondWave, isNotNull);
    expect(
      completedLevelCountInWave(
        secondWave!,
        {1, 2, 5, 7, 8, 10, 13, 17},
      ),
      2,
    );
  });

  test('mission metadata exists for every campaign wave', () {
    final waves = buildCampaignWaves(totalLevels: localLevelPack.length);

    for (final wave in waves) {
      expect(wave.title.trim().isNotEmpty, isTrue);
      expect(wave.objective.trim().isNotEmpty, isTrue);
      expect(wave.reward.trim().isNotEmpty, isTrue);
      expect(wave.startLevel <= wave.endLevel, isTrue);
      expect(wave.endLevel <= localLevelPack.length, isTrue);
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

  test('sample levels use unique board layouts', () {
    final layouts = localLevelPack.map((level) => level.rows.join('/')).toSet();

    expect(layouts.length, localLevelPack.length);
  });

  test('sample levels stay within mobile-friendly board bounds', () {
    for (final level in localLevelPack) {
      final board = engine.parse(level);

      expect(
        board.rowCount,
        inInclusiveRange(4, 9),
        reason: 'Level ${level.id} ${level.name} has unsupported row count.',
      );
      expect(
        board.colCount,
        inInclusiveRange(4, 9),
        reason: 'Level ${level.id} ${level.name} has unsupported column count.',
      );
      expect(
        level.name.trim(),
        isNotEmpty,
        reason: 'Level ${level.id} needs a display name.',
      );
      expect(
        level.lesson.trim(),
        isNotEmpty,
        reason: 'Level ${level.id} needs a lesson.',
      );
    }
  });

  test('late-game production levels are meaningfully denser', () {
    for (final level in localLevelPack.skip(50)) {
      expect(
        _arrowCount(level),
        greaterThanOrEqualTo(12),
        reason: 'Level ${level.id} ${level.name} should feel late-game.',
      );
    }
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

int _arrowCount(PuzzleLevel level) {
  return level.rows.join().split('').where((symbol) => symbol != '.').length;
}
