import 'package:flutter/material.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.score, required this.bestScore});

  final int score;
  final int bestScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ScorePill(label: 'SCORE', value: score),
        const SizedBox(width: 10),
        _ScorePill(label: 'BEST', value: bestScore),
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
    return Row(
      children: [
        _HoldButton(label: 'LEFT', isPressed: leftHeld, onChanged: onLeftHeld),
        const SizedBox(width: 12),
        _HoldButton(
          label: 'RIGHT',
          isPressed: rightHeld,
          onChanged: onRightHeld,
        ),
      ],
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

class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.label,
    required this.isPressed,
    required this.onChanged,
  });

  final String label;
  final bool isPressed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final background = isPressed
        ? const Color(0xffd64c35)
        : const Color(0xff062d33);

    return Expanded(
      child: Listener(
        onPointerDown: (_) => onChanged(true),
        onPointerUp: (_) => onChanged(false),
        onPointerCancel: (_) => onChanged(false),
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
              height: 58,
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
