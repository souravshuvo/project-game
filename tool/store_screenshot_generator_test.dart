import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/application/puzzle_controller.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/data/local_level_pack.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/data/puzzle_progress_store.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/domain/player_progress.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/domain/puzzle_engine.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/presentation/pages/home_page.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/presentation/pages/level_complete_page.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/presentation/pages/level_select_page.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/presentation/pages/puzzle_page.dart';
import 'package:arrow_puzzle_tap_puzzle_games/features/arrow_puzzle/presentation/theme/arrow_puzzle_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generates Play Store phone screenshots from real widgets', (
    tester,
  ) async {
    const requestedScreenshot = String.fromEnvironment('STORE_SCREENSHOT');
    await _loadFonts();
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final outputDirectory = Directory('store_assets/screenshots/phone_final');
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }

    final homeController = _controller();
    await _captureIfRequested(
      tester,
      outputDirectory,
      requestedScreenshot: requestedScreenshot,
      screenshotId: 'home',
      fileName: '01-home.png',
      headline: 'Clear arrows in order',
      child: HomePage(controller: homeController),
    );
    homeController.dispose();

    final progress = _progressForCompletedLevels(12);
    final levelSelectController = _controller(initialProgress: progress)
      ..showLevelSelect();
    await _captureIfRequested(
      tester,
      outputDirectory,
      requestedScreenshot: requestedScreenshot,
      screenshotId: 'levels',
      fileName: '02-levels.png',
      headline: '60 handcrafted levels',
      child: LevelSelectPage(controller: levelSelectController),
    );
    levelSelectController.dispose();

    final earlyController = _controller()..play();
    await _captureIfRequested(
      tester,
      outputDirectory,
      requestedScreenshot: requestedScreenshot,
      screenshotId: 'gameplay',
      fileName: '03-gameplay.png',
      headline: 'Find clear paths',
      child: PuzzlePage(controller: earlyController),
    );
    earlyController.dispose();

    final midGameController = _controller(
      initialProgress: _progressForUnlockedLevel(44),
    )..play();
    await _captureIfRequested(
      tester,
      outputDirectory,
      requestedScreenshot: requestedScreenshot,
      screenshotId: 'plan',
      fileName: '04-plan-each-move.png',
      headline: 'Plan each move',
      child: PuzzlePage(controller: midGameController),
    );
    midGameController.dispose();

    final hintController = _controller()..play();
    hintController.useHint();
    await _captureIfRequested(
      tester,
      outputDirectory,
      requestedScreenshot: requestedScreenshot,
      screenshotId: 'hints',
      fileName: '05-hints.png',
      headline: 'Hints when needed',
      child: PuzzlePage(controller: hintController),
    );
    hintController.dispose();

    final completeController = _controller()..play();
    _solveCurrentLevel(completeController);
    await _captureIfRequested(
      tester,
      outputDirectory,
      requestedScreenshot: requestedScreenshot,
      screenshotId: 'complete',
      fileName: '06-level-complete.png',
      headline: 'Replay for better moves',
      child: LevelCompletePage(controller: completeController),
    );
    completeController.dispose();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    exit(0);
  });
}

Future<void> _captureIfRequested(
  WidgetTester tester,
  Directory outputDirectory, {
  required String requestedScreenshot,
  required String screenshotId,
  required String fileName,
  required String headline,
  required Widget child,
}) async {
  if (requestedScreenshot.isNotEmpty && requestedScreenshot != screenshotId) {
    return;
  }

  await _capture(
    tester,
    outputDirectory,
    fileName: fileName,
    headline: headline,
    child: child,
  );
}

Future<void> _capture(
  WidgetTester tester,
  Directory outputDirectory, {
  required String fileName,
  required String headline,
  required Widget child,
}) async {
  debugPrint('Capturing $fileName');
  final boundaryKey = GlobalKey();

  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _screenshotTheme(),
        home: _StoreScreenshotFrame(headline: headline, child: child),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 700));

  final boundary =
      boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  File(
    '${outputDirectory.path}/$fileName',
  ).writeAsBytesSync(byteData!.buffer.asUint8List());
  image.dispose();
  debugPrint('Captured $fileName');
}

ThemeData _screenshotTheme() {
  final theme = ArrowPuzzleTheme.light();

  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
    primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'Roboto'),
    filledButtonTheme: FilledButtonThemeData(
      style: theme.filledButtonTheme.style?.copyWith(
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: theme.outlinedButtonTheme.style?.copyWith(
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

Future<void> _loadFonts() async {
  await _loadFont(
    family: 'Roboto',
    paths: const [
      r'C:\flutter\bin\cache\artifacts\material_fonts\roboto-regular.ttf',
      r'C:\flutter\bin\cache\artifacts\material_fonts\roboto-medium.ttf',
      r'C:\flutter\bin\cache\artifacts\material_fonts\roboto-bold.ttf',
      r'C:\flutter\bin\cache\artifacts\material_fonts\roboto-black.ttf',
    ],
  );
  await _loadFont(
    family: 'MaterialIcons',
    paths: const [
      r'C:\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf',
    ],
  );
}

Future<void> _loadFont({
  required String family,
  required List<String> paths,
}) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(
      Future.value(ByteData.sublistView(Uint8List.fromList(bytes))),
    );
  }
  await loader.load();
}

PuzzleController _controller({PlayerProgress? initialProgress}) {
  return PuzzleController(
    engine: const PuzzleEngine(),
    levels: localLevelPack,
    progressStore: _MemoryProgressStore(),
    initialProgress: initialProgress ?? PlayerProgress.initial(),
    enableFeedback: false,
    now: () => DateTime(2026, 8, 11),
  );
}

PlayerProgress _progressForCompletedLevels(int count) {
  final completedLevels = localLevelPack.take(count).toList();

  return PlayerProgress.initial().copyWith(
    currentLevelIndex: math.min(count, localLevelPack.length - 1),
    unlockedLevelIndex: math.min(count, localLevelPack.length - 1),
    completedLevelIds: completedLevels.map((level) => level.id).toSet(),
    bestMovesByLevel: {
      for (final level in completedLevels) level.id: level.rows.join().length,
    },
    streakDays: 4,
    hintCount: 2,
    lastCompletionDate: '2026-08-11',
  );
}

PlayerProgress _progressForUnlockedLevel(int levelIndex) {
  final completedLevels = localLevelPack.take(levelIndex).toList();

  return PlayerProgress.initial().copyWith(
    currentLevelIndex: levelIndex,
    unlockedLevelIndex: levelIndex,
    completedLevelIds: completedLevels.map((level) => level.id).toSet(),
    bestMovesByLevel: {
      for (final level in completedLevels) level.id: level.rows.join().length,
    },
    streakDays: 7,
    hintCount: 2,
    lastCompletionDate: '2026-08-11',
  );
}

void _solveCurrentLevel(PuzzleController controller) {
  while (!controller.board.isCleared) {
    controller.tap(controller.validMoves.first);
  }
}

class _StoreScreenshotFrame extends StatelessWidget {
  const _StoreScreenshotFrame({required this.headline, required this.child});

  final String headline;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArrowPuzzleColors.canvas,
      body: Column(
        children: [
          Container(
            height: 64,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            alignment: Alignment.centerLeft,
            color: ArrowPuzzleColors.primaryDark,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                headline,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MemoryProgressStore implements PuzzleProgressStore {
  @override
  Future<PlayerProgress> load() async => PlayerProgress.initial();

  @override
  Future<void> save(PlayerProgress progress) async {}
}
