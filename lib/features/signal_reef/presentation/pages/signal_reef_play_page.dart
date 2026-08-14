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

  @override
  void initState() {
    super.initState();
    _game = widget.controller.game;
  }

  @override
  void didUpdateWidget(covariant SignalReefPlayPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.game != _game) {
      _game = widget.controller.game;
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game;

    if (game == null) {
      return const Scaffold(body: SignalReefBackdrop(child: SizedBox()));
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox.expand(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) =>
                          game.beginPlayerDrag(details.localPosition),
                      onPanUpdate: (details) =>
                          game.updatePlayerDrag(details.localPosition),
                      onPanEnd: (_) => game.endPlayerDrag(),
                      onPanCancel: game.endPlayerDrag,
                      child: ClipRect(
                        child: GameWidget<SignalReefGame>(
                          key: ValueKey(game),
                          game: game,
                          loadingBuilder: (_) => const SizedBox.expand(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: SignalReefHud(controller: widget.controller, game: game),
            ),
            IgnorePointer(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: game.runState == SignalReefRunState.ready
                    ? const Center(key: ValueKey('ready'), child: _ReadyCard())
                    : const SizedBox.shrink(key: ValueKey('playing')),
              ),
            ),
            if (widget.controller.isPaused)
              SignalReefPauseOverlay(controller: widget.controller),
          ],
        ),
      ),
    );
  }
}

class _ReadyCard extends StatelessWidget {
  const _ReadyCard();

  @override
  Widget build(BuildContext context) {
    return SignalReefPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ready',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Drag anywhere to steer\nShots fire automatically',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SignalReefColors.mutedInk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
