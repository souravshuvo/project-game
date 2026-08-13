import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_content.dart';
import 'game_engine.dart';
import 'services/ad_service.dart';
import 'services/app_services.dart';
import 'widgets/ad_banner_slot.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(AppServices.instance.initialize());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencil Pitch',
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'pencil_pitch_app',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F8B63)),
        scaffoldBackgroundColor: const Color(0xFFF8F7F1),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color(0xFF17201C),
              displayColor: const Color(0xFF17201C),
            ),
      ),
      home: const GameShell(),
    );
  }
}

class GameShell extends StatefulWidget {
  const GameShell({super.key});

  @override
  State<GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<GameShell> with RestorationMixin {
  final RestorableBool _soundEnabled = RestorableBool(true);
  final RestorableBool _hapticsEnabled = RestorableBool(true);
  final RestorableInt _selectedPresetIndex = RestorableInt(1);
  final RestorableString _progressJson = RestorableString('{}');

  GameSetup? _activeSetup;
  GameProgress _progress = GameProgress.initial();

  @override
  String? get restorationId => 'game_shell';

  MatchPreset get _selectedPreset {
    final index =
        _selectedPresetIndex.value.clamp(0, kMatchPresets.length - 1) as int;
    return kMatchPresets[index];
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_soundEnabled, 'sound_enabled');
    registerForRestoration(_hapticsEnabled, 'haptics_enabled');
    registerForRestoration(_selectedPresetIndex, 'selected_preset_index');
    registerForRestoration(_progressJson, 'progress_json');
    _progress = GameProgress.fromJsonString(_progressJson.value);
    unawaited(AppServices.instance.analytics.logMenuView(_progress));
  }

  @override
  void dispose() {
    _soundEnabled.dispose();
    _hapticsEnabled.dispose();
    _selectedPresetIndex.dispose();
    _progressJson.dispose();
    super.dispose();
  }

  void _startSetup(GameSetup setup) {
    unawaited(AppServices.instance.analytics.logMatchStart(setup));
    setState(() => _activeSetup = setup);
  }

