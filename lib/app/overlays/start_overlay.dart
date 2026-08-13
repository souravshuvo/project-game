import 'package:flutter/material.dart';

import '../../game/world/world_config.dart';

class StartOverlay extends StatelessWidget {
  const StartOverlay({
    super.key,
    required this.onStart,
    required this.onSettings,
    required this.onHelp,
    required this.routeLabel,
    required this.routeTitle,
    required this.goalLabel,
    required this.completedRoutes,
    required this.totalRoutes,
  });

  final VoidCallback onStart;
  final VoidCallback onSettings;
  final VoidCallback onHelp;
  final String routeLabel;
  final String routeTitle;
  final String goalLabel;
  final int completedRoutes;
  final int totalRoutes;

  @override
  Widget build(BuildContext context) {
    return _PanelOverlay(
      title: WorldConfig.gameTitle.toUpperCase(),
      subtitle: 'Endless sky route',
      message:
          'Current stamp: $routeLabel - $routeTitle\nGoal: $goalLabel\nProgress: $completedRoutes/$totalRoutes stamps',
      primaryLabel: 'START RUN',
      onPrimary: onStart,
      note: 'Hold a side to steer. Collect signal motes and avoid sparks.',
      secondaryActions: [
        _PanelAction(label: 'HELP', onPressed: onHelp),
        _PanelAction(label: 'SETTINGS', onPressed: onSettings),
      ],
    );
  }
}

class HelpOverlay extends StatelessWidget {
  const HelpOverlay({super.key, required this.onStart, required this.onBack});

  final VoidCallback onStart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _PanelOverlay(
      title: 'HOW TO CLIMB',
      subtitle: 'Quick guide',
      message:
          'The courier jumps automatically after landing. Hold LEFT or RIGHT to line up the next pad. Gold signal motes add score and help complete route stamps. Red sparks are hazards, so land beside them.',
      primaryLabel: 'START RUN',
      onPrimary: onStart,
      secondaryActions: [_PanelAction(label: 'BACK', onPressed: onBack)],
    );
  }
}

class SettingsOverlay extends StatelessWidget {
  const SettingsOverlay({
    super.key,
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.onSoundChanged,
    required this.onHapticsChanged,
    required this.onBack,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onHapticsChanged;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _PanelOverlay(
      title: 'SETTINGS',
      subtitle: 'Feedback',
      message:
          'Keep feedback on for clearer jumps and mistakes. You can turn either option off anytime.',
      primaryLabel: 'DONE',
      onPrimary: onBack,
      settings: [
        SwitchListTile(
          value: soundEnabled,
          onChanged: onSoundChanged,
          title: const Text('Sound'),
          subtitle: const Text('Built-in tap and alert sounds'),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: hapticsEnabled,
          onChanged: onHapticsChanged,
          title: const Text('Haptics'),
          subtitle: const Text('Small vibrations for landings and losses'),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _PanelOverlay extends StatelessWidget {
  const _PanelOverlay({
    required this.title,
    required this.subtitle,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.note,
    this.secondaryActions = const [],
    this.settings = const [],
  });

  final String title;
  final String subtitle;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? note;
  final List<_PanelAction> secondaryActions;
  final List<Widget> settings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xff062d33).withAlpha(96),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Material(
                color: const Color(0xfffff8df).withAlpha(238),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xff163d3f), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xff163d3f),
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xffd64c35),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xff274c48),
                          fontSize: 16,
                          height: 1.35,
                          letterSpacing: 0,
                        ),
                      ),
                      if (settings.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        ...settings,
                      ],
                      if (note != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          note!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xff274c48),
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: onPrimary,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(172, 52),
                          backgroundColor: const Color(0xffd64c35),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          primaryLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      if (secondaryActions.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final action in secondaryActions)
                              OutlinedButton(
                                onPressed: action.onPressed,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(116, 44),
                                  foregroundColor: const Color(0xff163d3f),
                                  side: const BorderSide(
                                    color: Color(0xff163d3f),
                                    width: 1.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  action.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
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

class _PanelAction {
  const _PanelAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}
