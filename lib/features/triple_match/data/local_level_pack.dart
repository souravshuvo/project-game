import '../domain/level_definition.dart';
import '../domain/tile_instance.dart';
import '../domain/tile_kind.dart';

const productionLevelCount = 50;

final localLevelPack = <LevelDefinition>[
  ..._starterLevels,
  for (var id = _starterLevels.length + 1; id <= productionLevelCount; id++)
    _buildGeneratedLevel(id),
];

final prototypeLevel = localLevelPack.first;

const _starterLevels = <LevelDefinition>[
  LevelDefinition(
    id: 1,
    name: 'First Shelf',
    width: 6,
    height: 3,
    trayCapacity: 7,
    solutionTileIds: [
      'l1-jar-1',
      'l1-jar-2',
      'l1-jar-3',
      'l1-note-1',
      'l1-note-2',
      'l1-note-3',
      'l1-tin-1',
      'l1-tin-2',
      'l1-tin-3',
      'l1-flour-1',
      'l1-flour-2',
      'l1-flour-3',
      'l1-tea-1',
      'l1-tea-2',
      'l1-tea-3',
      'l1-seed-1',
      'l1-seed-2',
      'l1-seed-3',
    ],
    tiles: [
      TileInstance(id: 'l1-jar-1', kind: TileKind.jarLabel, row: 0, col: 0),
      TileInstance(id: 'l1-note-1', kind: TileKind.foldedNote, row: 0, col: 1),
      TileInstance(id: 'l1-tin-1', kind: TileKind.berryTin, row: 0, col: 2),
      TileInstance(id: 'l1-flour-1', kind: TileKind.flourTag, row: 0, col: 3),
      TileInstance(id: 'l1-tea-1', kind: TileKind.teaPacket, row: 0, col: 4),
      TileInstance(id: 'l1-seed-1', kind: TileKind.seedCard, row: 0, col: 5),
      TileInstance(id: 'l1-jar-2', kind: TileKind.jarLabel, row: 1, col: 0),
      TileInstance(id: 'l1-note-2', kind: TileKind.foldedNote, row: 1, col: 1),
      TileInstance(id: 'l1-tin-2', kind: TileKind.berryTin, row: 1, col: 2),
      TileInstance(id: 'l1-flour-2', kind: TileKind.flourTag, row: 1, col: 3),
      TileInstance(id: 'l1-tea-2', kind: TileKind.teaPacket, row: 1, col: 4),
      TileInstance(id: 'l1-seed-2', kind: TileKind.seedCard, row: 1, col: 5),
      TileInstance(id: 'l1-jar-3', kind: TileKind.jarLabel, row: 2, col: 0),
      TileInstance(id: 'l1-note-3', kind: TileKind.foldedNote, row: 2, col: 1),
      TileInstance(id: 'l1-tin-3', kind: TileKind.berryTin, row: 2, col: 2),
      TileInstance(id: 'l1-flour-3', kind: TileKind.flourTag, row: 2, col: 3),
      TileInstance(id: 'l1-tea-3', kind: TileKind.teaPacket, row: 2, col: 4),
      TileInstance(id: 'l1-seed-3', kind: TileKind.seedCard, row: 2, col: 5),
    ],
  ),
  LevelDefinition(
    id: 2,
    name: 'Seven Slots',
    width: 7,
    height: 3,
    trayCapacity: 7,
    solutionTileIds: [
      'l2-jar-1',
      'l2-jar-2',
      'l2-jar-3',
      'l2-note-1',
      'l2-note-2',
      'l2-note-3',
      'l2-tin-1',
      'l2-tin-2',
      'l2-tin-3',
      'l2-flour-1',
      'l2-flour-2',
      'l2-flour-3',
      'l2-tea-1',
      'l2-tea-2',
      'l2-tea-3',
      'l2-seed-1',
      'l2-seed-2',
      'l2-seed-3',
      'l2-honey-1',
      'l2-honey-2',
      'l2-honey-3',
    ],
    tiles: [
      TileInstance(id: 'l2-jar-1', kind: TileKind.jarLabel, row: 0, col: 0),
      TileInstance(id: 'l2-note-1', kind: TileKind.foldedNote, row: 0, col: 1),
      TileInstance(id: 'l2-tin-1', kind: TileKind.berryTin, row: 0, col: 2),
      TileInstance(id: 'l2-flour-1', kind: TileKind.flourTag, row: 0, col: 3),
      TileInstance(id: 'l2-tea-1', kind: TileKind.teaPacket, row: 0, col: 4),
      TileInstance(id: 'l2-seed-1', kind: TileKind.seedCard, row: 0, col: 5),
      TileInstance(id: 'l2-honey-1', kind: TileKind.honeyMark, row: 0, col: 6),
      TileInstance(id: 'l2-tea-2', kind: TileKind.teaPacket, row: 1, col: 0),
      TileInstance(id: 'l2-honey-2', kind: TileKind.honeyMark, row: 1, col: 1),
      TileInstance(id: 'l2-jar-2', kind: TileKind.jarLabel, row: 1, col: 2),
      TileInstance(id: 'l2-note-2', kind: TileKind.foldedNote, row: 1, col: 3),
      TileInstance(id: 'l2-tin-2', kind: TileKind.berryTin, row: 1, col: 4),
      TileInstance(id: 'l2-flour-2', kind: TileKind.flourTag, row: 1, col: 5),
      TileInstance(id: 'l2-seed-2', kind: TileKind.seedCard, row: 1, col: 6),
      TileInstance(id: 'l2-flour-3', kind: TileKind.flourTag, row: 2, col: 0),
      TileInstance(id: 'l2-seed-3', kind: TileKind.seedCard, row: 2, col: 1),
      TileInstance(id: 'l2-honey-3', kind: TileKind.honeyMark, row: 2, col: 2),
      TileInstance(id: 'l2-jar-3', kind: TileKind.jarLabel, row: 2, col: 3),
      TileInstance(id: 'l2-note-3', kind: TileKind.foldedNote, row: 2, col: 4),
      TileInstance(id: 'l2-tin-3', kind: TileKind.berryTin, row: 2, col: 5),
      TileInstance(id: 'l2-tea-3', kind: TileKind.teaPacket, row: 2, col: 6),
    ],
  ),
  LevelDefinition(
    id: 3,
    name: 'Lifted Labels',
    width: 6,
    height: 4,
    trayCapacity: 7,
    solutionTileIds: [
      'l3-honey-2',
      'l3-honey-3',
      'l3-honey-1',
      'l3-ribbon-2',
      'l3-ribbon-3',
      'l3-ribbon-1',
      'l3-jar-1',
      'l3-jar-2',
      'l3-jar-3',
      'l3-note-1',
      'l3-note-2',
      'l3-note-3',
      'l3-tin-1',
      'l3-tin-2',
      'l3-tin-3',
      'l3-flour-1',
      'l3-flour-2',
      'l3-flour-3',
      'l3-tea-1',
      'l3-tea-2',
      'l3-tea-3',
      'l3-seed-1',
      'l3-seed-2',
      'l3-seed-3',
    ],
    tiles: [
      TileInstance(id: 'l3-jar-1', kind: TileKind.jarLabel, row: 0, col: 0),
      TileInstance(id: 'l3-note-1', kind: TileKind.foldedNote, row: 0, col: 1),
      TileInstance(id: 'l3-tin-1', kind: TileKind.berryTin, row: 0, col: 2),
      TileInstance(id: 'l3-flour-1', kind: TileKind.flourTag, row: 0, col: 3),
      TileInstance(id: 'l3-jar-2', kind: TileKind.jarLabel, row: 0, col: 4),
      TileInstance(id: 'l3-flour-2', kind: TileKind.flourTag, row: 1, col: 0),
      TileInstance(id: 'l3-tea-1', kind: TileKind.teaPacket, row: 1, col: 1),
      TileInstance(id: 'l3-honey-1', kind: TileKind.honeyMark, row: 1, col: 2),
      TileInstance(id: 'l3-jar-3', kind: TileKind.jarLabel, row: 1, col: 4),
      TileInstance(id: 'l3-tin-2', kind: TileKind.berryTin, row: 1, col: 5),
      TileInstance(id: 'l3-note-2', kind: TileKind.foldedNote, row: 2, col: 0),
      TileInstance(id: 'l3-seed-1', kind: TileKind.seedCard, row: 2, col: 1),
      TileInstance(id: 'l3-seed-2', kind: TileKind.seedCard, row: 2, col: 2),
      TileInstance(id: 'l3-ribbon-1', kind: TileKind.ribbonTab, row: 2, col: 3),
      TileInstance(id: 'l3-tin-3', kind: TileKind.berryTin, row: 2, col: 4),
      TileInstance(id: 'l3-tea-2', kind: TileKind.teaPacket, row: 2, col: 5),
      TileInstance(id: 'l3-tea-3', kind: TileKind.teaPacket, row: 3, col: 0),
      TileInstance(id: 'l3-flour-3', kind: TileKind.flourTag, row: 3, col: 2),
      TileInstance(id: 'l3-note-3', kind: TileKind.foldedNote, row: 3, col: 3),
      TileInstance(id: 'l3-seed-3', kind: TileKind.seedCard, row: 3, col: 4),
      TileInstance(
        id: 'l3-honey-2',
        kind: TileKind.honeyMark,
        row: 1,
        col: 2,
        layer: 1,
      ),
      TileInstance(
        id: 'l3-honey-3',
        kind: TileKind.honeyMark,
        row: 0,
        col: 4,
        layer: 1,
      ),
      TileInstance(
        id: 'l3-ribbon-2',
        kind: TileKind.ribbonTab,
        row: 2,
        col: 3,
        layer: 1,
      ),
      TileInstance(
        id: 'l3-ribbon-3',
        kind: TileKind.ribbonTab,
        row: 3,
        col: 4,
        layer: 1,
      ),
    ],
  ),
  LevelDefinition(
    id: 4,
    name: 'Tight Tray',
    width: 6,
    height: 4,
    trayCapacity: 7,
    solutionTileIds: [
      'l4-ribbon-2',
      'l4-ribbon-3',
      'l4-ribbon-1',
      'l4-honey-2',
      'l4-honey-3',
      'l4-honey-1',
      'l4-tea-1',
      'l4-tea-2',
      'l4-tea-3',
      'l4-seed-1',
      'l4-seed-2',
      'l4-seed-3',
      'l4-jar-1',
      'l4-jar-2',
      'l4-jar-3',
      'l4-note-1',
      'l4-note-2',
      'l4-note-3',
      'l4-tin-1',
      'l4-tin-2',
      'l4-tin-3',
      'l4-flour-1',
      'l4-flour-2',
      'l4-flour-3',
    ],
    tiles: [
      TileInstance(id: 'l4-jar-1', kind: TileKind.jarLabel, row: 0, col: 0),
      TileInstance(id: 'l4-tea-1', kind: TileKind.teaPacket, row: 0, col: 1),
      TileInstance(id: 'l4-note-1', kind: TileKind.foldedNote, row: 0, col: 2),
      TileInstance(id: 'l4-tin-1', kind: TileKind.berryTin, row: 0, col: 3),
      TileInstance(id: 'l4-honey-1', kind: TileKind.honeyMark, row: 0, col: 5),
      TileInstance(id: 'l4-seed-1', kind: TileKind.seedCard, row: 1, col: 0),
      TileInstance(id: 'l4-flour-1', kind: TileKind.flourTag, row: 1, col: 1),
      TileInstance(id: 'l4-ribbon-1', kind: TileKind.ribbonTab, row: 1, col: 2),
      TileInstance(id: 'l4-jar-2', kind: TileKind.jarLabel, row: 1, col: 4),
      TileInstance(id: 'l4-tea-2', kind: TileKind.teaPacket, row: 1, col: 5),
      TileInstance(id: 'l4-note-2', kind: TileKind.foldedNote, row: 2, col: 0),
      TileInstance(id: 'l4-tin-2', kind: TileKind.berryTin, row: 2, col: 1),
      TileInstance(id: 'l4-honey-2', kind: TileKind.honeyMark, row: 2, col: 2),
      TileInstance(id: 'l4-seed-2', kind: TileKind.seedCard, row: 2, col: 3),
      TileInstance(id: 'l4-flour-2', kind: TileKind.flourTag, row: 2, col: 5),
      TileInstance(id: 'l4-jar-3', kind: TileKind.jarLabel, row: 3, col: 0),
      TileInstance(id: 'l4-note-3', kind: TileKind.foldedNote, row: 3, col: 1),
      TileInstance(id: 'l4-tin-3', kind: TileKind.berryTin, row: 3, col: 2),
      TileInstance(id: 'l4-tea-3', kind: TileKind.teaPacket, row: 3, col: 3),
      TileInstance(id: 'l4-seed-3', kind: TileKind.seedCard, row: 3, col: 4),
      TileInstance(id: 'l4-flour-3', kind: TileKind.flourTag, row: 3, col: 5),
      TileInstance(
        id: 'l4-ribbon-2',
        kind: TileKind.ribbonTab,
        row: 1,
        col: 2,
        layer: 1,
      ),
      TileInstance(
        id: 'l4-ribbon-3',
        kind: TileKind.ribbonTab,
        row: 2,
        col: 3,
        layer: 1,
      ),
      TileInstance(
        id: 'l4-honey-3',
        kind: TileKind.honeyMark,
        row: 0,
        col: 5,
        layer: 1,
      ),
    ],
  ),
  LevelDefinition(
    id: 5,
    name: 'Label Stack',
    width: 6,
    height: 5,
    trayCapacity: 7,
    solutionTileIds: [
      'l5-jar-3',
      'l5-jar-1',
      'l5-jar-2',
      'l5-honey-3',
      'l5-honey-1',
      'l5-honey-2',
      'l5-oat-3',
      'l5-oat-1',
      'l5-oat-2',
      'l5-cocoa-3',
      'l5-cocoa-1',
      'l5-cocoa-2',
      'l5-note-1',
      'l5-note-2',
      'l5-note-3',
      'l5-tin-1',
      'l5-tin-2',
      'l5-tin-3',
      'l5-flour-1',
      'l5-flour-2',
      'l5-flour-3',
      'l5-tea-1',
      'l5-tea-2',
      'l5-tea-3',
      'l5-seed-1',
      'l5-seed-2',
      'l5-seed-3',
      'l5-ribbon-1',
      'l5-ribbon-2',
      'l5-ribbon-3',
    ],
    tiles: [
      TileInstance(id: 'l5-jar-1', kind: TileKind.jarLabel, row: 0, col: 0),
      TileInstance(id: 'l5-note-1', kind: TileKind.foldedNote, row: 0, col: 1),
      TileInstance(id: 'l5-tin-1', kind: TileKind.berryTin, row: 0, col: 2),
      TileInstance(id: 'l5-flour-1', kind: TileKind.flourTag, row: 0, col: 3),
      TileInstance(id: 'l5-jar-2', kind: TileKind.jarLabel, row: 0, col: 4),
      TileInstance(id: 'l5-tea-1', kind: TileKind.teaPacket, row: 1, col: 1),
      TileInstance(id: 'l5-honey-1', kind: TileKind.honeyMark, row: 1, col: 2),
      TileInstance(id: 'l5-cocoa-1', kind: TileKind.cocoaSeal, row: 1, col: 3),
      TileInstance(id: 'l5-tin-2', kind: TileKind.berryTin, row: 1, col: 5),
      TileInstance(id: 'l5-note-2', kind: TileKind.foldedNote, row: 2, col: 0),
      TileInstance(id: 'l5-seed-1', kind: TileKind.seedCard, row: 2, col: 1),
      TileInstance(id: 'l5-seed-2', kind: TileKind.seedCard, row: 2, col: 2),
      TileInstance(id: 'l5-ribbon-1', kind: TileKind.ribbonTab, row: 2, col: 3),
      TileInstance(id: 'l5-tin-3', kind: TileKind.berryTin, row: 2, col: 4),
      TileInstance(id: 'l5-tea-2', kind: TileKind.teaPacket, row: 2, col: 5),
      TileInstance(id: 'l5-tea-3', kind: TileKind.teaPacket, row: 3, col: 0),
      TileInstance(id: 'l5-oat-1', kind: TileKind.oatStamp, row: 3, col: 1),
      TileInstance(id: 'l5-flour-2', kind: TileKind.flourTag, row: 3, col: 2),
      TileInstance(id: 'l5-note-3', kind: TileKind.foldedNote, row: 3, col: 3),
      TileInstance(id: 'l5-seed-3', kind: TileKind.seedCard, row: 3, col: 4),
      TileInstance(id: 'l5-ribbon-2', kind: TileKind.ribbonTab, row: 4, col: 0),
      TileInstance(id: 'l5-flour-3', kind: TileKind.flourTag, row: 4, col: 1),
      TileInstance(id: 'l5-honey-2', kind: TileKind.honeyMark, row: 4, col: 2),
      TileInstance(id: 'l5-ribbon-3', kind: TileKind.ribbonTab, row: 4, col: 3),
      TileInstance(id: 'l5-oat-2', kind: TileKind.oatStamp, row: 4, col: 4),
      TileInstance(id: 'l5-cocoa-2', kind: TileKind.cocoaSeal, row: 4, col: 5),
      TileInstance(
        id: 'l5-jar-3',
        kind: TileKind.jarLabel,
        row: 0,
        col: 0,
        layer: 1,
      ),
      TileInstance(
        id: 'l5-honey-3',
        kind: TileKind.honeyMark,
        row: 1,
        col: 2,
        layer: 1,
      ),
      TileInstance(
        id: 'l5-oat-3',
        kind: TileKind.oatStamp,
        row: 3,
        col: 1,
        layer: 1,
      ),
      TileInstance(
        id: 'l5-cocoa-3',
        kind: TileKind.cocoaSeal,
        row: 1,
        col: 3,
        layer: 1,
      ),
    ],
  ),
];