  void _recordMatchFinished(MatchState state) {
    final setup = _activeSetup;
    if (setup == null || state.phase != MatchPhase.matchComplete) {
      return;
    }

    setState(() {
      _progress = _progress.recordMatch(setup: setup, state: state);
      _progressJson.value = _progress.toJsonString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeSetup = _activeSetup;

    if (activeSetup == null) {
      return MainMenuPage(
        soundEnabled: _soundEnabled.value,
        hapticsEnabled: _hapticsEnabled.value,
        selectedPreset: _selectedPreset,
        progress: _progress,
        onSoundChanged: (value) {
          unawaited(
            AppServices.instance.analytics.logSettingsChanged('sound', value),
          );
          setState(() => _soundEnabled.value = value);
        },
        onHapticsChanged: (value) {
          unawaited(
            AppServices.instance.analytics.logSettingsChanged('haptics', value),
          );
          setState(() => _hapticsEnabled.value = value);
        },
        onPresetChanged: (preset) {
          final index = kMatchPresets.indexWhere((item) => item.id == preset.id);
          if (index >= 0) {
            unawaited(AppServices.instance.analytics.logPresetSelected(preset));
            setState(() => _selectedPresetIndex.value = index);
          }
        },
        onStartSetup: _startSetup,
      );
    }

    return CricketMatchPage(
      key: ValueKey(
        '${activeSetup.mode.name}-${activeSetup.preset.id}-${activeSetup.challenge?.id ?? 'free'}',
      ),
      setup: activeSetup,
      soundEnabled: _soundEnabled.value,
      hapticsEnabled: _hapticsEnabled.value,
      onMatchFinished: _recordMatchFinished,
      onExitToMenu: () {
        unawaited(AppServices.instance.analytics.logMenuView(_progress));
        setState(() => _activeSetup = null);
      },
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({
    super.key,
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.selectedPreset,
    required this.progress,
    required this.onSoundChanged,
    required this.onHapticsChanged,
    required this.onPresetChanged,
    required this.onStartSetup,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final MatchPreset selectedPreset;
  final GameProgress progress;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onHapticsChanged;
  final ValueChanged<MatchPreset> onPresetChanged;
  final ValueChanged<GameSetup> onStartSetup;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F8B63),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_note,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pencil Pitch', style: titleStyle),
                            Text(
                              'Offline notebook cricket',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: const Color(0xFF59635F),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _PresetSelector(
                    selectedPreset: selectedPreset,
                    onPresetChanged: onPresetChanged,
                  ),
                  const SizedBox(height: 12),
                  _ModeButton(
                    icon: Icons.sports_cricket,
                    title: 'Practice innings',
                    subtitle: selectedPreset.description,
                    onPressed: () => onStartSetup(
                      GameSetup(
                        mode: GameMode.practiceInnings,
                        preset: selectedPreset,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ModeButton(
                    icon: Icons.track_changes,
                    title: 'Target chase',
                    subtitle: 'Set a score, then chase it with ${selectedPreset.title}.',
                    onPressed: () => onStartSetup(
                      GameSetup(
                        mode: GameMode.targetChase,
                        preset: selectedPreset,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ChallengePreview(
                    progress: progress,
                    onStartChallenge: (challenge) {
                      onStartSetup(GameSetup.challenge(challenge));
                    },
                  ),
                  const SizedBox(height: 12),
                  _ProgressPanel(progress: progress),
                  const SizedBox(height: 18),
                  _Panel(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: const Icon(
                        Icons.help_outline,
                        color: Color(0xFF0F8B63),
                      ),
                      title: const Text('How to play'),
                      subtitle: const Text(
                        'Spin, stop, score, and replay extras.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showHowToPlaySheet(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Panel(
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Sound'),
                          subtitle: const Text(
                            'Short system clicks for taps and outcomes.',
                          ),
                          value: soundEnabled,
                          onChanged: onSoundChanged,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Haptics'),
                          subtitle: const Text(
                            'Light device feedback on actions and results.',
                          ),
                          value: hapticsEnabled,
                          onChanged: onHapticsChanged,
                        ),
                      ],
                    ),
                  ),
                  const AdBannerSlot(placement: AdPlacements.mainMenu),
                  const SizedBox(height: 12),
                  Text(
                    'Offline play. Ads are limited to menu, results, or safe breaks.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF59635F),
                          fontWeight: FontWeight.w600,
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

void _showHowToPlaySheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How to play',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const _HelpRow(
                    icon: Icons.cyclone,
                    title: 'Tap Spin',
                    detail: 'The wheel starts moving. Tap the wheel or button again to stop.',
                  ),
                  const _HelpRow(
                    icon: Icons.arrow_drop_down_circle,
                    title: 'Read the pointer',
                    detail: 'The top pointer decides the result when the wheel settles.',
                  ),
                  const _HelpRow(
                    icon: Icons.add_circle_outline,
                    title: 'Extras replay the ball',
                    detail: 'Wide and No-ball add 1 run but do not use a legal delivery.',
                  ),
                  const _HelpRow(
                    icon: Icons.flag_outlined,
                    title: 'Chase the target',
                    detail: 'In Target chase, first innings score plus 1 becomes the target.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check),
                    label: const Text('Got it'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F8B63)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF59635F),
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

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({
    required this.selectedPreset,
    required this.onPresetChanged,
  });

  final MatchPreset selectedPreset;
  final ValueChanged<MatchPreset> onPresetChanged;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: Color(0xFF0F8B63)),
              const SizedBox(width: 10),
              Text(
                'Match preset',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in kMatchPresets)
                ChoiceChip(
                  label: Text(preset.title),
                  selected: preset.id == selectedPreset.id,
                  onSelected: (_) => onPresetChanged(preset),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            selectedPreset.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF59635F),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChallengePreview extends StatelessWidget {
  const _ChallengePreview({
    required this.progress,
    required this.onStartChallenge,
  });

  final GameProgress progress;
  final ValueChanged<ChallengeSpec> onStartChallenge;

  @override
  Widget build(BuildContext context) {
    final next = progress.nextChallenge;
    final countText =
        '${progress.completedChallengeCount}/${kChallengeLadder.length}';

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, color: Color(0xFF0F8B63)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Challenge ladder',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                ),
              ),
              Text(
                countText,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF59635F),
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (next == null)
            const Text('All challenges complete. Nice page of cricket.')
          else ...[
            Text(
              next.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              next.goalText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF59635F),
                  ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => onStartChallenge(next),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start next challenge'),
            ),
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              unawaited(
                AppServices.instance.analytics.logChallengeLadderView(progress),
              );
              _showChallengeLadderSheet(
                context,
                progress,
                onStartChallenge,
              );
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('View all challenges'),
          ),
        ],
      ),
    );
  }
}

void _showChallengeLadderSheet(
  BuildContext context,
  GameProgress progress,
  ValueChanged<ChallengeSpec> onStartChallenge,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final height = MediaQuery.sizeOf(context).height * 0.78;

      return SafeArea(
        child: SizedBox(
          height: height,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            itemCount: kChallengeLadder.length + 1,
            separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 12 : 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Text(
                  'Challenge ladder',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                );
              }

              final challenge = kChallengeLadder[index - 1];
              return _ChallengeCard(
                number: index,
                challenge: challenge,
                completed: progress.isChallengeComplete(challenge),
                unlocked: progress.isChallengeUnlocked(challenge),
                onStart: () {
                  Navigator.of(context).pop();
                  onStartChallenge(challenge);
                },
              );
            },
          ),
        ),
      );
    },
  );
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.number,
    required this.challenge,
    required this.completed,
    required this.unlocked,
    required this.onStart,
  });

  final int number;
  final ChallengeSpec challenge;
  final bool completed;
  final bool unlocked;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final icon = completed
        ? Icons.check_circle
        : unlocked
            ? Icons.play_circle_outline
            : Icons.lock_outline;
    final color = completed
        ? const Color(0xFF0F8B63)
        : unlocked
            ? const Color(0xFF243B53)
            : const Color(0xFF7A8580);

    return _Panel(
      color: unlocked ? Colors.white : const Color(0xFFF0F0ED),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. ${challenge.title}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${challenge.difficulty.label} - ${challenge.preset.title}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF59635F),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(challenge.description),
                const SizedBox(height: 4),
                Text(
                  challenge.goalText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF59635F),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (completed)
            const Text('Done')
          else
            FilledButton(
              onPressed: unlocked ? onStart : null,
              child: Text(unlocked ? 'Start' : 'Locked'),
            ),
        ],
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.progress});

  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: Color(0xFF0F8B63)),
              const SizedBox(width: 10),
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _ProgressStat(
                label: 'Matches',
                value: '${progress.matchesPlayed}',
              ),
              _ProgressStat(
                label: 'Best practice',
                value: '${progress.bestPracticeRuns}',
              ),
              _ProgressStat(
                label: 'Best chase',
                value: '${progress.bestChaseRuns}',
              ),
              _ProgressStat(
                label: 'Chase wins',
                value: '${progress.targetChaseWins}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          if (progress.recentMatches.isEmpty)
            Text(
              'No match history yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF59635F),
                  ),
            )
          else
            for (final record in progress.recentMatches.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${record.setupTitle}: ${record.result} (${record.scoreLine})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF59635F),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
        ],
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF59635F),
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF0F8B63), size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF59635F),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class CricketMatchPage extends StatefulWidget {
  const CricketMatchPage({
    super.key,
    required this.setup,
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.onMatchFinished,
    required this.onExitToMenu,
  });

  final GameSetup setup;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final ValueChanged<MatchState> onMatchFinished;
  final VoidCallback onExitToMenu;

  @override
  State<CricketMatchPage> createState() => _CricketMatchPageState();
}

