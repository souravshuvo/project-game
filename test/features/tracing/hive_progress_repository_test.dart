import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rapid_jump/features/tracing/data/hive_progress_repository.dart';

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
    expect(repository.isLetterAComplete, isFalse);
    expect(repository.soundEnabled, isTrue);
  });

  test('persists letter A completion and sound preference', () async {
    var repository = await HiveProgressRepository.create(box);

    await repository.markLetterAComplete();
    await repository.setSoundEnabled(false);
    await box.close();

    box = await Hive.openBox<dynamic>('progress_test');
    repository = await HiveProgressRepository.create(box);

    expect(repository.isLetterAComplete, isTrue);
    expect(repository.soundEnabled, isFalse);
  });

  test('reset removes progress and restores defaults', () async {
    final repository = await HiveProgressRepository.create(box);
    await repository.markLetterAComplete();
    await repository.setSoundEnabled(false);

    await repository.reset();

    expect(repository.isLetterAComplete, isFalse);
    expect(repository.soundEnabled, isTrue);
    expect(
      box.get('schemaVersion'),
      HiveProgressRepository.currentSchemaVersion,
    );
  });

  test('unknown schema data is discarded instead of reinterpreted', () async {
    await box.putAll(<String, Object>{
      'schemaVersion': 999,
      'letterAComplete': true,
      'unrecognizedChildData': 'discard me',
    });

    final repository = await HiveProgressRepository.create(box);

    expect(repository.isLetterAComplete, isFalse);
    expect(box.containsKey('unrecognizedChildData'), isFalse);
  });
}
