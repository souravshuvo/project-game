import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/application/game_ad_service.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/application/game_telemetry.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/application/water_sort_controller.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/data/local_water_level_pack.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/data/water_progress_store.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/water_player_progress.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/domain/water_sort_engine.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/presentation/pages/home_page.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/presentation/pages/level_complete_page.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/presentation/pages/level_select_page.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/presentation/pages/puzzle_page.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/presentation/theme/weather_sort_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

var _fontsLoaded = false;
const _isPreviewCapture = bool.fromEnvironment('SCREENSHOT_PREVIEW');
const _exitAfterCapture = bool.fromEnvironment('SCREENSHOT_EXIT_AFTER_CAPTURE');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captures 01 home screenshot', (tester) async {
    _prepareScreenshotSurface(tester);
    await _capture(
      tester,
      filename: '01-calm-sorting-puzzles.png',
      child: WaterHomePage(
        controller: _buildController(
          progress: _progressWithCompletedLevels(
            completedCount: 2,
            currentLevelIndex: 2,
          ),
        ),
      ),
      outputDirectory: _outputDirectory(),
    );
  });

  testWidgets('captures 02 early gameplay screenshot', (tester) async {
    _prepareScreenshotSurface(tester);
    final earlyController = _buildController(
      progress: _progressWithCompletedLevels(
        completedCount: 2,
        currentLevelIndex: 2,
      ),
    );
    earlyController.play();
    _tapMoves(earlyController, const [(0, 2), (1, 3)]);
    earlyController.tapTube(0);
    await _capture(
      tester,
      filename: '02-tap-pour-sort.png',
      child: WaterPuzzlePage(controller: earlyController),
      outputDirectory: _outputDirectory(),
    );
  });

  testWidgets('captures 03 advanced gameplay screenshot', (tester) async {
    _prepareScreenshotSurface(tester);
    final cloudController = _buildController(
      progress: _progressWithCompletedLevels(
        completedCount: 21,
        currentLevelIndex: 21,
      ),
    )..play();
    _tapMoves(cloudController, const [(0, 2), (1, 3), (4, 2), (5, 3)]);
    await _capture(
      tester,
      filename: '03-plan-each-pour.png',
      child: WaterPuzzlePage(controller: cloudController),
      outputDirectory: _outputDirectory(),
    );
  });

  testWidgets('captures 04 invalid move screenshot', (tester) async {
    _prepareScreenshotSurface(tester);
    final invalidController = _buildController(
      progress: _progressWithCompletedLevels(
        completedCount: 2,
        currentLevelIndex: 2,
      ),
    )..play();
    _tapMoves(invalidController, const [(0, 2), (1, 3)]);
    invalidController
      ..tapTube(0)
      ..tapTube(1);
    await _capture(
      tester,
      filename: '04-clear-feedback.png',
      child: WaterPuzzlePage(controller: invalidController),
      outputDirectory: _outputDirectory(),
    );
  });

  testWidgets('captures 05 complete screenshot', (tester) async {
    _prepareScreenshotSurface(tester);
    final completeController = _buildController()..play();
    _tapMoves(completeController, const [(0, 2), (1, 0), (1, 2)]);
    await _capture(
      tester,
      filename: '05-improve-your-score.png',
      child: WaterLevelCompletePage(controller: completeController),
      outputDirectory: _outputDirectory(),
    );
  });

  testWidgets('captures 06 level select screenshot', (tester) async {
    _prepareScreenshotSurface(tester, devicePixelRatio: 3.25);
    final levelSelectController = _buildController(
      progress: _progressWithCompletedLevels(
        completedCount: 8,
        currentLevelIndex: 8,
      ),
    )..showLevelSelect();
    await _capture(
      tester,
      filename: '06-50-forecast-levels.png',
      child: WaterLevelSelectPage(controller: levelSelectController),
      outputDirectory: _outputDirectory(),
    );
  });
}

