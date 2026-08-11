import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rapid_jump/app/game_app.dart';

void main() {
  const bestScoreChannel = MethodChannel('cloud_courier_climb/best_score');

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
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(bestScoreChannel, null);
    });

    await tester.pumpWidget(const GameApp());
    await tester.pump();

    expect(find.text('CLOUD COURIER CLIMB'), findsOneWidget);
    expect(find.text('START RUN'), findsOneWidget);
    expect(find.text('BEST 42'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'START RUN'));
    await tester.pump();

    expect(find.text('LEFT'), findsOneWidget);
    expect(find.text('RIGHT'), findsOneWidget);
    expect(find.textContaining('SCORE'), findsOneWidget);
    expect(find.text('START RUN'), findsNothing);
  });
}
