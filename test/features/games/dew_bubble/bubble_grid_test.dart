import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/features/games/dew_bubble/data/dew_levels.dart';
import 'package:rapid_jump/features/games/dew_bubble/data/dew_progression.dart';
import 'package:rapid_jump/features/games/dew_bubble/domain/attach_solver.dart';
import 'package:rapid_jump/features/games/dew_bubble/domain/bubble_color.dart';
import 'package:rapid_jump/features/games/dew_bubble/domain/bubble_grid.dart';
import 'package:rapid_jump/features/games/dew_bubble/domain/bubble_level.dart';
import 'package:rapid_jump/features/games/dew_bubble/domain/grid_position.dart';
import 'package:rapid_jump/features/tracing/data/progress_repository.dart';

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
    test('defines a production v1 level pack with unique sequential ids', () {
      expect(dewBubbleLevels, hasLength(40));
      expect(
        dewBubbleLevels.map((level) => level.id).toSet(),
        hasLength(dewBubbleLevels.length),
      );
      expect(dewBubbleLevels.first.id, 'dew-1');
      expect(dewBubbleLevels.last.id, 'dew-40');
      for (var index = 0; index < dewBubbleLevels.length; index++) {
        expect(dewBubbleLevels[index].id, 'dew-${index + 1}');
      }
    });

    test('all levels are rectangular and have enough queued shots', () {
      for (final level in dewBubbleLevels) {
        expect(level.layout, hasLength(6), reason: level.id);
        expect(level.bubbleQueue.length, greaterThanOrEqualTo(2));
        expect(level.bubbleQueue.length, level.shots, reason: level.id);
        expect(level.shots, greaterThanOrEqualTo(8), reason: level.id);
        expect(level.shots, lessThanOrEqualTo(17), reason: level.id);

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

    test('levels provide target pairs and ramp row and color pressure', () {
      for (final level in dewBubbleLevels) {
        final grid = level.createGrid();
        final pairCells = grid.occupiedPositions().where(
          (position) => grid.connectedSameColor(position).length == 2,
        );
        expect(pairCells, isNotEmpty, reason: level.id);
      }

      expect(
        dewBubbleLevels.take(10).map(_activeRows).reduce(_maxInt),
        lessThanOrEqualTo(2),
      );
      expect(
        dewBubbleLevels.skip(10).take(10).map(_activeRows),
        everyElement(3),
      );
      expect(dewBubbleLevels.skip(20).map(_activeRows), everyElement(4));

      expect(_colorsIn(dewBubbleLevels[0]), hasLength(3));
      expect(_colorsIn(dewBubbleLevels[3]), contains(DewBubbleColor.green));
      expect(
        dewBubbleLevels
            .skip(10)
            .every((level) => _colorsIn(level).contains(DewBubbleColor.green)),
        isTrue,
      );
    });

    test('production content has missions, chapters, and target scores', () {
      expect(dewBubbleStageMissions, hasLength(dewBubbleLevels.length));
      expect(dewCampaignChapters, hasLength(4));
      expect(dewBubbleAchievements, hasLength(10));

      for (var index = 0; index < dewBubbleLevels.length; index++) {
        expect(dewBubbleStageMission(index).trim(), isNotEmpty);
        expect(dewBubbleTargetScore(dewBubbleLevels[index]), greaterThan(0));
      }

      for (var index = 0; index < dewBubbleLevels.length; index++) {
        final matchingChapters = dewCampaignChapters.where(
          (chapter) => chapter.containsLevelIndex(index),
        );
        expect(matchingChapters, hasLength(1), reason: 'stage ${index + 1}');
      }

      expect(
        dewBubbleTargetScore(dewBubbleLevels.last),
        greaterThan(dewBubbleTargetScore(dewBubbleLevels.first)),
      );
    });

    test('each stage has a queue-supported deterministic clear route', () {
      for (final level in dewBubbleLevels) {
        expect(_canClearWithQueue(level), isTrue, reason: level.id);
      }
    });

    test('achievements are derived from saved local progress', () {
      final bestScores = <String, int>{
        for (final level in dewBubbleLevels.take(15))
          level.id: dewBubbleTargetScore(level),
      };
      final bestStars = <String, int>{
        for (final level in dewBubbleLevels.take(12)) level.id: 3,
      };
      final repository = MemoryProgressRepository(
        dewBubbleHighestUnlockedLevelIndex: 19,
        dewBubbleBestScores: bestScores,
        dewBubbleBestStars: bestStars,
      );

      final snapshot = dewBubbleProgressSnapshot(repository);
      final unlockedIds = dewBubbleUnlockedAchievements(
        snapshot,
      ).map((achievement) => achievement.id).toSet();

      expect(snapshot.unlockedStages, 20);
      expect(snapshot.targetScoreClears, 15);
      expect(snapshot.savedStars, 36);
      expect(snapshot.threeStarClears, 12);
      expect(unlockedIds, contains('first-clear'));
      expect(unlockedIds, contains('route-runner'));
      expect(unlockedIds, contains('canopy-reader'));
      expect(unlockedIds, contains('star-collector'));
      expect(unlockedIds, contains('clean-dozen'));
      expect(unlockedIds, contains('target-chaser'));
      expect(unlockedIds, isNot(contains('star-garden')));
      expect(unlockedIds, isNot(contains('target-master')));
      expect(unlockedIds, isNot(contains('route-master')));
    });
  });
}

