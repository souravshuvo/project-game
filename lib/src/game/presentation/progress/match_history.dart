import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../domain/models.dart';

class MatchHistoryEntry {
  const MatchHistoryEntry({
    required this.completedAt,
    required this.mode,
    required this.winner,
    required this.reason,
    required this.moveCount,
    required this.captureCount,
    required this.player1Beads,
    required this.player2Beads,
    this.botDifficulty,
  });

  final DateTime completedAt;
  final MatchMode mode;
  final BotDifficulty? botDifficulty;
  final Player? winner;
  final MatchEndReason reason;
  final int moveCount;
  final int captureCount;
  final int player1Beads;
  final int player2Beads;

  bool get isDraw => winner == null;

  String get modeLabel {
    final difficulty = botDifficulty;
    if (difficulty == null) {
      return mode.label;
    }
    return '${mode.label} - ${difficulty.label}';
  }

  String get resultLabel {
    if (winner == null) {
      return 'Draw';
    }
    if (mode == MatchMode.playerVsBot) {
      return winner == Player.player1 ? 'You won' : 'Bot won';
    }
    return '${winner!.label} won';
  }

  String get reasonLabel => switch (reason) {
    MatchEndReason.capturedAll => 'Captured all beads',
    MatchEndReason.blocked => 'Blocked opponent',
    MatchEndReason.repetition => 'Repeated position',
    MatchEndReason.noCaptureLimit => 'No-capture limit',
  };

  Map<String, Object?> toJson() {
    return {
      'completedAt': completedAt.toIso8601String(),
      'mode': mode.name,
      'botDifficulty': botDifficulty?.name,
      'winner': winner?.name,
      'reason': reason.name,
      'moveCount': moveCount,
      'captureCount': captureCount,
      'player1Beads': player1Beads,
      'player2Beads': player2Beads,
    };
  }

  static MatchHistoryEntry? fromJson(Object? value) {
    if (value is! Map<String, Object?>) {
      return null;
    }

    final completedAt = DateTime.tryParse('${value['completedAt']}');
    final mode = _enumByName(MatchMode.values, value['mode']);
    final reason = _enumByName(MatchEndReason.values, value['reason']);
    final winner = _enumByName(Player.values, value['winner']);
    final botDifficulty = _enumByName(
      BotDifficulty.values,
      value['botDifficulty'],
    );

    if (completedAt == null || mode == null || reason == null) {
      return null;
    }

    return MatchHistoryEntry(
      completedAt: completedAt,
      mode: mode,
      botDifficulty: botDifficulty,
      winner: winner,
      reason: reason,
      moveCount: _intValue(value['moveCount']),
      captureCount: _intValue(value['captureCount']),
      player1Beads: _intValue(value['player1Beads']),
      player2Beads: _intValue(value['player2Beads']),
    );
  }

  static T? _enumByName<T extends Enum>(List<T> values, Object? name) {
    if (name == null) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }

  static int _intValue(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }
}

class MatchHistoryController extends ChangeNotifier {
  MatchHistoryController({this.onChanged});

  final ValueChanged<String>? onChanged;
  List<MatchHistoryEntry> _entries = const [];

  List<MatchHistoryEntry> get entries => List.unmodifiable(_entries);
  bool get isEmpty => _entries.isEmpty;

  void add(MatchHistoryEntry entry) {
    _entries = [entry, ..._entries].take(20).toList(growable: false);
    _persist();
  }

  void clear() {
    if (_entries.isEmpty) {
      return;
    }
    _entries = const [];
    _persist();
  }

  void restoreFromJson(String rawJson, {bool notify = true}) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List<Object?>) {
        return;
      }
      _entries = [
        for (final item in decoded)
          if (MatchHistoryEntry.fromJson(item) case final entry?) entry,
      ].take(20).toList(growable: false);
      if (notify) {
        notifyListeners();
      }
    } on FormatException {
      _entries = const [];
      if (notify) {
        notifyListeners();
      }
    }
  }

  String toRawJson() {
    return jsonEncode([for (final entry in _entries) entry.toJson()]);
  }

  void _persist() {
    onChanged?.call(toRawJson());
    notifyListeners();
  }
}

class MatchHistoryScope extends InheritedNotifier<MatchHistoryController> {
  const MatchHistoryScope({
    super.key,
    required MatchHistoryController controller,
    required super.child,
  }) : super(notifier: controller);

  static MatchHistoryController watch(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MatchHistoryScope>();
    assert(scope != null, 'MatchHistoryScope is missing from the widget tree.');
    return scope!.notifier!;
  }

  static MatchHistoryController read(BuildContext context) {
    final inherited = context
        .getElementForInheritedWidgetOfExactType<MatchHistoryScope>()
        ?.widget;
    final scope = inherited as MatchHistoryScope?;
    assert(scope != null, 'MatchHistoryScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}
