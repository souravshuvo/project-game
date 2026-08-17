import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/features/games/dew_bubble/data/dew_levels.dart';
import 'package:rapid_jump/features/games/dew_bubble/data/dew_progression.dart';
import 'package:rapid_jump/features/games/dew_bubble/dew_bubble_game_screen.dart';
import 'package:rapid_jump/features/tracing/data/progress_repository.dart';

void main() {
  testWidgets('level select shows saved progress and opens unlocked levels', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = MemoryProgressRepository(
      dewBubbleHighestUnlockedLevelIndex: 2,
      dewBubbleBestScores: const {'dew-1': 320},
      dewBubbleBestStars: const {'dew-1': 3},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DewBubbleGameScreen(
          progressRepository: repository,
          onCompleted: () {},
        ),
      ),
    );

    expect(find.text('Garden Route'), findsOneWidget);
    expect(find.text('Opening Route - Stage 3'), findsOneWidget);
    expect(find.text('Route stages'), findsOneWidget);
    expect(find.text('Sprout Steps'), findsOneWidget);
    expect(find.text('Loose Leaves'), findsWidgets);
    expect(find.text('Best 320'), findsOneWidget);

    await tester.tap(find.text('Loose Leaves').last);
    await tester.pump();

    final thirdTarget = dewBubbleTargetScore(dewBubbleLevels[2]);
    expect(find.text('Loose Leaves'), findsOneWidget);
    expect(find.text('Stage 3 of 40'), findsOneWidget);
    expect(find.byKey(const ValueKey('dew-bubble-playfield')), findsOneWidget);
    expect(find.text('Match 3, chain streaks, save shots'), findsOneWidget);
    expect(find.text('Target $thirdTarget'), findsOneWidget);
    expect(find.text('Drop loose bubbles from the side.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('dew-pause-button')));
    await tester.pumpAndSettle();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Sound feedback'), findsOneWidget);
    expect(find.text('Haptic feedback'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    expect(find.text('Paused'), findsNothing);
  });
}
