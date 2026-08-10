import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../application/signal_reef_controller.dart';
import '../../game/signal_reef_game.dart';
import '../theme/signal_reef_theme.dart';
import '../widgets/game_hud.dart';
import '../widgets/pause_overlay.dart';

class SignalReefPlayPage extends StatefulWidget {
  const SignalReefPlayPage({super.key, required this.controller});

  final SignalReefController controller;

  @override
  State<SignalReefPlayPage> createState() => _SignalReefPlayPageState();
}

class _SignalReefPlayPageState extends State<SignalReefPlayPage> {
  SignalReefGame? _game;
  Widget? _gameWidget;

  @override
  void initState() {
    super.initState();
    _attachGame();
  }

  @override
  void didUpdateWidget(covariant SignalReefPlayPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.game != _game) {
      _attachGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;
    final gameWidget = _gameWidget;

    if (game == null || gameWidget == null) {
      return const Scaffold(body: SignalReefBackdrop(child: SizedBox()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) => game.movePlayerTo(details.localPosition),
              onPanUpdate: (details) =>
                  game.movePlayerTo(details.localPosition),
              child: gameWidget,
            ),
          ),
          SafeArea(
            child: SignalReefHud(controller: widget.controller, game: game),
          ),
          if (game.runState == SignalReefRunState.ready)
            const Center(child: _ReadyCard()),
          if (widget.controller.isPaused)
            SignalReefPauseOverlay(controller: widget.controller),
        ],
      ),
    );
  }

  void _attachGame() {
    _game = widget.controller.game;
    final game = _game;
    _gameWidget = game == null
        ? null
        : ClipRect(
            child: GameWidget<SignalReefGame>(key: ValueKey(game), game: game),
          );
  }
}

class _ReadyCard extends StatelessWidget {
  const _ReadyCard();

  @override
  Widget build(BuildContext context) {
    return SignalReefPanel(
      child: Text(
        'Ready',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}