const _kindPool = <TileKind>[
  TileKind.jarLabel,
  TileKind.foldedNote,
  TileKind.berryTin,
  TileKind.flourTag,
  TileKind.teaPacket,
  TileKind.seedCard,
  TileKind.honeyMark,
  TileKind.ribbonTab,
  TileKind.oatStamp,
  TileKind.cocoaSeal,
];

const _nameRoots = <String>[
  'Pantry Row',
  'Tea Drawer',
  'Seed Shelf',
  'Jar Corner',
  'Ribbon Rack',
  'Cocoa Nook',
  'Honey Stack',
  'Oat Bin',
  'Market Notes',
  'Flour Lane',
];

LevelDefinition _buildGeneratedLevel(int id) {
  final plan = _planFor(id);
  final kinds = _rotatedKinds(plan.kindCount, id);
  final positions = _positionsFor(
    width: plan.width,
    height: plan.height,
    count: plan.kindCount * 3,
    seed: id,
  );
  final basePositions = <String, _Cell>{};

  var cursor = 0;
  for (var kindIndex = 0; kindIndex < kinds.length; kindIndex++) {
    for (var copy = 1; copy <= 3; copy++) {
      basePositions[_tileKey(kindIndex, copy)] = positions[cursor++];
    }
  }

  final stackPairs = _stackPairsFor(
    stackCount: plan.stackCount,
    kindCount: plan.kindCount,
    seed: id,
  );
  final topPairByKind = {
    for (final pair in stackPairs) pair.topKindIndex: pair,
  };

  final tiles = <TileInstance>[];
  for (var kindIndex = 0; kindIndex < kinds.length; kindIndex++) {
    final kind = kinds[kindIndex];
    for (var copy = 1; copy <= 3; copy++) {
      final pair = topPairByKind[kindIndex];
      final isTopCover = pair != null && copy == 3;
      final position = isTopCover
          ? basePositions[_tileKey(pair.bottomKindIndex, pair.bottomCopy)]!
          : basePositions[_tileKey(kindIndex, copy)]!;

      tiles.add(
        TileInstance(
          id: _tileId(id, kind, copy),
          kind: kind,
          row: position.row,
          col: position.col,
          layer: isTopCover ? 1 : 0,
        ),
      );
    }
  }

  return LevelDefinition(
    id: id,
    name: _levelName(id),
    width: plan.width,
    height: plan.height,
    trayCapacity: 7,
    solutionTileIds: [
      for (var kindIndex = 0; kindIndex < kinds.length; kindIndex++)
        ..._solutionCopies(
          topPairByKind.containsKey(kindIndex),
        ).map((copy) => _tileId(id, kinds[kindIndex], copy)),
    ],
    tiles: tiles,
  );
}

