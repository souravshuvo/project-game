import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/app/kids_land_app.dart';
import 'package:rapid_jump/core/audio/letter_audio_cue.dart';
import 'package:rapid_jump/features/tracing/data/progress_repository.dart';
import 'package:rapid_jump/features/tracing/domain/trace_definition.dart';

void main() {
  testWidgets('home opens the single letter-A tracing activity', (
    tester,
  ) async {
    final repository = RecordingProgressRepository();
    await tester.pumpWidget(_app(repository: repository));

    expect(find.byKey(const ValueKey('trace-a-button')), findsOneWidget);
    expect(find.text('Trace A'), findsOneWidget);
    expect(find.byKey(const ValueKey('trace-canvas')), findsNothing);

    await _openTrace(tester);

    expect(find.byKey(const ValueKey('trace-canvas')), findsOneWidget);
    expect(find.text('Start at the glowing dot'), findsOneWidget);
  });

  testWidgets('valid three-stroke gesture saves once and celebrates', (
    tester,
  ) async {
    final repository = RecordingProgressRepository();
    await tester.pumpWidget(_app(repository: repository));
    await _openTrace(tester);

    await _traceUppercaseA(tester);

    expect(repository.markCompleteCalls, 1);
    expect(repository.isLetterAComplete, isTrue);
    expect(find.byKey(const ValueKey('celebration-overlay')), findsOneWidget);

    // Extra pointer input cannot duplicate completion persistence.
    await tester.tapAt(
      tester.getCenter(find.byKey(const ValueKey('trace-canvas'))),
    );
    await tester.pump();
    expect(repository.markCompleteCalls, 1);
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

    expect(find.text('Nice try — find the glowing dot'), findsOneWidget);
    expect(repository.isLetterAComplete, isFalse);
    expect(repository.markCompleteCalls, 0);
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

    expect(find.byKey(const ValueKey('trace-a-button')), findsOneWidget);
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
    expect(repository.isLetterAComplete, isTrue);
    expect(find.byKey(const ValueKey('celebration-overlay')), findsOneWidget);
  });

  testWidgets('saved completion is visible after relaunch', (tester) async {
    final repository = RecordingProgressRepository(isLetterAComplete: true);
    await tester.pumpWidget(_app(repository: repository));

    expect(find.bySemanticsLabel('Trace letter A. Completed.'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
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

    final homeAction = tester.getSize(
      find.byKey(const ValueKey('trace-a-button')),
    );
    expect(homeAction.width, greaterThanOrEqualTo(64));
    expect(homeAction.height, greaterThanOrEqualTo(64));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byKey(const ValueKey('trace-a-button')));
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
}

Widget _app({
  required RecordingProgressRepository repository,
  LetterAudioCue? audioCue,
}) {
  return KidsLandApp(
    progressRepository: repository,
    audioCue: audioCue ?? RecordingAudioCue(),
  );
}

Future<void> _openTrace(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('trace-a-button')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _traceUppercaseA(WidgetTester tester) async {
  final definition = TraceDefinition.uppercaseA();
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
  }) : _isLetterAComplete = isLetterAComplete,
       _soundEnabled = soundEnabled;

  bool _isLetterAComplete;
  bool _soundEnabled;
  int markCompleteCalls = 0;

  @override
  bool get isLetterAComplete => _isLetterAComplete;

  @override
  bool get soundEnabled => _soundEnabled;

  @override
  Future<void> markLetterAComplete() async {
    markCompleteCalls++;
    _isLetterAComplete = true;
  }

  @override
  Future<void> reset() async {
    _isLetterAComplete = false;
    _soundEnabled = true;
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
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
}
