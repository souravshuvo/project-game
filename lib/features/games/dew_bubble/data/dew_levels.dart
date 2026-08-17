import '../domain/bubble_color.dart';
import '../domain/bubble_level.dart';

final List<BubbleLevel> dewBubbleLevels = List<BubbleLevel>.unmodifiable([
  const BubbleLevel(
    id: 'dew-1',
    title: 'Sprout Steps',
    shots: 10,
    layout: [
      ['B', 'B', null, 'P', 'P', null, 'Y', 'Y'],
      [null, 'Y', null, 'B', null, 'P', null, 'B'],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
    ],
    bubbleQueue: [
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
      DewBubbleColor.blue,
    ],
  ),
  const BubbleLevel(
    id: 'dew-2',
    title: 'Tall Dewdrops',
    shots: 10,
    layout: [
      ['B', null, 'P', null, 'Y', null, 'B', null],
      ['B', null, 'P', null, 'Y', null, 'B', null],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
    ],
    bubbleQueue: [
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
      DewBubbleColor.blue,
    ],
  ),
  const BubbleLevel(
    id: 'dew-3',
    title: 'Loose Leaves',
    shots: 10,
    layout: [
      [null, 'B', 'B', null, 'P', 'P', null, 'Y'],
      [null, 'Y', 'Y', null, null, null, null, 'Y'],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
    ],
    bubbleQueue: [
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
      DewBubbleColor.blue,
    ],
  ),
  const BubbleLevel(
    id: 'dew-4',
    title: 'Green Corners',
    shots: 12,
    layout: [
      ['G', null, 'B', 'B', null, 'P', 'P', 'Y'],
      ['G', null, null, null, null, null, null, 'Y'],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
    ],
    bubbleQueue: [
      DewBubbleColor.green,
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
      DewBubbleColor.green,
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
      DewBubbleColor.green,
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.yellow,
    ],
  ),
  const BubbleLevel(
    id: 'dew-5',
    title: 'Garden Mix',
    shots: 12,
    layout: [
      ['B', 'B', null, 'P', 'P', null, 'G', 'G'],
      ['Y', 'Y', null, null, null, null, 'B', 'B'],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null],
    ],
    bubbleQueue: [
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.green,
      DewBubbleColor.yellow,
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.green,
      DewBubbleColor.yellow,
      DewBubbleColor.blue,
      DewBubbleColor.pink,
      DewBubbleColor.green,
      DewBubbleColor.yellow,
    ],
  ),
  ..._buildProductionLevels(),
]);

List<BubbleLevel> _buildProductionLevels() {
  return [
    for (var index = 0; index < _productionPlans.length; index++)
      _buildLevel(index + 6, _productionPlans[index]),
  ];
}

BubbleLevel _buildLevel(int levelNumber, _DewLevelPlan plan) {
  final layout = _buildLayout(plan);
  final queueSeeds = _targetColors(layout, plan.palette);
  final bubbleQueue = <DewBubbleColor>[
    for (var index = 0; index < plan.shots; index++)
      queueSeeds[(index + plan.seed) % queueSeeds.length],
  ];

  return BubbleLevel(
    id: 'dew-$levelNumber',
    title: plan.title,
    shots: plan.shots,
    layout: layout,
    bubbleQueue: bubbleQueue,
  );
}

List<List<String?>> _buildLayout(_DewLevelPlan plan) {
  final layout = List<List<String?>>.generate(
    6,
    (_) => List<String?>.filled(8, null),
  );

  for (var row = 0; row < plan.activeRows; row++) {
    final groups = _groupsFor(plan.pattern, row);
    for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) {
      final columns = groups[groupIndex];
      for (var attempt = 0; attempt < plan.palette.length; attempt++) {
        final color =
            plan.palette[(plan.seed + (row * 3) + (groupIndex * 2) + attempt) %
                plan.palette.length];
        final token = dewBubbleColorToken(color);
        if (_canPlace(layout, row, columns, token)) {
          for (final column in columns) {
            layout[row][column] = token;
          }
          break;
        }
      }
    }
  }

  return layout;
}

bool _canPlace(
  List<List<String?>> layout,
  int row,
  List<int> columns,
  String token,
) {
  for (final column in columns) {
    if (column < 0 || column >= 8 || layout[row][column] != null) {
      return false;
    }
  }

  final columnSet = columns.toSet();
  for (final column in columns) {
    for (final neighbor in _neighborCells(row, column)) {
      final neighborRow = neighbor.$1;
      final neighborColumn = neighbor.$2;
      if (neighborRow < 0 ||
          neighborRow >= layout.length ||
          neighborColumn < 0 ||
          neighborColumn >= 8) {
        continue;
      }
      if (neighborRow == row && columnSet.contains(neighborColumn)) {
        continue;
      }
      if (layout[neighborRow][neighborColumn] == token) {
        return false;
      }
    }
  }

  return true;
}

