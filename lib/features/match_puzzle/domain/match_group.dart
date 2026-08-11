import 'board_position.dart';
import 'tile_kind.dart';

class MatchGroup {
  MatchGroup({required this.tile, required Iterable<BoardPosition> positions})
    : positions = List.unmodifiable(positions);

  final TileKind tile;
  final List<BoardPosition> positions;
}
