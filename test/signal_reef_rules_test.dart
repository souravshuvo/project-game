import 'package:signal_reef_space_shooter/features/signal_reef/data/signal_reef_save_store.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/data/wave_definitions.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/domain/enemy_type.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/domain/save_data.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/domain/score_rules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('enemy and wave score rules match the prototype design', () {
    expect(SignalReefScoreRules.enemyDestroyed(SignalEnemyType.driftNode), 10);
    expect(SignalReefScoreRules.enemyDestroyed(SignalEnemyType.pulseSeed), 30);
    expect(SignalReefScoreRules.waveCleared(3), 150);
    expect(SignalReefScoreRules.winBonus, 500);
  });

  test('prototype waves are sequential and produce full spawn queues', () {
    expect(prototypeWaveDefinitions.map((wave) => wave.number), [1, 2, 3]);

    for (final wave in prototypeWaveDefinitions) {
      expect(wave.totalEnemies, greaterThan(0));
      expect(wave.buildSpawnQueue(), hasLength(wave.totalEnemies));
      expect(wave.spawnInterval, greaterThan(0));
      expect(wave.maxActiveEnemies, greaterThan(0));
    }
  });

  test('mixed waves distribute pulse seeds through the queue', () {
    final wave = prototypeWaveDefinitions[1];
    final queue = wave.buildSpawnQueue();

    expect(
      queue.where((type) => type == SignalEnemyType.pulseSeed),
      hasLength(2),
    );
    expect(queue.first, SignalEnemyType.driftNode);
    expect(queue[1], SignalEnemyType.pulseSeed);
  });

  test(
    'shared preferences save store roundtrips Signal Reef settings',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPreferencesSignalReefSaveStore();
      const data = SignalReefSaveData(
        bestScore: 740,
        soundEnabled: false,
        musicEnabled: false,
        hapticsEnabled: false,
        runsPlayed: 4,
      );

      await store.save(data);
      final loaded = await store.load();

      expect(loaded.bestScore, 740);
      expect(loaded.soundEnabled, isFalse);
      expect(loaded.musicEnabled, isFalse);
      expect(loaded.hapticsEnabled, isFalse);
      expect(loaded.runsPlayed, 4);
    },
  );
}