enum _SpinnerPhase { idle, spinning, settling, revealing }

class _CricketMatchPageState extends State<CricketMatchPage>
    with SingleTickerProviderStateMixin {
  static const _loopDuration = Duration(milliseconds: 520);
  static const _settleDuration = Duration(milliseconds: 920);
  static const _resultHold = Duration(milliseconds: 650);

  late CricketMatch _match;
  late final AnimationController _spinController;
  late Animation<double> _settleAnimation;
  late DateTime _matchStartedAt;

  double _wheelRotation = 0;
  int? _selectedSegmentIndex;
  _SpinnerPhase _spinnerPhase = _SpinnerPhase.idle;
  Timer? _resultTimer;

  MatchState get _state => _match.state;

  bool get _isSpinning => _spinnerPhase == _SpinnerPhase.spinning;

  bool get _isSettling => _spinnerPhase == _SpinnerPhase.settling;

  bool get _isResultAnimating => _spinnerPhase == _SpinnerPhase.revealing;

  bool get _isBusy => _spinnerPhase != _SpinnerPhase.idle;

  bool get _canTapSpinner {
    return _state.canPlayDelivery && !_isSettling && !_isResultAnimating;
  }

  void _playTapFeedback() {
    if (widget.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (widget.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void _playInvalidFeedback() {
    if (widget.soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
    if (widget.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void _playOutcomeFeedback(DeliveryResult result) {
    if (widget.soundEnabled) {
      final alertSound =
          result.outcome == DeliveryOutcome.wicket ||
          result.phaseAfter == MatchPhase.matchComplete;
      SystemSound.play(
        alertSound ? SystemSoundType.alert : SystemSoundType.click,
      );
    }

    if (!widget.hapticsEnabled) {
      return;
    }

    if (result.phaseAfter == MatchPhase.matchComplete) {
      HapticFeedback.heavyImpact();
      return;
    }

    switch (result.outcome) {
      case DeliveryOutcome.six:
      case DeliveryOutcome.four:
      case DeliveryOutcome.wicket:
        HapticFeedback.mediumImpact();
        return;
      case DeliveryOutcome.wide:
      case DeliveryOutcome.noBall:
        HapticFeedback.lightImpact();
        return;
      case DeliveryOutcome.dot:
      case DeliveryOutcome.one:
      case DeliveryOutcome.two:
      case DeliveryOutcome.three:
        HapticFeedback.selectionClick();
        return;
    }
  }

  double get _displayRotation {
    if (_isSpinning) {
      return _wheelRotation + (_spinController.value * pi * 2);
    }

    if (_isSettling) {
      return _settleAnimation.value;
    }

    return _wheelRotation;
  }

  @override
  void initState() {
    super.initState();
    _match = CricketMatch(mode: widget.setup.mode, rules: widget.setup.rules);
    _matchStartedAt = DateTime.now();
    _spinController = AnimationController(vsync: this, duration: _loopDuration);
    _settleAnimation = AlwaysStoppedAnimation(_wheelRotation);
  }

  @override
  void dispose() {
    _resultTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  void _handleSpinnerTap() {
    if (!_canTapSpinner) {
      _playInvalidFeedback();
      return;
    }

    if (_isSpinning) {
      _stopSpinner();
    } else {
      _startSpinner();
    }
  }

  void _startSpinner() {
    _resultTimer?.cancel();
    setState(() {
      _selectedSegmentIndex = null;
      _spinnerPhase = _SpinnerPhase.spinning;
    });
    _spinController.duration = _loopDuration;
    _spinController.reset();
    _spinController.repeat();
    _playTapFeedback();
    unawaited(
      AppServices.instance.analytics.logSpinnerStart(widget.setup, _state),
    );
  }

  Future<void> _stopSpinner() async {
    if (!_isSpinning) {
      return;
    }

    final startRotation = _displayRotation;
    final segmentIndex = _segmentIndexUnderPointer(startRotation);
    final targetRotation = _targetRotationFor(segmentIndex, startRotation);
    _spinController.stop();

    setState(() {
      _spinnerPhase = _SpinnerPhase.settling;
      _settleAnimation = Tween<double>(
        begin: startRotation,
        end: targetRotation,
      ).animate(
        CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
      );
    });

    _spinController.duration = _settleDuration;
    await _spinController.forward(from: 0);

    if (!mounted) {
      return;
    }

    final outcome = SpinWheelModel.segments[segmentIndex];
    final deliveryResult = _match.deliver(outcome);
    _playOutcomeFeedback(deliveryResult);
    final matchFinished = deliveryResult.phaseAfter == MatchPhase.matchComplete;
    unawaited(
      AppServices.instance.analytics.logDeliveryResult(
        setup: widget.setup,
        state: _match.state,
        result: deliveryResult,
      ),
    );

    setState(() {
      _wheelRotation = targetRotation;
      _selectedSegmentIndex = segmentIndex;
      _spinnerPhase = _SpinnerPhase.revealing;
    });

    if (matchFinished) {
      unawaited(
        AppServices.instance.analytics.logMatchFinish(
          setup: widget.setup,
          state: _match.state,
          duration: DateTime.now().difference(_matchStartedAt),
        ),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onMatchFinished(_match.state);
        }
      });
    }

    _resultTimer?.cancel();
    _resultTimer = Timer(_resultHold, () {
      if (!mounted) {
        return;
      }

      if (_isResultAnimating) {
        setState(() => _spinnerPhase = _SpinnerPhase.idle);
        if (_state.phase == MatchPhase.matchComplete) {
          AppServices.instance.ads.recordMatchCompleted();
          unawaited(
            AppServices.instance.ads.maybeShowMatchEndInterstitial(
              appIsInSafeBreak: true,
            ),
          );
        }
      }
    });
  }

  int _segmentIndexUnderPointer(double rotation) {
    final sweep = (pi * 2) / SpinWheelModel.segments.length;
    final angleUnderPointer = _normalizeRadians(-rotation);
    return angleUnderPointer ~/ sweep;
  }

  double _normalizeRadians(double angle) {
    final fullTurn = pi * 2;
    return ((angle % fullTurn) + fullTurn) % fullTurn;
  }

  double _targetRotationFor(int segmentIndex, double fromRotation) {
    final sweep = (pi * 2) / SpinWheelModel.segments.length;
    final alignedRotation = -((segmentIndex + 0.5) * sweep);
    final minimumTarget = fromRotation + (pi * 2 * 2.25);
    var target = alignedRotation;

    while (target < minimumTarget) {
      target += pi * 2;
    }

    return target;
  }

  void _startChase() {
    if (_isBusy || _state.phase != MatchPhase.inningsBreak) {
      _playInvalidFeedback();
      return;
    }

    _playTapFeedback();
    setState(_match.startChase);
  }

  void _restart() {
    _playTapFeedback();
    _resultTimer?.cancel();
    _spinController.stop();
    _spinController.reset();
    setState(() {
      _match.restart();
      _matchStartedAt = DateTime.now();
      _wheelRotation = 0;
      _selectedSegmentIndex = null;
      _spinnerPhase = _SpinnerPhase.idle;
      _settleAnimation = AlwaysStoppedAnimation(_wheelRotation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            final body = isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildMatchColumn(context)),
                      const SizedBox(width: 18),
                      Expanded(child: _buildSpinnerColumn(context)),
                    ],
                  )
                : Column(
                    children: [
                      _buildMatchColumn(context),
                      const SizedBox(height: 16),
                      _buildSpinnerColumn(context),
                    ],
                  );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: body,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMatchColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MatchHeader(
          setup: widget.setup,
          menuEnabled: !_isBusy,
          onShowHelp: () => _showHowToPlaySheet(context),
          onExitToMenu: widget.onExitToMenu,
        ),
        const SizedBox(height: 14),
        _PhaseBanner(state: _state),
        if (widget.setup.challenge != null) ...[
          const SizedBox(height: 14),
          _ChallengeGoalPanel(
            challenge: widget.setup.challenge!,
            state: _state,
          ),
        ],
        const SizedBox(height: 14),
        _GameplayHint(
          state: _state,
          isSpinning: _isSpinning,
          isSettling: _isSettling,
          isResultAnimating: _isResultAnimating,
        ),
        const SizedBox(height: 14),
        _ScoreBoard(state: _state),
        const SizedBox(height: 14),
        _LastDeliveryCard(
          result: _state.lastDelivery,
          isAnimating: _isResultAnimating,
        ),
        if (_state.phase == MatchPhase.matchComplete) ...[
          const SizedBox(height: 14),
          _MatchResultPanel(state: _state),
          if (!_isBusy)
            const AdBannerSlot(placement: AdPlacements.matchResult),
        ],
      ],
    );
  }

  Widget _buildSpinnerColumn(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _spinController,
            builder: (context, child) {
              return _SpinWheel(
                rotation: _displayRotation,
                selectedIndex: _selectedSegmentIndex,
                isSpinning: _isSpinning,
                isSettling: _isSettling,
                enabled: _canTapSpinner,
                onTap: _handleSpinnerTap,
              );
            },
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _ActionArea(
              key: ValueKey('${_state.phase}-$_isSpinning-$_isSettling'),
              state: _state,
              isSpinning: _isSpinning,
              isSettling: _isSettling,
              isResultAnimating: _isResultAnimating,
              onSpinnerTap: _handleSpinnerTap,
              onStartChase: _startChase,
              onRestart: _restart,
              onExitToMenu: widget.onExitToMenu,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchHeader extends StatelessWidget {
  const _MatchHeader({
    required this.setup,
    required this.menuEnabled,
    required this.onShowHelp,
    required this.onExitToMenu,
  });

  final GameSetup setup;
  final bool menuEnabled;
  final VoidCallback onShowHelp;
  final VoidCallback onExitToMenu;

  @override
  Widget build(BuildContext context) {
    final title = setup.challenge?.title ?? 'Pencil Pitch';
    final modeLabel = setup.challenge == null
        ? setup.detail
        : '${setup.modeLabel} - ${setup.preset.title}';

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0F8B63),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.edit_note, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                modeLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF59635F),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Help',
          onPressed: menuEnabled ? onShowHelp : null,
          icon: const Icon(Icons.help_outline),
        ),
        IconButton(
          tooltip: 'Menu',
          onPressed: menuEnabled ? onExitToMenu : null,
          icon: const Icon(Icons.home_outlined),
        ),
      ],
    );
  }
}

class _PhaseBanner extends StatelessWidget {
  const _PhaseBanner({required this.state});

  final MatchState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, detail, icon) = switch (state.phase) {
      MatchPhase.firstInnings when state.mode == GameMode.practiceInnings => (
          'Practice innings',
          '${state.rules.maxOversLimitLabelText}, ${state.rules.maxWickets} wickets',
          Icons.sports_cricket,
        ),
      MatchPhase.firstInnings => (
          'Set the target',
          '${state.rules.maxOversLimitLabelText}, ${state.rules.maxWickets} wickets',
          Icons.flag,
        ),
      MatchPhase.inningsBreak => (
          'Innings complete',
          'Target ${state.target} from ${state.rules.oversLimitLabel} overs',
          Icons.pause_circle,
        ),
      MatchPhase.secondInnings => (
          'Chase ${state.target}',
          '${state.runsNeeded} needed from ${state.ballsRemaining} balls',
          Icons.track_changes,
        ),
      MatchPhase.matchComplete => (
          state.matchResult ?? 'Match complete',
          _finalScoreText(state),
          Icons.emoji_events,
        ),
    };

    return _Panel(
      color: const Color(0xFF19241F),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF7C948)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFDCE5DF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _finalScoreText(MatchState state) {
    if (state.mode == GameMode.practiceInnings) {
      return 'Final: ${state.firstInnings.runs}/${state.firstInnings.wickets} in ${state.firstInnings.oversLabel} overs';
    }

    return 'Final: ${state.firstInnings.runs}/${state.firstInnings.wickets} and ${state.secondInnings.runs}/${state.secondInnings.wickets}';
  }
}

