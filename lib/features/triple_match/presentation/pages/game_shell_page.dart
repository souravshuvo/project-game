import 'package:flutter/material.dart';

import '../../application/triple_match_controller.dart';
import '../../../../shared/ads/ad_mob_service.dart';
import '../feedback/triple_match_feedback.dart';
import '../theme/triple_match_theme.dart';
import '../widgets/pantry_helper.dart';
import 'puzzle_page.dart';

enum _ShellScreen { home, game }

class GameShellPage extends StatefulWidget {
  const GameShellPage({
    super.key,
    required this.controller,
    required this.adMobService,
  });

  final TripleMatchController controller;
  final AdMobService adMobService;

  @override
  State<GameShellPage> createState() => _GameShellPageState();
}

class _GameShellPageState extends State<GameShellPage> {
  var _screen = _ShellScreen.home;

  void _openGame() {
    TripleMatchFeedback.play(widget.controller, TripleMatchFeedbackCue.tap);
    widget.controller.logScreenView('game');
    widget.controller.logCurrentLevelStart(source: 'play');
    setState(() => _screen = _ShellScreen.game);
  }

  void _openHome() {
    TripleMatchFeedback.play(widget.controller, TripleMatchFeedbackCue.tap);
    widget.controller.logScreenView('home');
    setState(() => _screen = _ShellScreen.home);
  }

  void _showHelp() {
    TripleMatchFeedback.play(widget.controller, TripleMatchFeedbackCue.tap);
    widget.controller.logScreenView('help');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _HelpSheet(),
    );
  }

  void _showSettings() {
    TripleMatchFeedback.play(widget.controller, TripleMatchFeedbackCue.tap);
    widget.controller.logScreenView('settings');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _SettingsSheet(controller: widget.controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _screen == _ShellScreen.home
              ? _HomeView(
                  key: const ValueKey('home'),
                  controller: widget.controller,
                  onPlay: _openGame,
                  onHelp: _showHelp,
                  onSettings: _showSettings,
                )
              : PuzzlePage(
                  key: const ValueKey('game'),
                  controller: widget.controller,
                  adMobService: widget.adMobService,
                  onHomePressed: _openHome,
                  onHelpPressed: _showHelp,
                  onSettingsPressed: _showSettings,
                ),
        );
      },
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({
    super.key,
    required this.controller,
    required this.onPlay,
    required this.onHelp,
    required this.onSettings,
  });

  final TripleMatchController controller;
  final VoidCallback onPlay;
  final VoidCallback onHelp;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Larder Labels'),
        actions: [
          IconButton(
            onPressed: onHelp,
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Help',
          ),
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                TripleMatchColors.surface,
                                TripleMatchColors.softGreen,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: TripleMatchColors.primary.withValues(
                                alpha: 0.22,
                              ),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: TripleMatchColors.primaryDark.withValues(
                                  alpha: 0.12,
                                ),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                            child: Column(
                              children: [
                                const _AnimatedHomeHero(),
                                const SizedBox(height: 20),
                                Text(
                                  'Ready to clear the shelf?',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: TripleMatchColors.primaryDark,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pick free labels, make triples, and keep the tray from filling.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: TripleMatchColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                const _GoalStrip(),
                                const SizedBox(height: 14),
                                Text(
                                  '${controller.totalLevels} offline shelves ready - ${controller.progressSummary}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: TripleMatchColors.mutedInk,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: onPlay,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            controller.completedLevelCount == 0
                                ? 'Play'
                                : 'Continue',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onHelp,
                                icon: const Icon(Icons.help_outline_rounded),
                                label: const Text('Help'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onSettings,
                                icon: const Icon(Icons.settings_rounded),
                                label: const Text('Settings'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeTilePreview extends StatelessWidget {
  const _HomeTilePreview();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TripleMatchColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _PreviewTile(label: 'JAR', color: Color(0xFFE9F6EE)),
            SizedBox(width: 8),
            _PreviewTile(label: 'JAR', color: Color(0xFFE9F6EE)),
            SizedBox(width: 8),
            _PreviewTile(label: 'JAR', color: Color(0xFFE9F6EE)),
          ],
        ),
      ),
    );
  }
}

class _AnimatedHomeHero extends StatefulWidget {
  const _AnimatedHomeHero();

  @override
  State<_AnimatedHomeHero> createState() => _AnimatedHomeHeroState();
}

class _AnimatedHomeHeroState extends State<_AnimatedHomeHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final bob = -5.0 * Curves.easeInOut.transform(_controller.value);
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            return Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: compact ? 12 : 22,
              runSpacing: 12,
              children: [
                Transform.translate(
                  offset: Offset(0, bob),
                  child: const PantryHelper(
                    size: 104,
                    mood: PantryHelperMood.happy,
                  ),
                ),
                const _HomeTilePreview(),
              ],
            );
          },
        );
      },
    );
  }
}

class _GoalStrip extends StatelessWidget {
  const _GoalStrip();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: const [
        _GoalPill(icon: Icons.touch_app_rounded, label: 'Pick'),
        _GoalPill(icon: Icons.view_week_rounded, label: 'Match'),
        _GoalPill(icon: Icons.inventory_2_rounded, label: 'Clear'),
      ],
    );
  }
}

class _GoalPill extends StatelessWidget {
  const _GoalPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TripleMatchColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: TripleMatchColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: TripleMatchColors.primaryDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TripleMatchColors.primary),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TripleMatchColors.primaryDark,
              fontWeight: FontWeight.w900,
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How To Play',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const _HelpRow(
              icon: Icons.touch_app_rounded,
              text: 'Tap bright labels to move them into the tray.',
            ),
            const _HelpRow(
              icon: Icons.layers_rounded,
              text: 'Dim labels are covered. Clear the label above first.',
            ),
            const _HelpRow(
              icon: Icons.view_week_rounded,
              text: 'Three matching labels clear from the tray.',
            ),
            const _HelpRow(
              icon: Icons.error_outline_rounded,
              text: 'If all tray slots fill, restart and try a cleaner order.',
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
        children: [
          Icon(icon, color: TripleMatchColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({required this.controller});

  final TripleMatchController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: controller.soundEnabled,
                  secondary: const Icon(Icons.volume_up_rounded),
                  title: const Text('Sound Feedback'),
                  onChanged: (value) {
                    final cue = controller.setSoundEnabled(value);
                    TripleMatchFeedback.play(controller, cue);
                  },
                ),
                SwitchListTile(
                  value: controller.hapticsEnabled,
                  secondary: const Icon(Icons.vibration_rounded),
                  title: const Text('Haptic Feedback'),
                  onChanged: (value) {
                    final cue = controller.setHapticsEnabled(value);
                    TripleMatchFeedback.play(controller, cue);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
