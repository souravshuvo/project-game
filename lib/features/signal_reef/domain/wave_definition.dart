import 'enemy_type.dart';

class WaveDefinition {
  const WaveDefinition({
    required this.number,
    required this.enemyCounts,
    required this.spawnInterval,
    required this.maxActiveEnemies,
  });

  final int number;
  final Map<SignalEnemyType, int> enemyCounts;
  final double spawnInterval;
  final int maxActiveEnemies;

  int get totalEnemies {
    return enemyCounts.values.fold(0, (total, count) => total + count);
  }

  List<SignalEnemyType> buildSpawnQueue() {
    final remaining = Map<SignalEnemyType, int>.of(enemyCounts);
    final queue = <SignalEnemyType>[];

    while (remaining.values.any((count) => count > 0)) {
      for (final type in SignalEnemyType.values) {
        final count = remaining[type] ?? 0;
        if (count <= 0) {
          continue;
        }

        queue.add(type);
        remaining[type] = count - 1;
      }
    }

    return queue;
  }
}
