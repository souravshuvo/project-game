import 'package:flutter/material.dart';

import 'features/arrow_puzzle/domain/board_position.dart';
import 'features/arrow_puzzle/domain/puzzle_cell.dart';
import 'features/weather_sort/application/game_telemetry.dart';
import 'features/weather_sort/application/water_sort_controller.dart';
import 'features/weather_sort/data/local_water_level_pack.dart';
import 'features/weather_sort/data/water_progress_store.dart';
import 'features/weather_sort/domain/water_player_progress.dart';
import 'features/weather_sort/domain/water_sort_engine.dart';
import 'features/weather_sort/presentation/pages/home_page.dart';
import 'features/weather_sort/presentation/pages/level_complete_page.dart';
import 'features/weather_sort/presentation/pages/level_select_page.dart';
import 'features/weather_sort/presentation/pages/puzzle_page.dart';
import 'features/weather_sort/presentation/pages/settings_page.dart';
import 'features/weather_sort/presentation/theme/weather_sort_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressStore = SharedPreferencesWaterProgressStore();
  final initialProgress = await progressStore.load();

  runApp(
    WeatherSortApp(
      progressStore: progressStore,
      initialProgress: initialProgress,
    ),
  );
}

class WeatherSortApp extends StatefulWidget {
  const WeatherSortApp({
    super.key,
    required this.progressStore,
    required this.initialProgress,
  });

  final WaterProgressStore progressStore;
  final WaterPlayerProgress initialProgress;

  @override
  State<WeatherSortApp> createState() => _WeatherSortAppState();
}

class _WeatherSortAppState extends State<WeatherSortApp> {
  late final WaterSortController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WaterSortController(
      engine: const WaterSortEngine(),
      levels: localWaterLevelPack,
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
          title: 'Weather Lab Sort',
          debugShowCheckedModeBanner: false,
          theme: WeatherSortTheme.light(),
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    return switch (_controller.screen) {
      WaterSortScreen.home => WaterHomePage(controller: _controller),
      WaterSortScreen.levelSelect => WaterLevelSelectPage(
        controller: _controller,
      ),
      WaterSortScreen.settings => WaterSettingsPage(controller: _controller),
      WaterSortScreen.playing => WaterPuzzlePage(controller: _controller),
      WaterSortScreen.complete => WaterLevelCompletePage(
        controller: _controller,
      ),
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
