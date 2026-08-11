import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/src/game/domain/board_spec.dart';
import 'package:rapid_jump/src/game/domain/board_validator.dart';
import 'package:rapid_jump/src/game/domain/models.dart';

void main() {
  group('Board spec', () {
    test('validates the approved 37-node graph', () {
      final result = BoardValidator.validate();

      expect(result.errors, isEmpty);
      expect(BoardSpec.nodes, hasLength(37));
      expect(BoardSpec.edges, hasLength(76));
      expect(BoardSpec.undirectedJumpPaths, hasLength(56));
      expect(BoardSpec.directionalJumpPaths, hasLength(112));
    });

    test('matches the exact approved node coordinates', () {
      expect(
        BoardSpec.nodes.map((node) => (node.id, node.xRatio, node.yRatio)),
        [
          (0, 0.0, 0.0),
          (1, 0.5, 0.0),
          (2, 1.0, 0.0),
          (3, 0.25, 0.125),
          (4, 0.5, 0.125),
          (5, 0.75, 0.125),
          (6, 0.0, 0.25),
          (7, 0.25, 0.25),
          (8, 0.5, 0.25),
          (9, 0.75, 0.25),
          (10, 1.0, 0.25),
          (11, 0.0, 0.375),
          (12, 0.25, 0.375),
          (13, 0.5, 0.375),
          (14, 0.75, 0.375),
          (15, 1.0, 0.375),
          (16, 0.0, 0.5),
          (17, 0.25, 0.5),
          (18, 0.5, 0.5),
          (19, 0.75, 0.5),
          (20, 1.0, 0.5),
          (21, 0.0, 0.625),
          (22, 0.25, 0.625),
          (23, 0.5, 0.625),
          (24, 0.75, 0.625),
          (25, 1.0, 0.625),
          (26, 0.0, 0.75),
          (27, 0.25, 0.75),
          (28, 0.5, 0.75),
          (29, 0.75, 0.75),
          (30, 1.0, 0.75),
          (31, 0.25, 0.875),
          (32, 0.5, 0.875),
          (33, 0.75, 0.875),
          (34, 0.0, 1.0),
          (35, 0.5, 1.0),
          (36, 1.0, 1.0),
        ],
      );
    });

    test('matches the exact approved direct edges', () {
      expect(BoardSpec.edges.map((edge) => (edge.a, edge.b)), [
        (0, 1),
        (0, 3),
        (1, 2),
        (1, 4),
        (2, 5),
        (3, 4),
        (3, 8),
        (4, 5),
        (4, 8),
        (5, 8),
        (6, 7),
        (6, 11),
        (6, 12),
        (7, 8),
        (7, 12),
        (8, 9),
        (8, 12),
        (8, 13),
        (8, 14),
        (9, 10),
        (9, 14),
        (10, 14),
        (10, 15),
        (11, 12),
        (11, 16),
        (12, 13),
        (12, 16),
        (12, 17),
        (12, 18),
        (13, 14),
        (13, 18),
        (14, 15),
        (14, 18),
        (14, 19),
        (14, 20),
        (15, 20),
        (16, 17),
        (16, 21),
        (16, 22),
        (17, 18),
        (17, 22),
        (18, 19),
        (18, 22),
        (18, 23),
        (18, 24),
        (19, 20),
        (19, 24),
        (20, 24),
        (20, 25),
        (21, 22),
        (21, 26),
        (22, 23),
        (22, 26),
        (22, 27),
        (22, 28),
        (23, 24),
        (23, 28),
        (24, 25),
        (24, 28),
        (24, 29),
        (24, 30),
        (25, 30),
        (26, 27),
        (27, 28),
        (28, 29),
        (28, 31),
        (28, 32),
        (28, 33),
        (29, 30),
        (31, 32),
        (31, 34),
        (32, 33),
        (32, 35),
        (33, 36),
        (34, 35),
        (35, 36),
      ]);
    });

    test('matches the exact approved jump paths', () {
      expect(
        BoardSpec.undirectedJumpPaths.map(
          (path) => (path.from, path.over, path.to),
        ),
        [
          (0, 1, 2),
          (3, 4, 5),
          (6, 7, 8),
          (7, 8, 9),
          (8, 9, 10),
          (11, 12, 13),
          (12, 13, 14),
          (13, 14, 15),
          (16, 17, 18),
          (17, 18, 19),
          (18, 19, 20),
          (21, 22, 23),
          (22, 23, 24),
          (23, 24, 25),
          (26, 27, 28),
          (27, 28, 29),
          (28, 29, 30),
          (31, 32, 33),
          (34, 35, 36),
          (6, 11, 16),
          (11, 16, 21),
          (16, 21, 26),
          (7, 12, 17),
          (12, 17, 22),
          (17, 22, 27),
          (1, 4, 8),
          (4, 8, 13),
          (8, 13, 18),
          (13, 18, 23),
          (18, 23, 28),
          (23, 28, 32),
          (28, 32, 35),
          (9, 14, 19),
          (14, 19, 24),
          (19, 24, 29),
          (10, 15, 20),
          (15, 20, 25),
          (20, 25, 30),
          (0, 3, 8),
          (3, 8, 14),
          (8, 14, 20),
          (2, 5, 8),
          (5, 8, 12),
          (8, 12, 16),
          (6, 12, 18),
          (12, 18, 24),
          (18, 24, 30),
          (10, 14, 18),
          (14, 18, 22),
          (18, 22, 26),
          (16, 22, 28),
          (22, 28, 33),
          (28, 33, 36),
          (20, 24, 28),
          (24, 28, 31),
          (28, 31, 34),
        ],
      );
    });

    test('initial placement has 16 beads per player and 5 empty nodes', () {
      final state = MatchState.initial();

      expect(state.beadCount(Player.player1), 16);
      expect(state.beadCount(Player.player2), 16);
      for (final node in [16, 17, 18, 19, 20]) {
        expect(state.occupancy[node], isNull);
      }
      for (var node = 0; node <= 15; node++) {
        expect(state.occupancy[node], Player.player2);
      }
      for (var node = 21; node <= 36; node++) {
        expect(state.occupancy[node], Player.player1);
      }
    });

    test('rejects an incomplete 32-node variant', () {
      final result = BoardValidator.validate(
        nodes: BoardSpec.nodes.take(32).toList(),
      );

      expect(result.isValid, isFalse);
      expect(result.errors, contains('Expected 37 nodes, found 32.'));
    });
  });
}
