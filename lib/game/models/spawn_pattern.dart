enum HazardSlot { none, left, center, right }

class SpawnPattern {
  const SpawnPattern(
    this.horizontalOffset,
    this.verticalGap,
    this.width,
    this.hazardSlot,
  );

  final double horizontalOffset;
  final double verticalGap;
  final double width;
  final HazardSlot hazardSlot;
}
