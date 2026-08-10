import 'package:flutter/foundation.dart';

import '../domain/level_definition.dart';
import '../domain/level_state.dart';
import '../domain/puzzle_engine.dart';
import '../domain/tile_instance.dart';

class TripleMatchController extends ChangeNotifier {
  TripleMatchController({
    required this.engine,
    required List<LevelDefinition> levels,
    int initialLevelIndex = 0,
  }) : assert(levels.isNotEmpty, 'At least one level is required.'),
       assert(initialLevelIndex >= 0),
       assert(initialLevelIndex < levels.length),
       _levels = List.unmodifiable(levels),
       _currentLevelIndex = initialLevelIndex,
       _state = engine.start(levels[initialLevelIndex]);

  final PuzzleEngine engine;
  final List<LevelDefinition> _levels;

  LevelState _state;
  int _currentLevelIndex;
  String _message = _openingMessage;

  static const _openingMessage =
      'Tap free labels. Match three before the tray fills.';

  LevelState get state => _state;
  String get message => _message;
  int get currentLevelNumber => _currentLevelIndex + 1;
  int get totalLevels => _levels.length;
  int get score => _state.score;
  int get moves => _state.moves;
  int get trayCapacity => _state.tray.capacity;
  List<String> get trayTileIds => _state.tray.tileIds;
  List<TileInstance> get boardTiles => engine.boardTiles(_state);
  LevelStatus get status => _state.status;
  bool get isLastLevel => _currentLevelIndex == _levels.length - 1;
  bool get isTrayDanger => _state.tray.size >= _state.tray.capacity - 2;

  TileInstance tileById(String tileId) => _state.level.tileById(tileId);

  bool isSelectable(String tileId) => engine.isSelectable(_state, tileId);

  void selectTile(String tileId) {
    if (!_state.isPlaying) {
      return;
    }

    if (!engine.isSelectable(_state, tileId)) {
      _message = 'That tile is covered. Clear the tile above it first.';
      notifyListeners();
      return;
    }

    final beforeTraySize = _state.tray.size;
    final tile = _state.level.tileById(tileId);
    _state = engine.selectTile(_state, tileId);

    if (_state.isWon) {
      _message = isLastLevel
          ? 'All shelves cleared.'
          : 'Shelf cleared. Continue when ready.';
    } else if (_state.isFailed) {
      _message = 'Tray full. Restart to try again.';
    } else if (_state.tray.size < beforeTraySize) {
      _message = 'Triple cleared: ${tile.kind.displayName}.';
    } else if (_state.tray.size >= _state.tray.capacity - 1) {
      _message = 'One tray slot left. Find a triple.';
    } else if (isTrayDanger) {
      _message = 'Tray is getting tight.';
    } else {
      _message = 'Selected ${tile.kind.displayName}.';
    }
    notifyListeners();
  }

  void restart() {
    _state = engine.restart(_state);
    _message = 'Level restarted.';
    notifyListeners();
  }

  void nextLevel() {
    if (!_state.isWon || isLastLevel) {
      return;
    }

    _currentLevelIndex++;
    _state = engine.start(_levels[_currentLevelIndex]);
    _message = _openingMessage;
    notifyListeners();
  }
}
