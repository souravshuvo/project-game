import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'components/hazard_component.dart';
import 'components/pickup_component.dart';
import 'components/platform_component.dart';
import 'components/player_component.dart';
import 'models/challenge_step.dart';
import 'models/run_state.dart';
import 'systems/collision_system.dart';
import 'systems/score_system.dart';
import 'world/challenge_catalog.dart';
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
  final List<PickupComponent> pickups = <PickupComponent>[];

  final SpawnController _spawnController;
  final CollisionSystem _collisionSystem;
  final ScoreSystem _scoreSystem;

  Size viewport = Size.zero;
  RunPhase phase = RunPhase.ready;
  double cameraY = 0;
  double visualTime = 0;
  double landingPulse = 0;
  double hitFlash = 0;
  int landingsThisRun = 0;
  int pickupsThisRun = 0;
  int revivesThisRun = 0;
  int completedChallengeSteps = 0;
  bool lastRunCompletedChallenge = false;
  bool challengeCompletedThisRun = false;
  DeathReason deathReason = DeathReason.none;
  bool lastRunWasNewBest = false;

  double _startPlatformTop = 0;

  bool get hasViewport => viewport.width > 0 && viewport.height > 0;
  int get score => _scoreSystem.score;
  int get bestScore => _scoreSystem.bestScore;
  ChallengeStep get currentChallenge =>
      const ChallengeCatalog().stepForProgress(completedChallengeSteps);
  ChallengeStep get displayedChallenge {
    if ((challengeCompletedThisRun || allChallengesComplete) &&
        completedChallengeSteps > 0) {
      return const ChallengeCatalog().stepForProgress(
        completedChallengeSteps - 1,
      );
    }

    return currentChallenge;
  }

  String get challengeProgressLabel => displayedChallenge.progressLabel(
    score: score,
    landings: landingsThisRun,
    pickups: pickupsThisRun,
    completed: challengeCompletedThisRun || allChallengesComplete,
  );

  bool get allChallengesComplete =>
      completedChallengeSteps >= ChallengeCatalog.totalSteps;
  bool get canRevive => phase == RunPhase.gameOver && revivesThisRun == 0;
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

  void setCompletedChallengeSteps(int value) {
    completedChallengeSteps = value.clamp(0, ChallengeCatalog.totalSteps);
  }

  void startRun() {
    _resetWorld();
    phase = RunPhase.playing;
    player.launch();
  }

  void pauseRun() {
    if (phase == RunPhase.playing) {
      phase = RunPhase.paused;
    }
  }

  void resumeRun() {
    if (phase == RunPhase.paused) {
      phase = RunPhase.playing;
    }
  }

  void resetToMenu() {
    _resetWorld();
  }

  bool reviveAfterAd() {
    if (!canRevive || platforms.isEmpty || !hasViewport) {
      return false;
    }

    final platform = _revivePlatform();
    final safeX = _safeRevivePlayerX(platform);
    player
      ..x = safeX
      ..y = platform.top - player.size.height
      ..velocityX = 0
      ..velocityY = 0;
    player.launch();
    revivesThisRun += 1;
    phase = RunPhase.playing;
    deathReason = DeathReason.none;
    hitFlash = 0;
    landingPulse = 1;
    return true;
  }

  void tick(double dt) {
    visualTime += dt;
    landingPulse = math.max(0, landingPulse - dt * 3.8);
    hitFlash = math.max(0, hitFlash - dt * 2.8);
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
      landingPulse = 1;
      landingsThisRun += 1;
    }

    final pickupIndex = _collisionSystem.touchedPickupIndex(
      player: player,
      pickups: pickups,
    );
    if (pickupIndex >= 0) {
      final pickup = pickups[pickupIndex];
      pickups[pickupIndex] = pickup.markCollected();
      pickupsThisRun += 1;
      _scoreSystem.addBonus(pickup.scoreValue);
    }

    _updateCameraAndScore(dt);
    _checkChallengeProgress();

    _spawnController.ensurePlatformsAhead(
      viewport: viewport,
      cameraY: cameraY,
      score: score,
      platforms: platforms,
      hazards: hazards,
      pickups: pickups,
    );
    _spawnController.trimBelowCamera(
      cameraY: cameraY,
      viewportHeight: viewport.height,
      platforms: platforms,
      hazards: hazards,
      pickups: pickups,
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
    landingPulse = 0;
    hitFlash = 0;
    landingsThisRun = 0;
    pickupsThisRun = 0;
    revivesThisRun = 0;
    lastRunCompletedChallenge = false;
    challengeCompletedThisRun = allChallengesComplete;
    deathReason = DeathReason.none;
    lastRunWasNewBest = false;
    _scoreSystem.resetRun();
    player.reset(viewport: viewport, platformTop: _startPlatformTop);
    _spawnController.reset(
      viewport: viewport,
      startPlatformTop: _startPlatformTop,
      platforms: platforms,
      hazards: hazards,
      pickups: pickups,
    );
    _spawnController.ensurePlatformsAhead(
      viewport: viewport,
      cameraY: cameraY,
      score: score,
      platforms: platforms,
      hazards: hazards,
      pickups: pickups,
    );
  }

  bool _finishRun(DeathReason reason) {
    phase = RunPhase.gameOver;
    player.stop();
    hitFlash = 1;
    deathReason = reason;
    lastRunWasNewBest = _scoreSystem.finishRun();
    return lastRunWasNewBest;
  }

  PlatformComponent _revivePlatform() {
    final visibleTop = cameraY + viewport.height * 0.28;
    final visibleBottom = cameraY + viewport.height * 0.78;
    final visiblePlatforms =
        platforms
            .where(
              (platform) =>
                  platform.top >= visibleTop && platform.top <= visibleBottom,
            )
            .toList()
          ..sort((a, b) => b.top.compareTo(a.top));

    if (visiblePlatforms.isNotEmpty) {
      return visiblePlatforms.first;
    }

    return platforms.reduce(
      (best, platform) => platform.top > best.top ? platform : best,
    );
  }

  double _safeRevivePlayerX(PlatformComponent platform) {
    var centerX = platform.left + platform.width / 2;
    for (final hazard in hazards) {
      if ((hazard.baseY - platform.top).abs() > 1) {
        continue;
      }

      final playerLeft = centerX - player.size.width / 2;
      final playerRight = centerX + player.size.width / 2;
      if (playerRight < hazard.left - 10 || playerLeft > hazard.right + 10) {
        continue;
      }

      final leftCandidate = platform.left + platform.width * 0.24;
      final rightCandidate = platform.left + platform.width * 0.76;
      centerX = hazard.left - platform.left > platform.width / 2
          ? leftCandidate
          : rightCandidate;
      break;
    }

    return (centerX - player.size.width / 2)
        .clamp(0.0, math.max(0.0, viewport.width - player.size.width))
        .toDouble();
  }

  void _checkChallengeProgress() {
    if (challengeCompletedThisRun || allChallengesComplete) {
      return;
    }

    if (currentChallenge.isComplete(
      score: score,
      landings: landingsThisRun,
      pickups: pickupsThisRun,
    )) {
      completedChallengeSteps = math.min(
        completedChallengeSteps + 1,
        ChallengeCatalog.totalSteps,
      );
      challengeCompletedThisRun = true;
      lastRunCompletedChallenge = true;
    }
  }
}