class _ChallengeGoalPanel extends StatelessWidget {
  const _ChallengeGoalPanel({
    required this.challenge,
    required this.state,
  });

  final ChallengeSpec challenge;
  final MatchState state;

  @override
  Widget build(BuildContext context) {
    final complete = challenge.isComplete(state);
    final matchEnded = state.phase == MatchPhase.matchComplete;
    final icon = complete
        ? Icons.check_circle
        : matchEnded
            ? Icons.refresh
            : Icons.flag_outlined;
    final color = complete
        ? const Color(0xFFE7F8F0)
        : matchEnded
            ? const Color(0xFFFFF6DA)
            : Colors.white;
    final status = complete
        ? 'Challenge complete'
        : matchEnded
            ? 'Try again'
            : challenge.difficulty.label;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: _Panel(
        key: ValueKey('$status-${state.phase}'),
        color: color,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF0F8B63)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF59635F),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    challenge.goalText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameplayHint extends StatelessWidget {
  const _GameplayHint({
    required this.state,
    required this.isSpinning,
    required this.isSettling,
    required this.isResultAnimating,
  });

  final MatchState state;
  final bool isSpinning;
  final bool isSettling;
  final bool isResultAnimating;

  @override
  Widget build(BuildContext context) {
    final (icon, message, color) = _hint;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: _Panel(
        key: ValueKey(message),
        color: color,
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0F8B63)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF26342E),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, String, Color) get _hint {
    if (state.phase == MatchPhase.matchComplete) {
      return (
        Icons.emoji_events_outlined,
        'Match complete. Restart for another try or return to the menu.',
        const Color(0xFFFFF6DA),
      );
    }

    if (state.phase == MatchPhase.inningsBreak) {
      return (
        Icons.flag_outlined,
        'Target is set. Start the chase when you are ready.',
        const Color(0xFFFFF6DA),
      );
    }

    if (isSpinning) {
      return (
        Icons.touch_app_outlined,
        'Tap the wheel or button now to stop under the pointer.',
        const Color(0xFFE7F8F0),
      );
    }

    if (isSettling || isResultAnimating) {
      return (
        Icons.hourglass_top,
        'Scoring this delivery. Controls unlock after the result.',
        const Color(0xFFFFF6DA),
      );
    }

    final lastOutcome = state.lastDelivery?.outcome;
    if (lastOutcome == DeliveryOutcome.wide ||
        lastOutcome == DeliveryOutcome.noBall) {
      return (
        Icons.replay,
        'Extra added. This ball is replayed and the over count stays put.',
        const Color(0xFFFFF6DA),
      );
    }

    return (
      Icons.cyclone,
      'Tap Spin, then tap again to stop the wheel.',
      const Color(0xFFE7F8F0),
    );
  }
}

