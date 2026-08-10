import 'level_definition.dart';
import 'tray_state.dart';

enum LevelStatus { playing, won, failed }

class LevelState {
  LevelState({
    required this.level,
    required this.tray,
    required Set<String> removedTileIds,
    required this.moves,
    required this.score,
    required this.status,
  }) : removedTileIds = Set.unmodifiable(removedTileIds);

  final LevelDefinition level;
  final TrayState tray;
  final Set<String> removedTileIds;
  final int moves;
  final int score;
  final LevelStatus status;

  bool get isPlaying => status == LevelStatus.playing;
  bool get isWon => status == LevelStatus.won;
  bool get isFailed => status == LevelStatus.failed;

  LevelState copyWith({
    TrayState? tray,
    Set<String>? removedTileIds,
    int? moves,
    int? score,
    LevelStatus? status,
  }) {
    return LevelState(
      level: level,
      tray: tray ?? this.tray,
      removedTileIds: removedTileIds ?? this.removedTileIds,
      moves: moves ?? this.moves,
      score: score ?? this.score,
      status: status ?? this.status,
    );
  }
}
