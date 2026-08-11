import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/application/puzzle_controller.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/data/puzzle_progress_store.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/domain/board_position.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/domain/player_progress.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/domain/puzzle_engine.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/domain/puzzle_level.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/presentation/pages/level_complete_page.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/presentation/pages/puzzle_page.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/presentation/theme/arrow_puzzle_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pause menu exposes restart, navigation, and settings controls', (
    tester,
  ) async {
    final controller = _buildController();
    controller.play();

    await tester.pumpWidget(
      _TestShell(child: PuzzlePage(controller: controller)),
    );
    await tester.tap(find.byTooltip('Pause'));
    await tester.pumpAndSettle();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Levels'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Haptics'), findsOneWidget);
  });

  testWidgets('final result screen celebrates completing the level pack', (
    tester,
  ) async {
    final controller = _buildController(levels: const [_oneTapLevel]);
    controller.play();
    controller.tap(const BoardPosition(0, 0));

    await tester.pumpWidget(
      _TestShell(child: LevelCompletePage(controller: controller)),
    );

    expect(find.text('All Levels Clear'), findsOneWidget);
    expect(find.text('Every board in this pack is complete.'), findsOneWidget);
    expect(find.text('Back Home'), findsOneWidget);
  });
}

const _oneTapLevel = PuzzleLevel(
  id: 1,
  name: 'One',
  rows: ['R'],
  lesson: 'Go right.',
);

PuzzleController _buildController({
  List<PuzzleLevel> levels = const [_oneTapLevel],
}) {
  return PuzzleController(
    engine: const PuzzleEngine(),
    levels: levels,
    progressStore: _MemoryProgressStore(),
    initialProgress: PlayerProgress.initial(),
    enableFeedback: false,
    now: () => DateTime(2026, 8, 2),
  );
}

class _TestShell extends StatelessWidget {
  const _TestShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ArrowPuzzleTheme.light(), home: child);
  }
}

class _MemoryProgressStore implements PuzzleProgressStore {
  @override
  Future<PlayerProgress> load() async {
    return PlayerProgress.initial();
  }

  @override
  Future<void> save(PlayerProgress progress) async {}
}
