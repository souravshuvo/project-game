import 'package:signal_reef_space_shooter/features/signal_reef/data/signal_reef_save_store.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/data/wave_definitions.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/domain/enemy_type.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/domain/save_data.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/domain/score_rules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('enemy and wave score rules match the production design', () {
    expect(SignalReefScoreRules.enemyDestroyed(SignalEnemyType.driftNode), 10);
    expect(SignalReefScoreRules.enemyDestroyed(SignalEnemyType.pulseSeed), 30);
    expect(SignalReefScoreRules.waveCleared(3), 150);
    expect(SignalReefScoreRules.winBonus, 500);
  });

  test('production waves meet the v1 content target', () {
    expect(productionWaveDefinitions, hasLength(20));
    expect(
      productionWaveDefinitions.map((wave) => wave.number),
      List.generate(20, (index) => index + 1),
    );

    var previousTotal = 0;
    var previousSpawnInterval = double.infinity;
    for (final wave in productionWaveDefinitions) {
      expect(wave.totalEnemies, greaterThan(0));
      expect(wave.buildSpawnQueue(), hasLength(wave.totalEnemies));
      expect(wave.totalEnemies, greaterThanOrEqualTo(previousTotal));
      expect(wave.spawnInterval, greaterThanOrEqualTo(0.46));
      expect(wave.spawnInterval, lessThanOrEqualTo(previousSpawnInterval));
      expect(wave.maxActiveEnemies, inInclusiveRange(4, 8));
      expect(wave.maxActiveEnemies, lessThanOrEqualTo(wave.totalEnemies));

      if (wave.number >= 3) {
        expect(wave.enemyCounts[SignalEnemyType.pulseSeed], greaterThan(0));
      }

      previousTotal = wave.totalEnemies;
      previousSpawnInterval = wave.spawnInterval;
    }
  });

  test('mixed waves distribute pulse seeds through the queue', () {
    final wave = productionWaveDefinitions[2];
    final queue = wave.buildSpawnQueue();

    expect(
      queue.where((type) => type == SignalEnemyType.pulseSeed),
      hasLength(2),
    );
    expect(queue.first, SignalEnemyType.driftNode);
    expect(queue[1], SignalEnemyType.pulseSeed);
  });

  test(
    'shared preferences save store roundtrips Signal Reef progress and settings',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPreferencesSignalReefSaveStore();
      const data = SignalReefSaveData(
        bestScore: 740,
        bestWaveReached: 14,
        soundEnabled: false,
        hapticsEnabled: false,
        runsPlayed: 4,
      );

      await store.save(data);
      final loaded = await store.load();

      expect(loaded.bestScore, 740);
      expect(loaded.bestWaveReached, 14);
      expect(loaded.soundEnabled, isFalse);
      expect(loaded.hapticsEnabled, isFalse);
      expect(loaded.runsPlayed, 4);
    },
  );
}
