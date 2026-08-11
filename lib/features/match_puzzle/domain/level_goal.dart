import 'tile_kind.dart';

class LevelGoal {
  const LevelGoal({required this.tile, required this.count});

  final TileKind tile;
  final int count;
}
