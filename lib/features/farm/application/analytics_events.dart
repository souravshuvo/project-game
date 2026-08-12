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
  static const progressReset = 'progress_reset';
  static const screenViewed = 'screen_viewed';
  static const invalidAction = 'invalid_action';
  static const adsInitialized = 'ads_initialized';
  static const adsInitializeSkipped = 'ads_initialize_skipped';
  static const adsInitializeFailed = 'ads_initialize_failed';
  static const adBannerLoadRequested = 'ad_banner_load_requested';
  static const adBannerLoaded = 'ad_banner_loaded';
  static const adBannerFailed = 'ad_banner_failed';
  static const adBannerImpression = 'ad_banner_impression';
  static const adBannerClicked = 'ad_banner_clicked';
  static const adInterstitialLoadRequested = 'ad_interstitial_load_requested';
  static const adInterstitialLoaded = 'ad_interstitial_loaded';
  static const adInterstitialFailed = 'ad_interstitial_failed';
  static const adInterstitialEligible = 'ad_interstitial_eligible';
  static const adInterstitialCapped = 'ad_interstitial_capped';
  static const adInterstitialSkipped = 'ad_interstitial_skipped';
  static const adInterstitialShown = 'ad_interstitial_shown';
  static const adInterstitialDismissed = 'ad_interstitial_dismissed';
  static const adInterstitialShowFailed = 'ad_interstitial_show_failed';
  static const adInterstitialImpression = 'ad_interstitial_impression';
  static const adInterstitialClicked = 'ad_interstitial_clicked';
}

abstract class FarmAnalytics {
  void log(String eventName, [Map<String, Object?> properties = const {}]);
}

class NoOpFarmAnalytics implements FarmAnalytics {
  const NoOpFarmAnalytics();

  @override
  void log(String eventName, [Map<String, Object?> properties = const {}]) {}
}
