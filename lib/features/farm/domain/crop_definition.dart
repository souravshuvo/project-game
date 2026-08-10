class CropDefinition {
  const CropDefinition({
    required this.id,
    required this.name,
    required this.unlockLevel,
    required this.growDuration,
    required this.seedCost,
    required this.harvestYield,
    required this.sellValue,
  });

  final String id;
  final String name;
  final int unlockLevel;
  final Duration growDuration;
  final int seedCost;
  final int harvestYield;
  final int sellValue;
}
