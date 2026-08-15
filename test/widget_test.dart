import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidsland/app/kids_land_app.dart';
import 'package:kidsland/core/ads/app_ads_controller.dart';
import 'package:kidsland/core/analytics/game_analytics.dart';
import 'package:kidsland/core/audio/letter_audio_cue.dart';
import 'package:kidsland/features/parent/presentation/parent_corner_screen.dart';
import 'package:kidsland/features/tracing/data/progress_repository.dart';
import 'package:kidsland/features/tracing/domain/trace_definition.dart';

void main() {
  testWidgets('home opens letter tracing and the letter-A activity', (
    tester,
  ) async {
    final repository = RecordingProgressRepository();
    await tester.pumpWidget(_app(repository: repository));
    await _revealLetterGameCard(tester);

    expect(
      find.byKey(const ValueKey('game-card-letter-tracing')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('game-card-letter-tracing')),
        matching: find.text('Letter Tracing'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('trace-canvas')), findsNothing);

    await _openTrace(tester);

    expect(find.byKey(const ValueKey('trace-canvas')), findsOneWidget);
    expect(find.text('Start at the glowing dot'), findsOneWidget);
  });

  testWidgets('adventure mix starts quick play from the hub', (tester) async {
    final repository = RecordingProgressRepository();
    await tester.pumpWidget(_app(repository: repository));

    expect(find.byKey(const ValueKey('adventure-mix-panel')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('adventure-start-run')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Balloon Pop'), findsOneWidget);
    expect(find.byKey(const ValueKey('balloon-grid')), findsOneWidget);
  });

  testWidgets('badge book gives the child a next unlock goal', (tester) async {
    final repository = RecordingProgressRepository();
    await tester.pumpWidget(_app(repository: repository));

    await tester.dragUntilVisible(
      find.byKey(const ValueKey('reward-album-panel')),
      find.byType(CustomScrollView),
      const Offset(0, -260),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('reward-album-panel')), findsOneWidget);
    expect(find.text('Badge Book'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('reward-unlock-next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Letter Tracing'), findsOneWidget);
    expect(find.byKey(const ValueKey('trace-entry-grid')), findsOneWidget);
  });

  testWidgets('completed logic run can play the next game', (tester) async {
    final repository = RecordingProgressRepository();
    final adsController = RecordingAppAdsController();
    await tester.pumpWidget(
      _app(repository: repository, adsController: adsController),
    );

    await _openGameCard(tester, 'counting');
    expect(find.text('Count & Choose'), findsOneWidget);

    for (var answer = 1; answer <= 10; answer += 1) {
      final answerFinder = find.text('$answer').last;
      await tester.ensureVisible(answerFinder);
      await tester.pump();
      await tester.tap(answerFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      if (answer < 10) {
        final nextGroupFinder = find.text('Next group');
        await tester.ensureVisible(nextGroupFinder);
        await tester.pump();
        await tester.tap(nextGroupFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
      }
    }

    final playNextFinder = find.textContaining('Play next: Color Sorting');
    await tester.ensureVisible(playNextFinder);
    await tester.pump();
    expect(playNextFinder, findsOneWidget);
    await tester.tap(playNextFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Color Sort'), findsOneWidget);
    expect(repository.isGameComplete('counting'), isTrue);
    expect(adsController.completedBreakCalls, 0);
  });

  testWidgets('letter tracing saves entry progress without ending at C', (
    tester,
  ) async {
    final repository = RecordingProgressRepository();
    await tester.pumpWidget(_app(repository: repository));

    await _openLetterTracingMenu(tester);
    await _openTraceEntry(tester, 'letter-a');
    await _traceDefinition(tester, TraceDefinition.uppercaseA());

    expect(find.byKey(const ValueKey('celebration-overlay')), findsOneWidget);
    expect(repository.markCompleteCalls, 0);

    await _returnToTraceMenu(tester);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('trace-entry-letter-a')),
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsOneWidget,
    );

    await _openTraceEntry(tester, 'letter-b');
    await _traceDefinition(tester, TraceDefinition.uppercaseB());
    await _returnToTraceMenu(tester);
    expect(repository.markCompleteCalls, 0);

    await _openTraceEntry(tester, 'letter-c');
    await _traceDefinition(tester, TraceDefinition.uppercaseC());

    expect(repository.markCompleteCalls, 0);
    expect(repository.isLetterAComplete, isFalse);
    expect(repository.completedContentIds('letter-tracing'), {
      'letter-a',
      'letter-b',
      'letter-c',
    });
    expect(find.byKey(const ValueKey('celebration-overlay')), findsOneWidget);

    // Extra pointer input cannot duplicate completion persistence.
    await tester.tapAt(
      tester.getCenter(find.byKey(const ValueKey('trace-canvas'))),
    );
    await tester.pump();
    expect(repository.markCompleteCalls, 0);
  });

  testWidgets('off-path touch gives a gentle hint and cannot complete', (
    tester,
  ) async {
    final repository = RecordingProgressRepository();
    await tester.pumpWidget(_app(repository: repository));
    await _openTrace(tester);

    final canvas = tester.getRect(find.byKey(const ValueKey('trace-canvas')));
    await tester.tapAt(canvas.center);
    await tester.pump();

    expect(find.text('Nice try - find the glowing dot'), findsOneWidget);
    expect(repository.isLetterAComplete, isFalse);
    expect(repository.markCompleteCalls, 0);
  });

  testWidgets('trace celebration can continue to the next symbol', (
    tester,
  ) async {
    final repository = RecordingProgressRepository();
    await tester.pumpWidget(_app(repository: repository));

    await _openLetterTracingMenu(tester);
    await _openTraceEntry(tester, 'letter-a');
    await _traceDefinition(tester, TraceDefinition.uppercaseA());

    expect(find.byKey(const ValueKey('celebration-next')), findsOneWidget);
    expect(find.text('Play Next: B'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('celebration-next')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Trace B'), findsOneWidget);
    expect(find.byKey(const ValueKey('trace-canvas')), findsOneWidget);
    expect(repository.completedContentIds('letter-tracing'), {'letter-a'});
  });

  testWidgets('reset clears only the partial attempt', (tester) async {
    final repository = RecordingProgressRepository(isLetterAComplete: true);
    await tester.pumpWidget(_app(repository: repository));
    await _openTrace(tester);

    final definition = TraceDefinition.uppercaseA();
    final canvas = tester.getRect(find.byKey(const ValueKey('trace-canvas')));
    final partial = await tester.startGesture(
      _onCanvas(canvas, definition.strokes.first.start),
    );
    await partial.moveTo(
      _onCanvas(canvas, definition.strokes.first.checkpoints[1].point),
    );
    await partial.up();
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('reset-trace-control')));
    await tester.pump();

    expect(find.text('Start at the glowing dot'), findsOneWidget);
    expect(repository.isLetterAComplete, isTrue);
    expect(repository.markCompleteCalls, 0);
  });

  testWidgets('back during a partial trace does not save completion', (
    tester,
  ) async {
    final repository = RecordingProgressRepository();
    await tester.pumpWidget(_app(repository: repository));
    await _openTrace(tester);

    final definition = TraceDefinition.uppercaseA();
    final canvas = tester.getRect(find.byKey(const ValueKey('trace-canvas')));
    final partial = await tester.startGesture(
      _onCanvas(canvas, definition.strokes.first.start),
    );
    await partial.moveTo(
      _onCanvas(canvas, definition.strokes.first.checkpoints[1].point),
    );
    await partial.up();

    await tester.tap(find.byKey(const ValueKey('home-control')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('trace-entry-grid')), findsOneWidget);
    expect(repository.markCompleteCalls, 0);
    expect(repository.isLetterAComplete, isFalse);
  });

  testWidgets('audio hook failure never blocks tracing completion', (
    tester,
  ) async {
    final repository = RecordingProgressRepository();
    await tester.pumpWidget(
      _app(
        repository: repository,
        audioCue: RecordingAudioCue(shouldFail: true),
      ),
    );
    await _openTrace(tester);

    await _traceUppercaseA(tester);

    expect(tester.takeException(), isNull);
    expect(repository.markCompleteCalls, 0);
    expect(find.byKey(const ValueKey('celebration-overlay')), findsOneWidget);
  });

  testWidgets('saved completion is visible after relaunch', (tester) async {
    final repository = RecordingProgressRepository(isLetterAComplete: true);
    await tester.pumpWidget(_app(repository: repository));
    await _revealLetterGameCard(tester);

    expect(
      find.byKey(const ValueKey('game-card-letter-tracing')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('game-card-letter-tracing')),
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('small high-text-scale layout keeps child controls usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final repository = RecordingProgressRepository();
    await tester.pumpWidget(_app(repository: repository));

    await _revealLetterGameCard(tester);

    final homeAction = tester.getSize(
      find.byKey(const ValueKey('game-card-letter-tracing')),
    );
    expect(homeAction.width, greaterThanOrEqualTo(64));
    expect(homeAction.height, greaterThanOrEqualTo(64));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(
      find.byKey(const ValueKey('game-card-letter-tracing')),
    );
    await tester.pump();
    await _openTrace(tester);

    for (final key in const [
      ValueKey('home-control'),
      ValueKey('replay-audio-control'),
      ValueKey('reset-trace-control'),
    ]) {
      final size = tester.getSize(find.byKey(key));
      expect(size.width, greaterThanOrEqualTo(64));
      expect(size.height, greaterThanOrEqualTo(64));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('parent settings cards fit compact screens', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = RecordingProgressRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ParentCornerScreen(
          progressRepository: repository,
          totalGames: 10,
          analytics: const NoopGameAnalytics(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Sound feedback'), findsOneWidget);
    expect(find.text('Haptic feedback'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({
  required RecordingProgressRepository repository,
  LetterAudioCue? audioCue,
  AppAdsController? adsController,
}) {
  return KidsLandApp(
    progressRepository: repository,
    audioCue: audioCue ?? RecordingAudioCue(),
    analytics: const NoopGameAnalytics(),
    adsController: adsController ?? const NoopAppAdsController(),
  );
}

Future<void> _openTrace(WidgetTester tester) async {
  await _openLetterTracingMenu(tester);
  await _openTraceEntry(tester, 'letter-a');
}

Future<void> _openLetterTracingMenu(WidgetTester tester) async {
  await _openGameCard(tester, 'letter-tracing');
}

Future<void> _openGameCard(WidgetTester tester, String gameId) async {
  await _revealGameCard(tester, gameId);
  await tester.tap(find.byKey(ValueKey('game-card-$gameId')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _revealLetterGameCard(WidgetTester tester) async {
  await _revealGameCard(tester, 'letter-tracing');
}

Future<void> _revealGameCard(WidgetTester tester, String gameId) async {
  await tester.dragUntilVisible(
    find.byKey(ValueKey('game-card-$gameId')),
    find.byType(CustomScrollView),
    const Offset(0, -300),
  );
  await tester.pump();
}

Future<void> _openTraceEntry(WidgetTester tester, String entryId) async {
  await tester.ensureVisible(find.byKey(ValueKey('trace-entry-$entryId')));
  await tester.pump();
  await tester.tap(find.byKey(ValueKey('trace-entry-$entryId')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _traceUppercaseA(WidgetTester tester) async {
  await _traceDefinition(tester, TraceDefinition.uppercaseA());
}

Future<void> _traceDefinition(
  WidgetTester tester,
  TraceDefinition definition,
) async {
  final canvas = tester.getRect(find.byKey(const ValueKey('trace-canvas')));

  for (final stroke in definition.strokes) {
    final gesture = await tester.startGesture(_onCanvas(canvas, stroke.start));
    for (final checkpoint in stroke.checkpoints.skip(1)) {
      await gesture.moveTo(_onCanvas(canvas, checkpoint.point));
    }
    await gesture.up();
    await tester.pump();
  }

  await tester.pump();
}

Future<void> _returnToTraceMenu(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('celebration-home')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Offset _onCanvas(Rect canvas, TracePoint point) {
  return Offset(
    canvas.left + (point.x * canvas.width),
    canvas.top + (point.y * canvas.height),
  );
}

class RecordingProgressRepository implements ProgressRepository {
  RecordingProgressRepository({
    bool isLetterAComplete = false,
    bool soundEnabled = true,
    bool hapticsEnabled = true,
  }) : _completedGameIds = <String>{if (isLetterAComplete) letterTracingGameId},
       _soundEnabled = soundEnabled,
       _hapticsEnabled = hapticsEnabled;

  final Set<String> _completedGameIds;
  final Set<String> _completedContentKeys = <String>{};
  bool _soundEnabled;
  bool _hapticsEnabled;
  int markCompleteCalls = 0;

  @override
  Set<String> get completedGameIds => Set.unmodifiable(_completedGameIds);

  @override
  bool get isLetterAComplete => isGameComplete(letterTracingGameId);

  @override
  Set<String> completedContentIds(String gameId) {
    final prefix = '$gameId::';
    return Set.unmodifiable(
      _completedContentKeys
          .where((key) => key.startsWith(prefix))
          .map((key) => key.substring(prefix.length)),
    );
  }

  @override
  bool get soundEnabled => _soundEnabled;

  @override
  bool get hapticsEnabled => _hapticsEnabled;

  @override
  Future<void> markLetterAComplete() async {
    await markGameComplete(letterTracingGameId);
  }

  @override
  Future<void> markGameComplete(String gameId) async {
    markCompleteCalls++;
    _completedGameIds.add(gameId);
  }

  @override
  Future<void> markContentComplete(String gameId, String contentId) async {
    _completedContentKeys.add('$gameId::$contentId');
  }

  @override
  bool isGameComplete(String gameId) {
    return _completedGameIds.contains(gameId);
  }

  @override
  bool isContentComplete(String gameId, String contentId) {
    return _completedContentKeys.contains('$gameId::$contentId');
  }

  @override
  Future<void> reset() async {
    _completedGameIds.clear();
    _completedContentKeys.clear();
    _soundEnabled = true;
    _hapticsEnabled = true;
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
  }

  @override
  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
  }
}

class RecordingAppAdsController implements AppAdsController {
  int completedBreakCalls = 0;
  bool disposed = false;

  @override
  bool get isEnabled => true;

  @override
  Widget buildHomeBanner() => const SizedBox.shrink();

  @override
  void preloadInterstitial() {}

  @override
  Future<void> recordCompletedGameBreak({
    required String gameId,
    required String gameTitle,
    required int completedGames,
    required int totalGames,
    required int gameDurationMs,
  }) async {
    completedBreakCalls += 1;
  }

  @override
  void dispose() {
    disposed = true;
  }
}

class RecordingAudioCue implements LetterAudioCue {
  RecordingAudioCue({this.shouldFail = false});

  final bool shouldFail;

  @override
  Future<void> playLetterA() async {
    if (shouldFail) {
      throw StateError('Test audio failure');
    }
  }

  @override
  Future<void> playSuccess() async {
    if (shouldFail) {
      throw StateError('Test audio failure');
    }
  }

  @override
  Future<void> playTap() async {
    if (shouldFail) {
      throw StateError('Test audio failure');
    }
  }

  @override
  Future<void> playValidAction() async {
    if (shouldFail) {
      throw StateError('Test audio failure');
    }
  }

  @override
  Future<void> playInvalidAction() async {
    if (shouldFail) {
      throw StateError('Test audio failure');
    }
  }

  @override
  Future<void> playReward() async {
    if (shouldFail) {
      throw StateError('Test audio failure');
    }
  }

  @override
  Future<void> playWin() async {
    if (shouldFail) {
      throw StateError('Test audio failure');
    }
  }

  @override
  Future<void> playRestart() async {
    if (shouldFail) {
      throw StateError('Test audio failure');
    }
  }
}
