import 'package:flutter_test/flutter_test.dart';
import 'package:sixteen_breed/src/game/domain/game_rules.dart';
import 'package:sixteen_breed/src/game/domain/models.dart';

void main() {
  test('initial state has correct beads and legal moves', () {
    final state = GameRules.initialState();
    final moves = GameRules.legalMoves(state);

    expect(state.beadCount(Player.player1), 16);
    expect(state.beadCount(Player.player2), 16);
    expect(moves, hasLength(9));
    expect(moves.every((move) => !move.isCapture), isTrue);
  });

  test('initial state is sourced from the approved placement', () {
    final state = GameRules.initialState();

    expect(state.occupancy[0], Player.player1);
    expect(state.occupancy[15], Player.player1);
    expect(state.occupancy[16], isNull);
    expect(state.occupancy[20], isNull);
    expect(state.occupancy[21], Player.player2);
    expect(state.occupancy[36], Player.player2);
  });

  test('captures are optional when normal moves are also available', () {
    final state = _customState({
      11: Player.player1,
      12: Player.player1,
      16: Player.player2,
      30: Player.player2,
    });

    final moves = GameRules.legalMoves(state, fromNode: 11);

    expect(moves.any((move) => move.kind == MoveKind.normal), isTrue);
    expect(moves.any((move) => move.kind == MoveKind.capture), isTrue);
  });

  test('backward captures are allowed along approved jump paths', () {
    final state = _customState({
      21: Player.player1,
      16: Player.player2,
      30: Player.player2,
    });

    final captures = GameRules.captureMovesFrom(state, 21);

    expect(
      captures,
      contains(
        const GameMove(
          player: Player.player1,
          from: 21,
          to: 11,
          kind: MoveKind.capture,
          capturedNode: 16,
        ),
      ),
    );
  });

  test('generates capture when opponent bead can be jumped', () {
    final state = _customState({
      11: Player.player1,
      16: Player.player2,
      30: Player.player2,
    });

    final captures = GameRules.captureMovesFrom(state, 11);

    expect(
      captures,
      contains(
        const GameMove(
          player: Player.player1,
          from: 11,
          to: 21,
          kind: MoveKind.capture,
          capturedNode: 16,
        ),
      ),
    );
  });

  test('applies capture and opens optional multi-capture chain', () {
    final state = _customState({
      11: Player.player1,
      16: Player.player2,
      22: Player.player2,
    });
    const firstCapture = GameMove(
      player: Player.player1,
      from: 11,
      to: 21,
      kind: MoveKind.capture,
      capturedNode: 16,
    );

    final next = GameRules.applyMove(state, firstCapture);

    expect(next.currentPlayer, Player.player1);
    expect(next.chainNode, 21);
    expect(next.occupancy[11], isNull);
    expect(next.occupancy[16], isNull);
    expect(next.occupancy[21], Player.player1);
    expect(
      GameRules.legalMoves(next),
      contains(
        const GameMove(
          player: Player.player1,
          from: 21,
          to: 23,
          kind: MoveKind.capture,
          capturedNode: 22,
        ),
      ),
    );
  });

  test('ending capture chain passes the turn', () {
    final state = _customState({
      11: Player.player1,
      16: Player.player2,
      22: Player.player2,
    });
    final chainState = GameRules.applyMove(
      state,
      const GameMove(
        player: Player.player1,
        from: 11,
        to: 21,
        kind: MoveKind.capture,
        capturedNode: 16,
      ),
    );

    final next = GameRules.endCaptureChain(chainState);

    expect(next.currentPlayer, Player.player2);
    expect(next.chainNode, isNull);
  });

  test('capture chain allows only captures from the chain bead', () {
    final state = _customState({
      11: Player.player1,
      12: Player.player1,
      16: Player.player2,
      22: Player.player2,
    });
    final chainState = GameRules.applyMove(
      state,
      const GameMove(
        player: Player.player1,
        from: 11,
        to: 21,
        kind: MoveKind.capture,
        capturedNode: 16,
      ),
    );

    expect(GameRules.normalMovesFrom(chainState, 21), isEmpty);
    expect(GameRules.legalMoves(chainState, fromNode: 12), isEmpty);
    expect(
      GameRules.legalMoves(chainState).every((move) => move.isCapture),
      isTrue,
    );
  });

  test('capturing the last opposing bead wins', () {
    final state = _customState({11: Player.player1, 16: Player.player2});

    final next = GameRules.applyMove(
      state,
      const GameMove(
        player: Player.player1,
        from: 11,
        to: 21,
        kind: MoveKind.capture,
        capturedNode: 16,
      ),
    );

    expect(next.result?.winner, Player.player1);
    expect(next.result?.reason, MatchEndReason.capturedAll);
  });

  test('blocked opponent loses after the active player moves', () {
    final occupancy = List<Player?>.filled(37, Player.player1);
    occupancy[18] = Player.player2;
    occupancy[35] = null;
    final state = MatchState(
      occupancy: occupancy,
      currentPlayer: Player.player1,
    );

    final next = GameRules.applyMove(
      state,
      const GameMove(
        player: Player.player1,
        from: 34,
        to: 35,
        kind: MoveKind.normal,
      ),
    );

    expect(next.result?.winner, Player.player1);
    expect(next.result?.reason, MatchEndReason.blocked);
  });
}

MatchState _customState(Map<int, Player> pieces) {
  final occupancy = List<Player?>.filled(37, null);
  for (final entry in pieces.entries) {
    occupancy[entry.key] = entry.value;
  }
  return MatchState(occupancy: occupancy, currentPlayer: Player.player1);
}
