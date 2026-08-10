import 'package:pocket_observatory_xo/features/arrow_puzzle/data/puzzle_progress_store.dart';
import 'package:pocket_observatory_xo/features/arrow_puzzle/domain/player_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('normalizes saved indexes to available and unlocked levels', () {
    final progress = PlayerProgress(
      currentLevelIndex: 9,
      unlockedLevelIndex: 3,
      completedLevelIds: const {},
      bestMovesByLevel: const {},
      streakDays: 0,
      hintCount: 150,
      soundEnabled: true,
      hapticsEnabled: true,
    ).normalized(5);

    expect(progress.currentLevelIndex, 3);
    expect(progress.unlockedLevelIndex, 3);
    expect(progress.hintCount, 99);
  });

  test('shared preferences progress store roundtrips progress', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPreferencesPuzzleProgressStore();
    final progress = PlayerProgress(
      currentLevelIndex: 2,
      unlockedLevelIndex: 4,
      completedLevelIds: const {1, 2},
      bestMovesByLevel: const {1: 2, 2: 4},
      streakDays: 3,
      hintCount: 5,
      soundEnabled: false,
      hapticsEnabled: false,
      lastCompletionDate: '2026-08-02',
      lastHintClaimDate: '2026-08-02',
    );

    await store.save(progress);
    final loaded = await store.load();

    expect(loaded.currentLevelIndex, 2);
    expect(loaded.unlockedLevelIndex, 4);
    expect(loaded.completedLevelIds, {1, 2});
    expect(loaded.bestMovesByLevel, {1: 2, 2: 4});
    expect(loaded.streakDays, 3);
    expect(loaded.hintCount, 5);
    expect(loaded.soundEnabled, isFalse);
    expect(loaded.hapticsEnabled, isFalse);
    expect(loaded.lastCompletionDate, '2026-08-02');
    expect(loaded.lastHintClaimDate, '2026-08-02');
  });
}
