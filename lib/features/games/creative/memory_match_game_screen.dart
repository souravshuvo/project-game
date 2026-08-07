import 'package:flutter/material.dart';

/// A deterministic six-pair emoji memory game that works fully offline.
class MemoryMatchGameScreen extends StatefulWidget {
  const MemoryMatchGameScreen({this.onCompleted, super.key});

  final VoidCallback? onCompleted;

  @override
  State<MemoryMatchGameScreen> createState() => _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen> {
  static const _cards = <_MemoryCardData>[
    _MemoryCardData('lion', '🦁'),
    _MemoryCardData('frog', '🐸'),
    _MemoryCardData('panda', '🐼'),
    _MemoryCardData('fox', '🦊'),
    _MemoryCardData('fish', '🐠'),
    _MemoryCardData('owl', '🦉'),
    _MemoryCardData('panda', '🐼'),
    _MemoryCardData('owl', '🦉'),
    _MemoryCardData('lion', '🦁'),
    _MemoryCardData('fish', '🐠'),
    _MemoryCardData('fox', '🦊'),
    _MemoryCardData('frog', '🐸'),
  ];

  final Set<int> _matched = <int>{};
  int? _firstIndex;
  int _moves = 0;
  int _roundGeneration = 0;
  bool _inputLocked = false;
  bool _isComplete = false;
  bool _completionReported = false;

  bool _isFaceUp(int index) => _matched.contains(index) || _firstIndex == index;

  Future<void> _flipCard(int index) async {
    if (_inputLocked || _isComplete || _matched.contains(index)) return;
    if (_firstIndex == index) return;

    if (_firstIndex == null) {
      setState(() => _firstIndex = index);
      return;
    }

    final firstIndex = _firstIndex!;
    final isMatch = _cards[firstIndex].id == _cards[index].id;
    if (isMatch) {
      var completedNow = false;
      setState(() {
        _moves += 1;
        _matched
          ..add(firstIndex)
          ..add(index);
        _firstIndex = null;
        if (_matched.length == _cards.length) {
          _isComplete = true;
          completedNow = true;
        }
      });
      if (completedNow && !_completionReported) {
        _completionReported = true;
        widget.onCompleted?.call();
      }
      return;
    }

    final generation = _roundGeneration;
    setState(() {
      _moves += 1;
      _inputLocked = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted || generation != _roundGeneration) return;
    setState(() {
      _firstIndex = null;
      _inputLocked = false;
    });
  }

  void _resetRound() {
    setState(() {
      _roundGeneration += 1;
      _matched.clear();
      _firstIndex = null;
      _moves = 0;
      _inputLocked = false;
      _isComplete = false;
      _completionReported = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFE6F8FF), Color(0xFFFFF0DD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _MemoryHeader(onReset: _resetRound),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _MemoryStat(
                      icon: Icons.touch_app_rounded,
                      value: '$_moves',
                      label: _moves == 1 ? 'move' : 'moves',
                      color: const Color(0xFF7257E8),
                    ),
                    const SizedBox(width: 12),
                    _MemoryStat(
                      icon: Icons.favorite_rounded,
                      value: '${_matched.length ~/ 2}/6',
                      label: 'pairs',
                      color: const Color(0xFFFF5D7D),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 760
                        ? 6
                        : constraints.maxWidth >= 500
                        ? 4
                        : 3;
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: GridView.builder(
                          key: const ValueKey<String>('memory-card-grid'),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: _cards.length,
                          itemBuilder: (context, index) {
                            final card = _cards[index];
                            return _MemoryCard(
                              index: index,
                              card: card,
                              faceUp: _isFaceUp(index),
                              matched: _matched.contains(index),
                              enabled: !_inputLocked && !_isComplete,
                              onPressed: () => _flipCard(index),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isComplete
                    ? _MemoryCompletePanel(moves: _moves, onReplay: _resetRound)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoryHeader extends StatelessWidget {
  const _MemoryHeader({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: <Widget>[
          SizedBox.square(
            dimension: 64,
            child: IconButton.filledTonal(
              tooltip: 'Go back',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 30),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Memory Friends',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF244466),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Find every matching pair',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF60758B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox.square(
            dimension: 64,
            child: IconButton.filled(
              key: const ValueKey<String>('memory-reset-button'),
              tooltip: 'Restart cards',
              onPressed: onReset,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF35A7FF),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryStat extends StatelessWidget {
  const _MemoryStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64, minWidth: 126),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x14244166), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 27),
          const SizedBox(width: 9),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF60758B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.index,
    required this.card,
    required this.faceUp,
    required this.matched,
    required this.enabled,
    required this.onPressed,
  });

  final int index;
  final _MemoryCardData card;
  final bool faceUp;
  final bool matched;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: matched
          ? '${card.id} matched'
          : faceUp
          ? card.id
          : 'Hidden card ${index + 1}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey<String>('memory-card-$index'),
          borderRadius: BorderRadius.circular(26),
          onTap: enabled ? onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            decoration: BoxDecoration(
              gradient: faceUp
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Colors.white, Color(0xFFFFF8E8)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Color(0xFF7357E8), Color(0xFF9C78F2)],
                    ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: matched
                    ? const Color(0xFF2DBE88)
                    : Colors.white.withValues(alpha: 0.9),
                width: matched ? 4 : 3,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: (faceUp
                          ? const Color(0xFFFFA928)
                          : const Color(0xFF7257E8))
                      .withValues(alpha: 0.24),
                  blurRadius: 13,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: faceUp
                      ? FittedBox(
                          key: ValueKey<String>('face-${card.id}'),
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              card.emoji,
                              textScaler: TextScaler.noScaling,
                              style: const TextStyle(fontSize: 58),
                            ),
                          ),
                        )
                      : const Icon(
                          key: ValueKey<String>('card-back'),
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                ),
                if (matched)
                  const Positioned(
                    right: 7,
                    top: 7,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF2DBE88),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 21,
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
  }
}

class _MemoryCompletePanel extends StatelessWidget {
  const _MemoryCompletePanel({required this.moves, required this.onReplay});

  final int moves;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'All pairs found in $moves moves',
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF2DBE88), Color(0xFF35A7FF)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x332DBE88), blurRadius: 15),
          ],
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 8),
            const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You found them all!\n$moves moves',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(
              height: 64,
              child: FilledButton.icon(
                onPressed: onReplay,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF17835F),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                icon: const Icon(Icons.replay_rounded, size: 27),
                label: const Text(
                  'Play again',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCardData {
  const _MemoryCardData(this.id, this.emoji);

  final String id;
  final String emoji;
}
