import 'package:flutter_test/flutter_test.dart';
import 'package:larder_labels/features/triple_match/application/triple_match_controller.dart';
import 'package:larder_labels/features/triple_match/data/local_level_pack.dart';
import 'package:larder_labels/features/triple_match/domain/level_state.dart';
import 'package:larder_labels/features/triple_match/domain/puzzle_engine.dart';

void main() {
  test('blocked taps report a useful message without mutating state', () {
    final controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
      initialLevelIndex: 2,
    );

    controller.selectTile('l3-honey-1');

    expect(controller.trayTileIds, isEmpty);
    expect(controller.message, contains('covered'));
  });

  test('restart resets controller state', () {
    final controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
    );

    controller.selectTile('l1-jar-1');
    controller.restart();

    expect(controller.trayTileIds, isEmpty);
    expect(controller.moves, 0);
    expect(controller.score, 0);
    expect(controller.message, 'Level restarted.');
  });

  test('next level advances after a win', () {
    final controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
    );

    for (final tileId in prototypeLevel.solutionTileIds) {
      controller.selectTile(tileId);
    }

    expect(controller.currentLevelNumber, 1);
    expect(controller.status, LevelStatus.won);

    controller.nextLevel();

    expect(controller.currentLevelNumber, 2);
    expect(controller.trayTileIds, isEmpty);
    expect(controller.moves, 0);
  });

  test('next level does not advance while level is still playing', () {
    final controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
    );

    controller.nextLevel();

    expect(controller.currentLevelNumber, 1);
    expect(controller.status, LevelStatus.playing);
  });
}
