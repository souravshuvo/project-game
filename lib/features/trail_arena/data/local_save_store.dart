import 'package:shared_preferences/shared_preferences.dart';

class LocalSaveData {
  const LocalSaveData({required this.bestScore, required this.gamesPlayed});

  final int bestScore;
  final int gamesPlayed;
}

class LocalSaveStore {
  static const _bestScoreKey = 'trail_arena.best_score';
  static const _gamesPlayedKey = 'trail_arena.games_played';

  Future<LocalSaveData> load() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalSaveData(
      bestScore: prefs.getInt(_bestScoreKey) ?? 0,
      gamesPlayed: prefs.getInt(_gamesPlayedKey) ?? 0,
    );
  }

  Future<void> saveRun({required int score}) async {
    final prefs = await SharedPreferences.getInstance();
    final bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    final gamesPlayed = prefs.getInt(_gamesPlayedKey) ?? 0;
    if (score > bestScore) {
      await prefs.setInt(_bestScoreKey, score);
    }
    await prefs.setInt(_gamesPlayedKey, gamesPlayed + 1);
  }
}
