class FarmAnalyticsEvents {
  const FarmAnalyticsEvents._();

  static const gameStarted = 'game_started';
  static const saveRestored = 'save_restored';
  static const plotSelected = 'plot_selected';
  static const plotPlanted = 'plot_planted';
  static const plotWatered = 'plot_watered';
  static const cropHarvested = 'crop_harvested';
  static const crateSold = 'crate_sold';
  static const seedPackBought = 'seed_pack_bought';
  static const farmUpgraded = 'farm_upgraded';
  static const offlineProgressApplied = 'offline_progress_applied';
  static const manualSaveTapped = 'manual_save_tapped';
}

abstract class FarmAnalytics {
  void log(String eventName, [Map<String, Object?> properties = const {}]);
}

class NoOpFarmAnalytics implements FarmAnalytics {
  const NoOpFarmAnalytics();

  @override
  void log(String eventName, [Map<String, Object?> properties = const {}]) {}
}
