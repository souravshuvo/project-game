import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../domain/level_definition.dart';
import '../domain/level_state.dart';
import '../domain/puzzle_engine.dart';
import '../domain/tile_instance.dart';
import '../../../shared/analytics/analytics_service.dart';

enum TripleMatchFeedbackCue {
  none,
  tap,
  select,
  invalid,
  match,
  warning,
  win,
  loss,
  restart,
  next,
  toggle,
}

class TripleMatchController extends ChangeNotifier {
  TripleMatchController({
    required this.engine,
    required List<LevelDefinition> levels,
    AnalyticsService analytics = const NoopAnalyticsService(),
    int initialLevelIndex = 0,
    int initialHighestUnlockedLevelIndex = 0,
    Set<int> completedLevelIds = const {},
  }) : assert(levels.isNotEmpty, 'At least one level is required.'),
       assert(initialLevelIndex >= 0),
       assert(initialLevelIndex < levels.length),
       _levels = List.unmodifiable(levels),
       _completedLevelIds = {
         for (final levelId in completedLevelIds)
           if (levels.any((level) => level.id == levelId)) levelId,
       },
       _highestUnlockedLevelIndex = _minInt(
         levels.length - 1,
         _maxInt(initialLevelIndex, initialHighestUnlockedLevelIndex),
       ),
       _analytics = analytics,
       _currentLevelIndex = initialLevelIndex,
       _state = engine.start(levels[initialLevelIndex]);

  final PuzzleEngine engine;
  final AnalyticsService _analytics;
  final List<LevelDefinition> _levels;

  LevelState _state;
  int _currentLevelIndex;
  int _highestUnlockedLevelIndex;
  int _trayHighWaterMark = 0;
  final Set<int> _completedLevelIds;
  String _message = _openingMessage;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  static const _openingMessage =
      'Tap free labels. Match three before the tray fills.';

  LevelState get state => _state;
  String get message => _message;
  int get currentLevelNumber => _currentLevelIndex + 1;
  int get totalLevels => _levels.length;
  int get currentLevelIndex => _currentLevelIndex;
  int get highestUnlockedLevelIndex => _highestUnlockedLevelIndex;
  int get highestUnlockedLevelNumber => _highestUnlockedLevelIndex + 1;
  int get completedLevelCount => _completedLevelIds.length;
  UnmodifiableSetView<int> get completedLevelIds =>
      UnmodifiableSetView(_completedLevelIds);
  String get progressSummary =>
      '$completedLevelCount/$totalLevels shelves cleared';
  int get score => _state.score;
  int get moves => _state.moves;
  int get trayCapacity => _state.tray.capacity;
  List<String> get trayTileIds => _state.tray.tileIds;
  List<TileInstance> get boardTiles => engine.boardTiles(_state);
  LevelStatus get status => _state.status;
  bool get isLastLevel => _currentLevelIndex == _levels.length - 1;
  bool get isTrayDanger => _state.tray.size >= _state.tray.capacity - 2;
  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  TileInstance tileById(String tileId) => _state.level.tileById(tileId);

  bool isSelectable(String tileId) => engine.isSelectable(_state, tileId);

  TripleMatchFeedbackCue selectTile(String tileId) {
    if (!_state.isPlaying) {
      return TripleMatchFeedbackCue.none;
    }

    if (!engine.isSelectable(_state, tileId)) {
      _message = 'That label is covered. Clear the label above it first.';
      _analytics.logEvent('covered_tile_tap', _levelAnalyticsParameters());
      notifyListeners();
      return TripleMatchFeedbackCue.invalid;
    }

    final beforeTraySize = _state.tray.size;
    final tile = _state.level.tileById(tileId);
    _state = engine.selectTile(_state, tileId);
    _trayHighWaterMark = _maxInt(_trayHighWaterMark, beforeTraySize + 1);
    _analytics.logEvent('tile_select', {
      ..._levelAnalyticsParameters(),
      'tile_kind': tile.kind.name,
      'tray_high_water': _trayHighWaterMark,
    });

    var cue = TripleMatchFeedbackCue.select;
    if (_state.isWon) {
      _recordCurrentLevelCompleted();
      _message = isLastLevel
          ? 'All shelves cleared.'
          : 'Shelf cleared. Continue when ready.';
      cue = TripleMatchFeedbackCue.win;
      _analytics.logEvent('level_complete', {
        ..._levelAnalyticsParameters(),
        'tray_high_water': _trayHighWaterMark,
      });
    } else if (_state.isFailed) {
      _message = 'Tray full. Restart to try again.';
      cue = TripleMatchFeedbackCue.loss;
      _analytics.logEvent('level_fail', {
        ..._levelAnalyticsParameters(),
        'tray_high_water': _trayHighWaterMark,
      });
    } else if (_state.tray.size < beforeTraySize) {
      _message = 'Triple cleared: ${tile.kind.displayName}.';
      cue = TripleMatchFeedbackCue.match;
      _analytics.logEvent('triple_clear', {
        ..._levelAnalyticsParameters(),
        'tile_kind': tile.kind.name,
        'tray_high_water': _trayHighWaterMark,
      });
    } else if (_state.tray.size >= _state.tray.capacity - 1) {
      _message = 'One tray slot left. Find a triple.';
      cue = TripleMatchFeedbackCue.warning;
      _analytics.logEvent('tray_warning', _levelAnalyticsParameters());
    } else if (isTrayDanger) {
      _message = 'Tray is getting tight.';
      cue = TripleMatchFeedbackCue.warning;
      _analytics.logEvent('tray_warning', _levelAnalyticsParameters());
    } else {
      _message = 'Selected ${tile.kind.displayName}.';
    }
    notifyListeners();
    return cue;
  }

