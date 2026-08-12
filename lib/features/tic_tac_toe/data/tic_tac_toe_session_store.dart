import 'package:shared_preferences/shared_preferences.dart';

class TicTacToeSessionMetrics {
  const TicTacToeSessionMetrics({
    required this.openCount,
    required this.daysSinceFirstOpen,
    required this.daysSincePreviousOpen,
  });

  final int openCount;
  final int daysSinceFirstOpen;
  final int daysSincePreviousOpen;
}

abstract interface class TicTacToeSessionStore {
  Future<TicTacToeSessionMetrics> recordOpen(DateTime openedAt);
}

class SharedPreferencesTicTacToeSessionStore implements TicTacToeSessionStore {
  static const _firstOpenedAtKey = 'pocket_observatory.first_opened_at';
  static const _previousOpenedAtKey = 'pocket_observatory.previous_opened_at';
  static const _openCountKey = 'pocket_observatory.open_count';

  @override
  Future<TicTacToeSessionMetrics> recordOpen(DateTime openedAt) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final openedAtMs = openedAt.millisecondsSinceEpoch;
      final firstOpenedAtMs = preferences.getInt(_firstOpenedAtKey);
      final previousOpenedAtMs = preferences.getInt(_previousOpenedAtKey);
      final openCount = (preferences.getInt(_openCountKey) ?? 0) + 1;

      await preferences.setInt(
        _firstOpenedAtKey,
        firstOpenedAtMs ?? openedAtMs,
      );
      await preferences.setInt(_previousOpenedAtKey, openedAtMs);
      await preferences.setInt(_openCountKey, openCount);

      return TicTacToeSessionMetrics(
        openCount: openCount,
        daysSinceFirstOpen: _daysBetween(firstOpenedAtMs, openedAt),
        daysSincePreviousOpen: _daysBetween(previousOpenedAtMs, openedAt),
      );
    } on Object {
      return const TicTacToeSessionMetrics(
        openCount: 1,
        daysSinceFirstOpen: 0,
        daysSincePreviousOpen: 0,
      );
    }
  }

  int _daysBetween(int? startedAtMs, DateTime endedAt) {
    if (startedAtMs == null) {
      return 0;
    }

    final startedAt = DateTime.fromMillisecondsSinceEpoch(startedAtMs);
    return endedAt.difference(startedAt).inDays;
  }
}
