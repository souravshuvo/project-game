import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game/board_hit_tester.dart';
import 'game/dots_and_boxes.dart';

const _defaultBoardPreset = BoardPreset(label: '4x4', rows: 4, columns: 4);
const _boardEdgePadding = 30.0;
const _boardTouchTolerance = 24.0;
const _boardAmbiguityMargin = 8.0;
const _playerOneColor = Color(0xFF2563EB);
const _playerTwoColor = Color(0xFFDC2626);

void main() {
  runApp(const DotsAndBoxesApp());
}

class DotsAndBoxesApp extends StatelessWidget {
  const DotsAndBoxesApp({super.key});

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
      home: const DotsAndBoxesShell(),
    );
  }
}

class DotsAndBoxesShell extends StatefulWidget {
  const DotsAndBoxesShell({super.key});

  @override
  State<DotsAndBoxesShell> createState() => _DotsAndBoxesShellState();
}

class _DotsAndBoxesShellState extends State<DotsAndBoxesShell> {
  BoardPreset _selectedPreset = _defaultBoardPreset;
  var _showMatch = false;
  var _matchSeed = 0;

  void _startLocalMatch() {
    setState(() {
      _matchSeed += 1;
      _showMatch = true;
    });
  }

  void _showMainMenu() {
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
        onExitToMenu: _showMainMenu,
      );
    }

    return MainMenuPage(
      selectedPreset: _selectedPreset,
      onPresetChanged: (preset) {
        setState(() {
          _selectedPreset = preset;
        });
      },
      onStartLocalMatch: _startLocalMatch,
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({
    super.key,
    required this.selectedPreset,
    required this.onPresetChanged,
    required this.onStartLocalMatch,
  });

  final BoardPreset selectedPreset;
  final ValueChanged<BoardPreset> onPresetChanged;
  final VoidCallback onStartLocalMatch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dots & Boxes')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Local dots. Shared turns. Quick captures.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                    onPressed: onStartLocalMatch,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Local Match'),
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

class DotsAndBoxesMatchPage extends StatefulWidget {
  const DotsAndBoxesMatchPage({
    super.key,
    required this.preset,
    required this.onExitToMenu,
  });

  final BoardPreset preset;
  final VoidCallback onExitToMenu;

  @override
  State<DotsAndBoxesMatchPage> createState() => _DotsAndBoxesMatchPageState();
}

class _DotsAndBoxesMatchPageState extends State<DotsAndBoxesMatchPage> {
  late DotsAndBoxesGame _game = DotsAndBoxesGame.fromPreset(widget.preset);
  String _statusMessage = '${Player.one.label} turn';

  void _restartMatch() {
    setState(() {
      _game = DotsAndBoxesGame.fromPreset(widget.preset);
      _statusMessage = '${Player.one.label} turn';
    });
  }

  void _handleLineSelected(BoardLine line) {
    setState(() {
      final result = _game.drawLine(line);
      _statusMessage = _messageFor(result);
    });
  }

  void _handleInvalidSelection(String message) {
    setState(() {
      _statusMessage = _game.isGameOver ? 'Match complete.' : message;
    });
  }

  String _messageFor(MoveResult result) {
    if (!result.accepted) {
      return result.rejectionReason ?? 'Choose another line.';
    }

    if (_game.isGameOver) {
      final winner = _game.winner;
      return winner == null ? 'Match complete: draw' : '${winner.label} wins';
    }

    if (result.boxesCompleted > 0) {
      final boxes = result.boxesCompleted == 1 ? 'box' : 'boxes';
      return '${result.player.label} claimed ${result.boxesCompleted} $boxes';
    }

    return '${_game.currentPlayer.label} turn';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Main menu',
          onPressed: widget.onExitToMenu,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Local 2 Player'),
        actions: [
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
              _MatchHeader(preset: widget.preset),
              const SizedBox(height: 12),
              _ScoreStrip(game: _game),
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
              _MatchStatus(message: _statusMessage, onRestart: _restartMatch),
              if (_game.isGameOver) ...[
                const SizedBox(height: 12),
                _ResultBanner(
                  game: _game,
                  onRestart: _restartMatch,
                  onMenu: widget.onExitToMenu,
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
  const _MatchHeader({required this.preset});

  final BoardPreset preset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.grid_4x4_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '${preset.label} boxes',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ScoreStrip extends StatelessWidget {
  const _ScoreStrip({required this.game});

  final DotsAndBoxesGame game;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ScoreBlock(
            player: Player.one,
            score: game.scoreFor(Player.one),
            active: !game.isGameOver && game.currentPlayer == Player.one,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ScoreBlock(
            player: Player.two,
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
    required this.score,
    required this.active,
  });

  final Player player;
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
              player.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Text(
            '$score',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchStatus extends StatelessWidget {
  const _MatchStatus({required this.message, required this.onRestart});

  final String message;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.tonalIcon(
          onPressed: onRestart,
          icon: const Icon(Icons.restart_alt_rounded),
          label: const Text('Restart'),
        ),
      ],
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({
    required this.game,
    required this.onRestart,
    required this.onMenu,
  });

  final DotsAndBoxesGame game;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final winner = game.winner;
    final title = winner == null ? 'Draw game' : '${winner.label} wins';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${Player.one.label} ${game.scoreFor(Player.one)} - '
            '${game.scoreFor(Player.two)} ${Player.two.label}',
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
    );
  }
}

class DotsAndBoxesBoard extends StatefulWidget {
  const DotsAndBoxesBoard({
    super.key,
    required this.game,
    required this.onLineSelected,
    required this.onInvalidSelection,
  });

  final DotsAndBoxesGame game;
  final ValueChanged<BoardLine> onLineSelected;
  final ValueChanged<String> onInvalidSelection;

  @override
  State<DotsAndBoxesBoard> createState() => _DotsAndBoxesBoardState();
}

class _DotsAndBoxesBoardState extends State<DotsAndBoxesBoard> {
  BoardLine? _previewLine;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final line = _hitTestLine(
              constraints,
              details.localPosition.dx,
              details.localPosition.dy,
            );

            setState(() {
              _previewLine = _isPreviewable(line) ? line : null;
            });
          },
          onTapUp: (details) {
            final line = _hitTestLine(
              constraints,
              details.localPosition.dx,
              details.localPosition.dy,
            );

            setState(() {
              _previewLine = null;
            });

            if (line != null) {
              widget.onLineSelected(line);
            } else {
              widget.onInvalidSelection('Tap closer to an open line.');
            }
          },
          onTapCancel: () {
            setState(() {
              _previewLine = null;
            });
          },
          child: CustomPaint(
            painter: _DotsAndBoxesPainter(
              widget.game,
              previewLine: _previewLine,
            ),
            child: const SizedBox.expand(),
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
  });

  final DotsAndBoxesGame game;
  final BoardLine? previewLine;

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
    _paintDots(canvas, layout, dotPaint);
  }

  void _paintClaimedBoxes(Canvas canvas, BoardMetrics layout) {
    for (final entry in game.claimedBoxes.entries) {
      final box = entry.key;
      final color = _colorForPlayer(entry.value);
      final rect = Rect.fromLTWH(
        layout.dotX(box.column),
        layout.dotY(box.row),
        layout.cellSize,
        layout.cellSize,
      ).deflate(7);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()..color = color.withAlpha(34),
      );

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

  @override
  bool shouldRepaint(covariant _DotsAndBoxesPainter oldDelegate) => true;
}

Color _colorForPlayer(Player player) {
  return player == Player.one ? _playerOneColor : _playerTwoColor;
}
