import '../components/hazard_component.dart';
import '../components/platform_component.dart';
import '../components/player_component.dart';
import '../world/world_config.dart';

class CollisionSystem {
  const CollisionSystem();

  PlatformComponent? landingPlatform({
    required PlayerComponent player,
    required double previousBottom,
    required List<PlatformComponent> platforms,
  }) {
    if (player.velocityY < 0) {
      return null;
    }

    final playerBottom = player.y + player.size.height;
    for (final platform in platforms) {
      final overlapsHorizontally =
          player.x + player.size.width > platform.left + 8 &&
          player.x < platform.right - 8;
      final crossedTop =
          previousBottom <= platform.top && playerBottom >= platform.top;

      if (overlapsHorizontally && crossedTop) {
        return platform;
      }
    }

    return null;
  }

  bool touchesHazard({
    required PlayerComponent player,
    required List<HazardComponent> hazards,
  }) {
    final playerHitBox = player.rect.deflate(7);
    for (final hazard in hazards) {
      if (playerHitBox.overlaps(hazard.hitBox)) {
        return true;
      }
    }

    return false;
  }

  bool fellBelowCamera({
    required PlayerComponent player,
    required double cameraY,
    required double viewportHeight,
  }) {
    return player.y - cameraY > viewportHeight + WorldConfig.fallMargin;
  }
}
