import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/src/game/domain/bot_player.dart';
import 'package:rapid_jump/src/game/domain/game_rules.dart';
import 'package:rapid_jump/src/game/domain/models.dart';

void main() {
  group('Game rules', () {
    test('initial player has only normal opening moves', () {
      final state = MatchState.initial();
      final moves = GameRules.legalMoves(state);

      expect(moves, hasLength(9));
      expect(moves.every((move) => move.kind == MoveKind.normal), isTrue);
      expect(moves.map((move) => move.to).toSet(), {16, 17, 18, 19, 20});
    });

    test('applies a normal move and changes turn', () {
      final state = MatchState.initial();
      final move = GameRules.legalMoves(
        state,
        fromNode: 21,
      ).singleWhere((move) => move.to == 16);

      final nextState = GameRules.applyMove(state, move);

      expect(nextState.occupancy[21], isNull);
      expect(nextState.occupancy[16], Player.player1);
      expect(nextState.currentPlayer, Player.player2);
      expect(nextState.result, isNull);
    });

    test('rejects a move with the wrong player owner', () {
      final state = MatchState.initial();
      final legalMove = GameRules.legalMoves(
        state,
        fromNode: 21,
      ).singleWhere((move) => move.to == 16);
      final wrongPlayerMove = GameMove(
        player: Player.player2,
        from: legalMove.from,
        to: legalMove.to,
        kind: legalMove.kind,
      );

      final nextState = GameRules.applyMove(state, wrongPlayerMove);

      expect(identical(nextState, state), isTrue);
      expect(nextState.occupancy[21], Player.player1);
      expect(nextState.occupancy[16], isNull);
    });

    test('detects a valid capture path', () {
      final occupancy = List<Player?>.filled(37, null);
      occupancy[21] = Player.player1;
      occupancy[16] = Player.player2;
      final state = MatchState(
        occupancy: occupancy,
        currentPlayer: Player.player1,
      );

      final captures = GameRules.captureMovesFrom(state, 21);

      expect(captures, hasLength(1));
      expect(captures.single.to, 11);
      expect(captures.single.capturedNode, 16);
    });

    test('capture removes the opponent bead and can end the match', () {
      final occupancy = List<Player?>.filled(37, null);
      occupancy[21] = Player.player1;
      occupancy[16] = Player.player2;
      final state = MatchState(
        occupancy: occupancy,
        currentPlayer: Player.player1,
      );
      final capture = GameRules.captureMovesFrom(state, 21).single;

      final nextState = GameRules.applyMove(state, capture);

      expect(nextState.occupancy[21], isNull);
      expect(nextState.occupancy[16], isNull);
      expect(nextState.occupancy[11], Player.player1);
      expect(nextState.result?.winner, Player.player1);
      expect(nextState.result?.reason, MatchEndReason.capturedAll);
    });

    test('keeps the same bead active for an optional capture chain', () {
      final occupancy = List<Player?>.filled(37, null);
      occupancy[26] = Player.player1;
      occupancy[22] = Player.player2;
      occupancy[14] = Player.player2;
      final state = MatchState(
        occupancy: occupancy,
        currentPlayer: Player.player1,
      );
      final capture = GameRules.captureMovesFrom(
        state,
        26,
      ).singleWhere((move) => move.to == 18);

      final nextState = GameRules.applyMove(state, capture);
      final chainMoves = GameRules.legalMoves(nextState);

      expect(nextState.isCaptureChain, isTrue);
      expect(nextState.chainNode, 18);
      expect(nextState.currentPlayer, Player.player1);
      expect(chainMoves, hasLength(1));
      expect(chainMoves.single.to, 10);
      expect(chainMoves.single.capturedNode, 14);
    });

    test('can end an optional capture chain', () {
      final occupancy = List<Player?>.filled(37, null);
      occupancy[26] = Player.player1;
      occupancy[22] = Player.player2;
      occupancy[14] = Player.player2;
      final state = MatchState(
        occupancy: occupancy,
        currentPlayer: Player.player1,
      );
      final capture = GameRules.captureMovesFrom(
        state,
        26,
      ).singleWhere((move) => move.to == 18);

      final chainState = GameRules.applyMove(state, capture);
      final nextState = GameRules.endCaptureChain(chainState);

      expect(nextState.isCaptureChain, isFalse);
      expect(nextState.currentPlayer, Player.player2);
    });

    test('bot chooses only legal moves and prefers captures on normal', () {
      final occupancy = List<Player?>.filled(37, null);
      occupancy[21] = Player.player1;
      occupancy[16] = Player.player2;
      final state = MatchState(
        occupancy: occupancy,
        currentPlayer: Player.player1,
      );

      final move = BotPlayer.chooseMove(state, BotDifficulty.normal);

      expect(move, isNotNull);
      expect(move!.kind, MoveKind.capture);
      expect(GameRules.legalMoves(state), contains(move));
    });

    test('detects a blocked next player as a loss', () {
      final occupancy = List<Player?>.filled(37, null);
      occupancy[0] = Player.player2;
      occupancy[1] = Player.player1;
      occupancy[2] = Player.player1;
      occupancy[4] = Player.player1;
      occupancy[8] = Player.player1;
      final state = MatchState(
        occupancy: occupancy,
        currentPlayer: Player.player1,
      );
      final move = GameRules.legalMoves(
        state,
        fromNode: 4,
      ).singleWhere((move) => move.to == 3);

      final nextState = GameRules.applyMove(state, move);

      expect(nextState.result?.winner, Player.player1);
      expect(nextState.result?.reason, MatchEndReason.blocked);
    });
  });
}