class _MatchResultPanel extends StatelessWidget {
  const _MatchResultPanel({required this.state});

  final MatchState state;

  @override
  Widget build(BuildContext context) {
    final title = state.matchResult ?? 'Match complete';
    final icon = title.contains('won')
        ? Icons.workspace_premium
        : title.contains('tied')
            ? Icons.balance
            : Icons.flag_outlined;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: _Panel(
        color: const Color(0xFFEEF7F1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0F8B63)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            _ResultLine(
              label: state.mode == GameMode.practiceInnings
                  ? 'Final score'
                  : 'First innings',
              value:
                  '${state.firstInnings.runs}/${state.firstInnings.wickets} in ${state.firstInnings.oversLabel}',
            ),
            if (state.mode == GameMode.targetChase) ...[
              _ResultLine(label: 'Target', value: '${state.target}'),
              _ResultLine(
                label: 'Chase score',
                value:
                    '${state.secondInnings.runs}/${state.secondInnings.wickets} in ${state.secondInnings.oversLabel}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF59635F),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBoard extends StatelessWidget {
  const _ScoreBoard({required this.state});

  final MatchState state;

  @override
  Widget build(BuildContext context) {
    final score = state.activeScore;
    final showTarget = state.target != null;
    final showNeeded = state.phase == MatchPhase.secondInnings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Innings ${state.inningsNumber}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF59635F),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 10,
                runSpacing: 4,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.92, end: 1).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      '${score.runs}/${score.wickets}',
                      key: ValueKey(
                        '${state.phase}-${score.runs}-${score.wickets}-${score.legalBalls}-${score.extras}',
                      ),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                                height: 0.95,
                              ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'overs ${score.oversLabel}/${state.rules.oversLimitLabel}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF4B5752),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.sports_baseball,
                label: 'Balls',
                value: '${score.legalBalls}/${state.rules.maxLegalBalls}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.add_circle_outline,
                label: 'Extras',
                value: '${score.extras}',
              ),
            ),
          ],
        ),
        if (showTarget) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.flag_outlined,
                  label: 'Target',
                  value: '${state.target}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.trending_up,
                  label: showNeeded ? 'Needed' : 'To chase',
                  value: '${state.runsNeeded ?? state.target}',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DeliveryVisualStyle {
  const _DeliveryVisualStyle({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.activeBackground,
  });

  final IconData icon;
  final Color iconColor;
  final Color background;
  final Color activeBackground;
}

