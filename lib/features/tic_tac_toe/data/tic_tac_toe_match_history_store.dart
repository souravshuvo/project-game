import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/match_record.dart';

abstract interface class TicTacToeMatchHistoryStore {
  Future<List<MatchRecord>> loadRecentMatches();

  Future<void> saveRecentMatches(List<MatchRecord> records);
}

class SharedPreferencesTicTacToeMatchHistoryStore
    implements TicTacToeMatchHistoryStore {
  static const _recentMatchesKey = 'pocket_observatory.recent_matches';

  @override
  Future<List<MatchRecord>> loadRecentMatches() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final storedRecords = preferences.getStringList(_recentMatchesKey) ?? [];
      final records = <MatchRecord>[];

      for (final value in storedRecords) {
        final record = _decodeRecord(value);
        if (record != null) {
          records.add(record);
        }
      }

      return records;
    } on Object {
      return const [];
    }
  }

  @override
  Future<void> saveRecentMatches(List<MatchRecord> records) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        _recentMatchesKey,
        records.map((record) => jsonEncode(record.toJson())).toList(),
      );
    } on Object {
      return;
    }
  }

  MatchRecord? _decodeRecord(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, Object?>) {
        return null;
      }

      return MatchRecord.fromJson(decoded);
    } on Object {
      return null;
    }
  }
}
