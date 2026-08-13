enum HazardSlot { none, left, center, right }

enum PickupSlot { none, left, center, right }

class SpawnPattern {
  const SpawnPattern(
    this.horizontalOffset,
    this.verticalGap,
    this.width,
    this.hazardSlot,
    this.pickupSlot,
  );

  final double horizontalOffset;
  final double verticalGap;
  final double width;
  final HazardSlot hazardSlot;
  final PickupSlot pickupSlot;
}
