import 'package:flutter_test/flutter_test.dart';
import 'package:larder_labels/features/triple_match/application/triple_match_controller.dart';
import 'package:larder_labels/features/triple_match/data/local_level_pack.dart';
import 'package:larder_labels/features/triple_match/domain/level_state.dart';
import 'package:larder_labels/features/triple_match/domain/puzzle_engine.dart';
import 'package:larder_labels/shared/analytics/analytics_service.dart';

void main() {
  test('blocked taps report a useful message without mutating state', () {
    final controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
      initialLevelIndex: 2,
    );

    final cue = controller.selectTile('l3-honey-1');

    expect(controller.trayTileIds, isEmpty);
    expect(controller.message, contains('covered'));
    expect(cue, TripleMatchFeedbackCue.invalid);
  });

  test('restart resets controller state', () {
    final controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
    );

    expect(controller.selectTile('l1-jar-1'), TripleMatchFeedbackCue.select);
    expect(controller.restart(), TripleMatchFeedbackCue.restart);

    expect(controller.trayTileIds, isEmpty);
    expect(controller.moves, 0);
    expect(controller.score, 0);
    expect(controller.message, 'Level restarted.');
  });

  test('next level advances after a win', () {
    final controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
    );

    for (final tileId in prototypeLevel.solutionTileIds) {
      controller.selectTile(tileId);
    }

    expect(controller.currentLevelNumber, 1);
    expect(controller.status, LevelStatus.won);

    expect(controller.nextLevel(), TripleMatchFeedbackCue.next);

    expect(controller.currentLevelNumber, 2);
    expect(controller.trayTileIds, isEmpty);
    expect(controller.moves, 0);
  });

  test('next level does not advance while level is still playing', () {
    final controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
    );

    final cue = controller.nextLevel();

    expect(controller.currentLevelNumber, 1);
    expect(controller.status, LevelStatus.playing);
    expect(cue, TripleMatchFeedbackCue.none);
  });

  test('controller reports match, win, and settings feedback cues', () {
    final controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
    );

    controller.selectTile('l1-jar-1');
    controller.selectTile('l1-jar-2');

    expect(controller.selectTile('l1-jar-3'), TripleMatchFeedbackCue.match);
    expect(controller.setSoundEnabled(false), TripleMatchFeedbackCue.toggle);
    expect(controller.soundEnabled, isFalse);
    expect(controller.setHapticsEnabled(false), TripleMatchFeedbackCue.toggle);
    expect(controller.hapticsEnabled, isFalse);

    for (final tileId in prototypeLevel.solutionTileIds.skip(3)) {
      controller.selectTile(tileId);
    }

    expect(controller.status, LevelStatus.won);
  });

  test('progress tracks completed levels and restores safely', () {
    final controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
    );

    for (final tileId in prototypeLevel.solutionTileIds) {
      controller.selectTile(tileId);
    }

    expect(controller.completedLevelCount, 1);
    expect(controller.completedLevelIds, contains(prototypeLevel.id));
    expect(controller.highestUnlockedLevelNumber, 2);
    expect(
      controller.progressSummary,
      '1/$productionLevelCount shelves cleared',
    );
    expect(controller.nextLevel(), TripleMatchFeedbackCue.next);

    final restored = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
    );
    restored.restoreProgress(
      currentLevelIndex: controller.currentLevelIndex,
      highestUnlockedLevelIndex: controller.highestUnlockedLevelIndex,
      completedLevelIds: controller.completedLevelIds.toSet(),
    );

    expect(restored.currentLevelNumber, 2);
    expect(restored.completedLevelIds, contains(prototypeLevel.id));
    expect(restored.highestUnlockedLevelNumber, 2);
    expect(restored.status, LevelStatus.playing);
  });

  test('controller emits gameplay analytics events', () {
    final analytics = _RecordingAnalyticsService();
    final controller = TripleMatchController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
      analytics: analytics,
    );

    controller.logCurrentLevelStart(source: 'test');
    controller.selectTile('l1-jar-1');
    controller.selectTile('l1-jar-2');
    controller.selectTile('l1-jar-3');

    for (final tileId in prototypeLevel.solutionTileIds.skip(3)) {
      controller.selectTile(tileId);
    }

    expect(
      analytics.eventNames,
      containsAll([
        'level_start',
        'tile_select',
        'triple_clear',
        'level_complete',
      ]),
    );
    expect(
      analytics.events.last.parameters['tray_high_water'],
      lessThanOrEqualTo(controller.trayCapacity),
    );
  });
}

class _RecordingAnalyticsService implements AnalyticsService {
  final events = <_RecordedAnalyticsEvent>[];

  List<String> get eventNames => [for (final event in events) event.name];

  @override
  bool get isEnabled => true;

  @override
  void logEvent(String name, Map<String, Object?> parameters) {
    events.add(_RecordedAnalyticsEvent(name, parameters));
  }
}

class _RecordedAnalyticsEvent {
  const _RecordedAnalyticsEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object?> parameters;
}
