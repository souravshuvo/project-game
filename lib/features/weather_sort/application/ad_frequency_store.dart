import 'package:shared_preferences/shared_preferences.dart';

import 'ad_frequency_policy.dart';

abstract interface class AdFrequencyStore {
  Future<InterstitialFrequencyState> load();

  Future<void> save(InterstitialFrequencyState state);
}

final class SharedPreferencesAdFrequencyStore implements AdFrequencyStore {
  static const _completedTransitionsKey =
      'weather_sort.ads.completed_transitions_since_interstitial';
  static const _lastShownAtMillisKey =
      'weather_sort.ads.last_interstitial_shown_at_millis';

  @override
  Future<InterstitialFrequencyState> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      return InterstitialFrequencyState(
        completedLevelTransitionsSinceInterstitial:
            preferences.getInt(_completedTransitionsKey) ?? 0,
        lastInterstitialShownAtMillis: preferences.getInt(
          _lastShownAtMillisKey,
        ),
        sessionInterstitialShowCount: 0,
      );
    } on Object {
      return InterstitialFrequencyState.initial();
    }
  }

  @override
  Future<void> save(InterstitialFrequencyState state) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt(
        _completedTransitionsKey,
        state.completedLevelTransitionsSinceInterstitial,
      );
      final lastShownAtMillis = state.lastInterstitialShownAtMillis;
      if (lastShownAtMillis == null) {
        await preferences.remove(_lastShownAtMillisKey);
      } else {
        await preferences.setInt(_lastShownAtMillisKey, lastShownAtMillis);
      }
    } on Object {
      return;
    }
  }
}
