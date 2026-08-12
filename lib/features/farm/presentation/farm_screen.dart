import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/ads/ad_banner_slot.dart';
import '../../../app/ads/ad_controller.dart';
import '../../../app/farm_loop_app.dart';
import '../../../app/game_feedback.dart';
import '../../../app/player_settings.dart';
import '../../../app/privacy_policy.dart';
import '../application/analytics_events.dart';
import '../application/farm_controller.dart';
import '../domain/farm_plot.dart';
import '../domain/farm_rules.dart';
import '../domain/farm_state.dart';
import 'widgets/crop_picker.dart';
import 'widgets/farm_grid.dart';
import 'widgets/market_panel.dart';
import 'widgets/plot_action_panel.dart';
import 'widgets/resource_hud.dart';
import 'widgets/return_progress_panel.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({
    super.key,
    required this.controller,
    required this.settings,
    required this.feedback,
    required this.ads,
  });

  final FarmController controller;
  final PlayerSettings settings;
  final GameFeedback feedback;
  final AdController ads;

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  late final Listenable _screenListenable;
  int _selectedPlot = 0;
  bool _playing = false;
  bool _completionSheetShown = false;

  FarmController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _screenListenable = Listenable.merge([widget.controller, widget.settings]);
    _logScreen('garden_home');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _screenListenable,
      builder: (context, _) {
        final state = _controller.state;
        final unlockedPlots = _controller.rules.unlockedPlotCount(
          state.farmLevel,
        );
        _selectedPlot = math.min(_selectedPlot, unlockedPlots - 1);

        if (!_playing) {
          return _GardenMenuScreen(
            state: state,
            rules: _controller.rules,
            nowMs: _controller.nowMs,
            hasReturnProgress: _controller.returnReport.hasProgress,
            onStart: _startPlaying,
            onHelp: _showHelpSheet,
            onSettings: _showSettingsSheet,
            onPrivacy: _showPrivacyPolicy,
            onReset: _showResetConfirmation,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Rain Garden'),
            actions: [
              IconButton(
                tooltip: 'Garden menu',
                onPressed: _showGardenMenu,
                icon: const Icon(Icons.menu_outlined),
              ),
              IconButton(
                tooltip: 'Save',
                onPressed: _controller.saving
                    ? null
                    : () => _runAction(
                        _controller.saveManually,
                        validFeedback: GameFeedbackType.valid,
                      ),
                icon: _controller.saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.save_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = math.min(680.0, constraints.maxWidth);
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      children: [
                        ResourceHud(state: state, rules: _controller.rules),
                        if (widget.settings.showHints) ...[
                          const SizedBox(height: 12),
                          _FirstActionHint(
                            onDismiss: () {
                              unawaited(
                                widget.feedback.play(GameFeedbackType.tap),
                              );
                              unawaited(widget.settings.setShowHints(false));
                            },
                          ),
                        ],
                        if (_controller.returnReport.hasProgress) ...[
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: ReturnProgressPanel(
                              key: const ValueKey('return-progress'),
                              report: _controller.returnReport,
                              onDismiss: () {
                                unawaited(
                                  widget.feedback.play(GameFeedbackType.tap),
                                );
                                _controller.dismissReturnReport();
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        CropPicker(
                          crops: _controller.allCrops,
                          farmLevel: state.farmLevel,
                          selectedCropId: _controller.selectedCropId,
                          onSelected: (cropId) {
                            unawaited(
                              widget.feedback.play(GameFeedbackType.tap),
                            );
                            _controller.selectCrop(cropId);
                          },
                        ),
                        const SizedBox(height: 14),
                        FarmGrid(
                          state: state,
                          rules: _controller.rules,
                          selectedPlot: _selectedPlot,
                          nowMs: _controller.nowMs,
                          onSelect: (index) {
                            unawaited(
                              widget.feedback.play(GameFeedbackType.tap),
                            );
                            setState(() => _selectedPlot = index);
                          },
                          onLockedSelect: (index) {
                            unawaited(
                              widget.feedback.play(GameFeedbackType.invalid),
                            );
                            _showSnackBar(
                              'Upgrade the garden to open Plot ${index + 1}.',
                              GameFeedbackType.invalid,
                              changed: false,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        PlotActionPanel(
                          state: state,
                          rules: _controller.rules,
                          selectedCrop: _controller.selectedCrop,
                          selectedPlot: _selectedPlot,
                          nowMs: _controller.nowMs,
                          onPlant: () => _runAction(
                            () => _controller.plant(_selectedPlot),
                            validFeedback: GameFeedbackType.valid,
                          ),
                          onWater: () => _runAction(
                            () => _controller.water(_selectedPlot),
                            validFeedback: GameFeedbackType.valid,
                          ),
                          onHarvest: () => _runAction(
                            () => _controller.harvest(_selectedPlot),
                            validFeedback: GameFeedbackType.reward,
                          ),
                        ),
                        const SizedBox(height: 14),
                        MarketPanel(
                          state: state,
                          rules: _controller.rules,
                          saving: _controller.saving,
                          onSell: () => _runAction(
                            _controller.sellCrate,
                            validFeedback: GameFeedbackType.reward,
                          ),
                          onBuySeeds: () => _runAction(
                            _controller.buySeeds,
                            validFeedback: GameFeedbackType.valid,
                          ),
                          onUpgrade: () => _runAction(
                            _controller.upgradeFarm,
                            validFeedback: GameFeedbackType.reward,
                            onChanged: _showCompletionIfReady,
                          ),
                          onSave: () => _runAction(
                            _controller.saveManually,
                            validFeedback: GameFeedbackType.valid,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: AdBannerSlot(ads: widget.ads),
        );
      },
    );
  }

  void _startPlaying() {
    unawaited(widget.feedback.play(GameFeedbackType.tap));
    _logScreen('gameplay');
    setState(() => _playing = true);
  }

  Future<void> _runAction(
    Future<String> Function() action, {
    required GameFeedbackType validFeedback,
    VoidCallback? onChanged,
  }) async {
    unawaited(widget.feedback.play(GameFeedbackType.tap));
    final message = await action();
    if (!mounted || message.isEmpty) {
      return;
    }

    final changed = _controller.lastActionChanged;
    final feedback = changed ? validFeedback : GameFeedbackType.invalid;
    unawaited(widget.feedback.play(feedback));
    _showSnackBar(message, feedback, changed: changed);
    if (changed) {
      widget.ads.recordSuccessfulGameplayAction();
      onChanged?.call();
    }
  }

  void _showCompletionIfReady() {
    if (_completionSheetShown ||
        _controller.rules.nextUpgrade(_controller.state.farmLevel) != null) {
      return;
    }

    _completionSheetShown = true;
    unawaited(widget.feedback.play(GameFeedbackType.complete));
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Garden level complete',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'You unlocked the current version of the rooftop garden. Keep farming for coins, or start a fresh garden.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: const Text('Keep Farming'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showResetConfirmation();
                      },
                      icon: const Icon(Icons.refresh_outlined),
                      label: const Text('New Garden'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _completionSheetShown = false;
      unawaited(
        widget.ads.maybeShowInterstitial(InterstitialPlacement.gardenComplete),
      );
    });
  }

  void _showGardenMenu() {
    unawaited(widget.feedback.play(GameFeedbackType.tap));
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Garden Menu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Continue'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _logScreen('garden_home');
                    setState(() => _playing = false);
                    unawaited(
                      widget.ads.maybeShowInterstitial(
                        InterstitialPlacement.gardenHome,
                      ),
                    );
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Garden Home'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showHelpSheet();
                  },
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Help'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showSettingsSheet();
                  },
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Settings'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showPrivacyPolicy();
                  },
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: const Text(PrivacyPolicy.title),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showResetConfirmation();
                  },
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('New Garden'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsSheet() {
    unawaited(widget.feedback.play(GameFeedbackType.tap));
    _logScreen('settings');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return AnimatedBuilder(
          animation: widget.settings,
          builder: (context, _) {
            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.volume_up_outlined),
                    title: const Text('Sound feedback'),
                    subtitle: const Text('System tap and alert sounds'),
                    value: widget.settings.soundEnabled,
                    onChanged: (value) {
                      unawaited(widget.settings.setSoundEnabled(value));
                      unawaited(widget.feedback.play(GameFeedbackType.tap));
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.vibration_outlined),
                    title: const Text('Haptic feedback'),
                    subtitle: const Text('Light taps for farm actions'),
                    value: widget.settings.hapticsEnabled,
                    onChanged: (value) {
                      unawaited(widget.settings.setHapticsEnabled(value));
                      unawaited(widget.feedback.play(GameFeedbackType.tap));
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.tips_and_updates_outlined),
                    title: const Text('First-action hints'),
                    subtitle: const Text('Show the short gameplay hint'),
                    value: widget.settings.showHints,
                    onChanged: (value) {
                      unawaited(widget.settings.setShowHints(value));
                      unawaited(widget.feedback.play(GameFeedbackType.tap));
                    },
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showHelpSheet();
                    },
                    icon: const Icon(Icons.help_outline),
                    label: const Text('How to Play'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHelpSheet() {
    unawaited(widget.feedback.play(GameFeedbackType.tap));
    _logScreen('help');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Row(
                children: [
                  const Icon(Icons.help_outline),
                  const SizedBox(width: 10),
                  Text(
                    'How to Play',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _HelpStep(
                icon: Icons.touch_app_outlined,
                title: 'First move',
                body: 'Tap an empty plot, plant Sun Sprouts, then water it.',
              ),
              const _HelpStep(
                icon: Icons.timer_outlined,
                title: 'Grow',
                body:
                    'Watered crops keep growing while the app is open or closed.',
              ),
              const _HelpStep(
                icon: Icons.shopping_basket_outlined,
                title: 'Harvest and sell',
                body:
                    'Harvest ready crops into the crate, then sell them for coins.',
              ),
              const _HelpStep(
                icon: Icons.upgrade_outlined,
                title: 'Upgrade',
                body:
                    'Use coins to unlock more plots, crops, and water capacity.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text('Got It'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showResetConfirmation() async {
    unawaited(widget.feedback.play(GameFeedbackType.tap));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Start a new garden?'),
          content: const Text(
            'This clears the current local garden save and starts over with fresh coins, seeds, water, and plots.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Start New'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _playing = true);
    await _runAction(
      _controller.resetProgress,
      validFeedback: GameFeedbackType.complete,
    );
  }

  void _showPrivacyPolicy() {
    unawaited(widget.feedback.play(GameFeedbackType.tap));
    _logScreen('privacy');
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PrivacyPolicy.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  PrivacyPolicy.updated,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Text(
                  PrivacyPolicy.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(
    String message,
    GameFeedbackType feedbackType, {
    required bool changed,
  }) {
    final icon = switch (feedbackType) {
      GameFeedbackType.invalid => Icons.info_outline,
      GameFeedbackType.reward => Icons.auto_awesome_outlined,
      GameFeedbackType.complete => Icons.emoji_events_outlined,
      _ => changed ? Icons.check_circle_outline : Icons.info_outline,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );

    if (!changed) {
      _controller.analytics
          .log(FarmAnalyticsEvents.invalidAction, <String, Object?>{
            'message': message,
            'farm_level': _controller.state.farmLevel,
            'selected_plot': _selectedPlot,
            'selected_crop_id': _controller.selectedCropId,
          });
    }
  }

  void _logScreen(String screenName) {
    _controller.analytics
        .log(FarmAnalyticsEvents.screenViewed, <String, Object?>{
          'screen': screenName,
          'farm_level': _controller.state.farmLevel,
          'coins': _controller.state.coins,
          'unlocked_plots': _controller.rules.unlockedPlotCount(
            _controller.state.farmLevel,
          ),
          'crate_items': _controller.state.inventory.totalCrateItems,
        });
  }
}

class _GardenMenuScreen extends StatelessWidget {
  const _GardenMenuScreen({
    required this.state,
    required this.rules,
    required this.nowMs,
    required this.hasReturnProgress,
    required this.onStart,
    required this.onHelp,
    required this.onSettings,
    required this.onPrivacy,
    required this.onReset,
  });

  final FarmState state;
  final FarmRules rules;
  final int nowMs;
  final bool hasReturnProgress;
  final VoidCallback onStart;
  final VoidCallback onHelp;
  final VoidCallback onSettings;
  final VoidCallback onPrivacy;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final completed = rules.nextUpgrade(state.farmLevel) == null;
    final nextAction = _nextActionText(state, rules, nowMs);

    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF6F0E7), Color(0xFFE4D1AB)],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                children: [
                  Text(
                    FarmLoopApp.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF273B29),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    completed
                        ? 'Your current garden level is complete.'
                        : 'Restore a tiny rooftop garden one crop at a time.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF4A4234),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _MenuStatusPanel(
                    title: hasReturnProgress
                        ? 'Your garden grew while away'
                        : 'Next best action',
                    body: nextAction,
                    icon: hasReturnProgress
                        ? Icons.history_toggle_off
                        : Icons.touch_app_outlined,
                  ),
                  const SizedBox(height: 12),
                  _MenuStatsPanel(state: state, rules: rules),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: Text(hasReturnProgress ? 'See Progress' : 'Start'),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MenuButton(
                        icon: Icons.help_outline,
                        label: 'Help',
                        onPressed: onHelp,
                      ),
                      _MenuButton(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onPressed: onSettings,
                      ),
                      _MenuButton(
                        icon: Icons.privacy_tip_outlined,
                        label: PrivacyPolicy.title,
                        onPressed: onPrivacy,
                      ),
                      _MenuButton(
                        icon: Icons.refresh_outlined,
                        label: 'New Garden',
                        onPressed: onReset,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _nextActionText(FarmState state, FarmRules rules, int nowMs) {
    final unlockedPlots = rules.unlockedPlotCount(state.farmLevel);
    for (var index = 0; index < unlockedPlots; index += 1) {
      if (rules.plotStatus(state, index, nowMs) == PlotStatus.ready) {
        return 'Harvest Plot ${index + 1}, then sell the crate for coins.';
      }
    }
    for (var index = 0; index < unlockedPlots; index += 1) {
      if (rules.plotStatus(state, index, nowMs) == PlotStatus.plantedDry) {
        return 'Water Plot ${index + 1} to start its growth timer.';
      }
    }
    for (var index = 0; index < unlockedPlots; index += 1) {
      if (rules.plotStatus(state, index, nowMs) == PlotStatus.empty &&
          state.inventory.seeds > 0) {
        return 'Tap Plot ${index + 1}, plant Sun Sprouts, then water it.';
      }
    }
    if (state.inventory.hasCrateItems) {
      return 'Sell the crate, buy more seeds, then keep planting.';
    }
    return 'Buy seeds, plant an empty plot, and water it to grow crops.';
  }
}

class _MenuStatusPanel extends StatelessWidget {
  const _MenuStatusPanel({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0D5C4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF405A37), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(body, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuStatsPanel extends StatelessWidget {
  const _MenuStatsPanel({required this.state, required this.rules});

  final FarmState state;
  final FarmRules rules;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF314B2E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MenuStat(label: 'Coins', value: state.coins.toString()),
            _MenuStat(label: 'Seeds', value: state.inventory.seeds.toString()),
            _MenuStat(
              label: 'Water',
              value: '${state.water}/${rules.waterCap(state.farmLevel)}',
            ),
            _MenuStat(
              label: 'Plots',
              value: '${rules.unlockedPlotCount(state.farmLevel)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuStat extends StatelessWidget {
  const _MenuStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x22FFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: const Color(0xFFEAF2DF)),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(minimumSize: const Size(128, 48)),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _FirstActionHint extends StatelessWidget {
  const _FirstActionHint({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8DC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3C266)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
        child: Row(
          children: [
            const Icon(Icons.touch_app_outlined, color: Color(0xFF785B18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'First: tap an empty plot, plant Sun Sprouts, then water it.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: 'Hide hint',
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpStep extends StatelessWidget {
  const _HelpStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF405A37)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