  TripleMatchFeedbackCue restart() {
    _analytics.logEvent('level_restart', {
      ..._levelAnalyticsParameters(),
      'tray_high_water': _trayHighWaterMark,
    });
    _state = engine.restart(_state);
    _trayHighWaterMark = 0;
    _message = 'Level restarted.';
    logCurrentLevelStart(source: 'restart');
    notifyListeners();
    return TripleMatchFeedbackCue.restart;
  }

  TripleMatchFeedbackCue nextLevel() {
    if (!_state.isWon || isLastLevel) {
      return TripleMatchFeedbackCue.none;
    }

    _currentLevelIndex++;
    _highestUnlockedLevelIndex = _maxInt(
      _highestUnlockedLevelIndex,
      _currentLevelIndex,
    );
    _state = engine.start(_levels[_currentLevelIndex]);
    _trayHighWaterMark = 0;
    _message = _openingMessage;
    logCurrentLevelStart(source: 'next');
    notifyListeners();
    return TripleMatchFeedbackCue.next;
  }

  TripleMatchFeedbackCue setSoundEnabled(bool value) {
    if (_soundEnabled == value) {
      return TripleMatchFeedbackCue.none;
    }

    _soundEnabled = value;
    _message = value ? 'Sound feedback on.' : 'Sound feedback off.';
    _analytics.logEvent('settings_change', {
      'setting': 'sound_feedback',
      'enabled': value,
    });
    notifyListeners();
    return TripleMatchFeedbackCue.toggle;
  }

  TripleMatchFeedbackCue setHapticsEnabled(bool value) {
    if (_hapticsEnabled == value) {
      return TripleMatchFeedbackCue.none;
    }

    _hapticsEnabled = value;
    _message = value ? 'Haptic feedback on.' : 'Haptic feedback off.';
    _analytics.logEvent('settings_change', {
      'setting': 'haptic_feedback',
      'enabled': value,
    });
    notifyListeners();
    return TripleMatchFeedbackCue.toggle;
  }

  void logScreenView(String screenName) {
    _analytics.logEvent('screen_view', {'screen_name': screenName});
  }

  void logCurrentLevelStart({required String source}) {
    _analytics.logEvent('level_start', {
      ..._levelAnalyticsParameters(),
      'source': source,
    });
  }

  void restoreProgress({
    required int currentLevelIndex,
    required int highestUnlockedLevelIndex,
    required Set<int> completedLevelIds,
  }) {
    final boundedHighest = _minInt(
      _levels.length - 1,
      _maxInt(0, highestUnlockedLevelIndex),
    );
    final requestedCurrent = _maxInt(0, currentLevelIndex);

    _completedLevelIds
      ..clear()
      ..addAll(
        completedLevelIds.where(
          (levelId) => _levels.any((level) => level.id == levelId),
        ),
      );
    _highestUnlockedLevelIndex = _maxInt(
      boundedHighest,
      _highestUnlockedIndexFromCompletedLevels(),
    );
    _currentLevelIndex = _minInt(requestedCurrent, _highestUnlockedLevelIndex);
    _state = engine.start(_levels[_currentLevelIndex]);
    _trayHighWaterMark = 0;
    _message = _openingMessage;
    logCurrentLevelStart(source: 'restore');
    notifyListeners();
  }

  void _recordCurrentLevelCompleted() {
    _completedLevelIds.add(_state.level.id);
    if (!isLastLevel) {
      _highestUnlockedLevelIndex = _maxInt(
        _highestUnlockedLevelIndex,
        _currentLevelIndex + 1,
      );
    }
  }

  int _highestUnlockedIndexFromCompletedLevels() {
    var highest = 0;
    for (var index = 0; index < _levels.length; index++) {
      if (_completedLevelIds.contains(_levels[index].id)) {
        highest = _minInt(_levels.length - 1, index + 1);
      }
    }
    return highest;
  }

  Map<String, Object?> _levelAnalyticsParameters() {
    return {
      'level_id': _state.level.id,
      'level_number': currentLevelNumber,
      'total_levels': totalLevels,
      'move_count': _state.moves,
      'score': _state.score,
      'tray_size': _state.tray.size,
      'tray_capacity': _state.tray.capacity,
      'remaining_tiles': engine.boardTiles(_state).length,
      'completed_levels': completedLevelCount,
      'highest_unlocked_level': highestUnlockedLevelNumber,
    };
  }
}

int _minInt(int left, int right) => left < right ? left : right;

int _maxInt(int left, int right) => left > right ? left : right;