List<(int, int)> _neighborCells(int row, int column) {
  final offsets = row.isEven
      ? const [(0, -1), (0, 1), (-1, -1), (-1, 0), (1, -1), (1, 0)]
      : const [(0, -1), (0, 1), (-1, 0), (-1, 1), (1, 0), (1, 1)];
  return [
    for (final (rowOffset, columnOffset) in offsets)
      (row + rowOffset, column + columnOffset),
  ];
}

List<DewBubbleColor> _targetColors(
  List<List<String?>> layout,
  List<DewBubbleColor> fallback,
) {
  final colors = <DewBubbleColor>[];
  for (final row in layout) {
    for (final token in row) {
      final color = dewBubbleColorFromToken(token);
      if (color != null) {
        colors.add(color);
      }
    }
  }
  return colors.isEmpty ? fallback : colors;
}

List<List<int>> _groupsFor(_DewPattern pattern, int row) {
  final parity = row.isEven ? 0 : 1;
  return switch (pattern) {
    _DewPattern.open =>
      parity == 0
          ? const [
              [0, 1],
              [3, 4],
              [6, 7],
            ]
          : const [
              [1, 2],
              [4, 5],
            ],
    _DewPattern.lanes =>
      parity == 0
          ? const [
              [1, 2],
              [4, 5],
            ]
          : const [
              [0, 1],
              [3, 4],
              [5, 6],
            ],
    _DewPattern.bridges =>
      parity == 0
          ? const [
              [0, 1],
              [2, 3],
              [5, 6],
            ]
          : const [
              [1, 2],
              [4, 5],
              [6, 7],
            ],
    _DewPattern.canopy =>
      parity == 0
          ? const [
              [0, 1],
              [3, 4],
              [6, 7],
            ]
          : const [
              [0],
              [2, 3],
              [5, 6],
            ],
  };
}

enum _DewPattern { open, lanes, bridges, canopy }

class _DewLevelPlan {
  const _DewLevelPlan({
    required this.title,
    required this.shots,
    required this.activeRows,
    required this.pattern,
    required this.palette,
    required this.seed,
  });

  final String title;
  final int shots;
  final int activeRows;
  final _DewPattern pattern;
  final List<DewBubbleColor> palette;
  final int seed;
}

const _threeColor = [
  DewBubbleColor.blue,
  DewBubbleColor.pink,
  DewBubbleColor.yellow,
];

const _fourColor = [
  DewBubbleColor.blue,
  DewBubbleColor.pink,
  DewBubbleColor.yellow,
  DewBubbleColor.green,
];

