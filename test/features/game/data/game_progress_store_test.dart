import 'package:flutter_test/flutter_test.dart';
import 'package:project_game/features/game/data/game_progress_store.dart';

void main() {
  test('progress unlocks the next level and keeps best results', () {
    final levelOneClear = GameProgress.initial().recordWin(
      levelNumber: 1,
      score: 1200,
      stars: 2,
      levelCount: 30,
    );

    expect(levelOneClear.unlockedLevelNumber, 2);
    expect(levelOneClear.bestScoreFor(1), 1200);
    expect(levelOneClear.bestStarsFor(1), 2);

    final replay = levelOneClear.recordWin(
      levelNumber: 1,
      score: 900,
      stars: 1,
      levelCount: 30,
    );

    expect(replay.unlockedLevelNumber, 2);
    expect(replay.bestScoreFor(1), 1200);
    expect(replay.bestStarsFor(1), 2);
  });

  test('progress json clamps invalid saved level data', () {
    final progress = GameProgress.fromJson({
      'unlockedLevelNumber': 99,
      'bestStarsByLevel': {'1': 3, '40': 3},
      'bestScoresByLevel': {'1': 1400, 'nope': 99},
    }, levelCount: 30);

    expect(progress.unlockedLevelNumber, 30);
    expect(progress.bestStarsFor(1), 3);
    expect(progress.bestStarsFor(40), 0);
    expect(progress.bestScoreFor(1), 1400);
  });
}
