import '../domain/enemy_type.dart';
import '../domain/wave_definition.dart';

const prototypeWaveDefinitions = [
  WaveDefinition(
    number: 1,
    enemyCounts: {SignalEnemyType.driftNode: 8},
    spawnInterval: 0.85,
    maxActiveEnemies: 4,
  ),
  WaveDefinition(
    number: 2,
    enemyCounts: {SignalEnemyType.driftNode: 10, SignalEnemyType.pulseSeed: 2},
    spawnInterval: 0.78,
    maxActiveEnemies: 5,
  ),
  WaveDefinition(
    number: 3,
    enemyCounts: {SignalEnemyType.driftNode: 12, SignalEnemyType.pulseSeed: 4},
    spawnInterval: 0.68,
    maxActiveEnemies: 6,
  ),
];
