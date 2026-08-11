import 'package:flutter/material.dart';

import 'features/match_puzzle/application/puzzle_controller.dart';
import 'features/match_puzzle/data/local_level_pack.dart';
import 'features/match_puzzle/data/local_progress_store.dart';
import 'features/match_puzzle/domain/player_progress.dart';
import 'features/match_puzzle/domain/puzzle_engine.dart';
import 'features/match_puzzle/presentation/pages/puzzle_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressStore = SharedPreferencesMatchProgressStore();
  final initialProgress = await progressStore.load();

  runApp(
    SignalWorkshopApp(
      progressStore: progressStore,
      initialProgress: initialProgress,
    ),
  );
}

class SignalWorkshopApp extends StatefulWidget {
  const SignalWorkshopApp({
    super.key,
    required this.progressStore,
    required this.initialProgress,
  });

  final MatchProgressStore progressStore;
  final PlayerProgress initialProgress;

  @override
  State<SignalWorkshopApp> createState() => _SignalWorkshopAppState();
}

class _SignalWorkshopAppState extends State<SignalWorkshopApp> {
  late final PuzzleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PuzzleController(
      engine: const PuzzleEngine(),
      levels: localLevelPack,
      progressStore: widget.progressStore,
      initialProgress: widget.initialProgress,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signal Workshop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3E6B5A)),
        textTheme: Typography.material2021().black.apply(
          bodyColor: const Color(0xFF1D2B2A),
          displayColor: const Color(0xFF1D2B2A),
        ),
      ),
      home: PuzzlePage(controller: _controller),
    );
  }
}
