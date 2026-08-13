import 'package:flutter/material.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({
    super.key,
    required this.score,
    required this.bestScore,
    required this.routeLabel,
    required this.goalLabel,
    required this.progressLabel,
    this.onPause,
  });

  final int score;
  final int bestScore;
  final String routeLabel;
  final String goalLabel;
  final String progressLabel;
  final VoidCallback? onPause;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ScorePill(label: 'SCORE', value: score),
            const SizedBox(width: 10),
            _ScorePill(label: 'BEST', value: bestScore),
            const Spacer(),
            if (onPause != null)
              _IconHudButton(
                label: 'Pause',
                icon: Icons.pause,
                onPressed: onPause!,
              ),
          ],
        ),
        const SizedBox(height: 8),
        _RoutePill(
          routeLabel: routeLabel,
          goalLabel: goalLabel,
          progressLabel: progressLabel,
        ),
      ],
    );
  }
}

class GameControls extends StatelessWidget {
  const GameControls({
    super.key,
    required this.leftHeld,
    required this.rightHeld,
    required this.onLeftHeld,
    required this.onRightHeld,
  });

  final bool leftHeld;
  final bool rightHeld;
  final ValueChanged<bool> onLeftHeld;
  final ValueChanged<bool> onRightHeld;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        void updatePointer(Offset localPosition) {
          final width = constraints.maxWidth;
          if (width <= 0) {
            return;
          }

          final isLeft = localPosition.dx.clamp(0, width) < width / 2;
          onLeftHeld(isLeft);
          onRightHeld(!isLeft);
        }

        void releasePointer() {
          onLeftHeld(false);
          onRightHeld(false);
        }

        return Listener(
          onPointerDown: (event) => updatePointer(event.localPosition),
          onPointerMove: (event) => updatePointer(event.localPosition),
          onPointerUp: (_) => releasePointer(),
          onPointerCancel: (_) => releasePointer(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xff062d33).withAlpha(116),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xfffff8df).withAlpha(92)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  _HoldButton(
                    label: 'LEFT',
                    icon: Icons.keyboard_arrow_left,
                    isPressed: leftHeld,
                  ),
                  const SizedBox(width: 8),
                  _HoldButton(
                    label: 'RIGHT',
                    icon: Icons.keyboard_arrow_right,
                    isPressed: rightHeld,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff062d33).withAlpha(190),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffffcb5b), width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '$label $value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _RoutePill extends StatelessWidget {
  const _RoutePill({
    required this.routeLabel,
    required this.goalLabel,
    required this.progressLabel,
  });

  final String routeLabel;
  final String goalLabel;
  final String progressLabel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xfffff8df).withAlpha(218),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xff163d3f), width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$routeLabel - $goalLabel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff163d3f),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                progressLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff274c48),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconHudButton extends StatelessWidget {
  const _IconHudButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: const Color(0xff062d33).withAlpha(190),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, color: Colors.white, size: 25),
            ),
          ),
        ),
      ),
    );
  }
}

class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.label,
    required this.icon,
    required this.isPressed,
  });

  final String label;
  final IconData icon;
  final bool isPressed;

  @override
  Widget build(BuildContext context) {
    final background = isPressed
        ? const Color(0xffd64c35)
        : const Color(0xff062d33);

    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background.withAlpha(220),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffffcb5b), width: 1.5),
          ),
          child: SizedBox(
            height: 68,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 30),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
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
