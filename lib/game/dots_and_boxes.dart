enum LineAxis { horizontal, vertical }

enum Player {
  one,
  two;

  Player get other => this == Player.one ? Player.two : Player.one;

  String get label => this == Player.one ? 'Player 1' : 'Player 2';
}

class BoardPreset {
  const BoardPreset({
    required this.label,
    required this.rows,
    required this.columns,
  }) : assert(rows > 0),
       assert(columns > 0);

  final String label;
  final int rows;
  final int columns;

  static const values = <BoardPreset>[
    BoardPreset(label: '2x2', rows: 2, columns: 2),
    BoardPreset(label: '3x3', rows: 3, columns: 3),
    BoardPreset(label: '4x4', rows: 4, columns: 4),
  ];

  @override
  bool operator ==(Object other) {
    return other is BoardPreset &&
        other.rows == rows &&
        other.columns == columns &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(label, rows, columns);
}

class BoardLine {
  const BoardLine({
    required this.axis,
    required this.row,
    required this.column,
  });

  const BoardLine.horizontal(this.row, this.column)
    : axis = LineAxis.horizontal;

  const BoardLine.vertical(this.row, this.column) : axis = LineAxis.vertical;

  final LineAxis axis;
  final int row;
  final int column;

  @override
  bool operator ==(Object other) {
    return other is BoardLine &&
        other.axis == axis &&
        other.row == row &&
        other.column == column;
  }

  @override
  int get hashCode => Object.hash(axis, row, column);

