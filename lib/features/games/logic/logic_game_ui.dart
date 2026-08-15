import 'package:flutter/material.dart';

import '../shared/kid_celebration.dart';

enum LogicFeedbackTone { neutral, success, encouragement }

class LogicGameScaffold extends StatelessWidget {
  const LogicGameScaffold({
    required this.title,
    required this.prompt,
    required this.accentColor,
    required this.round,
    required this.totalRounds,
    required this.child,
    this.onRestart,
    this.statusLabel,
    this.statusIcon = Icons.stars_rounded,
    super.key,
  });

  final String title;
  final String prompt;
  final Color accentColor;
  final int round;
  final int totalRounds;
  final Widget child;
  final VoidCallback? onRestart;
  final String? statusLabel;
  final IconData statusIcon;

  @override
  Widget build(BuildContext context) {
    final paleAccent = Color.lerp(accentColor, Colors.white, 0.88)!;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [paleAccent, const Color(0xFFFFFBF2), Colors.white],
            stops: const [0, 0.56, 1],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: 64,
                                child: Material(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  shadowColor: Colors.black12,
                                  child: IconButton(
                                    tooltip: 'Back',
                                    onPressed: () =>
                                        Navigator.maybePop(context),
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      size: 32,
                                    ),
                                    color: const Color(0xFF3D3754),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: const Color(0xFF352D58),
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                              if (onRestart != null) ...[
                                const SizedBox(width: 8),
                                SizedBox.square(
                                  dimension: 56,
                                  child: IconButton.filledTonal(
                                    tooltip: 'Restart',
                                    onPressed: onRestart,
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                              if (statusLabel case final label?) ...[
                                const SizedBox(width: 8),
                                _LogicStatusPill(
                                  icon: statusIcon,
                                  label: label,
                                  color: accentColor,
                                ),
                              ],
                              const SizedBox(width: 8),
                              Container(
                                constraints: const BoxConstraints(
                                  minWidth: 64,
                                  minHeight: 48,
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withValues(
                                        alpha: 0.25,
                                      ),
                                      offset: const Offset(0, 4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$round/$totalRounds',
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: List.generate(totalRounds, (index) {
                              final isReached = index < round;
                              return Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: 10,
                                  margin: EdgeInsets.only(
                                    right: index == totalRounds - 1 ? 0 : 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isReached
                                        ? accentColor
                                        : Colors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            prompt,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: const Color(0xFF443B62),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 18),
                          child,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LogicStatusPill extends StatelessWidget {
  const _LogicStatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48, maxWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              textScaler: TextScaler.noScaling,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF443B62),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LogicFeedbackBanner extends StatelessWidget {
  const LogicFeedbackBanner({
    required this.message,
    this.tone = LogicFeedbackTone.neutral,
    super.key,
  });

  final String message;
  final LogicFeedbackTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (tone) {
      LogicFeedbackTone.neutral => (
        const Color(0xFFF3F0FA),
        const Color(0xFF625A78),
        Icons.touch_app_rounded,
      ),
      LogicFeedbackTone.success => (
        const Color(0xFFE4F8EC),
        const Color(0xFF20754C),
        Icons.celebration_rounded,
      ),
      LogicFeedbackTone.encouragement => (
        const Color(0xFFFFF2D7),
        const Color(0xFF875B12),
        Icons.lightbulb_rounded,
      ),
    };

    final borderRadius = BorderRadius.circular(22);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: ClipRRect(
        key: ValueKey('$tone$message'),
        borderRadius: borderRadius,
        child: KidConfettiOverlay(
          active: tone == LogicFeedbackTone.success,
          density: 18,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(color: background),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: tone == LogicFeedbackTone.success ? 1.12 : 1,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  child: Icon(icon, color: foreground, size: 30),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LogicRunSummary extends StatelessWidget {
  const LogicRunSummary({
    required this.stars,
    required this.title,
    required this.subtitle,
    required this.color,
    super.key,
  });

  final int stars;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: '$title. $stars stars. $subtitle',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: KidConfettiOverlay(
          active: true,
          density: 14,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, Color.lerp(color, Colors.white, 0.24)!],
              ),
            ),
            child: Row(
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFFFA928),
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return Icon(
                      index < stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFFFD86B),
                      size: 25,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LogicRoundButton extends StatelessWidget {
  const LogicRoundButton({
    required this.label,
    required this.color,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    super.key,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.96, end: 1),
        duration: const Duration(milliseconds: 360),
        curve: Curves.elasticOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: FilledButton.icon(
          onPressed: onPressed,
          iconAlignment: IconAlignment.end,
          icon: Icon(icon, size: 30),
          label: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: TextScaler.noScaling,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 64),
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            elevation: 4,
            shadowColor: color.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

class LogicCompletionActions extends StatelessWidget {
  const LogicCompletionActions({
    required this.isLastRound,
    required this.nextRoundLabel,
    required this.replayLabel,
    required this.color,
    required this.onContinue,
    this.onPlayNextGame,
    this.nextGameTitle,
    super.key,
  });

  final bool isLastRound;
  final String nextRoundLabel;
  final String replayLabel;
  final Color color;
  final VoidCallback onContinue;
  final VoidCallback? onPlayNextGame;
  final String? nextGameTitle;

  @override
  Widget build(BuildContext context) {
    if (!isLastRound) {
      return LogicRoundButton(
        label: nextRoundLabel,
        color: color,
        icon: Icons.arrow_forward_rounded,
        onPressed: onContinue,
      );
    }

    final canPlayNextGame = onPlayNextGame != null && nextGameTitle != null;
    if (!canPlayNextGame) {
      return LogicRoundButton(
        label: replayLabel,
        color: color,
        icon: Icons.replay_rounded,
        onPressed: onContinue,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LogicRoundButton(
          label: 'Play next: $nextGameTitle',
          color: color,
          icon: Icons.arrow_forward_rounded,
          onPressed: onPlayNextGame!,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.replay_rounded),
            label: Text(
              replayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color.withValues(alpha: 0.5), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
