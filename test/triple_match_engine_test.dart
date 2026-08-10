import 'package:flutter_test/flutter_test.dart';
import 'package:larder_labels/features/triple_match/data/local_level_pack.dart';
import 'package:larder_labels/features/triple_match/domain/level_definition.dart';
import 'package:larder_labels/features/triple_match/domain/level_state.dart';
import 'package:larder_labels/features/triple_match/domain/puzzle_engine.dart';
import 'package:larder_labels/features/triple_match/domain/tile_instance.dart';
import 'package:larder_labels/features/triple_match/domain/tile_kind.dart';

void main() {
  const engine = PuzzleEngine();

  test('all local levels use valid triple sets', () {
    for (final level in localLevelPack) {
      expect(
        () => engine.validateLevel(level),
        returnsNormally,
        reason: 'Level ${level.id} ${level.name} should be valid.',
      );
    }
  });

  test('all local levels include deterministic winning solution paths', () {
    for (final level in localLevelPack) {
      var state = engine.start(level);

      expect(
        level.solutionTileIds.length,
        level.tiles.length,
        reason: 'Level ${level.id} solution should select every tile.',
      );

      for (final tileId in level.solutionTileIds) {
        expect(
          engine.isSelectable(state, tileId),
          isTrue,
          reason: 'Level ${level.id} solution tile $tileId must be selectable.',
        );
        state = engine.selectTile(state, tileId);
      }

      expect(
        state.status,
        LevelStatus.won,
        reason: 'Level ${level.id} ${level.name} should be solvable.',
      );
      expect(state.tray.tileIds, isEmpty);
      expect(state.removedTileIds.length, level.tiles.length);
    }
  });

  test('covered base tile is not selectable until top tile moves', () {
    var state = engine.start(prototypeLevel);

    expect(engine.isSelectable(state, 'l1-jar-1'), isTrue);

    state = engine.start(localLevelPack[2]);

    expect(engine.isSelectable(state, 'l3-honey-1'), isFalse);
    expect(engine.isSelectable(state, 'l3-honey-2'), isTrue);

    state = engine.selectTile(state, 'l3-honey-2');

    expect(engine.isSelectable(state, 'l3-honey-1'), isTrue);
  });

  test('selecting a tile moves it into the tray', () {
    final state = engine.selectTile(engine.start(prototypeLevel), 'l1-jar-1');

    expect(state.tray.tileIds, ['l1-jar-1']);
    expect(engine.isTileOnBoard(state, 'l1-jar-1'), isFalse);
    expect(state.moves, 1);
    expect(state.score, PuzzleEngine.selectTileScore);
  });

  test('three matching tray tiles are removed after selection', () {
    var state = engine.start(prototypeLevel);

    state = engine.selectTile(state, 'l1-jar-1');
    state = engine.selectTile(state, 'l1-jar-2');
    state = engine.selectTile(state, 'l1-jar-3');

    expect(state.tray.tileIds, isEmpty);
    expect(
      state.removedTileIds,
      containsAll(['l1-jar-1', 'l1-jar-2', 'l1-jar-3']),
    );
    expect(state.status, LevelStatus.playing);
    expect(
      state.score,
      PuzzleEngine.selectTileScore * 3 + PuzzleEngine.tripleClearScore,
    );
  });

  test('win triggers when all tiles are cleared and tray is empty', () {
    var state = engine.start(_simpleWinLevel);

    state = engine.selectTile(state, 'a1');
    state = engine.selectTile(state, 'a2');
    state = engine.selectTile(state, 'a3');

    expect(state.status, LevelStatus.won);
    expect(state.tray.tileIds, isEmpty);
    expect(state.removedTileIds.length, 3);
    expect(
      state.score,
      PuzzleEngine.selectTileScore * 3 +
          PuzzleEngine.tripleClearScore +
          PuzzleEngine.winBonusScore,
    );
  });

  test('fail triggers when tray reaches capacity after match resolution', () {
    var state = engine.start(_failLevel);

    for (final tileId in ['a1', 'a2', 'b1', 'b2', 'c1', 'c2', 'd1']) {
      state = engine.selectTile(state, tileId);
    }

    expect(state.status, LevelStatus.failed);
    expect(state.tray.size, 7);
    expect(state.removedTileIds, isEmpty);
  });

  test('restart restores the original level state', () {
    var state = engine.start(prototypeLevel);
    state = engine.selectTile(state, 'l1-jar-1');
    state = engine.selectTile(state, 'l1-note-1');

    final restarted = engine.restart(state);

    expect(restarted.tray.tileIds, isEmpty);
    expect(restarted.removedTileIds, isEmpty);
    expect(restarted.moves, 0);
    expect(restarted.score, 0);
    expect(restarted.status, LevelStatus.playing);
    expect(engine.isSelectable(restarted, 'l1-jar-1'), isTrue);
  });

  test('invalid selections leave state unchanged', () {
    final state = engine.start(localLevelPack[2]);
    final next = engine.selectTile(state, 'l3-honey-1');

    expect(identical(next, state), isTrue);
  });
}

const _simpleWinLevel = LevelDefinition(
  id: 100,
  name: 'Simple Win',
  width: 3,
  height: 1,
  trayCapacity: 7,
  solutionTileIds: ['a1', 'a2', 'a3'],
  tiles: [
    TileInstance(id: 'a1', kind: TileKind.jarLabel, row: 0, col: 0),
    TileInstance(id: 'a2', kind: TileKind.jarLabel, row: 0, col: 1),
    TileInstance(id: 'a3', kind: TileKind.jarLabel, row: 0, col: 2),
  ],
);

const _failLevel = LevelDefinition(
  id: 101,
  name: 'Fail Tray',
  width: 6,
  height: 2,
  trayCapacity: 7,
  tiles: [
    TileInstance(id: 'a1', kind: TileKind.jarLabel, row: 0, col: 0),
    TileInstance(id: 'a2', kind: TileKind.jarLabel, row: 0, col: 1),
    TileInstance(id: 'a3', kind: TileKind.jarLabel, row: 1, col: 0),
    TileInstance(id: 'b1', kind: TileKind.foldedNote, row: 0, col: 2),
    TileInstance(id: 'b2', kind: TileKind.foldedNote, row: 0, col: 3),
    TileInstance(id: 'b3', kind: TileKind.foldedNote, row: 1, col: 1),
    TileInstance(id: 'c1', kind: TileKind.berryTin, row: 0, col: 4),
    TileInstance(id: 'c2', kind: TileKind.berryTin, row: 0, col: 5),
    TileInstance(id: 'c3', kind: TileKind.berryTin, row: 1, col: 2),
    TileInstance(id: 'd1', kind: TileKind.flourTag, row: 1, col: 3),
    TileInstance(id: 'd2', kind: TileKind.flourTag, row: 1, col: 4),
    TileInstance(id: 'd3', kind: TileKind.flourTag, row: 1, col: 5),
  ],
);
