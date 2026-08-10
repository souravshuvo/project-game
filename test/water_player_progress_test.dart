import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/data/water_progress_store.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/water_player_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('normalizes saved indexes to available and unlocked levels', () {
    final progress = WaterPlayerProgress(
      currentLevelIndex: 9,
      unlockedLevelIndex: 3,
      completedLevelIds: const {},
      bestMovesByLevel: const {},
      bestStarsByLevel: const {},
      soundEnabled: true,
      hapticsEnabled: true,
    ).normalized(5);

    expect(progress.currentLevelIndex, 3);
    expect(progress.unlockedLevelIndex, 3);
  });

  test('shared preferences water progress store roundtrips progress', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPreferencesWaterProgressStore();
    final progress = WaterPlayerProgress(
      currentLevelIndex: 2,
      unlockedLevelIndex: 4,
      completedLevelIds: const {1, 2},
      bestMovesByLevel: const {1: 3, 2: 6},
      bestStarsByLevel: const {1: 3, 2: 2},
      soundEnabled: false,
      hapticsEnabled: false,
    );

    await store.save(progress);
    final loaded = await store.load();

    expect(loaded.currentLevelIndex, 2);
    expect(loaded.unlockedLevelIndex, 4);
    expect(loaded.completedLevelIds, {1, 2});
    expect(loaded.bestMovesByLevel, {1: 3, 2: 6});
    expect(loaded.bestStarsByLevel, {1: 3, 2: 2});
    expect(loaded.soundEnabled, isFalse);
    expect(loaded.hapticsEnabled, isFalse);
  });
}
