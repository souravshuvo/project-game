import 'level_definition.dart';
import 'level_state.dart';
import 'tile_instance.dart';
import 'tile_kind.dart';
import 'tray_state.dart';

class PuzzleEngine {
  const PuzzleEngine();

  static const selectTileScore = 10;
  static const tripleClearScore = 50;
  static const winBonusScore = 100;

  LevelState start(LevelDefinition level) {
    validateLevel(level);

    return LevelState(
      level: level,
      tray: TrayState(tileIds: const [], capacity: level.trayCapacity),
      removedTileIds: const {},
      moves: 0,
      score: 0,
      status: LevelStatus.playing,
    );
  }

  LevelState restart(LevelState state) => start(state.level);

  void validateLevel(LevelDefinition level) {
    if (level.width <= 0 || level.height <= 0) {
      throw const FormatException('Level dimensions must be positive.');
    }
    if (level.trayCapacity <= 0) {
      throw const FormatException('Tray capacity must be positive.');
    }
    if (level.tiles.isEmpty || level.tiles.length % 3 != 0) {
      throw const FormatException(
        'Tile count must be a positive multiple of 3.',
      );
    }

    final ids = <String>{};
    final occupiedCells = <String>{};
    final kindCounts = <TileKind, int>{};

    for (final tile in level.tiles) {
      if (!ids.add(tile.id)) {
        throw FormatException('Duplicate tile id: ${tile.id}');
      }
      if (tile.row < 0 ||
          tile.row >= level.height ||
          tile.col < 0 ||
          tile.col >= level.width ||
          tile.layer < 0) {
        throw FormatException('Tile outside level bounds: ${tile.id}');
      }

      final cellKey = '${tile.row}:${tile.col}:${tile.layer}';
      if (!occupiedCells.add(cellKey)) {
        throw FormatException('Two tiles share the same cell layer: $cellKey');
      }

      kindCounts[tile.kind] = (kindCounts[tile.kind] ?? 0) + 1;
    }

    final invalidKinds = kindCounts.entries.where((entry) => entry.value != 3);
    if (invalidKinds.isNotEmpty) {
      throw const FormatException(
        'Every tile kind must appear exactly 3 times.',
      );
    }
  }

  List<TileInstance> boardTiles(LevelState state) {
    return state.level.tiles
        .where((tile) => isTileOnBoard(state, tile.id))
        .toList(growable: false);
  }

  bool isTileOnBoard(LevelState state, String tileId) {
    return !state.removedTileIds.contains(tileId) &&
        !state.tray.contains(tileId);
  }

  bool isSelectable(LevelState state, String tileId) {
    if (!state.isPlaying ||
        !state.level.containsTile(tileId) ||
        !isTileOnBoard(state, tileId)) {
      return false;
    }

    final tile = state.level.tileById(tileId);
    return !_isCovered(state, tile);
  }

  List<String> selectableTileIds(LevelState state) {
    return boardTiles(state)
        .where((tile) => isSelectable(state, tile.id))
        .map((tile) => tile.id)
        .toList(growable: false);
  }

  LevelState selectTile(LevelState state, String tileId) {
    if (!isSelectable(state, tileId)) {
      return state;
    }

    var tray = state.tray.add(tileId);
    final removedTileIds = Set<String>.of(state.removedTileIds);
    var score = state.score + selectTileScore;

    while (true) {
      final triple = _firstTriple(tray, state.level);
      if (triple == null) {
        break;
      }
      tray = tray.removeAll(triple);
      removedTileIds.addAll(triple);
      score += tripleClearScore;
    }

    var status = LevelStatus.playing;
    if (removedTileIds.length == state.level.tiles.length &&
        tray.tileIds.isEmpty) {
      status = LevelStatus.won;
      score += winBonusScore;
    } else if (tray.isFull) {
      status = LevelStatus.failed;
    }

    return state.copyWith(
      tray: tray,
      removedTileIds: removedTileIds,
      moves: state.moves + 1,
      score: score,
      status: status,
    );
  }

  bool _isCovered(LevelState state, TileInstance tile) {
    return boardTiles(state).any(
      (other) =>
          other.id != tile.id &&
          other.occupiesSameCell(tile) &&
          other.layer > tile.layer,
    );
  }

  List<String>? _firstTriple(TrayState tray, LevelDefinition level) {
    final idsByKind = <TileKind, List<String>>{};
    for (final tileId in tray.tileIds) {
      final tile = level.tileById(tileId);
      final ids = idsByKind.putIfAbsent(tile.kind, () => <String>[]);
      ids.add(tileId);
      if (ids.length == 3) {
        return ids.toList(growable: false);
      }
    }
    return null;
  }
}
