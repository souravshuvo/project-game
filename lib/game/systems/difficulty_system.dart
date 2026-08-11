import '../models/spawn_pattern.dart';
import '../world/world_config.dart';

class DifficultySystem {
  const DifficultySystem();

  double progressForScore(int score) {
    return (score / 700).clamp(0, 1).toDouble();
  }

  double platformWidth(SpawnPattern pattern, double progress) {
    return (pattern.width - progress * 16).clamp(78.0, double.infinity);
  }

  double verticalGap(SpawnPattern pattern, double progress) {
    return (pattern.verticalGap + progress * 8)
        .clamp(WorldConfig.safeMinVerticalGap, WorldConfig.safeMaxVerticalGap)
        .toDouble();
  }

  double horizontalOffset(SpawnPattern pattern) {
    return pattern.horizontalOffset
        .clamp(
          -WorldConfig.safeMaxHorizontalOffset,
          WorldConfig.safeMaxHorizontalOffset,
        )
        .toDouble();
  }
}
