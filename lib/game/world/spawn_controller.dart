import 'package:flutter/material.dart';

import '../components/hazard_component.dart';
import '../components/pickup_component.dart';
import '../components/platform_component.dart';
import '../models/spawn_pattern.dart';
import '../systems/difficulty_system.dart';
import 'pattern_catalog.dart';
import 'world_config.dart';

class SpawnController {
  SpawnController({
    PatternCatalog? patternCatalog,
    DifficultySystem difficultySystem = const DifficultySystem(),
  }) : _patternCatalog = patternCatalog ?? PatternCatalog(),
       _difficultySystem = difficultySystem;

  final PatternCatalog _patternCatalog;
  final DifficultySystem _difficultySystem;

  double lastPlatformTop = 0;
  double lastPlatformCenterX = 0;
  int platformsSpawned = 0;

  void reset({
    required Size viewport,
    required double startPlatformTop,
    required List<PlatformComponent> platforms,
    required List<HazardComponent> hazards,
    required List<PickupComponent> pickups,
  }) {
    platforms.clear();
    hazards.clear();
    pickups.clear();
    lastPlatformTop = startPlatformTop;
    lastPlatformCenterX = viewport.width / 2;
    platformsSpawned = 0;

    final starterWidth = WorldConfig.starterPlatformWidth(viewport);
    platforms.add(
      PlatformComponent(
        viewport.width / 2 - starterWidth / 2,
        startPlatformTop,
        starterWidth,
        16,
      ),
    );
  }

  void ensurePlatformsAhead({
    required Size viewport,
    required double cameraY,
    required int score,
    required List<PlatformComponent> platforms,
    required List<HazardComponent> hazards,
    required List<PickupComponent> pickups,
  }) {
    final spawnTop = cameraY - viewport.height * 0.82;

    while (lastPlatformTop > spawnTop) {
      final progress = _difficultySystem.progressForScore(score);
      final pattern = _patternCatalog.nextPattern(
        platformsSpawned: platformsSpawned,
        difficulty: progress,
      );
      final width = _difficultySystem.platformWidth(pattern, progress);
      final gap = _difficultySystem.verticalGap(pattern, progress);
      final offset = _difficultySystem.horizontalOffset(pattern);
      final centerMin = width / 2 + 22;
      final centerMax = viewport.width - width / 2 - 22;
      final centerX = (lastPlatformCenterX + offset)
          .clamp(centerMin, centerMax)
          .toDouble();
      final top = lastPlatformTop - gap;
      final platform = PlatformComponent(centerX - width / 2, top, width, 14);

      platforms.add(platform);
      platformsSpawned += 1;

      if (pattern.hazardSlot != HazardSlot.none &&
          platformsSpawned > WorldConfig.firstHazardPlatform &&
          platform.width >= WorldConfig.hazardMinPlatformWidth) {
        hazards.add(HazardComponent.fromPlatform(platform, pattern.hazardSlot));
      }
      if (pattern.pickupSlot != PickupSlot.none) {
        pickups.add(_pickupFromPlatform(platform, pattern.pickupSlot));
      }

      lastPlatformCenterX = centerX;
      lastPlatformTop = top;
    }
  }

  void trimBelowCamera({
    required double cameraY,
    required double viewportHeight,
    required List<PlatformComponent> platforms,
    required List<HazardComponent> hazards,
    required List<PickupComponent> pickups,
  }) {
    final trimY = cameraY + viewportHeight + WorldConfig.trimMargin;
    platforms.removeWhere((platform) => platform.top > trimY);
    hazards.removeWhere((hazard) => hazard.baseY > trimY);
    pickups.removeWhere((pickup) => pickup.position.dy > trimY);
  }

  PickupComponent _pickupFromPlatform(
    PlatformComponent platform,
    PickupSlot slot,
  ) {
    final x = switch (slot) {
      PickupSlot.left => platform.left + platform.width * 0.28,
      PickupSlot.center => platform.left + platform.width * 0.5,
      PickupSlot.right => platform.left + platform.width * 0.72,
      PickupSlot.none => platform.left + platform.width * 0.5,
    };

    return PickupComponent(position: Offset(x, platform.top - 38));
  }
}
