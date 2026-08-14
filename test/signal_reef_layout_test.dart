import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/application/signal_reef_ads.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/application/signal_reef_controller.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/application/signal_reef_feedback.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/application/signal_reef_telemetry.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/data/signal_reef_save_store.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/domain/run_result.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/domain/save_data.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/presentation/pages/signal_reef_home_page.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/presentation/pages/signal_reef_play_page.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/presentation/pages/signal_reef_result_page.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/presentation/pages/signal_reef_settings_page.dart';
import 'package:signal_reef_space_shooter/features/signal_reef/presentation/theme/signal_reef_theme.dart';

void main() {
  testWidgets('Signal Reef pages fill a phone viewport', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await _setPhoneViewport(tester);
      final controller = _newController();

      await _pumpPage(tester, SignalReefHomePage(controller: controller));
      _expectFullScaffold(tester);

      await _pumpPage(tester, SignalReefSettingsPage(controller: controller));
      _expectFullScaffold(tester);

      controller.play();
      await _pumpPage(tester, SignalReefPlayPage(controller: controller));
      _expectFullScaffold(tester);
      expect(controller.game?.camera.viewfinder.anchor, Anchor.topLeft);

      controller.game?.onRunFinished(
        const SignalReefRunResult(
          score: 120,
          waveReached: 2,
          wavesCleared: 1,
          durationSeconds: 18,
          hullRemaining: 2,
          won: false,
        ),
      );
      await _pumpPage(tester, SignalReefResultPage(controller: controller));
      _expectFullScaffold(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('game callbacks do not notify during layout build', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await _setPhoneViewport(tester);
      final controller = _newController()..play();
      var notificationTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: SignalReefTheme.dark(),
          home: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (!notificationTriggered) {
                    notificationTriggered = true;
                    controller.game?.onStateChanged();
                  }
                  return SignalReefPlayPage(controller: controller);
                },
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      _expectFullScaffold(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Future<void> _setPhoneViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(
    MaterialApp(theme: SignalReefTheme.dark(), home: page),
  );
  await tester.pump();
  expect(tester.takeException(), isNull);
}

void _expectFullScaffold(WidgetTester tester) {
  expect(tester.getSize(find.byType(Scaffold).first), const Size(390, 844));
}

SignalReefController _newController() {
  return SignalReefController(
    saveStore: _MemorySaveStore(),
    initialSave: SignalReefSaveData.initial(),
    telemetry: const NoOpSignalReefTelemetry(),
    feedback: const _NoFeedback(),
    ads: SignalReefAdService(telemetry: const NoOpSignalReefTelemetry()),
  );
}

final class _MemorySaveStore implements SignalReefSaveStore {
  SignalReefSaveData _data = SignalReefSaveData.initial();

  @override
  Future<SignalReefSaveData> load() async => _data;

  @override
  Future<void> save(SignalReefSaveData data) async {
    _data = data;
  }
}

final class _NoFeedback implements SignalReefFeedback {
  const _NoFeedback();

  @override
  void play(SignalReefFeedbackCue cue, SignalReefFeedbackSettings settings) {}
}