_DeliveryVisualStyle _deliveryStyleFor(DeliveryResult? result) {
  return switch (result?.outcome) {
    DeliveryOutcome.wicket => const _DeliveryVisualStyle(
        icon: Icons.close,
        iconColor: Color(0xFF9B1C1C),
        background: Color(0xFFFFF1F1),
        activeBackground: Color(0xFFFFD9D9),
      ),
    DeliveryOutcome.four || DeliveryOutcome.six => const _DeliveryVisualStyle(
        icon: Icons.bolt,
        iconColor: Color(0xFF9B4D00),
        background: Color(0xFFFFF6DA),
        activeBackground: Color(0xFFFFE6A8),
      ),
    DeliveryOutcome.wide || DeliveryOutcome.noBall =>
      const _DeliveryVisualStyle(
        icon: Icons.replay,
        iconColor: Color(0xFF8A5200),
        background: Color(0xFFFFF6DA),
        activeBackground: Color(0xFFFFE9B8),
      ),
    DeliveryOutcome.one || DeliveryOutcome.two || DeliveryOutcome.three =>
      const _DeliveryVisualStyle(
        icon: Icons.add_circle_outline,
        iconColor: Color(0xFF0F8B63),
        background: Color(0xFFEFFAF4),
        activeBackground: Color(0xFFDDF5EA),
      ),
    DeliveryOutcome.dot => const _DeliveryVisualStyle(
        icon: Icons.radio_button_checked,
        iconColor: Color(0xFF4B5752),
        background: Colors.white,
        activeBackground: Color(0xFFEDEFEA),
      ),
    null => const _DeliveryVisualStyle(
        icon: Icons.info_outline,
        iconColor: Color(0xFF0F8B63),
        background: Colors.white,
        activeBackground: Color(0xFFEFFAF4),
      ),
  };
}

