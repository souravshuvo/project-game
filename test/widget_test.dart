import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_game/app/magnetic_marbles_app.dart';
import 'package:project_game/features/game/presentation/game_screen.dart';

void main() {
  testWidgets('home opens the game', (tester) async {
    await tester.pumpWidget(const MagneticMarblesApp());

    expect(find.text('Magnetic Marbles'), findsOneWidget);
    expect(find.byKey(const ValueKey('play-button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('play-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('Reserve'), findsOneWidget);
    expect(find.text('Crowd'), findsOneWidget);
  });

  testWidgets('game menu exposes help and feedback settings', (tester) async {
    await tester.pumpWidget(const MagneticMarblesApp());

    await tester.tap(find.byKey(const ValueKey('play-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('game-menu-button')));
    await tester.pump();

    expect(find.text('Game menu'), findsOneWidget);
    expect(find.byKey(const ValueKey('help-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('settings-button')));
    await tester.pump();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byKey(const ValueKey('sound-toggle')), findsOneWidget);
    expect(find.byKey(const ValueKey('haptics-toggle')), findsOneWidget);
  });
}
