import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/farm_loop_app.dart';
import '../../../app/privacy_policy.dart';
import '../application/farm_controller.dart';
import 'widgets/crop_picker.dart';
import 'widgets/farm_grid.dart';
import 'widgets/market_panel.dart';
import 'widgets/plot_action_panel.dart';
import 'widgets/resource_hud.dart';
import 'widgets/return_progress_panel.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key, required this.controller});

  final FarmController controller;

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  int _selectedPlot = 0;

  FarmController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        final unlockedPlots = _controller.rules.unlockedPlotCount(
          state.farmLevel,
        );
        _selectedPlot = math.min(_selectedPlot, unlockedPlots - 1);

        return Scaffold(
          appBar: AppBar(
            title: const Text(FarmLoopApp.title),
            actions: [
              IconButton(
                tooltip: PrivacyPolicy.title,
                onPressed: _showPrivacyPolicy,
                icon: const Icon(Icons.privacy_tip_outlined),
              ),
              IconButton(
                tooltip: 'Save',
                onPressed: _controller.saving
                    ? null
                    : () => _runAction(_controller.saveManually),
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
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        ResourceHud(state: state, rules: _controller.rules),
                        if (_controller.returnReport.hasProgress) ...[
                          const SizedBox(height: 12),
                          ReturnProgressPanel(
                            report: _controller.returnReport,
                            onDismiss: _controller.dismissReturnReport,
                          ),
                        ],
                        const SizedBox(height: 14),
                        CropPicker(
                          crops: _controller.allCrops,
                          farmLevel: state.farmLevel,
                          selectedCropId: _controller.selectedCropId,
                          onSelected: _controller.selectCrop,
                        ),
                        const SizedBox(height: 14),
                        FarmGrid(
                          state: state,
                          rules: _controller.rules,
                          selectedPlot: _selectedPlot,
                          nowMs: _controller.nowMs,
                          onSelect: (index) {
                            setState(() => _selectedPlot = index);
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
                          ),
                          onWater: () => _runAction(
                            () => _controller.water(_selectedPlot),
                          ),
                          onHarvest: () => _runAction(
                            () => _controller.harvest(_selectedPlot),
                          ),
                        ),
                        const SizedBox(height: 14),
                        MarketPanel(
                          state: state,
                          rules: _controller.rules,
                          saving: _controller.saving,
                          onSell: () => _runAction(_controller.sellCrate),
                          onBuySeeds: () => _runAction(_controller.buySeeds),
                          onUpgrade: () => _runAction(_controller.upgradeFarm),
                          onSave: () => _runAction(_controller.saveManually),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showPrivacyPolicy() {
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

  Future<void> _runAction(Future<String> Function() action) async {
    final message = await action();
    if (!mounted || message.isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
  }
}
