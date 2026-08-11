import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../game/models/save_data.dart';
import '../game/world/world_config.dart';

class LocalSaveService {
  const LocalSaveService();

  static const MethodChannel _channel = MethodChannel(
    WorldConfig.bestScoreChannel,
  );
  static int _memoryBestScore = 0;

  Future<SaveData> load() async {
    try {
      final score = await _channel.invokeMethod<int>('loadBestScore');
      _memoryBestScore = math.max(_memoryBestScore, score ?? 0);
      return SaveData(bestScore: _memoryBestScore);
    } on MissingPluginException {
      return SaveData(bestScore: _memoryBestScore);
    } on PlatformException {
      return SaveData(bestScore: _memoryBestScore);
    }
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
}