bool _canClearWithQueue(BubbleLevel level) {
  final grid = level.createGrid();

  for (final color in level.bubbleQueue) {
    if (grid.isCleared) {
      return true;
    }

    final attach = _bestClearRouteAttach(grid, color);
    if (attach == null) {
      continue;
    }

    grid.setColor(attach, color);
    final match = grid.connectedSameColor(attach);
    if (match.length >= 3) {
      grid.removeAll(match);
      grid.removeAll(grid.floatingPositions());
    }
  }

  return grid.isCleared;
}

GridPosition? _bestClearRouteAttach(BubbleGrid grid, DewBubbleColor color) {
  final occupied = grid
      .occupiedPositions()
      .where((position) => grid.colorAt(position) == color)
      .toList();
  if (occupied.isEmpty) {
    return null;
  }

  final seenGroups = <String>{};
  final candidates = <({GridPosition attach, int groupSize, int row})>[];

  for (final position in occupied) {
    final group = grid.connectedSameColor(position);
    final groupKey = _groupKey(group);
    if (!seenGroups.add(groupKey)) {
      continue;
    }

    for (final neighbor in group.expand(grid.neighbors)) {
      if (!grid.isEmpty(neighbor)) {
        continue;
      }
      candidates.add((
        attach: neighbor,
        groupSize: group.length,
        row: neighbor.row,
      ));
    }
  }

  candidates.sort((a, b) {
    final byGroup = b.groupSize.compareTo(a.groupSize);
    if (byGroup != 0) {
      return byGroup;
    }
    final byRow = a.row.compareTo(b.row);
    if (byRow != 0) {
      return byRow;
    }
    return a.attach.column.compareTo(b.attach.column);
  });

  return candidates.isEmpty ? null : candidates.first.attach;
}

String _groupKey(Set<GridPosition> group) {
  final cells = group.toList()
    ..sort((a, b) {
      final byRow = a.row.compareTo(b.row);
      return byRow != 0 ? byRow : a.column.compareTo(b.column);
    });
  return cells
      .map((position) => '${position.row}:${position.column}')
      .join('|');
}

int _activeRows(BubbleLevel level) {
  var activeRows = 0;
  for (var row = 0; row < level.layout.length; row++) {
    if (level.layout[row].any((token) => token != null)) {
      activeRows = row + 1;
    }
  }
  return activeRows;
}

Set<DewBubbleColor> _colorsIn(BubbleLevel level) {
  return {
    for (final row in level.layout)
      for (final token in row)
        if (dewBubbleColorFromToken(token) case final color?) color,
  };
}

int _maxInt(int a, int b) => a > b ? a : b;
