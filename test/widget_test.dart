import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/app/kids_land_app.dart';
import 'package:rapid_jump/features/games/dew_bubble/data/dew_levels.dart';
import 'package:rapid_jump/features/games/dew_bubble/data/dew_progression.dart';
import 'package:rapid_jump/features/games/game_catalog.dart';
import 'package:rapid_jump/features/tracing/data/progress_repository.dart';

void main() {
  testWidgets('home shows Dew Bubble Garden hub', (tester) async {
    await tester.pumpWidget(_app(repository: MemoryProgressRepository()));

    expect(kidsGameCatalog, hasLength(1));
    expect(find.byKey(const ValueKey('game-card-dew-bubble')), findsOneWidget);
    expect(find.text('Dew Bubble Garden'), findsWidgets);
    expect(find.text('Letter Tracing'), findsNothing);
    expect(find.text('Memory Match'), findsNothing);
    expect(find.text('Start Stage 1'), findsOneWidget);
    expect(find.text('Campaign Route'), findsOneWidget);
    expect(find.text('Run goals'), findsOneWidget);
    expect(find.text('Badges 0/10'), findsOneWidget);
  });

  testWidgets('home primary action opens Dew Bubble gameplay', (tester) async {
    final firstTarget = dewBubbleTargetScore(dewBubbleLevels.first);
    await tester.pumpWidget(_app(repository: MemoryProgressRepository()));

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('game-card-dew-bubble')),
      300,
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('game-card-dew-bubble')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Sprout Steps'), findsOneWidget);
    expect(find.text('Stage 1 of 40'), findsOneWidget);
    expect(find.text('Target $firstTarget'), findsOneWidget);
    expect(find.text('Learn three clean color matches.'), findsOneWidget);
    expect(find.byKey(const ValueKey('dew-bubble-playfield')), findsOneWidget);
    expect(find.text('Garden Route'), findsNothing);
  });

  testWidgets('home secondary action opens the campaign route', (tester) async {
    await tester.pumpWidget(_app(repository: MemoryProgressRepository()));

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('choose-garden-button')),
      300,
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('choose-garden-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Garden Route'), findsOneWidget);
    expect(
      find.text('Continue the route, chase targets, bank stars.'),
      findsOneWidget,
    );
    expect(find.text('Opening Route - Stage 1'), findsOneWidget);
    expect(find.text('Route stages'), findsOneWidget);
    expect(find.text('Learn three clean color matches.'), findsWidgets);
    expect(find.text('Sprout Steps'), findsWidgets);
    expect(find.byKey(const ValueKey('dew-bubble-playfield')), findsNothing);
  });

  testWidgets('saved Dew Bubble completion is visible on home', (tester) async {
    final repository = MemoryProgressRepository(
      completedGameIds: const {dewBubbleGameId},
    );

    await tester.pumpWidget(_app(repository: repository));

    expect(
      find.byKey(const ValueKey('dew-bubble-complete-check')),
      findsOneWidget,
    );
  });

  testWidgets('small high-text-scale layout keeps game card usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app(repository: MemoryProgressRepository()));

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('game-card-dew-bubble')),
      300,
    );
    await tester.pump();

    final gameCardSize = tester.getSize(
      find.byKey(const ValueKey('game-card-dew-bubble')),
    );
    expect(gameCardSize.width, greaterThanOrEqualTo(64));
    expect(gameCardSize.height, greaterThanOrEqualTo(64));
    expect(tester.takeException(), isNull);
  });
}

Widget _app({required ProgressRepository repository}) {
  return KidsLandApp(progressRepository: repository);
}
