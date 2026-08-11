enum Player {
  player1,
  player2;

  Player get opponent =>
      this == Player.player1 ? Player.player2 : Player.player1;

  String get label => this == Player.player1 ? 'Player 1' : 'Player 2';
}

enum MatchMode {
  localTwoPlayer,
  vsBot;

  String get label => switch (this) {
    MatchMode.localTwoPlayer => 'Local Two Player',
    MatchMode.vsBot => 'Player vs Bot',
  };
}

enum BotDifficulty {
  easy,
  normal;

  String get label => switch (this) {
    BotDifficulty.easy => 'Easy',
    BotDifficulty.normal => 'Normal',
  };
}

enum BoardThemeChoice {
  classic,
  night,
  highContrast;

  String get label => switch (this) {
    BoardThemeChoice.classic => 'Classic',
    BoardThemeChoice.night => 'Night',
    BoardThemeChoice.highContrast => 'High Contrast',
  };
}

class BoardNode {
  const BoardNode(this.id, this.xRatio, this.yRatio);

  final int id;
  final double xRatio;
  final double yRatio;
}

class BoardEdge {
  const BoardEdge(this.a, this.b);

  final int a;
  final int b;
}

class JumpPath {
  const JumpPath(this.from, this.over, this.to);

  final int from;
  final int over;
  final int to;

  JumpPath get reversed => JumpPath(to, over, from);
}

enum MoveKind { normal, capture }

class GameMove {
  const GameMove({
    required this.player,
    required this.from,
    required this.to,
    required this.kind,
    this.capturedNode,
  });

  final Player player;
  final int from;
  final int to;
  final MoveKind kind;
  final int? capturedNode;

  bool get isCapture => kind == MoveKind.capture;

  @override
  bool operator ==(Object other) {
    return other is GameMove &&
        other.player == player &&
        other.from == from &&
        other.to == to &&
        other.kind == kind &&
        other.capturedNode == capturedNode;
  }

  @override
  int get hashCode => Object.hash(player, from, to, kind, capturedNode);
}

enum MatchEndReason { capturedAll, blocked }

class MatchResult {
  const MatchResult({required this.winner, required this.reason});

  final Player winner;
  final MatchEndReason reason;
}

class MatchState {
  MatchState({
    required List<Player?> occupancy,
    required this.currentPlayer,
    this.chainNode,
    this.result,
  }) : occupancy = List.unmodifiable(occupancy);

  factory MatchState.initial() {
    final occupancy = List<Player?>.filled(37, null);
    for (var node = 0; node <= 15; node++) {
      occupancy[node] = Player.player2;
    }
    for (var node = 21; node <= 36; node++) {
      occupancy[node] = Player.player1;
    }
    return MatchState(occupancy: occupancy, currentPlayer: Player.player1);
  }

  final List<Player?> occupancy;
  final Player currentPlayer;
  final int? chainNode;
  final MatchResult? result;

  bool get isGameOver => result != null;
  bool get isCaptureChain => chainNode != null;

  int beadCount(Player player) =>
      occupancy.where((occupant) => occupant == player).length;

  int capturedCount(Player player) => 16 - beadCount(player.opponent);

  MatchState copyWith({
    List<Player?>? occupancy,
    Player? currentPlayer,
    int? chainNode,
    bool clearChainNode = false,
    MatchResult? result,
    bool clearResult = false,
  }) {
    return MatchState(
      occupancy: occupancy ?? this.occupancy,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      chainNode: clearChainNode ? null : chainNode ?? this.chainNode,
      result: clearResult ? null : result ?? this.result,
    );
  }
}

class GameSettings {
  const GameSettings({
    this.botDifficulty = BotDifficulty.easy,
    this.boardTheme = BoardThemeChoice.classic,
    this.hintsEnabled = true,
  });

  final BotDifficulty botDifficulty;
  final BoardThemeChoice boardTheme;
  final bool hintsEnabled;

  GameSettings copyWith({
    BotDifficulty? botDifficulty,
    BoardThemeChoice? boardTheme,
    bool? hintsEnabled,
  }) {
    return GameSettings(
      botDifficulty: botDifficulty ?? this.botDifficulty,
      boardTheme: boardTheme ?? this.boardTheme,
      hintsEnabled: hintsEnabled ?? this.hintsEnabled,
    );
  }
}

class MatchRecord {
  const MatchRecord({
    required this.endedAt,
    required this.mode,
    required this.botDifficulty,
    required this.winner,
    required this.reason,
    required this.turnCount,
    required this.captureCount,
    required this.player1Beads,
    required this.player2Beads,
  });

  final DateTime endedAt;
  final MatchMode mode;
  final BotDifficulty? botDifficulty;
  final Player winner;
  final MatchEndReason reason;
  final int turnCount;
  final int captureCount;
  final int player1Beads;
  final int player2Beads;
}
