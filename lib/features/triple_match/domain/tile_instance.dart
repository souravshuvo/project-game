import 'board_position.dart';
import 'tile_kind.dart';

class TileInstance {
  const TileInstance({
    required this.id,
    required this.kind,
    required this.row,
    required this.col,
    this.layer = 0,
  });

  final String id;
  final TileKind kind;
  final int row;
  final int col;
  final int layer;

  BoardPosition get position => BoardPosition(row: row, col: col);

  bool occupiesSameCell(TileInstance other) {
    return row == other.row && col == other.col;
  }
}