_LevelPlan _planFor(int id) {
  if (id <= 10) {
    return _LevelPlan(
      width: 6,
      height: 4,
      kindCount: 6,
      stackCount: id < 8 ? 0 : 1,
    );
  }
  if (id <= 20) {
    return _LevelPlan(
      width: 7,
      height: 4,
      kindCount: 7,
      stackCount: id.isEven ? 1 : 2,
    );
  }
  if (id <= 32) {
    return _LevelPlan(width: 8, height: 4, kindCount: 8, stackCount: 2);
  }
  if (id <= 42) {
    return _LevelPlan(width: 8, height: 5, kindCount: 9, stackCount: 3);
  }
  return const _LevelPlan(width: 8, height: 5, kindCount: 10, stackCount: 4);
}

List<TileKind> _rotatedKinds(int count, int seed) {
  final start = seed % _kindPool.length;
  return [
    for (var index = 0; index < count; index++)
      _kindPool[(start + index) % _kindPool.length],
  ];
}

List<_Cell> _positionsFor({
  required int width,
  required int height,
  required int count,
  required int seed,
}) {
  final total = width * height;
  final stride = _coprimeStride(total);
  final positions = <_Cell>[];
  final used = <int>{};
  var cursor = seed % total;

  while (positions.length < count) {
    if (used.add(cursor)) {
      positions.add(_Cell(row: cursor ~/ width, col: cursor % width));
    }
    cursor = (cursor + stride) % total;
  }

  return positions;
}

