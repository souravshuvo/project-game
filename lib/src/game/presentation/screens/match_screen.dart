import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/bot_player.dart';
import '../../domain/game_rules.dart';
import '../../domain/models.dart';
import '../../infrastructure/ads/game_ads.dart';
import '../../infrastructure/analytics/game_analytics.dart';
import '../progress/match_history.dart';
import '../services/game_feedback.dart';
import '../widgets/board_view.dart';
import 'rules_screen.dart';
import 'settings_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({
    super.key,
    this.setup = const MatchSetup.localTwoPlayer(),
  });

  final MatchSetup setup;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen>
    with TickerProviderStateMixin {
  MatchState _state = GameRules.initialState();
  int? _selectedNode;
  String? _message;
  _MessageTone _messageTone = _MessageTone.info;
  GameMove? _lastMove;
  bool _botTurnQueued = false;
  bool _botThinking = false;
  bool _resultRecorded = false;
  bool _matchStartedLogged = false;
  bool _postResultAdQueued = false;
  int _moveCount = 0;
  int _captureCount = 0;
  GameAdsController? _ads;
  GameAnalytics? _analytics;

  late final AnimationController _moveFeedbackController;
  late final AnimationController _resultController;
  late final Animation<double> _moveFeedback;
  late final Animation<double> _resultFade;
  late final Animation<double> _resultScale;

  List<GameMove> get _selectedMoves {
    final selectedNode = _selectedNode;
    if (selectedNode == null) {
      return const [];
    }
    return GameRules.legalMoves(_state, fromNode: selectedNode);
  }

  bool get _isBotTurn =>
      widget.setup.hasBot &&
      _state.currentPlayer == Player.player2 &&
      !_state.isGameOver;

  @override
  void initState() {
    super.initState();
    _moveFeedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    )..value = 1;
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _moveFeedback = CurvedAnimation(
      parent: _moveFeedbackController,
      curve: Curves.easeOutCubic,
    );
    _resultFade = CurvedAnimation(
      parent: _resultController,
      curve: Curves.easeOutCubic,
    );
    _resultScale = CurvedAnimation(
      parent: _resultController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ads = GameAdsScope.read(context);
    _analytics = GameAnalyticsScope.read(context);
    if (_matchStartedLogged) {
      return;
    }
    _matchStartedLogged = true;
    _ads!.markGameplayStarted();
    unawaited(_analytics!.logMatchStart(widget.setup));
  }

  @override
  void dispose() {
    if (!_state.isGameOver) {
      _ads?.markGameplayEnded();
    }
    _moveFeedbackController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _handleNodeTap(int nodeId) {
    if (_state.isGameOver) {
      return;
    }
    if (_isBotTurn || _botThinking) {
      _showInvalid('Bot is choosing a move.');
      return;
    }

    final destinationMove = _moveTo(nodeId);
    if (destinationMove != null) {
      _applyMove(destinationMove);
      return;
    }

    if (_state.isCaptureChain) {
      _showInvalid('Continue from the selected bead or end the turn.');
      return;
    }

    if (_state.occupancy[nodeId] == _state.currentPlayer) {
      final moves = GameRules.legalMoves(_state, fromNode: nodeId);
      GameFeedback.play(
        context,
        moves.isEmpty ? GameFeedbackCue.invalid : GameFeedbackCue.select,
      );
      setState(() {
        _selectedNode = nodeId;
        _message = moves.isEmpty ? 'That bead has no legal moves.' : null;
        _messageTone = moves.isEmpty ? _MessageTone.warning : _MessageTone.info;
      });
      return;
    }

    final owner = _state.occupancy[nodeId];
    _showInvalid(
      owner == null
          ? 'Choose one of your beads or a highlighted point.'
          : '${owner.label} owns that bead.',
    );
  }

  void _handleEmptyTap() {
    if (_state.isGameOver) {
      return;
    }
    if (_isBotTurn || _botThinking) {
      _showInvalid('Bot is choosing a move.');
      return;
    }
    if (_state.isCaptureChain) {
      _showInvalid('Finish the capture chain or tap End Turn.');
      return;
    }
    if (_selectedNode == null) {
      return;
    }
    GameFeedback.play(context, GameFeedbackCue.tap);
    setState(() {
      _selectedNode = null;
      _message = 'Selection cleared.';
      _messageTone = _MessageTone.info;
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

  void _applyMove(GameMove move, {_MoveActor actor = _MoveActor.human}) {
    final nextState = GameRules.applyMove(_state, move);
    if (identical(nextState, _state)) {
      _showInvalid('That move is not legal.');
      return;
    }

    final result = nextState.result;
    final cue = result != null
        ? _resultCue(result)
        : move.isCapture
        ? GameFeedbackCue.capture
        : GameFeedbackCue.validMove;
    GameFeedback.play(context, cue);

    setState(() {
      _state = nextState;
      _selectedNode = nextState.isCaptureChain ? nextState.chainNode : null;
      _lastMove = move;
      _moveCount++;
      if (move.isCapture) {
        _captureCount++;
      }
      _message = _messageFor(nextState, move, actor);
      _messageTone = result != null
          ? _MessageTone.result
          : move.isCapture
          ? _MessageTone.capture
          : _MessageTone.success;
    });

    _logMove(move, actor);
    _moveFeedbackController.forward(from: 0);
    if (result != null) {
      _resultController.forward(from: 0);
    }
    _recordResultIfNeeded(nextState);
    _scheduleBotTurn();
  }

  void _endCaptureChain() {
    if (_isBotTurn || _botThinking) {
      _showInvalid('Bot is choosing a move.');
      return;
    }
    _finishCaptureChain(actor: _MoveActor.human);
  }

  void _finishCaptureChain({required _MoveActor actor}) {
    final nextState = GameRules.endCaptureChain(_state);
    final result = nextState.result;
    unawaited(
      (_analytics ?? GameAnalyticsScope.read(context)).logCaptureChain(
        setup: widget.setup,
        action: 'ended',
        actor: actor.name,
      ),
    );
    GameFeedback.play(
      context,
      result == null ? GameFeedbackCue.validMove : _resultCue(result),
    );
    setState(() {
      _state = nextState;
      _selectedNode = null;
      _botThinking = false;
      _message = result == null
          ? _chainEndedMessage(actor, nextState)
          : _resultText(result);
      _messageTone = result == null ? _MessageTone.info : _MessageTone.result;
    });
    if (result != null) {
      _resultController.forward(from: 0);
    }
    _recordResultIfNeeded(nextState);
    _scheduleBotTurn();
  }

  void _restart() {
    GameFeedback.play(context, GameFeedbackCue.restart);
    _moveFeedbackController.value = 1;
    _resultController.reset();
    setState(() {
      _state = GameRules.initialState();
      _selectedNode = null;
      _message = null;
      _messageTone = _MessageTone.info;
      _lastMove = null;
      _botTurnQueued = false;
      _botThinking = false;
      _resultRecorded = false;
      _postResultAdQueued = false;
      _moveCount = 0;
      _captureCount = 0;
    });
    _scheduleBotTurn();
  }

  void _scheduleBotTurn() {
    if (!_isBotTurn || _botTurnQueued || !mounted) {
      return;
    }

    _botTurnQueued = true;
    setState(() {
      _botThinking = true;
      _message = _state.isCaptureChain
          ? 'Bot is checking the capture chain.'
          : 'Bot is choosing a move.';
      _messageTone = _MessageTone.info;
    });

    Future<void>.delayed(const Duration(milliseconds: 520), () {
      if (!mounted) {
        return;
      }
      _botTurnQueued = false;
      _playBotStep();
    });
  }

  void _playBotStep() {
    if (!_isBotTurn) {
      setState(() {
        _botThinking = false;
      });
      return;
    }

    final difficulty = widget.setup.botDifficulty ?? BotDifficulty.easy;
    if (_state.isCaptureChain &&
        !BotPlayer.shouldContinueCaptureChain(_state, difficulty: difficulty)) {
      _finishCaptureChain(actor: _MoveActor.bot);
      return;
    }

    final move = BotPlayer.chooseMove(_state, difficulty: difficulty);
    if (move == null) {
      setState(() {
        _botThinking = false;
        _message = 'Bot has no legal move.';
        _messageTone = _MessageTone.warning;
      });
      return;
    }

    setState(() {
      _botThinking = false;
    });
    _applyMove(move, actor: _MoveActor.bot);
  }

  void _recordResultIfNeeded(MatchState state) {
    final result = state.result;
    if (_resultRecorded || result == null) {
      return;
    }

    _resultRecorded = true;
    final entry = MatchHistoryEntry(
      completedAt: DateTime.now(),
      mode: widget.setup.mode,
      botDifficulty: widget.setup.botDifficulty,
      winner: result.winner,
      reason: result.reason,
      moveCount: _moveCount,
      captureCount: _captureCount,
      player1Beads: state.beadCount(Player.player1),
      player2Beads: state.beadCount(Player.player2),
    );
    MatchHistoryScope.read(context).add(entry);
    unawaited(
      (_analytics ?? GameAnalyticsScope.read(context)).logMatchFinish(entry),
    );
    (_ads ?? GameAdsScope.read(context)).markMatchFinished();
    _schedulePostResultAd();
  }

  void _logMove(GameMove move, _MoveActor actor) {
    final analytics = _analytics ?? GameAnalyticsScope.read(context);
    unawaited(
      analytics.logMove(
        setup: widget.setup,
        move: move,
        moveCount: _moveCount,
        captureCount: _captureCount,
        actor: actor.name,
      ),
    );
    if (move.isCapture) {
      unawaited(
        analytics.logCaptureChain(
          setup: widget.setup,
          action: _state.isCaptureChain ? 'available' : 'not_available',
          actor: actor.name,
        ),
      );
    }
  }

  void _schedulePostResultAd() {
    if (_postResultAdQueued) {
      return;
    }
    _postResultAdQueued = true;
    Future<void>.delayed(GameAdsController.postResultDelay, () {
      if (!mounted || !_state.isGameOver) {
        return;
      }
      unawaited(
        (_ads ?? GameAdsScope.read(context)).maybeShowMatchEndInterstitial(),
      );
    });
  }

  void _showInvalid(String message) {
    GameFeedback.play(context, GameFeedbackCue.invalid);
    unawaited(
      (_analytics ?? GameAnalyticsScope.read(context)).logInvalidAction(
        setup: widget.setup,
        reason: message,
      ),
    );
    setState(() {
      _message = message;
      _messageTone = _MessageTone.warning;
    });
  }

  void _showHelp() {
    GameFeedback.play(context, GameFeedbackCue.tap);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _HelpSheet(),
    );
  }

  void _showPauseMenu() {
    GameFeedback.play(context, GameFeedbackCue.tap);
    final screenContext = context;
    showModalBottomSheet<void>(
      context: screenContext,
      showDragHandle: true,
      builder: (sheetContext) {
        return _PauseSheet(
          onResume: () => Navigator.of(sheetContext).pop(),
          onRules: () {
            Navigator.of(sheetContext).pop();
            Navigator.of(screenContext).push(
              MaterialPageRoute<void>(builder: (_) => const RulesScreen()),
            );
          },
          onSettings: () {
            Navigator.of(sheetContext).pop();
            Navigator.of(screenContext).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            );
          },
          onRestart: () {
            Navigator.of(sheetContext).pop();
            _restart();
          },
          onHome: () {
            Navigator.of(sheetContext).pop();
            Navigator.of(screenContext).pop();
          },
        );
      },
    );
  }

  GameFeedbackCue _resultCue(MatchResult result) {
    if (result.isDraw) {
      return GameFeedbackCue.loss;
    }
    if (widget.setup.hasBot && result.winner == Player.player2) {
      return GameFeedbackCue.loss;
    }
    return GameFeedbackCue.win;
  }

  String _messageFor(MatchState state, GameMove move, _MoveActor actor) {
    final result = state.result;
    if (result != null) {
      return _resultText(result);
    }
    if (state.isCaptureChain) {
      if (actor == _MoveActor.bot) {
        return 'Bot captured and is checking for another jump.';
      }
      return 'Capture made. Continue with this bead or tap End Turn.';
    }
    final player = _playerLabel(state.currentPlayer);
    if (actor == _MoveActor.bot) {
      return move.isCapture
          ? 'Bot captured. Your turn.'
          : 'Bot moved. Your turn.';
    }
    return move.isCapture
        ? 'Capture made. $player turn.'
        : 'Move made. $player turn.';
  }

  String _chainEndedMessage(_MoveActor actor, MatchState state) {
    if (actor == _MoveActor.bot) {
      return 'Bot ended the capture chain. Your turn.';
    }
    return '${_playerLabel(state.currentPlayer)} turn.';
  }

  String _promptText() {
    final result = _state.result;
    if (result != null) {
      return 'Match complete. Rematch or go home.';
    }
    if (_state.isCaptureChain) {
      if (_isBotTurn || _botThinking) {
        return 'Bot is checking the capture chain.';
      }
      return 'Optional chain: capture again with the selected bead or end turn.';
    }
    if (_isBotTurn || _botThinking) {
      return 'Bot is choosing a move.';
    }
    if (_selectedNode == null) {
      return '${_playerLabel(_state.currentPlayer)}: select one of your beads.';
    }
    if (_selectedMoves.isEmpty) {
      return 'Pick another bead with a legal move.';
    }

    final captureCount = _selectedMoves.where((move) => move.isCapture).length;
    if (captureCount > 0) {
      return '$captureCount capture target${captureCount == 1 ? '' : 's'} highlighted.';
    }
    return '${_selectedMoves.length} move target${_selectedMoves.length == 1 ? '' : 's'} highlighted.';
  }

  String _resultText(MatchResult result) {
    if (result.isDraw) {
      return switch (result.reason) {
        MatchEndReason.repetition => 'Draw by repeated position.',
        MatchEndReason.noCaptureLimit => 'Draw: no capture limit reached.',
        MatchEndReason.capturedAll || MatchEndReason.blocked => 'Draw.',
      };
    }
    final winner = _playerLabel(result.winner!);
    return switch (result.reason) {
      MatchEndReason.capturedAll => '$winner wins by capture.',
      MatchEndReason.blocked => '$winner wins by blocking.',
      MatchEndReason.repetition ||
      MatchEndReason.noCaptureLimit => '$winner wins.',
    };
  }

  String _playerLabel(Player player) {
    if (!widget.setup.hasBot) {
      return player.label;
    }
    return player == Player.player1 ? 'You' : 'Bot';
  }

  @override
  Widget build(BuildContext context) {
    final result = _state.result;
    final visibleMessage = _message ?? _promptText();
    final visibleTone = _message == null ? _MessageTone.info : _messageTone;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.setup.label),
        actions: [
          IconButton(
            tooltip: 'Help',
            onPressed: _showHelp,
            icon: const Icon(Icons.help_outline_rounded),
          ),
          IconButton(
            tooltip: 'Pause',
            onPressed: _showPauseMenu,
            icon: const Icon(Icons.pause_circle_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _MatchHud(
              state: _state,
              resultText: result == null ? null : _resultText(result),
              message: visibleMessage,
              messageTone: visibleTone,
              player1Label: widget.setup.hasBot ? 'You' : 'Player 1',
              player2Label: widget.setup.hasBot ? 'Bot' : 'Player 2',
              botThinking: _botThinking,
            ),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BoardView(
                      state: _state,
                      selectedNode: _selectedNode,
                      legalMoves: _selectedMoves,
                      lastMove: _lastMove,
                      feedbackAnimation: _moveFeedback,
                      onNodeTap: _handleNodeTap,
                      onEmptyTap: _handleEmptyTap,
                    ),
                    if (result != null)
                      _GameOverPanel(
                        resultText: _resultText(result),
                        animation: _resultFade,
                        scaleAnimation: _resultScale,
                        onRematch: _restart,
                        onHome: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),
            ),
            _ActionBar(
              isCaptureChain: _state.isCaptureChain,
              onRestart: _restart,
              onHelp: _showHelp,
              onEndTurn: _endCaptureChain,
            ),
          ],
        ),
      ),
    );
  }
}

