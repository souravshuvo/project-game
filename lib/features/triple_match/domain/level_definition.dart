import 'tile_instance.dart';

class LevelDefinition {
  const LevelDefinition({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.trayCapacity,
    required this.tiles,
    this.solutionTileIds = const [],
  });

  final int id;
  final String name;
  final int width;
  final int height;
  final int trayCapacity;
  final List<TileInstance> tiles;
  final List<String> solutionTileIds;

  TileInstance tileById(String tileId) {
    return tiles.firstWhere(
      (tile) => tile.id == tileId,
      orElse: () => throw ArgumentError.value(tileId, 'tileId', 'Unknown tile'),
    );
  }
}