List<_StackPair> _stackPairsFor({
  required int stackCount,
  required int kindCount,
  required int seed,
}) {
  return [
    for (var index = 0; index < stackCount; index++)
      _StackPair(
        topKindIndex: index,
        bottomKindIndex: kindCount - 1 - index,
        bottomCopy: 1 + ((seed + index) % 3),
      ),
  ];
}

Iterable<int> _solutionCopies(bool hasTopCover) {
  return hasTopCover ? const [3, 1, 2] : const [1, 2, 3];
}

String _levelName(int id) {
  final root = _nameRoots[(id - 1) % _nameRoots.length];
  final batch = ((id - 1) ~/ _nameRoots.length) + 1;
  return '$root $batch';
}

String _tileKey(int kindIndex, int copy) => '$kindIndex:$copy';

String _tileId(int levelId, TileKind kind, int copy) {
  return 'l$levelId-${kind.name}-$copy';
}

int _coprimeStride(int value) {
  var stride = 5;
  while (_greatestCommonDivisor(stride, value) != 1) {
    stride += 2;
  }
  return stride;
}

int _greatestCommonDivisor(int a, int b) {
  var left = a;
  var right = b;
  while (right != 0) {
    final next = left % right;
    left = right;
    right = next;
  }
  return left;
}

class _LevelPlan {
  const _LevelPlan({
    required this.width,
    required this.height,
    required this.kindCount,
    required this.stackCount,
  });

  final int width;
  final int height;
  final int kindCount;
  final int stackCount;
}

class _Cell {
  const _Cell({required this.row, required this.col});

  final int row;
  final int col;
}

class _StackPair {
  const _StackPair({
    required this.topKindIndex,
    required this.bottomKindIndex,
    required this.bottomCopy,
  });

  final int topKindIndex;
  final int bottomKindIndex;
  final int bottomCopy;
}
