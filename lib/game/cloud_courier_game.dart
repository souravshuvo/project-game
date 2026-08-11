import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'components/hazard_component.dart';
import 'components/platform_component.dart';
import 'components/player_component.dart';
import 'models/run_state.dart';
import 'systems/collision_system.dart';
import 'systems/score_system.dart';
import 'world/spawn_controller.dart';
import 'world/world_config.dart';

class CloudCourierGame {
  CloudCourierGame({
    SpawnController? spawnController,
    CollisionSystem collisionSystem = const CollisionSystem(),
    ScoreSystem? scoreSystem,
  }) : _spawnController = spawnController ?? SpawnController(),
       _collisionSystem = collisionSystem,
       _scoreSystem = scoreSystem ?? ScoreSystem();

  final PlayerComponent player = PlayerComponent();
  final List<PlatformComponent> platforms = <PlatformComponent>[];
  final List<HazardComponent> hazards = <HazardComponent>[];

  final SpawnController _spawnController;
  final CollisionSystem _collisionSystem;
  final ScoreSystem _scoreSystem;

  Size viewport = Size.zero;
  RunPhase phase = RunPhase.ready;
  double cameraY = 0;
  DeathReason deathReason = DeathReason.none;
  bool lastRunWasNewBest = false;

  double _startPlatformTop = 0;

  bool get hasViewport => viewport.width > 0 && viewport.height > 0;
  int get score => _scoreSystem.score;
  int get bestScore => _scoreSystem.bestScore;
  Rect get playerRect => player.rect;

  void configureViewport(Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final firstLayout = !hasViewport;
    viewport = size;

    if (firstLayout) {
      _resetWorld();
    }
  }

  void setBestScore(int value) {
    _scoreSystem.setBestScore(value);
  }

  void startRun() {
    _resetWorld();
    phase = RunPhase.playing;
    player.launch();
  }

  bool step(double dt, int inputAxis) {
    if (phase != RunPhase.playing) {
      return false;
    }

    player.applyHorizontalInput(dt, inputAxis);
    final previousBottom = player.y + player.size.height;
    player.step(dt, viewport);

    final landing = _collisionSystem.landingPlatform(
      player: player,
      previousBottom: previousBottom,
      platforms: platforms,
    );
    if (landing != null) {
      player.landOn(landing.top);
    }

    _updateCameraAndScore(dt);
    _spawnController.ensurePlatformsAhead(
      viewport: viewport,
      cameraY: cameraY,
      score: score,
      platforms: platforms,
      hazards: hazards,
    );
    _spawnController.trimBelowCamera(
      cameraY: cameraY,
      viewportHeight: viewport.height,
      platforms: platforms,
      hazards: hazards,
    );

    if (_collisionSystem.touchesHazard(player: player, hazards: hazards)) {
      return _finishRun(DeathReason.hazard);
    }

    if (_collisionSystem.fellBelowCamera(
      player: player,
      cameraY: cameraY,
      viewportHeight: viewport.height,
    )) {
      return _finishRun(DeathReason.fall);
    }

    return false;
  }

  void _updateCameraAndScore(double dt) {
    final targetCameraY = player.y - viewport.height * WorldConfig.cameraAnchor;
    cameraY = math.min(
      cameraY,
      cameraY + (targetCameraY - cameraY) * dt * WorldConfig.cameraEase,
    );
    _scoreSystem.updateHeight(
      startPlatformTop: _startPlatformTop,
      playerY: player.y,
    );
  }

  void _resetWorld() {
    phase = RunPhase.ready;
    _startPlatformTop = WorldConfig.startPlatformTop(viewport);
    cameraY = 0;
    deathReason = DeathReason.none;
    lastRunWasNewBest = false;
    _scoreSystem.resetRun();
    player.reset(viewport: viewport, platformTop: _startPlatformTop);
    _spawnController.reset(
      viewport: viewport,
      startPlatformTop: _startPlatformTop,
      platforms: platforms,
      hazards: hazards,
    );
    _spawnController.ensurePlatformsAhead(
      viewport: viewport,
      cameraY: cameraY,
      score: score,
      platforms: platforms,
      hazards: hazards,
    );
  }

  bool _finishRun(DeathReason reason) {
    phase = RunPhase.gameOver;
    player.stop();
    deathReason = reason;
    lastRunWasNewBest = _scoreSystem.finishRun();
    return lastRunWasNewBest;
  }
}