enum _MessageTone { info, success, capture, warning, result }

enum _MoveActor { human, bot }

class _MatchHud extends StatelessWidget {
  const _MatchHud({
    required this.state,
    required this.resultText,
    required this.message,
    required this.messageTone,
    required this.player1Label,
    required this.player2Label,
    required this.botThinking,
  });

  final MatchState state;
  final String? resultText;
  final String message;
  final _MessageTone messageTone;
  final String player1Label;
  final String player2Label;
  final bool botThinking;

  @override
  Widget build(BuildContext context) {
    final turnLabel = state.currentPlayer == Player.player1
        ? player1Label
        : player2Label;
    final turnText =
        resultText ?? (botThinking ? 'Bot thinking...' : '$turnLabel turn');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PlayerCount(
                  label: player1Label,
                  beads: state.beadCount(Player.player1),
                  color: _playerColor(Player.player1),
                  isActive:
                      !state.isGameOver &&
                      state.currentPlayer == Player.player1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PlayerCount(
                  label: player2Label,
                  beads: state.beadCount(Player.player2),
                  color: _playerColor(Player.player2),
                  isActive:
                      !state.isGameOver &&
                      state.currentPlayer == Player.player2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              turnText,
              key: ValueKey(turnText),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          _StatusBanner(message: message, tone: messageTone),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message, required this.tone});

  final String message;
  final _MessageTone tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (tone) {
      _MessageTone.info => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
        Icons.touch_app_rounded,
      ),
      _MessageTone.success => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        Icons.check_circle_outline_rounded,
      ),
      _MessageTone.capture => (
        const Color(0xFFFFE1A6),
        const Color(0xFF432C00),
        Icons.bolt_rounded,
      ),
      _MessageTone.warning => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        Icons.error_outline_rounded,
      ),
      _MessageTone.result => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        Icons.emoji_events_rounded,
      ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 160),
      child: DecoratedBox(
        key: ValueKey('$message-$tone'),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: foreground),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isCaptureChain,
    required this.onRestart,
    required this.onHelp,
    required this.onEndTurn,
  });

  final bool isCaptureChain;
  final VoidCallback onRestart;
  final VoidCallback onHelp;
  final VoidCallback onEndTurn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Restart'),
          ),
          OutlinedButton.icon(
            onPressed: onHelp,
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Help'),
          ),
          if (isCaptureChain)
            FilledButton.icon(
              onPressed: onEndTurn,
              icon: const Icon(Icons.check_rounded),
              label: const Text('End Turn'),
            ),
        ],
      ),
    );
  }
}

