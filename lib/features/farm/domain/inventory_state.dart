class InventoryState {
  InventoryState({
    required this.seeds,
    Map<String, int> crate = const <String, int>{},
  }) : crate = Map.unmodifiable(
         Map.fromEntries(crate.entries.where((entry) => entry.value > 0)),
       );

  final int seeds;
  final Map<String, int> crate;

  int get totalCrateItems {
    return crate.values.fold(0, (total, count) => total + count);
  }

  bool get hasCrateItems => totalCrateItems > 0;

  int countForCrop(String cropId) => crate[cropId] ?? 0;

  InventoryState copyWith({int? seeds, Map<String, int>? crate}) {
    return InventoryState(
      seeds: seeds ?? this.seeds,
      crate: crate ?? this.crate,
    );
  }

  InventoryState addHarvest(String cropId, int amount) {
    final nextCrate = Map<String, int>.from(crate);
    nextCrate[cropId] = countForCrop(cropId) + amount;
    return copyWith(crate: nextCrate);
  }

  InventoryState clearCrate() {
    return copyWith(crate: const <String, int>{});
  }
}
