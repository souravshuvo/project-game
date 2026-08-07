import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/features/tracing/application/trace_controller.dart';
import 'package:rapid_jump/features/tracing/domain/trace_definition.dart';

void main() {
  group('uppercase A definition', () {
    test('uses normalized geometry and an explicit three-stroke order', () {
      final definition = TraceDefinition.uppercaseA();

      expect(definition.symbol, 'A');
      expect(definition.strokes.map((stroke) => stroke.id), [
        'left-leg',
        'right-leg',
        'crossbar',
      ]);
      expect(definition.checkpointCount, 15);

      for (final stroke in definition.strokes) {
        expect(stroke.checkpoints.length, greaterThanOrEqualTo(2));
        for (final checkpoint in stroke.checkpoints) {
          expect(checkpoint.point.x, inInclusiveRange(0, 1));
          expect(checkpoint.point.y, inInclusiveRange(0, 1));
        }
      }
    });

    test('rejects coordinates outside normalized space', () {
      expect(() => TracePoint(-0.01, 0.5), throwsRangeError);
      expect(() => TracePoint(0.5, 1.01), throwsRangeError);
      expect(() => TracePoint(double.nan, 0.5), throwsRangeError);
    });

    test('exposes unmodifiable stroke and checkpoint collections', () {
      final definition = TraceDefinition.uppercaseA();

      expect(
        () => definition.strokes.add(definition.strokes.first),
        throwsUnsupportedError,
      );
      expect(
        () => definition.strokes.first.checkpoints.clear(),
        throwsUnsupportedError,
      );
    });
  });

  group('TraceController', () {
    late TraceDefinition definition;
    late TraceController controller;

    setUp(() {
      definition = TraceDefinition.uppercaseA();
      controller = TraceController(definition: definition);
    });

    test('starts ready with immutable UI-facing progress state', () {
      expect(controller.state.status, TraceStatus.ready);
      expect(controller.state.currentStrokeIndex, 0);
      expect(controller.state.currentStroke?.id, 'left-leg');
      expect(controller.state.nextCheckpointIndex, 0);
      expect(controller.state.completedCheckpointCount, 0);
      expect(controller.state.progress, 0);
      expect(controller.state.currentStrokeProgress, 0);
      expect(controller.state.isPointerActive, isFalse);
    });

    test('requires a gesture to start at the first ordered checkpoint', () {
      final rejected = controller.start(TracePoint(0.8, 0.2));

      expect(rejected.status, TraceStatus.offPath);
      expect(rejected.offPathPoint, TracePoint(0.8, 0.2));
      expect(rejected.progress, 0);

      final accepted = controller.start(definition.strokes.first.start);
      expect(accepted.status, TraceStatus.tracing);
      expect(accepted.nextCheckpointIndex, 1);
      expect(accepted.completedCheckpointCount, 1);
      expect(accepted.lastAcceptedPoint, definition.strokes.first.start);
      expect(accepted.isPointerActive, isTrue);
    });

    test('interpolates sparse samples through ordered checkpoints', () {
      final leftLeg = definition.strokes.first;

      controller.start(leftLeg.start);
      final result = controller.update(leftLeg.end);

      expect(result.status, TraceStatus.ready);
      expect(result.currentStrokeIndex, 1);
      expect(result.currentStroke?.id, 'right-leg');
      expect(result.completedCheckpointCount, leftLeg.checkpoints.length);
      expect(result.progress, closeTo(1 / 3, 0.0001));
    });

    test(
      'rejects an unrelated scribble and clears current-stroke progress',
      () {
        final leftLeg = definition.strokes.first;

        controller.start(leftLeg.start);
        controller.update(leftLeg.checkpoints[1].point);
        expect(controller.state.nextCheckpointIndex, greaterThan(1));

        final result = controller.update(TracePoint(0.9, 0.5));

        expect(result.status, TraceStatus.offPath);
        expect(result.offPathPoint, TracePoint(0.9, 0.5));
        expect(result.currentStrokeIndex, 0);
        expect(result.nextCheckpointIndex, 0);
        expect(result.completedCheckpointCount, 0);
        expect(result.progress, 0);
      },
    );

    test('keeps accepted samples inside a forgiving stroke corridor', () {
      controller.start(TracePoint(0.23, 0.88));
      final result = controller.update(TracePoint(0.52, 0.12));

      expect(result.status, TraceStatus.ready);
      expect(result.currentStrokeIndex, 1);
    });

    test('requires a failed stroke to restart at its first checkpoint', () {
      final leftLeg = definition.strokes.first;

      controller.start(leftLeg.start);
      controller.update(TracePoint(0.9, 0.5));

      final stillRejected = controller.start(leftLeg.checkpoints[2].point);
      expect(stillRejected.status, TraceStatus.offPath);
      expect(stillRejected.progress, 0);

      final restarted = controller.start(leftLeg.start);
      expect(restarted.status, TraceStatus.tracing);
      expect(restarted.nextCheckpointIndex, 1);
    });

    test('keeps the gentle off-path hint visible after pointer up', () {
      controller.start(TracePoint(0.8, 0.2));

      final result = controller.end();

      expect(result.status, TraceStatus.offPath);
      expect(result.offPathPoint, TracePoint(0.8, 0.2));
      expect(result.progress, 0);
    });

    test('ending early restarts only the unfinished stroke', () {
      final leftLeg = definition.strokes[0];
      final rightLeg = definition.strokes[1];

      controller.start(leftLeg.start);
      controller.update(leftLeg.end);
      controller.start(rightLeg.start);
      controller.update(rightLeg.checkpoints[1].point);

      final result = controller.end();

      expect(result.status, TraceStatus.ready);
      expect(result.currentStrokeIndex, 1);
      expect(result.nextCheckpointIndex, 0);
      expect(result.completedCheckpointCount, leftLeg.checkpoints.length);
      expect(result.progress, closeTo(1 / 3, 0.0001));
    });

    test('completes only after all three strokes are traced in order', () {
      for (final stroke in definition.strokes) {
        controller.start(stroke.start);
        controller.update(stroke.end);
      }

      expect(controller.state.status, TraceStatus.completed);
      expect(controller.state.isCompleted, isTrue);
      expect(controller.state.currentStroke, isNull);
      expect(controller.state.currentStrokeIndex, definition.strokes.length);
      expect(
        controller.state.completedCheckpointCount,
        definition.checkpointCount,
      );
      expect(controller.state.currentStrokeProgress, 1);
      expect(controller.state.progress, 1);
    });

    test('reset clears completed and failed states', () {
      controller.start(definition.strokes.first.start);
      controller.update(TracePoint(0.9, 0.5));
      expect(controller.state.status, TraceStatus.offPath);

      final reset = controller.reset();

      expect(reset.status, TraceStatus.ready);
      expect(reset.currentStrokeIndex, 0);
      expect(reset.nextCheckpointIndex, 0);
      expect(reset.completedCheckpointCount, 0);
      expect(reset.lastAcceptedPoint, isNull);
      expect(reset.offPathPoint, isNull);
      expect(reset.progress, 0);
    });

    test('ignores movement before a valid start and after completion', () {
      final untouched = controller.update(TracePoint(0.5, 0.5));
      expect(untouched.status, TraceStatus.ready);
      expect(untouched.progress, 0);

      for (final stroke in definition.strokes) {
        controller.start(stroke.start);
        controller.update(stroke.end);
      }
      final completed = controller.state;

      expect(controller.update(TracePoint(0.1, 0.1)), same(completed));
      expect(controller.start(TracePoint(0.1, 0.1)), same(completed));
      expect(controller.end(), same(completed));
    });
  });
}
