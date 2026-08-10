class UpgradeDefinition {
  const UpgradeDefinition({
    required this.targetLevel,
    required this.cost,
    required this.unlockedPlots,
    required this.waterCap,
    required this.description,
  });

  final int targetLevel;
  final int cost;
  final int unlockedPlots;
  final int waterCap;
  final String description;
}
