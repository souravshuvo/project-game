import 'package:shared_preferences/shared_preferences.dart';

import '../domain/game_settings.dart';

class LocalSaveData {
  const LocalSaveData({
    required this.bestScore,
    required this.gamesPlayed,
    required this.settings,
    required this.completedGoalIds,
  });

  final int bestScore;
  final int gamesPlayed;
  final GameSettings settings;
  final Set<String> completedGoalIds;
}

class AdFrequencyData {
  const AdFrequencyData({
    required this.completedRunsSinceInterstitial,
    required this.lastInterstitialAtMillis,
  });

  static const empty = AdFrequencyData(
    completedRunsSinceInterstitial: 0,
    lastInterstitialAtMillis: null,
  );

  final int completedRunsSinceInterstitial;
  final int? lastInterstitialAtMillis;

  AdFrequencyData copyWith({
    int? completedRunsSinceInterstitial,
    int? lastInterstitialAtMillis,
  }) {
    return AdFrequencyData(
      completedRunsSinceInterstitial:
          completedRunsSinceInterstitial ?? this.completedRunsSinceInterstitial,
      lastInterstitialAtMillis:
          lastInterstitialAtMillis ?? this.lastInterstitialAtMillis,
    );
  }
}

class LocalSaveStore {
  static const _bestScoreKey = 'trail_arena.best_score';
  static const _gamesPlayedKey = 'trail_arena.games_played';
  static const _soundEnabledKey = 'trail_arena.sound_enabled';
  static const _hapticsEnabledKey = 'trail_arena.haptics_enabled';
  static const _controlSensitivityKey = 'trail_arena.control_sensitivity';
  static const _completedGoalIdsKey = 'trail_arena.completed_goal_ids';
  static const _adRunsSinceInterstitialKey =
      'trail_arena.ad_runs_since_interstitial';
  static const _adLastInterstitialAtKey = 'trail_arena.ad_last_interstitial_at';

  Future<LocalSaveData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final sensitivity = prefs.getDouble(_controlSensitivityKey) ?? 1;
    return LocalSaveData(
      bestScore: prefs.getInt(_bestScoreKey) ?? 0,
      gamesPlayed: prefs.getInt(_gamesPlayedKey) ?? 0,
      settings: GameSettings(
        soundEnabled: prefs.getBool(_soundEnabledKey) ?? true,
        hapticsEnabled: prefs.getBool(_hapticsEnabledKey) ?? true,
        controlSensitivity: sensitivity.clamp(0.75, 1.35).toDouble(),
      ),
      completedGoalIds:
          (prefs.getStringList(_completedGoalIdsKey) ?? const <String>[])
              .toSet(),
    );
  }

  Future<void> saveRun({
    required int score,
    Set<String> completedGoalIds = const <String>{},
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    final gamesPlayed = prefs.getInt(_gamesPlayedKey) ?? 0;
    if (score > bestScore) {
      await prefs.setInt(_bestScoreKey, score);
    }
    await prefs.setInt(_gamesPlayedKey, gamesPlayed + 1);
    if (completedGoalIds.isNotEmpty) {
      await saveCompletedGoals(completedGoalIds);
    }
  }

  Future<void> saveCompletedGoals(Set<String> completedGoalIds) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = completedGoalIds.toList()..sort();
    await prefs.setStringList(_completedGoalIdsKey, sorted);
  }

  Future<AdFrequencyData> loadAdFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    return AdFrequencyData(
      completedRunsSinceInterstitial:
          prefs.getInt(_adRunsSinceInterstitialKey) ?? 0,
      lastInterstitialAtMillis: prefs.getInt(_adLastInterstitialAtKey),
    );
  }

  Future<void> saveAdFrequency(AdFrequencyData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _adRunsSinceInterstitialKey,
      data.completedRunsSinceInterstitial,
    );
    final lastAt = data.lastInterstitialAtMillis;
    if (lastAt == null) {
      await prefs.remove(_adLastInterstitialAtKey);
    } else {
      await prefs.setInt(_adLastInterstitialAtKey, lastAt);
    }
  }

  Future<void> saveSettings(GameSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_soundEnabledKey, settings.soundEnabled),
      prefs.setBool(_hapticsEnabledKey, settings.hapticsEnabled),
      prefs.setDouble(_controlSensitivityKey, settings.controlSensitivity),
    ]);
  }
}
