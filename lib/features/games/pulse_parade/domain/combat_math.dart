import 'dart:math' as math;

import 'level_definition.dart';

class CombatResult {
  const CombatResult({
    required this.sparkCount,
    required this.sparkLoss,
    required this.damagePerSpark,
    required this.enemyDefeated,
  });

  final int sparkCount;
  final int sparkLoss;
  final int damagePerSpark;
  final bool enemyDefeated;
}

CombatResult resolveStaticGlitchCombat({
  required int sparkCount,
  required PulsePolarity polarity,
  required PulseEnemyDefinition enemy,
}) {
  final damagePerSpark = polarity == enemy.weakness ? 2 : 1;
  final sparkLoss = math.min(
    sparkCount,
    (enemy.strength / damagePerSpark).ceil(),
  );
  final nextCount = math.max(0, sparkCount - sparkLoss);

  return CombatResult(
    sparkCount: nextCount,
    sparkLoss: sparkLoss,
    damagePerSpark: damagePerSpark,
    enemyDefeated:
        nextCount > 0 || sparkLoss * damagePerSpark >= enemy.strength,
  );
}
