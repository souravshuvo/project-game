import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rapid_jump/app/game_app.dart';

void main() {
  const bestScoreChannel = MethodChannel('cloud_courier_climb/best_score');
  const settingsChannel = MethodChannel('cloud_courier_climb/settings');

  testWidgets('shows menu, saved best score, and readable controls', (
    WidgetTester tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(bestScoreChannel, (MethodCall call) async {
          switch (call.method) {
            case 'loadBestScore':
              return 42;
            case 'saveBestScore':
              return null;
          }

          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(settingsChannel, (MethodCall call) async {
          switch (call.method) {
            case 'loadSettings':
              return <String, Object?>{
                'completedChallengeSteps': 0,
                'soundEnabled': true,
                'hapticsEnabled': true,
              };
            case 'saveSettings':
              return null;
          }

          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(bestScoreChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(settingsChannel, null);
    });

    await tester.pumpWidget(const GameApp());
    await tester.pump();

    expect(find.text('CLOUD COURIER CLIMB'), findsOneWidget);
    expect(find.text('START RUN'), findsOneWidget);
    expect(find.text('HELP'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.textContaining('Route 1'), findsWidgets);
    expect(find.textContaining('score 20'), findsWidgets);
    expect(find.text('BEST 42'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'HELP'));
    await tester.pump();
    expect(find.text('HOW TO CLIMB'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'BACK'));
    await tester.pump();

    await tester.tap(find.widgetWithText(OutlinedButton, 'SETTINGS'));
    await tester.pump();
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Haptics'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'DONE'));
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'START RUN'));
    await tester.pump();

    expect(find.text('LEFT'), findsOneWidget);
    expect(find.text('RIGHT'), findsOneWidget);
    expect(find.textContaining('SCORE'), findsOneWidget);
    expect(find.textContaining('Route 1'), findsOneWidget);
    expect(find.text('START RUN'), findsNothing);

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();

    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('RESUME'), findsOneWidget);
  });
}
