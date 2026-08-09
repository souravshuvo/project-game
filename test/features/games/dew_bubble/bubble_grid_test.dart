import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/features/games/dew_bubble/data/dew_levels.dart';
import 'package:rapid_jump/features/games/dew_bubble/domain/attach_solver.dart';
import 'package:rapid_jump/features/games/dew_bubble/domain/bubble_color.dart';
import 'package:rapid_jump/features/games/dew_bubble/domain/bubble_grid.dart';
import 'package:rapid_jump/features/games/dew_bubble/domain/grid_position.dart';

void main() {
  group('BubbleGrid', () {
    test('uses staggered hex neighbors for even and odd rows', () {
      final grid = BubbleGrid.fromTokens([
        [null, null, null],
        [null, null, null],
        [null, null, null],
      ]);

      expect(
        grid.neighbors(const GridPosition(0, 1)),
        containsAll(const [
          GridPosition(0, 0),
          GridPosition(0, 2),
          GridPosition(1, 0),
          GridPosition(1, 1),
        ]),
      );
      expect(
        grid.neighbors(const GridPosition(1, 1)),
        containsAll(const [
          GridPosition(1, 0),
          GridPosition(1, 2),
          GridPosition(0, 1),
          GridPosition(0, 2),
          GridPosition(2, 1),
          GridPosition(2, 2),
        ]),
      );
    });

    test('finds a same-color connected match group', () {
      final grid = BubbleGrid.fromTokens([
        ['B', 'B', null],
        ['B', 'P', null],
        [null, null, null],
      ]);

      final match = grid.connectedSameColor(const GridPosition(1, 0));

      expect(match.length, 3);
      expect(match, contains(const GridPosition(0, 0)));
      expect(match, contains(const GridPosition(0, 1)));
      expect(match, contains(const GridPosition(1, 0)));
    });

    test('detects bubbles that lose their top support', () {
      final grid = BubbleGrid.fromTokens([
        ['B', null, null],
        ['B', null, null],
        ['G', 'G', null],
      ]);

      expect(grid.floatingPositions(), isEmpty);

      grid.removeAll(const [GridPosition(0, 0), GridPosition(1, 0)]);

      expect(
        grid.floatingPositions(),
        equals({const GridPosition(2, 0), const GridPosition(2, 1)}),
      );
    });

    test('removes popped cells and reports cleared state', () {
      final grid = BubbleGrid.fromTokens([
        ['Y', 'Y', null],
        ['Y', null, null],
      ]);
      final match = grid.connectedSameColor(const GridPosition(0, 0));

      grid.removeAll(match);

      expect(grid.isCleared, isTrue);
      expect(grid.colorAt(const GridPosition(0, 0)), isNull);
      expect(grid.colorAt(const GridPosition(0, 1)), isNull);
      expect(grid.colorAt(const GridPosition(1, 0)), isNull);
    });

    test('parses color tokens', () {
      final grid = BubbleGrid.fromTokens([
        ['B', 'P', 'Y', 'G'],
      ]);

      expect(grid.colorAt(const GridPosition(0, 0)), DewBubbleColor.blue);
      expect(grid.colorAt(const GridPosition(0, 1)), DewBubbleColor.pink);
      expect(grid.colorAt(const GridPosition(0, 2)), DewBubbleColor.yellow);
      expect(grid.colorAt(const GridPosition(0, 3)), DewBubbleColor.green);
    });
  });

  group('BubbleAttachSolver', () {
    const solver = BubbleAttachSolver();

    test('chooses the closest empty neighbor of the hit bubble', () {
      final grid = BubbleGrid.fromTokens([
        [null, 'B', null],
        [null, null, null],
        [null, null, null],
      ]);

      final attach = solver.nearestEmptyNeighbor(
        grid: grid,
        hitPosition: const GridPosition(0, 1),
        distanceToImpact: (position) {
          return switch (position) {
            GridPosition(row: 0, column: 0) => 4,
            GridPosition(row: 0, column: 2) => 2,
            GridPosition(row: 1, column: 0) => 1,
            GridPosition(row: 1, column: 1) => 3,
            _ => 99,
          };
        },
        maxDistance: 10,
      );

      expect(attach, const GridPosition(1, 0));
    });

    test('does not snap to far empty cells outside the hit neighborhood', () {
      final grid = BubbleGrid.fromTokens([
        ['B', 'B', 'B'],
        ['B', 'B', 'B'],
        [null, null, null],
      ]);

      final attach = solver.nearestEmptyNeighbor(
        grid: grid,
        hitPosition: const GridPosition(0, 1),
        distanceToImpact: (_) => 1,
        maxDistance: 10,
      );

      expect(attach, isNull);
    });

    test(
      'rejects neighboring cells that are beyond the fair snap distance',
      () {
        final grid = BubbleGrid.fromTokens([
          [null, 'B', null],
          [null, null, null],
        ]);

        final attach = solver.nearestEmptyNeighbor(
          grid: grid,
          hitPosition: const GridPosition(0, 1),
          distanceToImpact: (_) => 50,
          maxDistance: 10,
        );

        expect(attach, isNull);
      },
    );

    test('uses only close empty cells on the top row for ceiling attaches', () {
      final grid = BubbleGrid.fromTokens([
        [null, 'B', null],
        [null, null, null],
      ]);

      final attach = solver.nearestTopCell(
        grid: grid,
        distanceToImpact: (position) {
          return switch (position) {
            GridPosition(row: 0, column: 0) => 7,
            GridPosition(row: 0, column: 2) => 2,
            _ => 99,
          };
        },
        maxDistance: 5,
      );

      expect(attach, const GridPosition(0, 2));
    });
  });

  group('dewBubbleLevels', () {
    test('defines a small handcrafted level pack with unique ids', () {
      expect(dewBubbleLevels, hasLength(5));
      expect(
        dewBubbleLevels.map((level) => level.id).toSet(),
        hasLength(dewBubbleLevels.length),
      );
    });

    test('all levels are rectangular and have enough queued shots', () {
      for (final level in dewBubbleLevels) {
        expect(level.layout, hasLength(6), reason: level.id);
        expect(level.bubbleQueue.length, greaterThanOrEqualTo(2));
        expect(level.shots, greaterThanOrEqualTo(level.bubbleQueue.length));

        for (final row in level.layout) {
          expect(row, hasLength(8), reason: level.id);
        }
      }
    });

    test(
      'levels start supported and without accidental ready-made matches',
      () {
        for (final level in dewBubbleLevels) {
          final grid = level.createGrid();

          expect(grid.floatingPositions(), isEmpty, reason: level.id);

          for (final position in grid.occupiedPositions()) {
            expect(
              grid.connectedSameColor(position),
              hasLength(lessThan(3)),
              reason: '${level.id} at $position',
            );
          }
        }
      },
    );
  });
}
