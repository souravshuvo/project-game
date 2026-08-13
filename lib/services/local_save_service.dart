import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../game/models/save_data.dart';
import '../game/world/world_config.dart';

class LocalSaveService {
  const LocalSaveService();

  static const MethodChannel _channel = MethodChannel(
    WorldConfig.bestScoreChannel,
  );
  static const MethodChannel _settingsChannel = MethodChannel(
    WorldConfig.settingsChannel,
  );
  static int _memoryBestScore = 0;
  static int _memoryCompletedChallengeSteps = 0;
  static bool _memorySoundEnabled = true;
  static bool _memoryHapticsEnabled = true;

  Future<SaveData> load() async {
    var completedChallengeSteps = _memoryCompletedChallengeSteps;
    var soundEnabled = _memorySoundEnabled;
    var hapticsEnabled = _memoryHapticsEnabled;

    try {
      final score = await _channel.invokeMethod<int>('loadBestScore');
      _memoryBestScore = math.max(_memoryBestScore, score ?? 0);
    } on MissingPluginException {
    } on PlatformException {}

    try {
      final settings = await _settingsChannel.invokeMapMethod<String, Object?>(
        'loadSettings',
      );
      if (settings != null) {
        completedChallengeSteps =
            settings['completedChallengeSteps'] as int? ??
            completedChallengeSteps;
        soundEnabled = settings['soundEnabled'] as bool? ?? soundEnabled;
        hapticsEnabled = settings['hapticsEnabled'] as bool? ?? hapticsEnabled;
      }
    } on MissingPluginException {
    } on PlatformException {}

    _memoryCompletedChallengeSteps = completedChallengeSteps;
    _memorySoundEnabled = soundEnabled;
    _memoryHapticsEnabled = hapticsEnabled;

    return SaveData(
      bestScore: _memoryBestScore,
      completedChallengeSteps: _memoryCompletedChallengeSteps,
      soundEnabled: _memorySoundEnabled,
      hapticsEnabled: _memoryHapticsEnabled,
    );
  }

  Future<void> saveBestScore(int score) async {
    _memoryBestScore = math.max(_memoryBestScore, score);

    try {
      await _channel.invokeMethod<void>('saveBestScore', <String, int>{
        'score': _memoryBestScore,
      });
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  Future<void> saveFeedbackSettings({
    required bool soundEnabled,
    required bool hapticsEnabled,
  }) async {
    _memorySoundEnabled = soundEnabled;
    _memoryHapticsEnabled = hapticsEnabled;

    try {
      await _settingsChannel.invokeMethod<void>('saveSettings', <String, bool>{
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
      });
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  Future<void> saveCompletedChallengeSteps(int completedSteps) async {
    _memoryCompletedChallengeSteps = math.max(
      _memoryCompletedChallengeSteps,
      completedSteps,
    );

    try {
      await _settingsChannel.invokeMethod<void>('saveSettings', <String, int>{
        'completedChallengeSteps': _memoryCompletedChallengeSteps,
      });
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