class _GameOverPanel extends StatelessWidget {
  const _GameOverPanel({
    required this.resultText,
    required this.animation,
    required this.scaleAnimation,
    required this.onRematch,
    required this.onHome,
  });

  final String resultText;
  final Animation<double> animation;
  final Animation<double> scaleAnimation;
  final VoidCallback onRematch;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                color: Color(0x33000000),
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: colorScheme.primary,
                    size: 42,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Match Complete',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    resultText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: onRematch,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Rematch'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onHome,
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Home'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        children: const [
          _SheetTitle(title: 'How to play'),
          _HelpItem(
            icon: Icons.touch_app_rounded,
            title: 'Select a bead',
            text: 'Tap or drag one of the current player beads.',
          ),
          _HelpItem(
            icon: Icons.radio_button_checked_rounded,
            title: 'Green targets move',
            text: 'Move to an adjacent empty point.',
          ),
          _HelpItem(
            icon: Icons.bolt_rounded,
            title: 'Amber targets capture',
            text: 'Jump over an opponent bead into the empty point beyond.',
          ),
          _HelpItem(
            icon: Icons.check_rounded,
            title: 'Capture chains are optional',
            text: 'After a capture, continue with the same bead or end turn.',
          ),
        ],
      ),
    );
  }
}

class _PauseSheet extends StatelessWidget {
  const _PauseSheet({
    required this.onResume,
    required this.onRules,
    required this.onSettings,
    required this.onRestart,
    required this.onHome,
  });

  final VoidCallback onResume;
  final VoidCallback onRules;
  final VoidCallback onSettings;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SheetTitle(title: 'Paused'),
            FilledButton.icon(
              onPressed: onResume,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Resume'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onRules,
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('Rules'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onSettings,
              icon: const Icon(Icons.settings_rounded),
              label: const Text('Settings'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Restart Match'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onHome,
              icon: const Icon(Icons.home_rounded),
              label: const Text('Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _playerColor(Player player) {
  return player == Player.player1
      ? const Color(0xFFB74135)
      : const Color(0xFF265C9E);
}

class _PlayerCount extends StatelessWidget {
  const _PlayerCount({
    required this.label,
    required this.beads,
    required this.color,
    required this.isActive,
  });

  final String label;
  final int beads;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final captured = 16 - beads;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.08) : null,
        border: Border.all(
          color: color.withValues(alpha: isActive ? 0.82 : 0.35),
          width: isActive ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '$captured captured',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Text(
              '$beads',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
