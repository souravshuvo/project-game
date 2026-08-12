import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/game_progress.dart';

abstract class GameProgressStore {
  Future<GameProgress> load();
  Future<void> save(GameProgress progress);
  Future<void> clear();
}

class MethodChannelGameProgressStore implements GameProgressStore {
  const MethodChannelGameProgressStore();

  static const MethodChannel _channel = MethodChannel(
    'emoji_chor_police/progress',
  );

  @override
  Future<GameProgress> load() async {
    try {
      final raw = await _channel.invokeMethod<String>('load');
      if (raw == null || raw.trim().isEmpty) {
        return GameProgress.empty();
      }
      return decodeGameProgress(raw);
    } on Object {
      return GameProgress.empty();
    }
  }

  @override
  Future<void> save(GameProgress progress) async {
    try {
      await _channel.invokeMethod<void>('save', <String, Object?>{
        'json': encodeGameProgress(progress),
      });
    } on Object {
      return;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _channel.invokeMethod<void>('clear');
    } on Object {
      return;
    }
  }
}

String encodeGameProgress(GameProgress progress) {
  return jsonEncode(progress.toJson());
}

GameProgress decodeGameProgress(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map<Object?, Object?>) {
    return GameProgress.empty();
  }
  return GameProgress.fromJson(
    decoded.map((key, value) => MapEntry('$key', value)),
  );
}
