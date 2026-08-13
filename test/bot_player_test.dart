import 'package:flutter_test/flutter_test.dart';
import 'package:sixteen_breed/src/game/domain/bot_player.dart';
import 'package:sixteen_breed/src/game/domain/game_rules.dart';
import 'package:sixteen_breed/src/game/domain/models.dart';

void main() {
  test('bot chooses a legal move from the initial board', () {
    final state = GameRules.initialState().copyWith(
      currentPlayer: Player.player2,
    );

    for (final difficulty in BotDifficulty.values) {
      final move = BotPlayer.chooseMove(state, difficulty: difficulty);

      expect(move, isNotNull);
      expect(GameRules.legalMoves(state), contains(move));
    }
  });

  test('easy bot prefers an available capture', () {
    final state = _customState({
      11: Player.player2,
      16: Player.player1,
      30: Player.player1,
    }, currentPlayer: Player.player2);

    final move = BotPlayer.chooseMove(state, difficulty: BotDifficulty.easy);

    expect(move?.isCapture, isTrue);
    expect(move?.capturedNode, 16);
  });

  test('sharp bot chooses a winning capture', () {
    final state = _customState({
      11: Player.player2,
      16: Player.player1,
    }, currentPlayer: Player.player2);

    final move = BotPlayer.chooseMove(state, difficulty: BotDifficulty.sharp);
    final next = GameRules.applyMove(state, move!);

    expect(move.isCapture, isTrue);
    expect(next.result?.winner, Player.player2);
    expect(next.result?.reason, MatchEndReason.capturedAll);
  });

  test('capture chain continuation ramps by difficulty', () {
    final state = _customState({
      11: Player.player2,
      16: Player.player1,
      22: Player.player1,
    }, currentPlayer: Player.player2);
    final chainState = GameRules.applyMove(
      state,
      const GameMove(
        player: Player.player2,
        from: 11,
        to: 21,
        kind: MoveKind.capture,
        capturedNode: 16,
      ),
    );

    expect(
      BotPlayer.shouldContinueCaptureChain(
        chainState,
        difficulty: BotDifficulty.easy,
      ),
      isFalse,
    );
    expect(
      BotPlayer.shouldContinueCaptureChain(
        chainState,
        difficulty: BotDifficulty.balanced,
      ),
      isTrue,
    );
    expect(
      BotPlayer.shouldContinueCaptureChain(
        chainState,
        difficulty: BotDifficulty.sharp,
      ),
      isTrue,
    );
  });
}

MatchState _customState(
  Map<int, Player> pieces, {
  required Player currentPlayer,
}) {
  final occupancy = List<Player?>.filled(37, null);
  for (final entry in pieces.entries) {
    occupancy[entry.key] = entry.value;
  }
  return MatchState(occupancy: occupancy, currentPlayer: currentPlayer);
}
