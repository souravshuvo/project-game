import 'package:flutter/material.dart';

import 'features/arrow_puzzle/application/puzzle_controller.dart';
import 'features/arrow_puzzle/application/game_telemetry.dart';
import 'features/arrow_puzzle/data/local_level_pack.dart';
import 'features/arrow_puzzle/data/puzzle_progress_store.dart';
import 'features/arrow_puzzle/domain/player_progress.dart';
import 'features/arrow_puzzle/domain/board_position.dart';
import 'features/arrow_puzzle/domain/puzzle_cell.dart';
import 'features/arrow_puzzle/domain/puzzle_engine.dart';
import 'features/arrow_puzzle/presentation/pages/home_page.dart';
import 'features/arrow_puzzle/presentation/pages/level_select_page.dart';
import 'features/arrow_puzzle/presentation/pages/level_complete_page.dart';
import 'features/arrow_puzzle/presentation/pages/puzzle_page.dart';
import 'features/arrow_puzzle/presentation/pages/settings_page.dart';
import 'features/arrow_puzzle/presentation/theme/arrow_puzzle_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressStore = SharedPreferencesPuzzleProgressStore();
  final initialProgress = await progressStore.load();

  runApp(
    ArrowPuzzleApp(
      progressStore: progressStore,
      initialProgress: initialProgress,
    ),
  );
}

class ArrowPuzzleApp extends StatefulWidget {
  const ArrowPuzzleApp({
    super.key,
    required this.progressStore,
    required this.initialProgress,
  });

  final PuzzleProgressStore progressStore;
  final PlayerProgress initialProgress;

  @override
  State<ArrowPuzzleApp> createState() => _ArrowPuzzleAppState();
}

class _ArrowPuzzleAppState extends State<ArrowPuzzleApp> {
  late final PuzzleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PuzzleController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
      progressStore: widget.progressStore,
      initialProgress: widget.initialProgress,
      telemetry: const NoOpGameTelemetry(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Arrow Puzzle',
          debugShowCheckedModeBanner: false,
          theme: ArrowPuzzleTheme.light(),
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    return switch (_controller.screen) {
      PuzzleScreen.home => HomePage(controller: _controller),
      PuzzleScreen.levelSelect => LevelSelectPage(controller: _controller),
      PuzzleScreen.settings => SettingsPage(controller: _controller),
      PuzzleScreen.playing => PuzzlePage(controller: _controller),
      PuzzleScreen.complete => LevelCompletePage(controller: _controller),
    };
  }
}

IconData arrowIcon(PuzzleCell cell) {
  return switch (cell) {
    PuzzleCell.up => Icons.arrow_upward_rounded,
    PuzzleCell.down => Icons.arrow_downward_rounded,
    PuzzleCell.left => Icons.arrow_back_rounded,
    PuzzleCell.right => Icons.arrow_forward_rounded,
    PuzzleCell.empty => Icons.circle_outlined,
  };
}

Alignment exitAlignment(BoardPosition _, PuzzleCell cell) {
  return switch (cell) {
    PuzzleCell.up => const Alignment(0, -6),
    PuzzleCell.down => const Alignment(0, 6),
    PuzzleCell.left => const Alignment(-6, 0),
    PuzzleCell.right => const Alignment(6, 0),
    PuzzleCell.empty => Alignment.center,
  };
}
