import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/bot_player.dart';
import '../../domain/game_rules.dart';
import '../../domain/models.dart';
import '../widgets/board_palette.dart';
import '../widgets/board_view.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({
    super.key,
    required this.mode,
    required this.settings,
    required this.onMatchFinished,
  });

  final MatchMode mode;
  final GameSettings settings;
  final ValueChanged<MatchRecord> onMatchFinished;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final Random _random = Random();
  final List<_UndoEntry> _undoStack = [];

  MatchState _state = MatchState.initial();
  int? _selectedNode;
  String? _message;
  GameMove? _hintMove;
  Timer? _botTimer;
  bool _botThinking = false;
  bool _resultRecorded = false;
  int _turnCount = 0;
  int _captureCount = 0;

  BoardPalette get _palette =>
      BoardPalette.fromChoice(widget.settings.boardTheme);

  bool get _isBotTurn =>
      widget.mode == MatchMode.vsBot &&
      _state.currentPlayer == Player.player2 &&
      !_state.isGameOver;

  bool get _canUndo =>
      _undoStack.isNotEmpty && !_botThinking && !_state.isGameOver;

  bool get _canHint =>
      widget.settings.hintsEnabled && !_botThinking && !_state.isGameOver;

  String get _turnLabel =>
      widget.mode == MatchMode.vsBot && _state.currentPlayer == Player.player2
      ? 'Bot turn'
      : '${_state.currentPlayer.label} turn';

  List<GameMove> get _selectedMoves {
    final selectedNode = _selectedNode;
    if (selectedNode == null) {
      return const [];
    }
    return GameRules.legalMoves(_state, fromNode: selectedNode);
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    super.dispose();
  }

  void _handleNodeTap(int nodeId) {
    if (_state.isGameOver) {
      return;
    }

    if (_isBotTurn || _botThinking) {
      setState(() {
        _message = 'Bot is thinking.';
      });
      return;
    }

    final destinationMove = _moveTo(nodeId);
    if (destinationMove != null) {
      _applyHumanMove(destinationMove);
      return;
    }

    if (_state.isCaptureChain) {
      setState(() {
        _message = 'Continue with the selected bead or end the turn.';
      });
      return;
    }

    if (_state.occupancy[nodeId] == _state.currentPlayer) {
      final moves = GameRules.legalMoves(_state, fromNode: nodeId);
      setState(() {
        _selectedNode = nodeId;
        _hintMove = null;
        _message = moves.isEmpty ? 'That bead has no legal moves.' : null;
      });
      return;
    }

    setState(() {
      _selectedNode = null;
      _hintMove = null;
      _message = 'Select one of your own beads.';
    });
  }

  GameMove? _moveTo(int nodeId) {
    for (final move in _selectedMoves) {
      if (move.to == nodeId) {
        return move;
      }
    }
    return null;
  }

  void _applyHumanMove(GameMove move) {
    if (!_state.isCaptureChain) {
      _undoStack.add(_UndoEntry.from(this));
    }
    _applyMove(move, byBot: false);
  }

  void _applyMove(GameMove move, {required bool byBot}) {
    final before = _state;
    final nextState = GameRules.applyMove(before, move);
    if (identical(nextState, before)) {
      setState(() {
        _message = 'That move is not legal.';
      });
      return;
    }
    final turnCompleted = !nextState.isCaptureChain;

    setState(() {
      _state = nextState;
      _selectedNode = nextState.isCaptureChain ? nextState.chainNode : null;
      _hintMove = null;
      if (move.isCapture) {
        _captureCount++;
      }
      if (turnCompleted) {
        _turnCount++;
      }
      _message = _statusMessageFor(nextState, move, byBot: byBot);
    });

    _recordResultIfNeeded();
    _queueBotTurnIfNeeded();
  }

  void _endChain() {
    if (_state.isGameOver || !_state.isCaptureChain || _botThinking) {
      return;
    }
    final nextState = GameRules.endCaptureChain(_state);
    setState(() {
      _state = nextState;
      _selectedNode = null;
      _hintMove = null;
      _turnCount++;
      _message = nextState.isGameOver
          ? _gameOverMessage(nextState.result!)
          : null;
    });
    _recordResultIfNeeded();
    _queueBotTurnIfNeeded();
  }

  void _showHint() {
    if (!_canHint) {
      return;
    }
    if (_isBotTurn) {
      setState(() {
        _message = 'Hints are available on human turns.';
      });
      return;
    }

    final move = BotPlayer.hintMove(_state);
    final message = move == null
        ? 'No legal moves available.'
        : move.isCapture
        ? 'Hint: capture from ${move.from} to ${move.to}.'
        : 'Hint: move from ${move.from} to ${move.to}.';
    setState(() {
      _hintMove = move;
      _selectedNode = move?.from;
      _message = message;
    });
  }

  void _undo() {
    if (!_canUndo) {
      return;
    }
    final entry = _undoStack.removeLast();
    setState(() {
      _state = entry.state;
      _selectedNode = null;
      _message = 'Turn undone.';
      _hintMove = null;
      _turnCount = entry.turnCount;
      _captureCount = entry.captureCount;
      _resultRecorded = entry.resultRecorded;
    });
  }

  void _restart() {
    _botTimer?.cancel();
    setState(() {
      _state = MatchState.initial();
      _selectedNode = null;
      _message = null;
      _hintMove = null;
      _botThinking = false;
      _resultRecorded = false;
      _turnCount = 0;
      _captureCount = 0;
      _undoStack.clear();
    });
  }

  void _queueBotTurnIfNeeded() {
    if (!_isBotTurn || _botThinking) {
      return;
    }
    setState(() {
      _botThinking = true;
      _message = 'Bot is thinking.';
    });
    _botTimer?.cancel();
    _botTimer = Timer(const Duration(milliseconds: 450), _playBotTurn);
  }

  void _playBotTurn() {
    if (!mounted || !_isBotTurn) {
      if (mounted) {
        setState(() {
          _botThinking = false;
        });
      }
      return;
    }

    var nextState = _state;
    var botCaptures = 0;
    var botMoved = false;

    for (var step = 0; step < 20; step++) {
      final move = BotPlayer.chooseMove(
        nextState,
        widget.settings.botDifficulty,
        random: _random,
      );
      if (move == null) {
        break;
      }

      botMoved = true;
      if (move.isCapture) {
        botCaptures++;
      }
      nextState = GameRules.applyMove(nextState, move);
      if (!nextState.isCaptureChain || nextState.isGameOver) {
        break;
      }
    }

    if (nextState.isCaptureChain && !nextState.isGameOver) {
      nextState = GameRules.endCaptureChain(nextState);
    }

    setState(() {
      _state = nextState;
      _selectedNode = null;
      _hintMove = null;
      _botThinking = false;
      if (botMoved) {
        _turnCount++;
      }
      _captureCount += botCaptures;
      _message = nextState.isGameOver
          ? _gameOverMessage(nextState.result!)
          : botCaptures > 0
          ? 'Bot captured $botCaptures bead${botCaptures == 1 ? '' : 's'}.'
          : 'Bot moved.';
    });
    _recordResultIfNeeded();
  }

  void _recordResultIfNeeded() {
    final result = _state.result;
    if (_resultRecorded || result == null) {
      return;
    }
    widget.onMatchFinished(
      MatchRecord(
        endedAt: DateTime.now(),
        mode: widget.mode,
        botDifficulty: widget.mode == MatchMode.vsBot
            ? widget.settings.botDifficulty
            : null,
        winner: result.winner,
        reason: result.reason,
        turnCount: _turnCount,
        captureCount: _captureCount,
        player1Beads: _state.beadCount(Player.player1),
        player2Beads: _state.beadCount(Player.player2),
      ),
    );
    _resultRecorded = true;
  }

  String _statusMessageFor(
    MatchState state,
    GameMove move, {
    required bool byBot,
  }) {
    if (state.isGameOver) {
      return _gameOverMessage(state.result!);
    }
    if (state.isCaptureChain) {
      return byBot
          ? 'Bot continues a capture chain.'
          : 'Capture made. Continue from this bead or end the turn.';
    }
    if (byBot) {
      return move.isCapture ? 'Bot captured a bead.' : 'Bot moved.';
    }
    return move.isCapture ? 'Capture made.' : 'Move made.';
  }

  String _gameOverMessage(MatchResult result) {
    return switch (result.reason) {
      MatchEndReason.capturedAll => '${result.winner.label} wins by capture.',
      MatchEndReason.blocked => '${result.winner.label} wins by blocking.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final result = _state.result;
    final player2Label = widget.mode == MatchMode.vsBot ? 'Bot' : 'Player 2';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode.label),
        actions: [
          IconButton(
            tooltip: 'Restart',
            onPressed: _restart,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _PlayerCount(
                          label: player2Label,
                          beads: _state.beadCount(Player.player2),
                          color: _palette.player2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PlayerCount(
                          label: 'Player 1',
                          beads: _state.beadCount(Player.player1),
                          color: _palette.player1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result == null ? _turnLabel : _gameOverMessage(result),
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 4),
                    Text(_message!, textAlign: TextAlign.center),
                  ],
                  if (_botThinking) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: BoardView(
                  state: _state,
                  selectedNode: _selectedNode,
                  legalMoves: _selectedMoves,
                  hintMove: _hintMove,
                  palette: _palette,
                  onNodeTap: _handleNodeTap,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _canUndo ? _undo : null,
                    icon: const Icon(Icons.undo_rounded),
                    label: const Text('Undo'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _canHint ? _showHint : null,
                    icon: const Icon(Icons.lightbulb_outline_rounded),
                    label: const Text('Hint'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _restart,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Restart'),
                  ),
                  if (_state.isCaptureChain && !_botThinking)
                    FilledButton.icon(
                      onPressed: _endChain,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('End Turn'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UndoEntry {
  const _UndoEntry({
    required this.state,
    required this.turnCount,
    required this.captureCount,
    required this.resultRecorded,
  });

  factory _UndoEntry.from(_MatchScreenState screen) {
    return _UndoEntry(
      state: screen._state,
      turnCount: screen._turnCount,
      captureCount: screen._captureCount,
      resultRecorded: screen._resultRecorded,
    );
  }

  final MatchState state;
  final int turnCount;
  final int captureCount;
  final bool resultRecorded;
}

class _PlayerCount extends StatelessWidget {
  const _PlayerCount({
    required this.label,
    required this.beads,
    required this.color,
  });

  final String label;
  final int beads;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            Text('$beads', style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