class _LastDeliveryCard extends StatelessWidget {
  const _LastDeliveryCard({required this.result, required this.isAnimating});

  final DeliveryResult? result;
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    final title = result?.title ?? 'Ready';
    final detail = result?.detail ?? 'Awaiting first delivery.';
    final style = _deliveryStyleFor(result);

    return AnimatedScale(
      scale: isAnimating ? 1.02 : 1,
      duration: const Duration(milliseconds: 180),
      child: _Panel(
        color: isAnimating ? style.activeBackground : style.background,
        child: Row(
          children: [
            Icon(
              style.icon,
              color: style.iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Column(
                  key: ValueKey('$title-$detail'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF59635F),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionArea extends StatelessWidget {
  const _ActionArea({
    super.key,
    required this.state,
    required this.isSpinning,
    required this.isSettling,
    required this.isResultAnimating,
    required this.onSpinnerTap,
    required this.onStartChase,
    required this.onRestart,
    required this.onExitToMenu,
  });

  final MatchState state;
  final bool isSpinning;
  final bool isSettling;
  final bool isResultAnimating;
  final VoidCallback onSpinnerTap;
  final VoidCallback onStartChase;
  final VoidCallback onRestart;
  final VoidCallback onExitToMenu;

  @override
  Widget build(BuildContext context) {
    final phaseActionLocked = isSpinning || isSettling || isResultAnimating;

    if (state.phase == MatchPhase.inningsBreak) {
      return Column(
        children: [
          _PrimaryButton(
            icon: Icons.play_arrow,
            label: 'Start chase',
            onPressed: phaseActionLocked ? null : onStartChase,
          ),
          const SizedBox(height: 10),
          _SecondaryActions(
            onRestart: phaseActionLocked ? null : onRestart,
            onExitToMenu: phaseActionLocked ? null : onExitToMenu,
          ),
        ],
      );
    }

    if (state.phase == MatchPhase.matchComplete) {
      return Column(
        children: [
          _PrimaryButton(
            icon: Icons.refresh,
            label: 'Restart',
            onPressed: phaseActionLocked ? null : onRestart,
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: phaseActionLocked ? null : onExitToMenu,
            icon: const Icon(Icons.home_outlined),
            label: const Text('Main menu'),
          ),
        ],
      );
    }

    final inputLocked = isSettling || isResultAnimating;
    final label = isSpinning
        ? 'Tap to stop'
        : inputLocked
            ? 'Resolving'
            : 'Spin';
    final icon = isSpinning ? Icons.stop_circle_outlined : Icons.cyclone;

    return Column(
      children: [
        _PrimaryButton(
          icon: icon,
          label: label,
          onPressed: inputLocked ? null : onSpinnerTap,
        ),
        const SizedBox(height: 10),
        _SecondaryActions(
          onRestart: inputLocked || isSpinning ? null : onRestart,
          onExitToMenu: inputLocked || isSpinning ? null : onExitToMenu,
        ),
      ],
    );
  }
}

class _SecondaryActions extends StatelessWidget {
  const _SecondaryActions({required this.onRestart, required this.onExitToMenu});

  final VoidCallback? onRestart;
  final VoidCallback? onExitToMenu;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Restart'),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onExitToMenu,
          icon: const Icon(Icons.home_outlined),
          label: const Text('Menu'),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _SpinWheel extends StatelessWidget {
  const _SpinWheel({
    required this.rotation,
    required this.selectedIndex,
    required this.isSpinning,
    required this.isSettling,
    required this.enabled,
    required this.onTap,
  });

  final double rotation;
  final int? selectedIndex;
  final bool isSpinning;
  final bool isSettling;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(320.0, max(240.0, constraints.maxWidth - 8));
        final centerText = _centerText;

        return Semantics(
          button: true,
          enabled: enabled,
          label: isSpinning ? 'Stop spinner' : 'Spin wheel',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: enabled || isSpinning || isSettling ? 1 : 0.68,
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size.square(size),
                      painter: _WheelPainter(
                        rotation: rotation,
                        selectedIndex: selectedIndex,
                        isSpinning: isSpinning || isSettling,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: 44,
                        color: const Color(0xFFE44835),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    AnimatedScale(
                      scale: isSpinning ? 1.06 : 1,
                      duration: const Duration(milliseconds: 160),
                      child: Container(
                        width: size * 0.3,
                        height: size * 0.3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF17201C),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              centerText,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String get _centerText {
    if (isSpinning) {
      return 'STOP';
    }

    if (isSettling) {
      return '...';
    }

    if (selectedIndex == null) {
      return 'SPIN';
    }

    return SpinWheelModel.segments[selectedIndex!].wheelLabel;
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.rotation,
    required this.selectedIndex,
    required this.isSpinning,
  });

  final double rotation;
  final int? selectedIndex;
  final bool isSpinning;

  static const _segmentColors = <Color>[
    Color(0xFFFFD166),
    Color(0xFF65D6AD),
    Color(0xFFEF476F),
    Color(0xFF243B53),
    Color(0xFF7BDFF2),
    Color(0xFFFF9F1C),
    Color(0xFF06D6A0),
    Color(0xFFFDE74C),
    Color(0xFF90BE6D),
    Color(0xFFFF6B6B),
    Color(0xFF4D96FF),
    Color(0xFFF9844A),
    Color(0xFF3D348B),
    Color(0xFFB8F2E6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 5;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = (pi * 2) / SpinWheelModel.segments.length;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.72);

    canvas.drawCircle(
      center,
      radius + 4,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF17201C),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    for (var index = 0; index < SpinWheelModel.segments.length; index++) {
      final startAngle = -pi / 2 + (index * sweep);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = _segmentColors[index % _segmentColors.length];

      canvas.drawArc(rect, startAngle, sweep, true, paint);
      canvas.drawArc(rect, startAngle, sweep, true, strokePaint);

      if (!isSpinning && selectedIndex == index) {
        canvas.drawArc(
          rect.deflate(5),
          startAngle + 0.02,
          sweep - 0.04,
          true,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..color = Colors.white,
        );
      }

      _drawLabel(canvas, center, radius, startAngle + sweep / 2, index);
    }

    canvas.restore();
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    int index,
  ) {
    final outcome = SpinWheelModel.segments[index];
    final labelRadius = radius * 0.68;
    final labelOffset = Offset(
      center.dx + cos(angle) * labelRadius,
      center.dy + sin(angle) * labelRadius,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: outcome.wheelLabel,
        style: TextStyle(
          color: _usesDarkText(index) ? const Color(0xFF17201C) : Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(labelOffset.dx, labelOffset.dy);
    canvas.rotate(angle + pi / 2);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  bool _usesDarkText(int index) {
    return index == 0 ||
        index == 1 ||
        index == 4 ||
        index == 7 ||
        index == 8 ||
        index == 13;
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.isSpinning != isSpinning;
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0F8B63)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF59635F),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
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

class _Panel extends StatelessWidget {
  const _Panel({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

extension on GameRules {
  String get maxOversLimitLabelText {
    return '$maxOvers ${maxOvers == 1 ? 'over' : 'overs'}';
  }
}
