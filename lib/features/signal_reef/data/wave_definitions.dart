import '../domain/enemy_type.dart';
import '../domain/wave_definition.dart';

const productionWaveDefinitions = [
  WaveDefinition(
    number: 1,
    enemyCounts: {SignalEnemyType.driftNode: 8},
    spawnInterval: 0.85,
    maxActiveEnemies: 4,
  ),
  WaveDefinition(
    number: 2,
    enemyCounts: {SignalEnemyType.driftNode: 10},
    spawnInterval: 0.82,
    maxActiveEnemies: 4,
  ),
  WaveDefinition(
    number: 3,
    enemyCounts: {SignalEnemyType.driftNode: 10, SignalEnemyType.pulseSeed: 2},
    spawnInterval: 0.78,
    maxActiveEnemies: 5,
  ),
  WaveDefinition(
    number: 4,
    enemyCounts: {SignalEnemyType.driftNode: 12, SignalEnemyType.pulseSeed: 2},
    spawnInterval: 0.76,
    maxActiveEnemies: 5,
  ),
  WaveDefinition(
    number: 5,
    enemyCounts: {SignalEnemyType.driftNode: 12, SignalEnemyType.pulseSeed: 3},
    spawnInterval: 0.74,
    maxActiveEnemies: 5,
  ),
  WaveDefinition(
    number: 6,
    enemyCounts: {SignalEnemyType.driftNode: 13, SignalEnemyType.pulseSeed: 4},
    spawnInterval: 0.72,
    maxActiveEnemies: 5,
  ),
  WaveDefinition(
    number: 7,
    enemyCounts: {SignalEnemyType.driftNode: 14, SignalEnemyType.pulseSeed: 4},
    spawnInterval: 0.70,
    maxActiveEnemies: 6,
  ),
  WaveDefinition(
    number: 8,
    enemyCounts: {SignalEnemyType.driftNode: 14, SignalEnemyType.pulseSeed: 5},
    spawnInterval: 0.68,
    maxActiveEnemies: 6,
  ),
  WaveDefinition(
    number: 9,
    enemyCounts: {SignalEnemyType.driftNode: 15, SignalEnemyType.pulseSeed: 5},
    spawnInterval: 0.66,
    maxActiveEnemies: 6,
  ),
  WaveDefinition(
    number: 10,
    enemyCounts: {SignalEnemyType.driftNode: 16, SignalEnemyType.pulseSeed: 6},
    spawnInterval: 0.64,
    maxActiveEnemies: 6,
  ),
  WaveDefinition(
    number: 11,
    enemyCounts: {SignalEnemyType.driftNode: 16, SignalEnemyType.pulseSeed: 7},
    spawnInterval: 0.62,
    maxActiveEnemies: 7,
  ),
  WaveDefinition(
    number: 12,
    enemyCounts: {SignalEnemyType.driftNode: 17, SignalEnemyType.pulseSeed: 7},
    spawnInterval: 0.60,
    maxActiveEnemies: 7,
  ),
  WaveDefinition(
    number: 13,
    enemyCounts: {SignalEnemyType.driftNode: 18, SignalEnemyType.pulseSeed: 8},
    spawnInterval: 0.58,
    maxActiveEnemies: 7,
  ),
  WaveDefinition(
    number: 14,
    enemyCounts: {SignalEnemyType.driftNode: 18, SignalEnemyType.pulseSeed: 9},
    spawnInterval: 0.56,
    maxActiveEnemies: 7,
  ),
  WaveDefinition(
    number: 15,
    enemyCounts: {SignalEnemyType.driftNode: 19, SignalEnemyType.pulseSeed: 9},
    spawnInterval: 0.54,
    maxActiveEnemies: 7,
  ),
  WaveDefinition(
    number: 16,
    enemyCounts: {SignalEnemyType.driftNode: 20, SignalEnemyType.pulseSeed: 10},
    spawnInterval: 0.52,
    maxActiveEnemies: 8,
  ),
  WaveDefinition(
    number: 17,
    enemyCounts: {SignalEnemyType.driftNode: 20, SignalEnemyType.pulseSeed: 11},
    spawnInterval: 0.50,
    maxActiveEnemies: 8,
  ),
  WaveDefinition(
    number: 18,
    enemyCounts: {SignalEnemyType.driftNode: 21, SignalEnemyType.pulseSeed: 11},
    spawnInterval: 0.49,
    maxActiveEnemies: 8,
  ),
  WaveDefinition(
    number: 19,
    enemyCounts: {SignalEnemyType.driftNode: 22, SignalEnemyType.pulseSeed: 12},
    spawnInterval: 0.48,
    maxActiveEnemies: 8,
  ),
  WaveDefinition(
    number: 20,
    enemyCounts: {SignalEnemyType.driftNode: 24, SignalEnemyType.pulseSeed: 12},
    spawnInterval: 0.46,
    maxActiveEnemies: 8,
  ),
];
