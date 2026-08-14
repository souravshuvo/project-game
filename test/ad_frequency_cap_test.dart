import 'package:flutter_test/flutter_test.dart';
import 'package:larder_labels/shared/ads/ad_frequency_cap.dart';

void main() {
  test('interstitial cap blocks failed and early levels', () {
    final cap = AdFrequencyCap();
    final now = DateTime(2026, 8, 14, 12);

    expect(
      cap.registerLevelEnd(levelNumber: 1, completed: false, now: now).reason,
      'failed_level',
    );
    expect(
      cap.registerLevelEnd(levelNumber: 1, completed: true, now: now).reason,
      'early_level',
    );
    expect(
      cap.registerLevelEnd(levelNumber: 2, completed: true, now: now).reason,
      'early_level',
    );
    expect(
      cap.registerLevelEnd(levelNumber: 3, completed: true, now: now).reason,
      'early_level',
    );
  });

  test(
    'interstitial cap allows level-end ads only after count and time caps',
    () {
      final cap = AdFrequencyCap();
      final now = DateTime(2026, 8, 14, 12);

      cap.registerLevelEnd(levelNumber: 1, completed: true, now: now);
      cap.registerLevelEnd(levelNumber: 2, completed: true, now: now);
      cap.registerLevelEnd(levelNumber: 3, completed: true, now: now);

      final allowed = cap.registerLevelEnd(
        levelNumber: 4,
        completed: true,
        now: now,
      );
      expect(allowed.allowed, isTrue);

      cap.recordInterstitialShown(now);

      expect(
        cap
            .registerLevelEnd(
              levelNumber: 5,
              completed: true,
              now: now.add(const Duration(minutes: 1)),
            )
            .reason,
        'level_frequency',
      );
      expect(
        cap
            .registerLevelEnd(
              levelNumber: 6,
              completed: true,
              now: now.add(const Duration(minutes: 2)),
            )
            .reason,
        'level_frequency',
      );
      expect(
        cap
            .registerLevelEnd(
              levelNumber: 7,
              completed: true,
              now: now.add(const Duration(minutes: 3)),
            )
            .reason,
        'time_frequency',
      );
      expect(
        cap
            .registerLevelEnd(
              levelNumber: 8,
              completed: true,
              now: now.add(const Duration(minutes: 5)),
            )
            .allowed,
        isTrue,
      );
    },
  );
}
