import 'package:flutter/foundation.dart';

import 'game_progress.dart';

class GameSettings extends ChangeNotifier {
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  GameProgress _progress = const GameProgress();

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  GameProgress get progress => _progress;

  void setSoundEnabled(bool value) {
    if (_soundEnabled == value) {
      return;
    }
    _soundEnabled = value;
    notifyListeners();
  }

  void setHapticsEnabled(bool value) {
    if (_hapticsEnabled == value) {
      return;
    }
    _hapticsEnabled = value;
    notifyListeners();
  }

  int recordGoal({
    required int challengeId,
    required int challengeIndex,
    required int attempt,
    required int totalChallenges,
  }) {
    _progress = _progress.recordGoal(
      challengeId: challengeId,
      challengeIndex: challengeIndex,
      attempt: attempt,
      totalChallenges: totalChallenges,
    );
    notifyListeners();
    return _progress.bestStarsFor(challengeId);
  }

  void resetProgress() {
    _progress = const GameProgress();
    notifyListeners();
  }
}
