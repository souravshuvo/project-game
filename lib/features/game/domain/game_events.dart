typedef GameEventSink =
    void Function(String name, Map<String, Object?> properties);

abstract final class GameEventNames {
  static const levelStart = 'level_start';
  static const levelRestart = 'level_restart';
  static const levelWin = 'level_win';
  static const levelLose = 'level_lose';
  static const gateSelected = 'gate_selected';
  static const enemyCollision = 'enemy_collision';
  static const enemyCleared = 'enemy_cleared';
  static const reserveEmpty = 'reserve_empty';
  static const crowdZero = 'crowd_zero';
}
