import 'dart:math' as math;
import 'dart:ui';

const gameWorldSize = Size(360, 720);

enum GamePhase { ready, playing, won, lost }

enum GateKind { add, multiply, subtract, wide, tight }

enum EnemyShape { cluster, wideLine, narrowBlock }

class GateEffect {
  const GateEffect.add(this.value) : kind = GateKind.add;

  const GateEffect.multiply(this.value) : kind = GateKind.multiply;

  const GateEffect.subtract(this.value) : kind = GateKind.subtract;

  const GateEffect.wide() : kind = GateKind.wide, value = 0;

  const GateEffect.tight() : kind = GateKind.tight, value = 0;

  final GateKind kind;
  final int value;

  String get label {
    return switch (kind) {
      GateKind.add => '+$value',
      GateKind.multiply => 'x$value',
      GateKind.subtract => '-$value',
      GateKind.wide => 'Wide',
      GateKind.tight => 'Tight',
    };
  }

  int applyTo(int activeCount, int maxCrowd) {
    final nextCount = switch (kind) {
      GateKind.add => activeCount + value,
      GateKind.multiply => activeCount * value,
      GateKind.subtract => activeCount - value,
      GateKind.wide || GateKind.tight => activeCount,
    };

    return nextCount.clamp(0, maxCrowd).toInt();
  }
}

class GateDefinition {
  const GateDefinition({
    required this.id,
    required this.center,
    required this.size,
    required this.effect,
    this.choiceGroup,
  });

  final String id;
  final Offset center;
  final Size size;
  final GateEffect effect;
  final String? choiceGroup;

  Rect get bounds =>
      Rect.fromCenter(center: center, width: size.width, height: size.height);
}

class EnemyDefinition {
  const EnemyDefinition({
    required this.id,
    required this.center,
    required this.size,
    required this.strength,
    this.shape = EnemyShape.cluster,
  });

  final String id;
  final Offset center;
  final Size size;
  final int strength;
  final EnemyShape shape;

  Rect get bounds =>
      Rect.fromCenter(center: center, width: size.width, height: size.height);
}

class LevelDefinition {
  const LevelDefinition({
    required this.id,
    required this.number,
    required this.name,
    required this.startReserve,
    required this.launchRate,
    required this.unitSpeed,
    required this.maxCrowd,
    required this.visualCap,
    required this.finishY,
    required this.gates,
    required this.enemies,
  });

  final String id;
  final int number;
  final String name;
  final int startReserve;
  final double launchRate;
  final double unitSpeed;
  final int maxCrowd;
  final int visualCap;
  final double finishY;
  final List<GateDefinition> gates;
  final List<EnemyDefinition> enemies;

  int get enemyStrengthTotal {
    return enemies.fold<int>(0, (total, enemy) => total + enemy.strength);
  }
}

class MarbleUnit {
  MarbleUnit({
    required this.id,
    required this.x,
    required this.y,
    required this.slot,
  });

  final int id;
  double x;
  double y;
  final double slot;

  Offset get position => Offset(x, y);
}

class EnemyState {
  EnemyState(this.definition) : remainingStrength = definition.strength;

  final EnemyDefinition definition;
  int remainingStrength;

  bool get defeated => remainingStrength <= 0;
}

class GameSnapshot {
  const GameSnapshot({
    required this.phase,
    required this.levelId,
    required this.levelNumber,
    required this.levelCount,
    required this.levelName,
    required this.reserveCount,
    required this.activeCount,
    required this.enemyStrength,
    required this.score,
    required this.stars,
    required this.elapsedSeconds,
    required this.message,
  });

  final GamePhase phase;
  final String levelId;
  final int levelNumber;
  final int levelCount;
  final String levelName;
  final int reserveCount;
  final int activeCount;
  final int enemyStrength;
  final int score;
  final int stars;
  final double elapsedSeconds;
  final String message;

  bool get isFinished => phase == GamePhase.won || phase == GamePhase.lost;
  bool get hasNextLevel => phase == GamePhase.won && levelNumber < levelCount;
}

class ScoreResult {
  const ScoreResult({required this.score, required this.stars});

  final int score;
  final int stars;
}

ScoreResult scoreLevel({
  required LevelDefinition level,
  required int remainingCount,
  required double elapsedSeconds,
}) {
  final timeBonus = math.max(0, 300 - elapsedSeconds.floor() * 4);
  final score = 1000 + remainingCount * 10 + timeBonus;
  final remainingRatio = remainingCount / math.max(1, level.startReserve);
  final stars = remainingRatio >= 1.1
      ? 3
      : remainingRatio >= 0.55
      ? 2
      : 1;

  return ScoreResult(score: score, stars: stars);
}
