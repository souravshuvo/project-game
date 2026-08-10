import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rapid_jump/features/tracing/data/hive_progress_repository.dart';
import 'package:rapid_jump/features/tracing/data/progress_repository.dart';

void main() {
  late Directory tempDirectory;
  late Box<dynamic> box;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'kidsland_progress_test_',
    );
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<dynamic>('progress_test');
  });

  tearDown(() async {
    await Hive.close();
    if (tempDirectory.existsSync()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('seeds privacy-safe defaults for a new box', () async {
    final repository = await HiveProgressRepository.create(box);

    expect(
      box.get('schemaVersion'),
      HiveProgressRepository.currentSchemaVersion,
    );
    expect(repository.completedGameIds, isEmpty);
    expect(repository.dewBubbleHighestUnlockedLevelIndex, 0);
    expect(repository.dewBubbleBestScore('dew-1'), 0);
    expect(repository.dewBubbleBestStars('dew-1'), 0);
    expect(repository.soundEnabled, isTrue);
  });

  test('persists sound preference', () async {
    var repository = await HiveProgressRepository.create(box);

    await repository.setSoundEnabled(false);
    await box.close();

    box = await Hive.openBox<dynamic>('progress_test');
    repository = await HiveProgressRepository.create(box);

    expect(repository.soundEnabled, isFalse);
  });

  test('persists dew bubble unlocks, best scores, and best stars', () async {
    var repository = await HiveProgressRepository.create(box);

    await repository.recordDewBubbleLevelWin(
      levelIndex: 0,
      levelId: 'dew-1',
      score: 320,
      stars: 2,
    );
    await repository.recordDewBubbleLevelWin(
      levelIndex: 0,
      levelId: 'dew-1',
      score: 280,
      stars: 1,
    );
    await repository.recordDewBubbleLevelWin(
      levelIndex: 1,
      levelId: 'dew-2',
      score: 410,
      stars: 3,
    );
    await repository.markGameComplete(dewBubbleGameId);
    await box.close();

    box = await Hive.openBox<dynamic>('progress_test');
    repository = await HiveProgressRepository.create(box);

    expect(repository.completedGameIds, {dewBubbleGameId});
    expect(repository.dewBubbleHighestUnlockedLevelIndex, 2);
    expect(repository.dewBubbleBestScore('dew-1'), 320);
    expect(repository.dewBubbleBestStars('dew-1'), 2);
    expect(repository.dewBubbleBestScore('dew-2'), 410);
    expect(repository.dewBubbleBestStars('dew-2'), 3);
  });

  test('migration removes completed games that are no longer active', () async {
    await box.putAll(<String, Object>{
      'schemaVersion': 3,
      'completedGameIds': <String>[
        'letter-tracing',
        dewBubbleGameId,
        'memory-match',
      ],
      'dewBubbleHighestUnlockedLevelIndex': 2,
      'dewBubbleBestScores': <String, int>{'dew-1': 320},
      'dewBubbleBestStars': <String, int>{'dew-1': 3},
      'soundEnabled': false,
    });

    final repository = await HiveProgressRepository.create(box);

    expect(
      box.get('schemaVersion'),
      HiveProgressRepository.currentSchemaVersion,
    );
    expect(repository.completedGameIds, {dewBubbleGameId});
    expect(repository.dewBubbleHighestUnlockedLevelIndex, 2);
    expect(repository.dewBubbleBestScore('dew-1'), 320);
    expect(repository.dewBubbleBestStars('dew-1'), 3);
    expect(repository.soundEnabled, isFalse);
  });

  test('reset removes progress and restores defaults', () async {
    final repository = await HiveProgressRepository.create(box);
    await repository.markGameComplete(dewBubbleGameId);
    await repository.setSoundEnabled(false);
    await repository.recordDewBubbleLevelWin(
      levelIndex: 0,
      levelId: 'dew-1',
      score: 320,
      stars: 2,
    );

    await repository.reset();

    expect(repository.completedGameIds, isEmpty);
    expect(repository.soundEnabled, isTrue);
    expect(repository.dewBubbleHighestUnlockedLevelIndex, 0);
    expect(repository.dewBubbleBestScore('dew-1'), 0);
    expect(repository.dewBubbleBestStars('dew-1'), 0);
    expect(
      box.get('schemaVersion'),
      HiveProgressRepository.currentSchemaVersion,
    );
  });

  test('unknown schema data is discarded instead of reinterpreted', () async {
    await box.putAll(<String, Object>{
      'schemaVersion': 999,
      'completedGameIds': <String>['letter-tracing'],
      'unrecognizedChildData': 'discard me',
    });

    final repository = await HiveProgressRepository.create(box);

    expect(repository.completedGameIds, isEmpty);
    expect(box.containsKey('unrecognizedChildData'), isFalse);
  });
}