void _prepareScreenshotSurface(
  WidgetTester tester, {
  double devicePixelRatio = 2.55,
}) {
  final screenshotSize = _isPreviewCapture
      ? const Size(390, 844)
      : const Size(1080, 1920);
  tester.view.physicalSize = screenshotSize;
  tester.view.devicePixelRatio = _isPreviewCapture ? 1.0 : devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Directory _outputDirectory() {
  return Directory(
    _isPreviewCapture
        ? 'store_assets/screenshots/weather_lab_sort_phone/preview_png'
        : 'store_assets/screenshots/weather_lab_sort_phone/source_png',
  )..createSync(recursive: true);
}

Future<void> _capture(
  WidgetTester tester, {
  required String filename,
  required Widget child,
  required Directory outputDirectory,
}) async {
  await tester.runAsync(_loadFonts);
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: WeatherSortTheme.light(),
        home: child,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 700));

  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(
    pixelRatio: tester.view.devicePixelRatio,
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  File('${outputDirectory.path}/$filename').writeAsBytesSync(bytes);
  image.dispose();
  if (_exitAfterCapture) {
    exit(0);
  }
}

Future<void> _loadFonts() async {
  if (_fontsLoaded) {
    return;
  }

  final robotoLoader = FontLoader('Roboto')
    ..addFont(
      _loadFont(
        'C:/flutter/bin/cache/artifacts/material_fonts/roboto-regular.ttf',
      ),
    )
    ..addFont(
      _loadFont(
        'C:/flutter/bin/cache/artifacts/material_fonts/roboto-medium.ttf',
      ),
    )
    ..addFont(
      _loadFont(
        'C:/flutter/bin/cache/artifacts/material_fonts/roboto-bold.ttf',
      ),
    )
    ..addFont(
      _loadFont(
        'C:/flutter/bin/cache/artifacts/material_fonts/roboto-black.ttf',
      ),
    );
  await robotoLoader.load();

  final iconLoader = FontLoader('MaterialIcons')
    ..addFont(
      _loadFont(
        'C:/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
      ),
    );
  await iconLoader.load();

  _fontsLoaded = true;
}

Future<ByteData> _loadFont(String path) async {
  final bytes = File(path).readAsBytesSync();
  return ByteData.sublistView(Uint8List.fromList(bytes));
}

WaterSortController _buildController({WaterPlayerProgress? progress}) {
  return WaterSortController(
    engine: const WaterSortEngine(),
    levels: localWaterLevelPack,
    progressStore: _MemoryWaterProgressStore(),
    initialProgress: progress ?? WaterPlayerProgress.initial(),
    enableFeedback: false,
    telemetry: const NoOpGameTelemetry(),
    adService: const NoOpGameAdService(),
    now: () => DateTime(2026, 8, 14, 12),
  );
}

WaterPlayerProgress _progressWithCompletedLevels({
  required int completedCount,
  required int currentLevelIndex,
}) {
  final completedIds = {
    for (var level = 1; level <= completedCount; level++) level,
  };
  return WaterPlayerProgress(
    currentLevelIndex: currentLevelIndex,
    unlockedLevelIndex: currentLevelIndex,
    completedLevelIds: completedIds,
    bestMovesByLevel: {
      for (final level in localWaterLevelPack.take(completedCount))
        level.id: level.parMoves,
    },
    bestStarsByLevel: {for (final levelId in completedIds) levelId: 3},
    soundEnabled: true,
    hapticsEnabled: true,
  );
}

void _tapMoves(WaterSortController controller, List<(int, int)> moves) {
  for (final move in moves) {
    controller
      ..tapTube(move.$1)
      ..tapTube(move.$2);
    controller.finishPourAnimation();
  }
}

class _MemoryWaterProgressStore implements WaterProgressStore {
  @override
  Future<WaterPlayerProgress> load() async => WaterPlayerProgress.initial();

  @override
  Future<void> save(WaterPlayerProgress progress) async {}
}