  @override
  String toString() => '${axis.name}($row, $column)';
}

class BoxCoordinate {
  const BoxCoordinate(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(Object other) {
    return other is BoxCoordinate && other.row == row && other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() => 'box($row, $column)';
}

class MoveResult {
  const MoveResult._({
    required this.accepted,
    required this.player,
    required this.completedBoxes,
    required this.extraTurn,
    this.line,
    this.rejectionReason,
  });

  factory MoveResult.accepted({
    required Player player,
    required BoardLine line,
    required List<BoxCoordinate> completedBoxes,
  }) {
    final lockedBoxes = List<BoxCoordinate>.unmodifiable(completedBoxes);
    return MoveResult._(
      accepted: true,
      player: player,
      line: line,
      completedBoxes: lockedBoxes,
      extraTurn: lockedBoxes.isNotEmpty,
    );
  }

  factory MoveResult.rejected({
    required Player player,
    required BoardLine line,
    required String reason,
  }) {
    return MoveResult._(
      accepted: false,
      player: player,
      line: line,
      completedBoxes: const <BoxCoordinate>[],
      extraTurn: false,
      rejectionReason: reason,
    );
  }

  final bool accepted;
  final Player player;
  final BoardLine? line;
  final List<BoxCoordinate> completedBoxes;
  final bool extraTurn;
  final String? rejectionReason;

  int get boxesCompleted => completedBoxes.length;
}

class DotsAndBoxesGame {
  DotsAndBoxesGame({required this.rows, required this.columns}) {
    if (rows <= 0) {
      throw ArgumentError.value(rows, 'rows', 'Must be greater than zero.');
    }
    if (columns <= 0) {
      throw ArgumentError.value(
        columns,
        'columns',
        'Must be greater than zero.',
      );
    }
  }

  factory DotsAndBoxesGame.fromPreset(BoardPreset preset) {
    return DotsAndBoxesGame(rows: preset.rows, columns: preset.columns);
  }

  final int rows;
  final int columns;

  final Set<BoardLine> _drawnLines = <BoardLine>{};
  final Map<BoardLine, Player> _lineOwners = <BoardLine, Player>{};
  final Map<BoxCoordinate, Player> _claimedBoxes = <BoxCoordinate, Player>{};

  Player _currentPlayer = Player.one;

  Player get currentPlayer => _currentPlayer;

  Set<BoardLine> get drawnLines => Set<BoardLine>.unmodifiable(_drawnLines);

  Map<BoxCoordinate, Player> get claimedBoxes {
    return Map<BoxCoordinate, Player>.unmodifiable(_claimedBoxes);
  }

  int get totalBoxes => rows * columns;

  int get totalLines => (rows + 1) * columns + rows * (columns + 1);

  bool get isGameOver => _claimedBoxes.length == totalBoxes;

  List<BoardLine> get openLines {
    final lines = <BoardLine>[];

    for (var row = 0; row <= rows; row += 1) {
      for (var column = 0; column < columns; column += 1) {
        final line = BoardLine.horizontal(row, column);
        if (!_drawnLines.contains(line)) {
          lines.add(line);
        }
      }
    }

    for (var row = 0; row < rows; row += 1) {
      for (var column = 0; column <= columns; column += 1) {
        final line = BoardLine.vertical(row, column);
        if (!_drawnLines.contains(line)) {
          lines.add(line);
        }
      }
    }

    return List<BoardLine>.unmodifiable(lines);
  }

  int scoreFor(Player player) {
    return _claimedBoxes.values.where((owner) => owner == player).length;
  }

  Player? get winner {
    if (!isGameOver) {
      return null;
    }

    final playerOneScore = scoreFor(Player.one);
    final playerTwoScore = scoreFor(Player.two);
    if (playerOneScore == playerTwoScore) {
      return null;
    }

    return playerOneScore > playerTwoScore ? Player.one : Player.two;
  }

  Player? ownerForLine(BoardLine line) => _lineOwners[line];

  MoveResult drawLine(BoardLine line) {
    if (isGameOver) {
      return MoveResult.rejected(
        player: _currentPlayer,
        line: line,
        reason: 'This match is already complete.',
      );
    }

    if (!isLineInBounds(line)) {
      return MoveResult.rejected(
        player: _currentPlayer,
        line: line,
        reason: 'That line is outside the board.',
      );
    }

    if (_drawnLines.contains(line)) {
      return MoveResult.rejected(
        player: _currentPlayer,
        line: line,
        reason: 'That line is already drawn.',
      );
    }

    final mover = _currentPlayer;
    _drawnLines.add(line);
    _lineOwners[line] = mover;

    final completedBoxes = <BoxCoordinate>[];
    for (final box in boxesAdjacentTo(line)) {
      if (_claimedBoxes.containsKey(box)) {
        continue;
      }

      if (_isBoxComplete(box)) {
        _claimedBoxes[box] = mover;
        completedBoxes.add(box);
      }
    }

    if (completedBoxes.isEmpty) {
      _currentPlayer = mover.other;
    }

    return MoveResult.accepted(
      player: mover,
      line: line,
      completedBoxes: completedBoxes,
    );
  }

  bool isLineInBounds(BoardLine line) {
    return switch (line.axis) {
      LineAxis.horizontal =>
        line.row >= 0 &&
            line.row <= rows &&
            line.column >= 0 &&
            line.column < columns,
      LineAxis.vertical =>
        line.row >= 0 &&
            line.row < rows &&
            line.column >= 0 &&
            line.column <= columns,
    };
  }

  List<BoxCoordinate> boxesAdjacentTo(BoardLine line) {
    if (!isLineInBounds(line)) {
      return const <BoxCoordinate>[];
    }

    return switch (line.axis) {
      LineAxis.horizontal => <BoxCoordinate>[
        if (line.row > 0) BoxCoordinate(line.row - 1, line.column),
        if (line.row < rows) BoxCoordinate(line.row, line.column),
      ],
      LineAxis.vertical => <BoxCoordinate>[
        if (line.column > 0) BoxCoordinate(line.row, line.column - 1),
        if (line.column < columns) BoxCoordinate(line.row, line.column),
      ],
    };
  }

  List<BoardLine> linesForBox(BoxCoordinate box) {
    if (box.row < 0 ||
        box.row >= rows ||
        box.column < 0 ||
        box.column >= columns) {
      return const <BoardLine>[];
    }

    return <BoardLine>[
      BoardLine.horizontal(box.row, box.column),
      BoardLine.horizontal(box.row + 1, box.column),
      BoardLine.vertical(box.row, box.column),
      BoardLine.vertical(box.row, box.column + 1),
    ];
  }

  int drawnSideCountForBox(BoxCoordinate box) {
    return linesForBox(box).where(_drawnLines.contains).length;
  }

  int completedBoxesForLine(BoardLine line) {
    if (!isLineInBounds(line) || _drawnLines.contains(line)) {
      return 0;
    }

    var count = 0;
    for (final box in boxesAdjacentTo(line)) {
      if (_claimedBoxes.containsKey(box)) {
        continue;
      }

      final wouldComplete = linesForBox(box).every((side) {
        return side == line || _drawnLines.contains(side);
      });
      if (wouldComplete) {
        count += 1;
      }
    }

    return count;
  }

  bool _isBoxComplete(BoxCoordinate box) {
    return linesForBox(box).every(_drawnLines.contains);
  }
}
