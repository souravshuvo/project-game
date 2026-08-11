enum FoodType { seed, brightSeed }

extension FoodTypeRules on FoodType {
  int get score => switch (this) {
    FoodType.seed => 10,
    FoodType.brightSeed => 30,
  };

  double get playerGrowth => switch (this) {
    FoodType.seed => 28,
    FoodType.brightSeed => 56,
  };

  double get botGrowth => playerGrowth * 0.65;

  double get radius => switch (this) {
    FoodType.seed => 8,
    FoodType.brightSeed => 11,
  };
}
