import 'package:flutter_test/flutter_test.dart';
import 'package:sixteen_breed/src/game/domain/models.dart';
import 'package:sixteen_breed/src/game/presentation/progress/match_history.dart';

void main() {
  test('match history serializes and restores entries', () {
    final controller = MatchHistoryController();
    controller.add(
      MatchHistoryEntry(
        completedAt: DateTime.utc(2026, 8, 13, 10, 30),
        mode: MatchMode.playerVsBot,
        botDifficulty: BotDifficulty.balanced,
        winner: Player.player1,
        reason: MatchEndReason.capturedAll,
        moveCount: 42,
        captureCount: 16,
        player1Beads: 9,
        player2Beads: 0,
      ),
    );

    final restored = MatchHistoryController()
      ..restoreFromJson(controller.toRawJson());

    expect(restored.entries, hasLength(1));
    expect(restored.entries.first.mode, MatchMode.playerVsBot);
    expect(restored.entries.first.botDifficulty, BotDifficulty.balanced);
    expect(restored.entries.first.winner, Player.player1);
    expect(restored.entries.first.moveCount, 42);
    expect(restored.entries.first.captureCount, 16);
  });

  test('match history keeps the newest twenty entries', () {
    final controller = MatchHistoryController();

    for (var i = 0; i < 25; i++) {
      controller.add(
        MatchHistoryEntry(
          completedAt: DateTime.utc(2026, 8, 13, 10, i),
          mode: MatchMode.localTwoPlayer,
          winner: Player.player1,
          reason: MatchEndReason.blocked,
          moveCount: i,
          captureCount: 0,
          player1Beads: 16,
          player2Beads: 16,
        ),
      );
    }

    expect(controller.entries, hasLength(20));
    expect(controller.entries.first.moveCount, 24);
    expect(controller.entries.last.moveCount, 5);
  });
}
