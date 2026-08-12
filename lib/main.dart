import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/board_hit_tester.dart';
import 'game/dots_and_boxes.dart';
import 'game/dots_and_boxes_bot.dart';
import 'services/ad_service.dart';
import 'services/analytics_service.dart';

const _defaultBoardPreset = BoardPreset(label: '4x4', rows: 4, columns: 4);
const _boardEdgePadding = 30.0;
const _boardTouchTolerance = 24.0;
const _boardAmbiguityMargin = 8.0;
const _playerOneColor = Color(0xFF2563EB);
const _playerTwoColor = Color(0xFFDC2626);

enum _StatusTone { turn, success, error, result }

enum MatchMode {
  localTwoPlayer,
  playerVsBot;

  String get label {
    return switch (this) {
      MatchMode.localTwoPlayer => '2 Players',
      MatchMode.playerVsBot => 'Vs Bot',
    };
  }

  String get title {
    return switch (this) {
      MatchMode.localTwoPlayer => 'Local 2 Player',
      MatchMode.playerVsBot => 'Player vs Bot',
    };
  }
}

class MatchSummary {
  const MatchSummary({
    required this.mode,
    required this.preset,
    required this.botDifficulty,
    required this.winner,
    required this.playerOneScore,
    required this.playerTwoScore,
    required this.moveCount,
    required this.boxesCompleted,
    required this.extraTurnCount,
    required this.invalidMoveCount,
    required this.durationSeconds,
    required this.completedAt,
  });

  final MatchMode mode;
  final BoardPreset preset;
  final BotDifficulty? botDifficulty;
  final Player? winner;
  final int playerOneScore;
  final int playerTwoScore;
  final int moveCount;
  final int boxesCompleted;
  final int extraTurnCount;
  final int invalidMoveCount;
  final int durationSeconds;
  final DateTime completedAt;

  String get scoreLine => '$playerOneScore - $playerTwoScore';

  String get resultLabel {
    final matchWinner = winner;
    if (matchWinner == null) {
      return 'Draw';
    }

    return switch ((mode, matchWinner)) {
      (MatchMode.playerVsBot, Player.two) => 'Bot won',
      (_, Player.one) => 'Player 1 won',
      (_, Player.two) => 'Player 2 won',
    };
  }
}

class GameSettings {
  const GameSettings({this.soundEnabled = true, this.hapticsEnabled = true});

  final bool soundEnabled;
  final bool hapticsEnabled;

  GameSettings copyWith({bool? soundEnabled, bool? hapticsEnabled}) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}

class _GameFeedback {
  const _GameFeedback(this.settings);

  final GameSettings settings;

  void tap() {
    _playSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.selectionClick);
  }

  void validMove() {
    _playSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.lightImpact);
  }

  void invalidMove() {
    _playSound(SystemSoundType.alert);
    _playHaptic(HapticFeedback.mediumImpact);
  }

  void score() {
    _playSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.mediumImpact);
  }

  void matchEnd({required bool draw}) {
    _playSound(draw ? SystemSoundType.alert : SystemSoundType.click);
    _playHaptic(
      draw ? HapticFeedback.mediumImpact : HapticFeedback.heavyImpact,
    );
  }

  void _playSound(SystemSoundType type) {
    if (!settings.soundEnabled) {
      return;
    }

    SystemSound.play(type).catchError((Object _) {});
  }

  void _playHaptic(Future<void> Function() action) {
    if (!settings.hapticsEnabled) {
      return;
    }

    action().catchError((Object _) {});
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final analytics = AppAnalytics();
  unawaited(analytics.initialize());
  final adService = AdMobService(analytics: analytics);
  unawaited(adService.initialize());
  runApp(DotsAndBoxesApp(analytics: analytics, adService: adService));
}

class DotsAndBoxesApp extends StatelessWidget {
  const DotsAndBoxesApp({super.key, this.analytics, this.adService});

  final AppAnalytics? analytics;
  final AdMobService? adService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dots & Boxes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _playerOneColor),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      home: DotsAndBoxesShell(
        analytics: analytics ?? AppAnalytics.disabled(),
        adService: adService ?? AdMobService.disabled(),
      ),
    );
  }
}

class DotsAndBoxesShell extends StatefulWidget {
  const DotsAndBoxesShell({
    super.key,
    required this.analytics,
    required this.adService,
  });

  final AppAnalytics analytics;
  final AdMobService adService;

  @override
  State<DotsAndBoxesShell> createState() => _DotsAndBoxesShellState();
}

class _DotsAndBoxesShellState extends State<DotsAndBoxesShell> {
  BoardPreset _selectedPreset = _defaultBoardPreset;
  MatchMode _selectedMode = MatchMode.localTwoPlayer;
  BotDifficulty _selectedBotDifficulty = BotDifficulty.casual;
  GameSettings _settings = const GameSettings();
  final List<MatchSummary> _matchHistory = <MatchSummary>[];
  var _showMatch = false;
  var _matchSeed = 0;

  @override
  void initState() {
    super.initState();
    unawaited(
      widget.analytics.logMainMenuViewed(historyCount: _matchHistory.length),
    );
  }

