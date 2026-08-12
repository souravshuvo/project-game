abstract interface class GameAnalytics {
  Future<void> logEvent(String name, Map<String, Object> parameters);
}

class NoopGameAnalytics implements GameAnalytics {
  const NoopGameAnalytics();

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {}
}

class GameAnalyticsEvents {
  const GameAnalyticsEvents._();

  static const appSessionStarted = 'app_session_started';
  static const homeViewed = 'home_viewed';
  static const gameOpened = 'game_opened';
  static const levelSelectViewed = 'level_select_viewed';
  static const levelStart = 'level_start';
  static const shotFired = 'shot_fired';
  static const invalidAim = 'invalid_aim';
  static const shotMissed = 'shot_missed';
  static const bubbleAttached = 'bubble_attached';
  static const matchPopped = 'match_popped';
  static const floatingDropped = 'floating_dropped';
  static const levelEnd = 'level_end';
  static const resultAction = 'result_action';
  static const settingsChanged = 'settings_changed';
  static const adLoadStart = 'ad_load_start';
  static const adLoadSuccess = 'ad_load_success';
  static const adLoadFailed = 'ad_load_failed';
  static const adShowAttempt = 'ad_show_attempt';
  static const adShow = 'ad_show';
  static const adShowFailed = 'ad_show_failed';
  static const adDismissed = 'ad_dismissed';
  static const adSkipped = 'ad_skipped';
}
