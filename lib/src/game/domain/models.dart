enum Player {
  player1,
  player2;

  Player get opponent =>
      this == Player.player1 ? Player.player2 : Player.player1;

  String get label => this == Player.player1 ? 'Player 1' : 'Player 2';
}

enum MatchMode {
  localTwoPlayer,
  playerVsBot;

  String get label => switch (this) {
    MatchMode.localTwoPlayer => 'Local 2 Player',
    MatchMode.playerVsBot => 'Player vs Bot',
  };
}

enum BotDifficulty {
  easy,
  balanced,
  sharp;

  String get label => switch (this) {
    BotDifficulty.easy => 'Easy',
    BotDifficulty.balanced => 'Balanced',
    BotDifficulty.sharp => 'Sharp',
  };

  String get description => switch (this) {
    BotDifficulty.easy => 'Learns the board and takes simple captures.',
    BotDifficulty.balanced => 'Prefers captures, mobility, and safer moves.',
    BotDifficulty.sharp => 'Looks harder for wins, chains, and counterplay.',
  };
}

class MatchSetup {
  const MatchSetup.localTwoPlayer()
    : mode = MatchMode.localTwoPlayer,
      botDifficulty = null;

  const MatchSetup.playerVsBot(this.botDifficulty)
    : mode = MatchMode.playerVsBot;

  final MatchMode mode;
  final BotDifficulty? botDifficulty;

  bool get hasBot => mode == MatchMode.playerVsBot;

  String get label {
    final difficulty = botDifficulty;
    if (difficulty == null) {
      return mode.label;
    }
    return '${mode.label} - ${difficulty.label}';
  }
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

  String get key {
    final low = a < b ? a : b;
    final high = a < b ? b : a;
    return '$low-$high';
  }
}

class JumpPath {
  const JumpPath(this.from, this.over, this.to);

  final int from;
  final int over;
  final int to;

  JumpPath get reversed => JumpPath(to, over, from);

  String get key => '$from-$over-$to';
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

enum MatchEndReason { capturedAll, blocked, repetition, noCaptureLimit }

class MatchResult {
  const MatchResult({required this.reason, this.winner});

  final MatchEndReason reason;
  final Player? winner;

  bool get isDraw => winner == null;
}

class MatchState {
  MatchState({
    required List<Player?> occupancy,
    required this.currentPlayer,
    this.chainNode,
    this.result,
    this.halfTurnsSinceCapture = 0,
    Map<String, int>? repetitionCounts,
  }) : occupancy = List.unmodifiable(occupancy),
       repetitionCounts = Map.unmodifiable(repetitionCounts ?? const {});

  factory MatchState.fromPlacement({
    required int nodeCount,
    required Iterable<int> player1Nodes,
    required Iterable<int> player2Nodes,
    Player currentPlayer = Player.player1,
  }) {
    final occupancy = List<Player?>.filled(nodeCount, null);
    for (final node in player1Nodes) {
      occupancy[node] = Player.player1;
    }
    for (final node in player2Nodes) {
      occupancy[node] = Player.player2;
    }

    return MatchState(
      occupancy: occupancy,
      currentPlayer: currentPlayer,
    ).recordCurrentPosition();
  }

  final List<Player?> occupancy;
  final Player currentPlayer;
  final int? chainNode;
  final MatchResult? result;
  final int halfTurnsSinceCapture;
  final Map<String, int> repetitionCounts;

  bool get isGameOver => result != null;
  bool get isCaptureChain => chainNode != null;

  int beadCount(Player player) =>
      occupancy.where((occupant) => occupant == player).length;

  String get positionKey {
    final cells = occupancy
        .map(
          (occupant) => switch (occupant) {
            Player.player1 => '1',
            Player.player2 => '2',
            null => '0',
          },
        )
        .join();
    return '${currentPlayer.index}:$cells';
  }

  int get currentPositionCount => repetitionCounts[positionKey] ?? 0;

  MatchState recordCurrentPosition() {
    final counts = Map<String, int>.of(repetitionCounts);
    counts[positionKey] = (counts[positionKey] ?? 0) + 1;
    return copyWith(repetitionCounts: counts);
  }

  MatchState copyWith({
    List<Player?>? occupancy,
    Player? currentPlayer,
    int? chainNode,
    bool clearChainNode = false,
    MatchResult? result,
    bool clearResult = false,
    int? halfTurnsSinceCapture,
    Map<String, int>? repetitionCounts,
  }) {
    return MatchState(
      occupancy: occupancy ?? this.occupancy,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      chainNode: clearChainNode ? null : chainNode ?? this.chainNode,
      result: clearResult ? null : result ?? this.result,
      halfTurnsSinceCapture:
          halfTurnsSinceCapture ?? this.halfTurnsSinceCapture,
      repetitionCounts: repetitionCounts ?? this.repetitionCounts,
    );
  }
}