  @override
  void dispose() {
    widget.adService.dispose();
    super.dispose();
  }

  void _startLocalMatch() {
    unawaited(
      widget.analytics.logMatchStarted(
        mode: _selectedMode.name,
        grid: _selectedPreset.label,
        rows: _selectedPreset.rows,
        columns: _selectedPreset.columns,
        botDifficulty: _selectedMode == MatchMode.playerVsBot
            ? _selectedBotDifficulty.name
            : null,
      ),
    );
    setState(() {
      _matchSeed += 1;
      _showMatch = true;
    });
  }

  void _showMainMenu() {
    unawaited(
      widget.analytics.logMainMenuViewed(historyCount: _matchHistory.length),
    );
    setState(() {
      _showMatch = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showMatch) {
      return DotsAndBoxesMatchPage(
        key: ValueKey<int>(_matchSeed),
        preset: _selectedPreset,
        mode: _selectedMode,
        botDifficulty: _selectedMode == MatchMode.playerVsBot
            ? _selectedBotDifficulty
            : null,
        settings: _settings,
        analytics: widget.analytics,
        adService: widget.adService,
        onSettingsChanged: _updateSettings,
        onMatchFinished: _recordMatchSummary,
        onExitToMenu: _showMainMenu,
      );
    }

    return MainMenuPage(
      selectedPreset: _selectedPreset,
      selectedMode: _selectedMode,
      selectedBotDifficulty: _selectedBotDifficulty,
      matchHistory: _matchHistory,
      settings: _settings,
      onSettingsChanged: _updateSettings,
      onModeChanged: (mode) {
        _GameFeedback(_settings).tap();
        setState(() {
          _selectedMode = mode;
        });
      },
      onBotDifficultyChanged: (difficulty) {
        _GameFeedback(_settings).tap();
        setState(() {
          _selectedBotDifficulty = difficulty;
        });
      },
      onPresetChanged: (preset) {
        _GameFeedback(_settings).tap();
        setState(() {
          _selectedPreset = preset;
        });
      },
      onStartLocalMatch: _startLocalMatch,
    );
  }

  void _updateSettings(GameSettings settings) {
    unawaited(
      widget.analytics.logSettingsChanged(
        soundEnabled: settings.soundEnabled,
        hapticsEnabled: settings.hapticsEnabled,
      ),
    );
    setState(() {
      _settings = settings;
    });
  }

  void _recordMatchSummary(MatchSummary summary) {
    widget.adService.recordMatchFinished();
    unawaited(
      widget.analytics.logMatchFinished(
        mode: summary.mode.name,
        grid: summary.preset.label,
        rows: summary.preset.rows,
        columns: summary.preset.columns,
        result: summary.resultLabel,
        playerOneScore: summary.playerOneScore,
        playerTwoScore: summary.playerTwoScore,
        moveCount: summary.moveCount,
        boxesCompleted: summary.boxesCompleted,
        extraTurnCount: summary.extraTurnCount,
        invalidMoveCount: summary.invalidMoveCount,
        durationSeconds: summary.durationSeconds,
        botDifficulty: summary.botDifficulty?.name,
      ),
    );
    setState(() {
      _matchHistory.insert(0, summary);
      if (_matchHistory.length > 10) {
        _matchHistory.removeRange(10, _matchHistory.length);
      }
    });
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({
    super.key,
    required this.selectedPreset,
    required this.selectedMode,
    required this.selectedBotDifficulty,
    required this.matchHistory,
    required this.settings,
    required this.onSettingsChanged,
    required this.onModeChanged,
    required this.onBotDifficultyChanged,
    required this.onPresetChanged,
    required this.onStartLocalMatch,
  });

  final BoardPreset selectedPreset;
  final MatchMode selectedMode;
  final BotDifficulty selectedBotDifficulty;
  final List<MatchSummary> matchHistory;
  final GameSettings settings;
  final ValueChanged<GameSettings> onSettingsChanged;
  final ValueChanged<MatchMode> onModeChanged;
  final ValueChanged<BotDifficulty> onBotDifficultyChanged;
  final ValueChanged<BoardPreset> onPresetChanged;
  final VoidCallback onStartLocalMatch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dots & Boxes'),
        actions: [
          IconButton(
            tooltip: 'How to play',
            onPressed: () {
              _GameFeedback(settings).tap();
              _showHelpSheet(context);
            },
            icon: const Icon(Icons.help_outline_rounded),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              _GameFeedback(settings).tap();
              _showSettingsSheet(context, settings, onSettingsChanged);
            },
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Local dots. Bot practice. Quick captures.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Draw open lines, close boxes to score, and keep your turn after every capture.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MenuSectionLabel(text: 'Mode'),
                    Align(
                      child: SegmentedButton<MatchMode>(
                        showSelectedIcon: false,
                        selected: <MatchMode>{selectedMode},
                        segments: MatchMode.values.map((mode) {
                          return ButtonSegment<MatchMode>(
                            value: mode,
                            label: Text(mode.label),
                          );
                        }).toList(),
                        onSelectionChanged: (selection) {
                          onModeChanged(selection.single);
                        },
                      ),
                    ),
                    if (selectedMode == MatchMode.playerVsBot) ...[
                      const SizedBox(height: 18),
                      _MenuSectionLabel(text: 'Bot difficulty'),
                      Align(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SegmentedButton<BotDifficulty>(
                            showSelectedIcon: false,
                            selected: <BotDifficulty>{selectedBotDifficulty},
                            segments: BotDifficulty.values.map((difficulty) {
                              return ButtonSegment<BotDifficulty>(
                                value: difficulty,
                                label: Text(difficulty.label),
                              );
                            }).toList(),
                            onSelectionChanged: (selection) {
                              onBotDifficultyChanged(selection.single);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedBotDifficulty.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    _MenuSectionLabel(text: 'Board'),
                    Text(
                      '${selectedPreset.label} boxes',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Align(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SegmentedButton<BoardPreset>(
                          showSelectedIcon: false,
                          selected: <BoardPreset>{selectedPreset},
                          segments: BoardPreset.values.map((preset) {
                            return ButtonSegment<BoardPreset>(
                              value: preset,
                              label: Text(preset.label),
                            );
                          }).toList(),
                          onSelectionChanged: (selection) {
                            onPresetChanged(selection.single);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () {
                        _GameFeedback(settings).tap();
                        onStartLocalMatch();
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        selectedMode == MatchMode.playerVsBot
                            ? 'Start Vs Bot'
                            : 'Start Local Match',
                      ),
                    ),
                    if (matchHistory.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _RecentMatches(history: matchHistory),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuSectionLabel extends StatelessWidget {
  const _MenuSectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: const Color(0xFF334155),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RecentMatches extends StatelessWidget {
  const _RecentMatches({required this.history});

  final List<MatchSummary> history;

  @override
  Widget build(BuildContext context) {
    final visibleMatches = history.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent matches',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final match in visibleMatches) _RecentMatchRow(summary: match),
        ],
      ),
    );
  }
}

class _RecentMatchRow extends StatelessWidget {
  const _RecentMatchRow({required this.summary});

  final MatchSummary summary;

  @override
  Widget build(BuildContext context) {
    final subtitle = summary.mode == MatchMode.playerVsBot
        ? '${summary.preset.label} vs ${summary.botDifficulty?.label ?? 'Bot'}'
        : '${summary.preset.label} local';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            summary.winner == null
                ? Icons.handshake_rounded
                : Icons.emoji_events_rounded,
            size: 18,
            color: const Color(0xFF475569),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${summary.resultLabel} ${summary.scoreLine}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '$subtitle, ${summary.moveCount} moves',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showHelpSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => const _HelpSheet(),
  );
}

void _showSettingsSheet(
  BuildContext context,
  GameSettings settings,
  ValueChanged<GameSettings> onChanged,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return _SettingsSheet(settings: settings, onChanged: onChanged);
    },
  );
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to play',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const _HelpRow(
              icon: Icons.timeline_rounded,
              text: 'Tap or drag near an open segment to draw one line.',
            ),
            const _HelpRow(
              icon: Icons.crop_square_rounded,
              text: 'Finish the fourth side of a box to claim it.',
            ),
            const _HelpRow(
              icon: Icons.replay_rounded,
              text: 'Claiming a box gives the same player another turn.',
            ),
            const _HelpRow(
              icon: Icons.emoji_events_rounded,
              text: 'When every box is claimed, the higher score wins.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet({required this.settings, required this.onChanged});

  final GameSettings settings;
  final ValueChanged<GameSettings> onChanged;

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late GameSettings _settings = widget.settings;

  void _update(GameSettings settings) {
    setState(() {
      _settings = settings;
    });
    widget.onChanged(settings);
    _GameFeedback(settings).tap();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Settings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.volume_up_rounded),
              title: const Text('Sound feedback'),
              subtitle: const Text('Move and result cues.'),
              value: _settings.soundEnabled,
              onChanged: (enabled) {
                _update(_settings.copyWith(soundEnabled: enabled));
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.vibration_rounded),
              title: const Text('Haptic feedback'),
              subtitle: const Text('Gentle touch cues.'),
              value: _settings.hapticsEnabled,
              onChanged: (enabled) {
                _update(_settings.copyWith(hapticsEnabled: enabled));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DotsAndBoxesMatchPage extends StatefulWidget {
  const DotsAndBoxesMatchPage({
    super.key,
    required this.preset,
    required this.mode,
    required this.botDifficulty,
    required this.settings,
    required this.analytics,
    required this.adService,
    required this.onSettingsChanged,
    required this.onMatchFinished,
    required this.onExitToMenu,
  });

  final BoardPreset preset;
  final MatchMode mode;
  final BotDifficulty? botDifficulty;
  final GameSettings settings;
  final AppAnalytics analytics;
  final AdMobService adService;
  final ValueChanged<GameSettings> onSettingsChanged;
  final ValueChanged<MatchSummary> onMatchFinished;
  final VoidCallback onExitToMenu;

  @override
  State<DotsAndBoxesMatchPage> createState() => _DotsAndBoxesMatchPageState();
}

class _DotsAndBoxesMatchPageState extends State<DotsAndBoxesMatchPage>
    with SingleTickerProviderStateMixin {
  late DotsAndBoxesGame _game = DotsAndBoxesGame.fromPreset(widget.preset);
  late final AnimationController _moveFeedbackController;
  Timer? _botTimer;
  BoardLine? _highlightLine;
  Set<BoxCoordinate> _highlightedBoxes = const <BoxCoordinate>{};
  String _statusMessage = '${Player.one.label} turn';
  _StatusTone _statusTone = _StatusTone.turn;
  late DateTime _matchStartedAt = DateTime.now();
  var _boxesCompleted = 0;
  var _extraTurnCount = 0;
  var _invalidMoveCount = 0;
  var _botThinking = false;
  var _reportedMatchResult = false;

  @override
  void initState() {
    super.initState();
    _moveFeedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    _moveFeedbackController.dispose();
    super.dispose();
  }

  void _restartMatch() {
    _GameFeedback(widget.settings).tap();
    _botTimer?.cancel();
    setState(() {
      _game = DotsAndBoxesGame.fromPreset(widget.preset);
      _highlightLine = null;
      _highlightedBoxes = const <BoxCoordinate>{};
      _statusMessage = '${Player.one.label} turn';
      _statusTone = _StatusTone.turn;
      _matchStartedAt = DateTime.now();
      _boxesCompleted = 0;
      _extraTurnCount = 0;
      _invalidMoveCount = 0;
      _botThinking = false;
      _reportedMatchResult = false;
    });
    _moveFeedbackController.reset();
    unawaited(
      widget.analytics.logMatchStarted(
        mode: widget.mode.name,
        grid: widget.preset.label,
        rows: widget.preset.rows,
        columns: widget.preset.columns,
        botDifficulty: widget.botDifficulty?.name,
      ),
    );
  }

  void _handleLineSelected(BoardLine line) {
    if (_isBotTurn || _botThinking) {
      _GameFeedback(widget.settings).invalidMove();
      setState(() {
        _invalidMoveCount += 1;
        _statusMessage = 'Bot is choosing a line.';
        _statusTone = _StatusTone.error;
      });
      unawaited(
        widget.analytics.logInvalidMove(
          mode: widget.mode.name,
          grid: widget.preset.label,
          reason: 'bot_turn',
        ),
      );
      return;
    }

    _applyMove(line);
  }

  void _applyMove(BoardLine line) {
    final result = _game.drawLine(line);
    final feedback = _GameFeedback(widget.settings);

    if (!result.accepted) {
      feedback.invalidMove();
      setState(() {
        _invalidMoveCount += 1;
        _highlightLine = null;
        _highlightedBoxes = const <BoxCoordinate>{};
        _statusMessage = _messageFor(result);
        _statusTone = _StatusTone.error;
      });
      unawaited(
        widget.analytics.logInvalidMove(
          mode: widget.mode.name,
          grid: widget.preset.label,
          reason: result.rejectionReason ?? 'rejected',
        ),
      );
      return;
    }

    if (_game.isGameOver) {
      feedback.matchEnd(draw: _game.winner == null);
    } else if (result.boxesCompleted > 0) {
      feedback.score();
    } else {
      feedback.validMove();
    }

    setState(() {
      _highlightLine = result.line;
      _highlightedBoxes = result.completedBoxes.toSet();
      _boxesCompleted += result.boxesCompleted;
      if (result.extraTurn) {
        _extraTurnCount += 1;
      }
      _statusMessage = _messageFor(result);
      _statusTone = _toneFor(result);
    });
    unawaited(
      widget.analytics.logLineDrawn(
        mode: widget.mode.name,
        grid: widget.preset.label,
        actor: _analyticsActorForPlayer(result.player),
        axis: result.line?.axis.name ?? 'unknown',
        moveCount: _game.drawnLines.length,
        boxesCompleted: result.boxesCompleted,
        extraTurn: result.extraTurn,
      ),
    );
    if (result.boxesCompleted > 0) {
      unawaited(
        widget.analytics.logBoxCapture(
          mode: widget.mode.name,
          grid: widget.preset.label,
          actor: _analyticsActorForPlayer(result.player),
          boxesCompleted: result.boxesCompleted,
        ),
      );
    }
    if (result.extraTurn) {
      unawaited(
        widget.analytics.logExtraTurn(
          mode: widget.mode.name,
          grid: widget.preset.label,
          actor: _analyticsActorForPlayer(result.player),
        ),
      );
    }
    _moveFeedbackController.forward(from: 0);
    _recordMatchIfNeeded();
    _queueBotTurnIfNeeded();
  }

  void _handleInvalidSelection(String message) {
    _GameFeedback(widget.settings).invalidMove();
    setState(() {
      _invalidMoveCount += 1;
      _highlightLine = null;
      _highlightedBoxes = const <BoxCoordinate>{};
      _statusMessage = _game.isGameOver ? 'Match complete.' : message;
      _statusTone = _game.isGameOver ? _StatusTone.result : _StatusTone.error;
    });
    unawaited(
      widget.analytics.logInvalidMove(
        mode: widget.mode.name,
        grid: widget.preset.label,
        reason: message,
      ),
    );
  }

  String _messageFor(MoveResult result) {
    if (!result.accepted) {
      return result.rejectionReason ?? 'Choose another line.';
    }

    if (_game.isGameOver) {
      final winner = _game.winner;
      return winner == null
          ? 'Match complete: draw'
          : '${_nameForPlayer(winner)} wins';
    }

    if (result.boxesCompleted > 0) {
      final boxes = result.boxesCompleted == 1 ? 'box' : 'boxes';
      return '${_nameForPlayer(result.player)} claimed '
          '${result.boxesCompleted} $boxes';
    }

    return '${_nameForPlayer(_game.currentPlayer)} turn';
  }

  _StatusTone _toneFor(MoveResult result) {
    if (!result.accepted) {
      return _StatusTone.error;
    }
    if (_game.isGameOver) {
      return _StatusTone.result;
    }
    if (result.boxesCompleted > 0) {
      return _StatusTone.success;
    }
    return _StatusTone.turn;
  }

  bool get _isBotMode => widget.mode == MatchMode.playerVsBot;

  bool get _isBotTurn {
    return _isBotMode && !_game.isGameOver && _game.currentPlayer == Player.two;
  }

  String _nameForPlayer(Player player) {
    if (_isBotMode && player == Player.two) {
      return 'Bot';
    }
    return player.label;
  }

  String _analyticsActorForPlayer(Player player) {
    if (_isBotMode && player == Player.two) {
      return 'bot';
    }
    return player == Player.one ? 'player_one' : 'player_two';
  }

  void _queueBotTurnIfNeeded() {
    if (!_isBotTurn) {
      if (_botThinking) {
        setState(() {
          _botThinking = false;
        });
      }
      return;
    }

    _botTimer?.cancel();
    setState(() {
      _botThinking = true;
      _statusMessage = 'Bot is choosing a line.';
      _statusTone = _StatusTone.turn;
    });
    _botTimer = Timer(const Duration(milliseconds: 420), _playBotTurn);
  }

  void _playBotTurn() {
    if (!mounted || !_isBotTurn || _game.isGameOver) {
      return;
    }

    final difficulty = widget.botDifficulty ?? BotDifficulty.casual;
    final line = DotsAndBoxesBot(difficulty: difficulty).chooseMove(_game);
    if (line == null) {
      setState(() {
        _botThinking = false;
      });
      _recordMatchIfNeeded();
      return;
    }

    setState(() {
      _botThinking = false;
    });
    _applyMove(line);
  }

  void _recordMatchIfNeeded() {
    if (!_game.isGameOver || _reportedMatchResult) {
      return;
    }

    _reportedMatchResult = true;
    widget.onMatchFinished(
      MatchSummary(
        mode: widget.mode,
        preset: widget.preset,
        botDifficulty: widget.mode == MatchMode.playerVsBot
            ? widget.botDifficulty
            : null,
        winner: _game.winner,
        playerOneScore: _game.scoreFor(Player.one),
        playerTwoScore: _game.scoreFor(Player.two),
        moveCount: _game.drawnLines.length,
        boxesCompleted: _boxesCompleted,
        extraTurnCount: _extraTurnCount,
        invalidMoveCount: _invalidMoveCount,
        durationSeconds: DateTime.now().difference(_matchStartedAt).inSeconds,
        completedAt: DateTime.now(),
      ),
    );
  }

  void _handleResultRestart() {
    if (!_game.isGameOver) {
      _restartMatch();
      return;
    }

    unawaited(
      widget.adService.showPostMatchInterstitial(
        placement: AdPlacement.postMatchRetry,
        onComplete: _restartMatch,
      ),
    );
  }

  void _handleResultMenu() {
    if (!_game.isGameOver) {
      widget.onExitToMenu();
      return;
    }

    unawaited(
      widget.adService.showPostMatchInterstitial(
        placement: AdPlacement.postMatchMenu,
        onComplete: widget.onExitToMenu,
      ),
    );
  }

  void _openHelp() {
    _GameFeedback(widget.settings).tap();
    _showHelpSheet(context);
  }

  void _openSettings() {
    _GameFeedback(widget.settings).tap();
    _showSettingsSheet(context, widget.settings, widget.onSettingsChanged);
  }

  void _openMatchMenu() {
    _GameFeedback(widget.settings).tap();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return _MatchMenuSheet(
          onResume: () {
            _GameFeedback(widget.settings).tap();
            Navigator.of(sheetContext).pop();
          },
          onRestart: () {
            Navigator.of(sheetContext).pop();
            _restartMatch();
          },
          onSettings: () {
            Navigator.of(sheetContext).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _openSettings();
              }
            });
          },
          onMenu: () {
            _GameFeedback(widget.settings).tap();
            Navigator.of(sheetContext).pop();
            widget.onExitToMenu();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Match menu',
          onPressed: _openMatchMenu,
          icon: const Icon(Icons.pause_rounded),
        ),
        title: Text(widget.mode.title),
        actions: [
          IconButton(
            tooltip: 'How to play',
            onPressed: _openHelp,
            icon: const Icon(Icons.help_outline_rounded),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: _openSettings,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: 'Restart',
            onPressed: _restartMatch,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _MatchHeader(
                preset: widget.preset,
                mode: widget.mode,
                botDifficulty: widget.botDifficulty,
              ),
              const SizedBox(height: 12),
              _ScoreStrip(
                game: _game,
                playerOneName: _nameForPlayer(Player.one),
                playerTwoName: _nameForPlayer(Player.two),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxSide = math.min(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      final side = math.min(maxSide, 540.0);

                      return SizedBox.square(
                        dimension: side,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DotsAndBoxesBoard(
                            game: _game,
                            inputEnabled: !_isBotTurn && !_botThinking,
                            disabledMessage: _game.isGameOver
                                ? 'Match complete.'
                                : 'Bot is choosing a line.',
                            highlightLine: _highlightLine,
                            highlightedBoxes: _highlightedBoxes,
                            highlightAnimation: _moveFeedbackController,
                            onLineSelected: _handleLineSelected,
                            onInvalidSelection: _handleInvalidSelection,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _MatchStatus(
                message: _statusMessage,
                tone: _statusTone,
                onRestart: _restartMatch,
              ),
              if (_game.isGameOver) ...[
                const SizedBox(height: 12),
                _ResultBanner(
                  game: _game,
                  playerOneName: _nameForPlayer(Player.one),
                  playerTwoName: _nameForPlayer(Player.two),
                  onRestart: _handleResultRestart,
                  onMenu: _handleResultMenu,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchHeader extends StatelessWidget {
  const _MatchHeader({
    required this.preset,
    required this.mode,
    required this.botDifficulty,
  });

  final BoardPreset preset;
  final MatchMode mode;
  final BotDifficulty? botDifficulty;

  @override
  Widget build(BuildContext context) {
    final subtitle = mode == MatchMode.playerVsBot
        ? '${preset.label} boxes, ${botDifficulty?.label ?? 'Casual'} bot'
        : '${preset.label} boxes';

    return Row(
      children: [
        Icon(
          mode == MatchMode.playerVsBot
              ? Icons.smart_toy_rounded
              : Icons.grid_4x4_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _MatchMenuSheet extends StatelessWidget {
  const _MatchMenuSheet({
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
    required this.onMenu,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Match menu',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: const Text('Resume'),
              onTap: onResume,
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt_rounded),
              title: const Text('Restart match'),
              onTap: onRestart,
            ),
            ListTile(
              leading: const Icon(Icons.tune_rounded),
              title: const Text('Settings'),
              onTap: onSettings,
            ),
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Main menu'),
              onTap: onMenu,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreStrip extends StatelessWidget {
  const _ScoreStrip({
    required this.game,
    required this.playerOneName,
    required this.playerTwoName,
  });

  final DotsAndBoxesGame game;
  final String playerOneName;
  final String playerTwoName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ScoreBlock(
            player: Player.one,
            label: playerOneName,
            score: game.scoreFor(Player.one),
            active: !game.isGameOver && game.currentPlayer == Player.one,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ScoreBlock(
            player: Player.two,
            label: playerTwoName,
            score: game.scoreFor(Player.two),
            active: !game.isGameOver && game.currentPlayer == Player.two,
          ),
        ),
      ],
    );
  }
}

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({
    required this.player,
    required this.label,
    required this.score,
    required this.active,
  });

  final Player player;
  final String label;
  final int score;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = _colorForPlayer(player);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? color.withAlpha(20) : Colors.white,
        border: Border.all(
          color: active ? color : const Color(0xFFE2E8F0),
          width: active ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 13, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Text(
              '$score',
              key: ValueKey<int>(score),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchStatus extends StatelessWidget {
  const _MatchStatus({
    required this.message,
    required this.tone,
    required this.onRestart,
  });

  final String message;
  final _StatusTone tone;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final status = _StatusMessageCard(message: message, tone: tone);
        final restart = FilledButton.tonalIcon(
          onPressed: onRestart,
          icon: const Icon(Icons.restart_alt_rounded),
          label: const Text('Restart'),
        );

        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [status, const SizedBox(height: 8), restart],
          );
        }

        return Row(
          children: [
            Expanded(child: status),
            const SizedBox(width: 12),
            restart,
          ],
        );
      },
    );
  }
}

class _StatusMessageCard extends StatelessWidget {
  const _StatusMessageCard({required this.message, required this.tone});

  final String message;
  final _StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _StatusTone.turn => Theme.of(context).colorScheme.primary,
      _StatusTone.success => const Color(0xFF15803D),
      _StatusTone.error => const Color(0xFFB91C1C),
      _StatusTone.result => const Color(0xFF7C3AED),
    };
    final icon = switch (tone) {
      _StatusTone.turn => Icons.touch_app_rounded,
      _StatusTone.success => Icons.check_circle_rounded,
      _StatusTone.error => Icons.error_outline_rounded,
      _StatusTone.result => Icons.emoji_events_rounded,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(95)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.game,
    required this.playerOneName,
    required this.playerTwoName,
    required this.onRestart,
    required this.onMenu,
  });

  final DotsAndBoxesGame game;
  final String playerOneName;
  final String playerTwoName;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final winner = game.winner;
    final winnerName = winner == Player.one ? playerOneName : playerTwoName;
    final title = winner == null ? 'Draw game' : '$winnerName wins';

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  winner == null
                      ? Icons.handshake_rounded
                      : Icons.emoji_events_rounded,
                  color: winner == null
                      ? const Color(0xFF64748B)
                      : _colorForPlayer(winner),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$playerOneName ${game.scoreFor(Player.one)} - '
              '${game.scoreFor(Player.two)} $playerTwoName',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Play Again'),
                ),
                OutlinedButton.icon(
                  onPressed: onMenu,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Menu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DotsAndBoxesBoard extends StatefulWidget {
  const DotsAndBoxesBoard({
    super.key,
    required this.game,
    this.inputEnabled = true,
    this.disabledMessage = 'Wait for your turn.',
    this.highlightLine,
    this.highlightedBoxes = const <BoxCoordinate>{},
    this.highlightAnimation,
    required this.onLineSelected,
    required this.onInvalidSelection,
  });

  final DotsAndBoxesGame game;
  final bool inputEnabled;
  final String disabledMessage;
  final BoardLine? highlightLine;
  final Set<BoxCoordinate> highlightedBoxes;
  final Animation<double>? highlightAnimation;
  final ValueChanged<BoardLine> onLineSelected;
  final ValueChanged<String> onInvalidSelection;

  @override
  State<DotsAndBoxesBoard> createState() => _DotsAndBoxesBoardState();
}

class _DotsAndBoxesBoardState extends State<DotsAndBoxesBoard> {
  BoardLine? _previewLine;
  BoardLine? _lastHitLine;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget paintedBoard() {
          return CustomPaint(
            painter: _DotsAndBoxesPainter(
              widget.game,
              previewLine: _previewLine,
              highlightLine: widget.highlightLine,
              highlightedBoxes: widget.highlightedBoxes,
              highlightProgress: widget.highlightAnimation?.value ?? 1,
            ),
            child: const SizedBox.expand(),
          );
        }

        final highlightAnimation = widget.highlightAnimation;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            if (!widget.inputEnabled) {
              return;
            }
            _updatePointerLine(constraints, details.localPosition);
          },
          onTapUp: (details) {
            if (!widget.inputEnabled) {
              widget.onInvalidSelection(widget.disabledMessage);
              return;
            }
            final line = _hitTestLine(
              constraints,
              details.localPosition.dx,
              details.localPosition.dy,
            );

            _submitLine(line);
          },
          onTapCancel: () {
            _clearPointerLine();
          },
          onPanStart: (details) {
            if (!widget.inputEnabled) {
              return;
            }
            _updatePointerLine(constraints, details.localPosition);
          },
          onPanUpdate: (details) {
            if (!widget.inputEnabled) {
              return;
            }
            _updatePointerLine(constraints, details.localPosition);
          },
          onPanEnd: (_) {
            if (!widget.inputEnabled) {
              widget.onInvalidSelection(widget.disabledMessage);
              return;
            }
            _submitLine(_lastHitLine);
          },
          onPanCancel: _clearPointerLine,
          child: highlightAnimation == null
              ? paintedBoard()
              : AnimatedBuilder(
                  animation: highlightAnimation,
                  builder: (context, _) => paintedBoard(),
                ),
        );
      },
    );
  }

  BoardLine? _hitTestLine(BoxConstraints constraints, double x, double y) {
    final hitTester = BoardHitTester(
      rows: widget.game.rows,
      columns: widget.game.columns,
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      edgePadding: _boardEdgePadding,
      touchTolerance: _boardTouchTolerance,
      ambiguityMargin: _boardAmbiguityMargin,
    );
    return hitTester.hitTest(x, y);
  }

  void _updatePointerLine(BoxConstraints constraints, Offset position) {
    final line = _hitTestLine(constraints, position.dx, position.dy);

    setState(() {
      _lastHitLine = line;
      _previewLine = _isPreviewable(line) ? line : null;
    });
  }

  void _clearPointerLine() {
    setState(() {
      _lastHitLine = null;
      _previewLine = null;
    });
  }

  void _submitLine(BoardLine? line) {
    setState(() {
      _lastHitLine = null;
      _previewLine = null;
    });

    if (line != null) {
      widget.onLineSelected(line);
    } else {
      widget.onInvalidSelection('Tap closer to an open line.');
    }
  }

  bool _isPreviewable(BoardLine? line) {
    return line != null &&
        !widget.game.isGameOver &&
        !widget.game.drawnLines.contains(line);
  }
}

class _DotsAndBoxesPainter extends CustomPainter {
  const _DotsAndBoxesPainter(
    this.game, {
    this.previewLine,
    this.highlightLine,
    this.highlightedBoxes = const <BoxCoordinate>{},
    this.highlightProgress = 1,
  });

  final DotsAndBoxesGame game;
  final BoardLine? previewLine;
  final BoardLine? highlightLine;
  final Set<BoxCoordinate> highlightedBoxes;
  final double highlightProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final layout = BoardHitTester(
      rows: game.rows,
      columns: game.columns,
      width: size.width,
      height: size.height,
      edgePadding: _boardEdgePadding,
      touchTolerance: _boardTouchTolerance,
      ambiguityMargin: _boardAmbiguityMargin,
    ).metrics;

    final guidePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = const Color(0xFF0F172A);

    _paintClaimedBoxes(canvas, layout);
    _paintAllLines(canvas, layout, guidePaint);
    _paintPreviewLine(canvas, layout);
    _paintDrawnLines(canvas, layout);
    _paintHighlightedLine(canvas, layout);
    _paintDots(canvas, layout, dotPaint);
  }

  void _paintClaimedBoxes(Canvas canvas, BoardMetrics layout) {
    for (final entry in game.claimedBoxes.entries) {
      final box = entry.key;
      final color = _colorForPlayer(entry.value);
      final isHighlighted = highlightedBoxes.contains(box);
      final pulse = isHighlighted ? _pulseAmount : 0.0;
      final rect = Rect.fromLTWH(
        layout.dotX(box.column),
        layout.dotY(box.row),
        layout.cellSize,
        layout.cellSize,
      ).deflate(isHighlighted ? 5 - pulse * 1.5 : 7);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()..color = color.withAlpha((34 + pulse * 48).round()),
      );

      if (isHighlighted) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()
            ..color = color.withAlpha((90 + pulse * 80).round())
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5 + pulse * 2,
        );
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: entry.value == Player.one ? '1' : '2',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: math.max(18.0, layout.cellSize * 0.28),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          rect.center.dx - textPainter.width / 2,
          rect.center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _paintAllLines(Canvas canvas, BoardMetrics layout, Paint paint) {
    for (var row = 0; row <= game.rows; row += 1) {
      for (var column = 0; column < game.columns; column += 1) {
        _drawLine(canvas, layout, BoardLine.horizontal(row, column), paint);
      }
    }

    for (var row = 0; row < game.rows; row += 1) {
      for (var column = 0; column <= game.columns; column += 1) {
        _drawLine(canvas, layout, BoardLine.vertical(row, column), paint);
      }
    }
  }

  void _paintDrawnLines(Canvas canvas, BoardMetrics layout) {
    for (final line in game.drawnLines) {
      final owner = game.ownerForLine(line) ?? Player.one;
      final paint = Paint()
        ..color = _colorForPlayer(owner)
        ..strokeWidth = math.max(5.0, layout.cellSize * 0.08)
        ..strokeCap = StrokeCap.round;

      _drawLine(canvas, layout, line, paint);
    }
  }

  void _paintHighlightedLine(Canvas canvas, BoardMetrics layout) {
    final line = highlightLine;
    if (line == null || !game.drawnLines.contains(line)) {
      return;
    }

    final owner = game.ownerForLine(line) ?? Player.one;
    final pulse = _pulseAmount;
    final paint = Paint()
      ..color = _colorForPlayer(owner).withAlpha((90 + pulse * 90).round())
      ..strokeWidth = math.max(8.0, layout.cellSize * 0.11) + pulse * 4
      ..strokeCap = StrokeCap.round;

    _drawLine(canvas, layout, line, paint);
  }

  void _paintPreviewLine(Canvas canvas, BoardMetrics layout) {
    final line = previewLine;
    if (line == null || game.drawnLines.contains(line)) {
      return;
    }

    final color = _colorForPlayer(game.currentPlayer);
    final paint = Paint()
      ..color = color.withAlpha(110)
      ..strokeWidth = math.max(7.0, layout.cellSize * 0.1)
      ..strokeCap = StrokeCap.round;

    _drawLine(canvas, layout, line, paint);
  }

  void _paintDots(Canvas canvas, BoardMetrics layout, Paint paint) {
    final radius = math.max(4.0, layout.cellSize * 0.07);

    for (var row = 0; row <= game.rows; row += 1) {
      for (var column = 0; column <= game.columns; column += 1) {
        canvas.drawCircle(
          Offset(layout.dotX(column), layout.dotY(row)),
          radius,
          paint,
        );
      }
    }
  }

  void _drawLine(
    Canvas canvas,
    BoardMetrics layout,
    BoardLine line,
    Paint paint,
  ) {
    final start = Offset(layout.dotX(line.column), layout.dotY(line.row));
    final end = switch (line.axis) {
      LineAxis.horizontal => Offset(
        layout.dotX(line.column + 1),
        layout.dotY(line.row),
      ),
      LineAxis.vertical => Offset(
        layout.dotX(line.column),
        layout.dotY(line.row + 1),
      ),
    };

    canvas.drawLine(start, end, paint);
  }

  double get _pulseAmount {
    final clamped = highlightProgress.clamp(0.0, 1.0).toDouble();
    return math.sin(clamped * math.pi);
  }

  @override
  bool shouldRepaint(covariant _DotsAndBoxesPainter oldDelegate) => true;
}

Color _colorForPlayer(Player player) {
  return player == Player.one ? _playerOneColor : _playerTwoColor;
}