const _productionPlans = <_DewLevelPlan>[
  _DewLevelPlan(
    title: 'Morning Lattice',
    shots: 10,
    activeRows: 2,
    pattern: _DewPattern.open,
    palette: _threeColor,
    seed: 1,
  ),
  _DewLevelPlan(
    title: 'Leafy Lanes',
    shots: 10,
    activeRows: 2,
    pattern: _DewPattern.lanes,
    palette: _threeColor,
    seed: 2,
  ),
  _DewLevelPlan(
    title: 'Petal Pairs',
    shots: 10,
    activeRows: 2,
    pattern: _DewPattern.open,
    palette: _threeColor,
    seed: 3,
  ),
  _DewLevelPlan(
    title: 'Pebble Glade',
    shots: 11,
    activeRows: 2,
    pattern: _DewPattern.bridges,
    palette: _threeColor,
    seed: 4,
  ),
  _DewLevelPlan(
    title: 'Tiny Trellis',
    shots: 11,
    activeRows: 2,
    pattern: _DewPattern.canopy,
    palette: _threeColor,
    seed: 5,
  ),
  _DewLevelPlan(
    title: 'Mossy Steps',
    shots: 11,
    activeRows: 3,
    pattern: _DewPattern.open,
    palette: _fourColor,
    seed: 6,
  ),
  _DewLevelPlan(
    title: 'Clover Arc',
    shots: 11,
    activeRows: 3,
    pattern: _DewPattern.lanes,
    palette: _fourColor,
    seed: 7,
  ),
  _DewLevelPlan(
    title: 'Daisy Drift',
    shots: 12,
    activeRows: 3,
    pattern: _DewPattern.bridges,
    palette: _fourColor,
    seed: 8,
  ),
  _DewLevelPlan(
    title: 'Fern Fence',
    shots: 12,
    activeRows: 3,
    pattern: _DewPattern.canopy,
    palette: _fourColor,
    seed: 9,
  ),
  _DewLevelPlan(
    title: 'Pollen Porch',
    shots: 12,
    activeRows: 3,
    pattern: _DewPattern.open,
    palette: _fourColor,
    seed: 10,
  ),
  _DewLevelPlan(
    title: 'Bluebell Bend',
    shots: 12,
    activeRows: 3,
    pattern: _DewPattern.lanes,
    palette: _fourColor,
    seed: 11,
  ),
  _DewLevelPlan(
    title: 'Sunlit Sprigs',
    shots: 12,
    activeRows: 3,
    pattern: _DewPattern.bridges,
    palette: _fourColor,
    seed: 12,
  ),
  _DewLevelPlan(
    title: 'Mint Maze',
    shots: 13,
    activeRows: 3,
    pattern: _DewPattern.canopy,
    palette: _fourColor,
    seed: 13,
  ),
  _DewLevelPlan(
    title: 'Raindrop Rail',
    shots: 13,
    activeRows: 3,
    pattern: _DewPattern.open,
    palette: _fourColor,
    seed: 14,
  ),
  _DewLevelPlan(
    title: 'Thyme Terrace',
    shots: 13,
    activeRows: 3,
    pattern: _DewPattern.lanes,
    palette: _fourColor,
    seed: 15,
  ),
  _DewLevelPlan(
    title: 'Violet Vines',
    shots: 13,
    activeRows: 4,
    pattern: _DewPattern.bridges,
    palette: _fourColor,
    seed: 16,
  ),
  _DewLevelPlan(
    title: 'Cedar Cup',
    shots: 13,
    activeRows: 4,
    pattern: _DewPattern.canopy,
    palette: _fourColor,
    seed: 17,
  ),
  _DewLevelPlan(
    title: 'Rosemary Run',
    shots: 14,
    activeRows: 4,
    pattern: _DewPattern.open,
    palette: _fourColor,
    seed: 18,
  ),
  _DewLevelPlan(
    title: 'Hazel Hollow',
    shots: 14,
    activeRows: 4,
    pattern: _DewPattern.lanes,
    palette: _fourColor,
    seed: 19,
  ),
  _DewLevelPlan(
    title: 'Garden Gate',
    shots: 14,
    activeRows: 4,
    pattern: _DewPattern.bridges,
    palette: _fourColor,
    seed: 20,
  ),
  _DewLevelPlan(
    title: 'Lily Locks',
    shots: 14,
    activeRows: 4,
    pattern: _DewPattern.canopy,
    palette: _fourColor,
    seed: 21,
  ),
  _DewLevelPlan(
    title: 'Bramble Bridge',
    shots: 14,
    activeRows: 4,
    pattern: _DewPattern.open,
    palette: _fourColor,
    seed: 22,
  ),
  _DewLevelPlan(
    title: 'Orchid Overlap',
    shots: 15,
    activeRows: 4,
    pattern: _DewPattern.lanes,
    palette: _fourColor,
    seed: 23,
  ),
  _DewLevelPlan(
    title: 'Sprinkle Shelf',
    shots: 15,
    activeRows: 4,
    pattern: _DewPattern.bridges,
    palette: _fourColor,
    seed: 24,
  ),
  _DewLevelPlan(
    title: 'Mulberry Mist',
    shots: 15,
    activeRows: 4,
    pattern: _DewPattern.canopy,
    palette: _fourColor,
    seed: 25,
  ),
  _DewLevelPlan(
    title: 'Twilight Twigs',
    shots: 15,
    activeRows: 4,
    pattern: _DewPattern.open,
    palette: _fourColor,
    seed: 26,
  ),
  _DewLevelPlan(
    title: 'Quiet Quince',
    shots: 15,
    activeRows: 4,
    pattern: _DewPattern.lanes,
    palette: _fourColor,
    seed: 27,
  ),
  _DewLevelPlan(
    title: 'Basil Balcony',
    shots: 16,
    activeRows: 4,
    pattern: _DewPattern.bridges,
    palette: _fourColor,
    seed: 28,
  ),
  _DewLevelPlan(
    title: 'Marigold Mesh',
    shots: 16,
    activeRows: 4,
    pattern: _DewPattern.canopy,
    palette: _fourColor,
    seed: 29,
  ),
  _DewLevelPlan(
    title: 'Juniper Jumps',
    shots: 16,
    activeRows: 4,
    pattern: _DewPattern.open,
    palette: _fourColor,
    seed: 30,
  ),
  _DewLevelPlan(
    title: 'Puddle Pergola',
    shots: 16,
    activeRows: 4,
    pattern: _DewPattern.lanes,
    palette: _fourColor,
    seed: 31,
  ),
  _DewLevelPlan(
    title: 'Sage Spiral',
    shots: 16,
    activeRows: 4,
    pattern: _DewPattern.bridges,
    palette: _fourColor,
    seed: 32,
  ),
  _DewLevelPlan(
    title: 'Willow Weave',
    shots: 17,
    activeRows: 4,
    pattern: _DewPattern.canopy,
    palette: _fourColor,
    seed: 33,
  ),
  _DewLevelPlan(
    title: 'Nectar Nook',
    shots: 17,
    activeRows: 4,
    pattern: _DewPattern.open,
    palette: _fourColor,
    seed: 34,
  ),
  _DewLevelPlan(
    title: 'Final Fernhouse',
    shots: 17,
    activeRows: 4,
    pattern: _DewPattern.bridges,
    palette: _fourColor,
    seed: 35,
  ),
];
