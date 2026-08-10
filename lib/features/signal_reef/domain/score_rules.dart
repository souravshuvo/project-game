import 'enemy_type.dart';

class SignalReefScoreRules {
  const SignalReefScoreRules._();

  static const winBonus = 500;

  static int enemyDestroyed(SignalEnemyType type) => type.scoreValue;

  static int waveCleared(int waveNumber) => 50 * waveNumber;
}
