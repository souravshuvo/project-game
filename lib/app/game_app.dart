import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../game/cloud_courier_game.dart';
import '../game/components/background_component.dart';
import '../game/models/run_state.dart';
import '../game/world/world_config.dart';
import '../services/analytics_service.dart';
import '../services/local_save_service.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/pause_overlay.dart';
import 'overlays/start_overlay.dart';

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: WorldConfig.gameTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1d6f78),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final LocalSaveService _localSaveService = const LocalSaveService();
  final AnalyticsService _analyticsService = const AnalyticsService();
  final CloudCourierGame _game = CloudCourierGame();

  Duration? _previousTick;
  bool _leftHeld = false;
  bool _rightHeld = false;

  int get _inputAxis {
    if (_leftHeld == _rightHeld) {
      return 0;
    }

    return _rightHeld ? 1 : -1;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadSaveData());
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _loadSaveData() async {
    final saveData = await _localSaveService.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _game.setBestScore(saveData.bestScore);
    });
  }

  void _onTick(Duration elapsed) {
    final previous = _previousTick;
    _previousTick = elapsed;

    if (previous == null || !_game.hasViewport) {
      return;
    }

    final dt = math.min(
      (elapsed - previous).inMicroseconds / Duration.microsecondsPerSecond,
      WorldConfig.maxFrameStep,
    );

    if (_game.phase != RunPhase.playing) {
      return;
    }

    setState(() {
      final bestScoreChanged = _game.step(dt, _inputAxis);
      if (_game.phase == RunPhase.gameOver) {
        _analyticsService.runEnded(
          score: _game.score,
          bestScore: _game.bestScore,
          deathReason: _game.deathReason.name,
        );
      }
      if (bestScoreChanged) {
        unawaited(_localSaveService.saveBestScore(_game.bestScore));
      }
    });
  }

  void _startRun() {
    if (!_game.hasViewport) {
      return;
    }

    setState(() {
      _leftHeld = false;
      _rightHeld = false;
      if (_game.phase == RunPhase.gameOver) {
        _analyticsService.restartTapped(previousScore: _game.score);
      }
      _analyticsService.runStarted(bestScoreBefore: _game.bestScore);
      _game.startRun();
    });
  }

  void _setLeftHeld(bool value) {
    if (_game.phase != RunPhase.playing && value) {
      return;
    }

    setState(() {
      _leftHeld = value;
    });
  }

  void _setRightHeld(bool value) {
    if (_game.phase != RunPhase.playing && value) {
      return;
    }

    setState(() {
      _rightHeld = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          _game.configureViewport(size);

          return Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: CloudCourierPainter(_game)),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: HudOverlay(
                    score: _game.score,
                    bestScore: _game.bestScore,
                  ),
                ),
              ),
              if (_game.phase == RunPhase.ready)
                Positioned.fill(child: StartOverlay(onStart: _startRun)),
              if (_game.phase == RunPhase.gameOver)
                Positioned.fill(
                  child: GameOverOverlay(
                    score: _game.score,
                    bestScore: _game.bestScore,
                    deathReason: _game.deathReason,
                    isNewBest: _game.lastRunWasNewBest,
                    onRestart: _startRun,
                  ),
                ),
              if (_game.phase == RunPhase.paused)
                Positioned.fill(child: PauseOverlay(onResume: () {})),
              if (_game.phase == RunPhase.playing)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: GameControls(
                      leftHeld: _leftHeld,
                      rightHeld: _rightHeld,
                      onLeftHeld: _setLeftHeld,
                      onRightHeld: _setRightHeld,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
