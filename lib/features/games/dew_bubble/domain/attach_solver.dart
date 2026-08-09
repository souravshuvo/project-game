import 'bubble_grid.dart';
import 'grid_position.dart';

typedef GridDistance = double Function(GridPosition position);

class BubbleAttachSolver {
  const BubbleAttachSolver();

  GridPosition? nearestEmptyNeighbor({
    required BubbleGrid grid,
    required GridPosition hitPosition,
    required GridDistance distanceToImpact,
    required double maxDistance,
  }) {
    return _nearest(
      grid.neighbors(hitPosition).where(grid.isEmpty),
      distanceToImpact,
      maxDistance,
    );
  }

  GridPosition? nearestTopCell({
    required BubbleGrid grid,
    required GridDistance distanceToImpact,
    required double maxDistance,
  }) {
    return _nearest(
      [
        for (var column = 0; column < grid.columns; column++)
          GridPosition(0, column),
      ].where(grid.isEmpty),
      distanceToImpact,
      maxDistance,
    );
  }

  GridPosition? _nearest(
    Iterable<GridPosition> candidates,
    GridDistance distanceToImpact,
    double maxDistance,
  ) {
    final sorted =
        candidates
            .map(
              (position) =>
                  (position: position, distance: distanceToImpact(position)),
            )
            .where((candidate) => candidate.distance <= maxDistance)
            .toList()
          ..sort((a, b) => a.distance.compareTo(b.distance));

    return sorted.isEmpty ? null : sorted.first.position;
  }
}
