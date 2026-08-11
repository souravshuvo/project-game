import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_engine.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencil Pitch',
      debugShowCheckedModeBanner: false,
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

class _GameShellState extends State<GameShell> {
  GameMode? _activeMode;
  bool _hapticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final activeMode = _activeMode;

    if (activeMode == null) {
      return MainMenuPage(
        hapticsEnabled: _hapticsEnabled,
        onHapticsChanged: (value) {
          setState(() => _hapticsEnabled = value);
        },
        onStartMode: (mode) {
          setState(() => _activeMode = mode);
        },
      );
    }

    return CricketMatchPage(
      key: ValueKey(activeMode),
      mode: activeMode,
      hapticsEnabled: _hapticsEnabled,
      onExitToMenu: () {
        setState(() => _activeMode = null);
      },
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({
    super.key,
    required this.hapticsEnabled,
    required this.onHapticsChanged,
    required this.onStartMode,
  });

  final bool hapticsEnabled;
  final ValueChanged<bool> onHapticsChanged;
  final ValueChanged<GameMode> onStartMode;

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
                  _ModeButton(
                    icon: Icons.sports_cricket,
                    title: 'Practice innings',
                    subtitle: 'One 2-over innings, restart anytime.',
                    onPressed: () => onStartMode(GameMode.practiceInnings),
                  ),
                  const SizedBox(height: 12),
                  _ModeButton(
                    icon: Icons.track_changes,
                    title: 'Target chase',
                    subtitle: 'Set a score, then chase it.',
                    onPressed: () => onStartMode(GameMode.targetChase),
                  ),
                  const SizedBox(height: 18),
                  _Panel(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Haptics'),
                      subtitle: const Text('Light device feedback on results.'),
                      value: hapticsEnabled,
                      onChanged: onHapticsChanged,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No ads, shop, login, leaderboard, or online play in v1.',
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
    required this.mode,
    required this.hapticsEnabled,
    required this.onExitToMenu,
  });

  final GameMode mode;
  final bool hapticsEnabled;
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
    _match = CricketMatch(mode: widget.mode);
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
    if (widget.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
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
    _match.deliver(outcome);

    if (widget.hapticsEnabled) {
      if (outcome == DeliveryOutcome.wicket || outcome == DeliveryOutcome.six) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }

    setState(() {
      _wheelRotation = targetRotation;
      _selectedSegmentIndex = segmentIndex;
      _spinnerPhase = _SpinnerPhase.revealing;
    });

    _resultTimer?.cancel();
    _resultTimer = Timer(_resultHold, () {
      if (!mounted) {
        return;
      }

      if (_isResultAnimating) {
        setState(() => _spinnerPhase = _SpinnerPhase.idle);
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
      return;
    }

    setState(_match.startChase);
  }

  void _restart() {
    _resultTimer?.cancel();
    _spinController.stop();
    _spinController.reset();
    setState(() {
      _match.restart();
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
          mode: widget.mode,
          menuEnabled: !_isBusy,
          onExitToMenu: widget.onExitToMenu,
        ),
        const SizedBox(height: 14),
        _PhaseBanner(state: _state),
        const SizedBox(height: 14),
        _ScoreBoard(state: _state),
        const SizedBox(height: 14),
        _LastDeliveryCard(
          result: _state.lastDelivery,
          isAnimating: _isResultAnimating,
        ),
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
    required this.mode,
    required this.menuEnabled,
    required this.onExitToMenu,
  });

  final GameMode mode;
  final bool menuEnabled;
  final VoidCallback onExitToMenu;

  @override
  Widget build(BuildContext context) {
    final modeLabel = mode == GameMode.practiceInnings
        ? 'Practice innings'
        : 'Target chase';

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
                'Pencil Pitch',
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
                  Text(
                    '${score.runs}/${score.wickets}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                          height: 0.95,
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

class _LastDeliveryCard extends StatelessWidget {
  const _LastDeliveryCard({required this.result, required this.isAnimating});

  final DeliveryResult? result;
  final bool isAnimating;

  @override
  Widget build(BuildContext context) {
    final title = result?.title ?? 'Ready';
    final detail = result?.detail ?? 'Awaiting first delivery.';

    return AnimatedScale(
      scale: isAnimating ? 1.02 : 1,
      duration: const Duration(milliseconds: 180),
      child: _Panel(
        color: isAnimating ? const Color(0xFFFFF0C7) : Colors.white,
        child: Row(
          children: [
            Icon(
              isAnimating ? Icons.bolt : Icons.info_outline,
              color: isAnimating
                  ? const Color(0xFF9B4D00)
                  : const Color(0xFF0F8B63),
            ),
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

        return GestureDetector(
          onTap: enabled ? onTap : null,
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
                Container(
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
                  child: Text(
                    centerText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                  ),
                ),
              ],
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
