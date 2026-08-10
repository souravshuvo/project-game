import 'dart:math';

import 'package:flutter/material.dart';

import '../domain/game_models.dart';
import '../logic/game_engine.dart';

enum _PlayPhase {
  menu,
  shuffling,
  handoff,
  privateReveal,
  policeReveal,
  accusation,
  roundReveal,
  roundSummary,
  matchSummary,
}

class EmojiChorPoliceApp extends StatefulWidget {
  const EmojiChorPoliceApp({super.key});

  @override
  State<EmojiChorPoliceApp> createState() => _EmojiChorPoliceAppState();
}

class _EmojiChorPoliceAppState extends State<EmojiChorPoliceApp> {
  static const int _totalRounds = 5;

  final GameEngine _engine = GameEngine(random: Random());

  _PlayPhase _phase = _PlayPhase.menu;
  GameMode? _mode;
  List<GamePlayer> _players = const <GamePlayer>[];
  Map<String, GameRole> _assignments = const <String, GameRole>{};
  Map<String, int> _totals = const <String, int>{};
  Map<String, int> _roundPoints = const <String, int>{};
  List<GameRound> _history = const <GameRound>[];
  int _roundNumber = 0;
  int _privatePlayerIndex = 0;
  bool _privateCardVisible = false;
  String? _policePlayerId;
  String? _selectedSuspectId;
  RoundResult? _roundResult;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emoji Chor-Police',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D8C83),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      home: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _buildPhase(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPhase(BuildContext context) {
    switch (_phase) {
      case _PlayPhase.menu:
        return _buildMenu(context);
      case _PlayPhase.shuffling:
        return _buildShuffling();
      case _PlayPhase.handoff:
        return _buildHandoff(context);
      case _PlayPhase.privateReveal:
        return _buildPrivateReveal(context);
      case _PlayPhase.policeReveal:
        return _buildPoliceReveal(context);
      case _PlayPhase.accusation:
        return _buildAccusation(context);
      case _PlayPhase.roundReveal:
        return _buildRoundReveal(context);
      case _PlayPhase.roundSummary:
        return _buildRoundSummary(context);
      case _PlayPhase.matchSummary:
        return _buildMatchSummary(context);
    }
  }

  Widget _buildMenu(BuildContext context) {
    return _ScreenShell(
      key: const ValueKey<String>('menu'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Spacer(),
          Text(
            'Emoji Chor-Police',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Offline secret-role party game',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 32),
          _MenuButton(
            icon: Icons.person,
            label: 'Single Player',
            onPressed: () => _startMatch(GameMode.singlePlayer),
          ),
          const SizedBox(height: 12),
          _MenuButton(
            icon: Icons.group,
            label: 'Pass & Play',
            onPressed: () => _startMatch(GameMode.passAndPlay),
          ),
          const SizedBox(height: 24),
          _InfoPanel(
            child: Text(
              'Offline 5-round MVP. No ads, login, chat, shop, or online play.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildShuffling() {
    return _ScreenShell(
      key: const ValueKey<String>('shuffling'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '🎴',
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontSize: 84),
          ),
          const SizedBox(height: 16),
          Text(
            'Shuffling secret cards...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildHandoff(BuildContext context) {
    final player = _players[_privatePlayerIndex];

    return _ScreenShell(
      key: ValueKey<String>('handoff-${player.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RoundHeader(
            title: 'Pass to ${player.name}',
            subtitle: 'Round $_roundNumber of $_totalRounds',
          ),
          const SizedBox(height: 20),
          _InfoPanel(
            child: Text(
              'Hand the phone to ${player.name}. Their card stays hidden until they confirm.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          const _RoleCard(
            role: null,
            title: 'Secret card',
            color: Colors.white,
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => setState(() => _phase = _PlayPhase.privateReveal),
            icon: const Icon(Icons.person_pin_circle),
            label: Text('I am ${player.name}'),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: _resetToMenu, child: const Text('Main menu')),
        ],
      ),
    );
  }

  Widget _buildPrivateReveal(BuildContext context) {
    final player = _players[_privatePlayerIndex];
    final role = _assignments[player.id]!;
    final isPassAndPlay = _mode == GameMode.passAndPlay;

    return _ScreenShell(
      key: ValueKey<String>('private-${player.id}-$_privateCardVisible'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RoundHeader(
            title: isPassAndPlay
                ? "${player.name}'s private card"
                : 'Your card',
            subtitle: 'Round $_roundNumber of $_totalRounds',
          ),
          const SizedBox(height: 20),
          _InfoPanel(
            child: Text(
              isPassAndPlay
                  ? 'Only ${player.name} should look now. Hide this card before giving the phone back.'
                  : 'Your role is secret until the final reveal.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          _RoleCard(
            role: _privateCardVisible ? role : null,
            title: _privateCardVisible ? role.label : 'Secret card',
            color: _privateCardVisible ? _roleColor(role) : Colors.white,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _privateCardVisible
                ? _finishPrivateView
                : () => setState(() => _privateCardVisible = true),
            icon: Icon(
              _privateCardVisible ? Icons.visibility_off : Icons.visibility,
            ),
            label: Text(
              _privateCardVisible ? 'Hide and continue' : 'Reveal card',
            ),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: _resetToMenu, child: const Text('Main menu')),
        ],
      ),
    );
  }

  Widget _buildPoliceReveal(BuildContext context) {
    final police = _playerById(_policePlayerId!);
    final isBotPolice = police.isBot;

    return _ScreenShell(
      key: const ValueKey<String>('police-reveal'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RoundHeader(
            title: 'Police reveal',
            subtitle: '${police.name} is the Police',
          ),
          const SizedBox(height: 18),
          _PlayerGrid(
            players: _players,
            itemBuilder: (player) {
              final isPolice = player.id == _policePlayerId;
              return _PlayerSeatCard(
                playerName: player.name,
                role: isPolice ? GameRole.police : null,
                color: isPolice ? _roleColor(GameRole.police) : Colors.white,
              );
            },
          ),
          const SizedBox(height: 20),
          _InfoPanel(
            child: Text(
              isBotPolice
                  ? '${police.name} will choose one hidden player at random and cannot see secret roles.'
                  : 'The Police must choose one hidden player. Other roles stay secret until reveal.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isBotPolice
                ? _submitBotAccusation
                : () => setState(() => _phase = _PlayPhase.accusation),
            icon: Icon(isBotPolice ? Icons.smart_toy : Icons.search),
            label: Text(
              isBotPolice
                  ? 'Let ${police.name} guess randomly'
                  : 'Choose suspect',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccusation(BuildContext context) {
    final police = _playerById(_policePlayerId!);
    final suspects = _players
        .where((player) => player.id != _policePlayerId)
        .toList(growable: false);

    return _ScreenShell(
      key: const ValueKey<String>('accusation'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RoundHeader(
            title: '${police.name}, find the Thief',
            subtitle: 'Choose exactly one suspect',
          ),
          const SizedBox(height: 16),
          for (final suspect in suspects) ...<Widget>[
            _SuspectButton(
              name: suspect.name,
              selected: suspect.id == _selectedSuspectId,
              onPressed: () => setState(() => _selectedSuspectId = suspect.id),
            ),
            const SizedBox(height: 10),
          ],
          const Spacer(),
          FilledButton.icon(
            onPressed: _selectedSuspectId == null
                ? null
                : () => _confirmAccusation(_selectedSuspectId!),
            icon: const Icon(Icons.gavel),
            label: Text(
              _selectedSuspectId == null
                  ? 'Select a suspect'
                  : 'Accuse ${_playerById(_selectedSuspectId!).name}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundReveal(BuildContext context) {
    final result = _roundResult!;
    final accused = _playerById(result.accusedPlayerId);
    final thief = _playerById(result.thiefPlayerId);

    return _ScreenShell(
      key: const ValueKey<String>('round-reveal'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RoundHeader(
            title: result.wasCorrect ? 'Thief caught' : 'Thief escaped',
            subtitle: result.wasCorrect
                ? '${accused.name} was the Thief'
                : '${accused.name} was accused, but ${thief.name} was the Thief',
          ),
          const SizedBox(height: 18),
          _PlayerGrid(
            players: _players,
            itemBuilder: (player) {
              final role = _assignments[player.id]!;
              return _PlayerSeatCard(
                playerName: player.name,
                role: role,
                color: _roleColor(role),
              );
            },
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => setState(() => _phase = _PlayPhase.roundSummary),
            icon: const Icon(Icons.leaderboard),
            label: const Text('View scores'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundSummary(BuildContext context) {
    final result = _roundResult!;

    return _ScreenShell(
      key: const ValueKey<String>('round-summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RoundHeader(
            title: 'Round $_roundNumber scores',
            subtitle: result.wasCorrect
                ? 'Police guessed correctly'
                : 'Police guessed wrong',
          ),
          const SizedBox(height: 16),
          _InfoPanel(
            child: Text(
              'Police: ${_playerById(result.policePlayerId).name}\n'
              'Accused: ${_playerById(result.accusedPlayerId).name}\n'
              'Thief: ${_playerById(result.thiefPlayerId).name}',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          for (final player in _players)
            _ScoreRow(
              name: player.name,
              role: _assignments[player.id]!,
              points: _roundPoints[player.id] ?? 0,
              total: _totals[player.id] ?? 0,
            ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _roundNumber >= _totalRounds
                ? () => setState(() => _phase = _PlayPhase.matchSummary)
                : _startNextRound,
            icon: Icon(
              _roundNumber >= _totalRounds
                  ? Icons.emoji_events
                  : Icons.arrow_forward,
            ),
            label: Text(
              _roundNumber >= _totalRounds ? 'Finish match' : 'Next round',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchSummary(BuildContext context) {
    final ranked = List<GamePlayer>.of(_players)
      ..sort((a, b) => (_totals[b.id] ?? 0).compareTo(_totals[a.id] ?? 0));
    final winner = ranked.first;

    return _ScreenShell(
      key: const ValueKey<String>('match-summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RoundHeader(
            title: '${winner.name} wins',
            subtitle: 'Final score: ${_totals[winner.id]}',
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < ranked.length; i++)
            _RankingRow(
              rank: i + 1,
              name: ranked[i].name,
              score: _totals[ranked[i].id] ?? 0,
              roleSummary: _roleSummaryFor(ranked[i].id),
            ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _startMatch(_mode ?? GameMode.singlePlayer),
            icon: const Icon(Icons.refresh),
            label: const Text('Play again'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _resetToMenu,
            icon: const Icon(Icons.home),
            label: const Text('Main menu'),
          ),
        ],
      ),
    );
  }

  Future<void> _startMatch(GameMode mode) async {
    final players = mode == GameMode.singlePlayer
        ? const <GamePlayer>[
            GamePlayer(id: 'p1', name: 'You', seatIndex: 0, isBot: false),
            GamePlayer(id: 'p2', name: 'Bot Mira', seatIndex: 1, isBot: true),
            GamePlayer(id: 'p3', name: 'Bot Nilu', seatIndex: 2, isBot: true),
            GamePlayer(id: 'p4', name: 'Bot Rafi', seatIndex: 3, isBot: true),
          ]
        : const <GamePlayer>[
            GamePlayer(id: 'p1', name: 'Player 1', seatIndex: 0, isBot: false),
            GamePlayer(id: 'p2', name: 'Player 2', seatIndex: 1, isBot: false),
            GamePlayer(id: 'p3', name: 'Player 3', seatIndex: 2, isBot: false),
            GamePlayer(id: 'p4', name: 'Player 4', seatIndex: 3, isBot: false),
          ];

    setState(() {
      _mode = mode;
      _players = players;
      _totals = <String, int>{for (final player in players) player.id: 0};
      _history = <GameRound>[];
      _roundNumber = 0;
    });
    await _startNextRound();
  }

  Future<void> _startNextRound() async {
    setState(() {
      _phase = _PlayPhase.shuffling;
      _assignments = const <String, GameRole>{};
      _roundPoints = const <String, int>{};
      _selectedSuspectId = null;
      _roundResult = null;
      _privateCardVisible = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }

    final assignments = _engine.assignRoles(_players);
    final policePlayerId = _engine.findPlayerWithRole(
      assignments,
      GameRole.police,
    );

    setState(() {
      _roundNumber += 1;
      _assignments = assignments;
      _policePlayerId = policePlayerId;
      _privatePlayerIndex = 0;
      _phase = _mode == GameMode.passAndPlay
          ? _PlayPhase.handoff
          : _PlayPhase.privateReveal;
    });
  }

  void _finishPrivateView() {
    if (_mode == GameMode.passAndPlay &&
        _privatePlayerIndex < _players.length - 1) {
      setState(() {
        _privatePlayerIndex += 1;
        _privateCardVisible = false;
        _phase = _PlayPhase.handoff;
      });
      return;
    }

    setState(() {
      _privateCardVisible = false;
      _phase = _PlayPhase.policeReveal;
    });
  }

  void _submitAccusation(String accusedPlayerId) {
    final accusation = Accusation(
      policePlayerId: _policePlayerId!,
      accusedPlayerId: accusedPlayerId,
    );
    final roundScore = _engine.scoreRound(
      players: _players,
      assignments: _assignments,
      currentTotals: _totals,
      accusation: accusation,
    );
    final nextTotals = <String, int>{};
    final roundPoints = <String, int>{};

    for (final entry in roundScore.entries) {
      nextTotals[entry.playerId] = entry.totalAfterRound;
      roundPoints[entry.playerId] = entry.points;
    }

    final round = GameRound(
      roundNumber: _roundNumber,
      assignments: Map<String, GameRole>.unmodifiable(_assignments),
      accusation: accusation,
      result: roundScore.result,
      scoreEntries: List<ScoreEntry>.unmodifiable(roundScore.entries),
    );

    setState(() {
      _roundResult = roundScore.result;
      _totals = nextTotals;
      _roundPoints = roundPoints;
      _history = <GameRound>[..._history, round];
      _phase = _PlayPhase.roundReveal;
    });
  }

  Future<void> _confirmAccusation(String accusedPlayerId) async {
    final suspect = _playerById(accusedPlayerId);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm accusation'),
          content: Text(
            'Accuse ${suspect.name} as the Thief? This cannot be changed.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Accuse'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }
    _submitAccusation(accusedPlayerId);
  }

  void _submitBotAccusation() {
    final accusedPlayerId = _engine.chooseBotSuspect(
      players: _players,
      policePlayerId: _policePlayerId!,
    );
    _submitAccusation(accusedPlayerId);
  }

  void _resetToMenu() {
    setState(() {
      _phase = _PlayPhase.menu;
      _mode = null;
      _players = const <GamePlayer>[];
      _assignments = const <String, GameRole>{};
      _totals = const <String, int>{};
      _roundPoints = const <String, int>{};
      _history = const <GameRound>[];
      _roundNumber = 0;
      _privatePlayerIndex = 0;
      _privateCardVisible = false;
      _policePlayerId = null;
      _selectedSuspectId = null;
      _roundResult = null;
    });
  }

  GamePlayer _playerById(String playerId) {
    return _players.singleWhere((player) => player.id == playerId);
  }

  Color _roleColor(GameRole role) {
    switch (role) {
      case GameRole.king:
        return const Color(0xFFFFC857);
      case GameRole.minister:
        return const Color(0xFF8E7DBE);
      case GameRole.police:
        return const Color(0xFF4EA5D9);
      case GameRole.thief:
        return const Color(0xFF3D405B);
    }
  }

  String _roleSummaryFor(String playerId) {
    int count(GameRole role) {
      return _history
          .where((round) => round.assignments[playerId] == role)
          .length;
    }

    return '👑 ${count(GameRole.king)}  🧙‍♂️ ${count(GameRole.minister)}  👮‍♂️ ${count(GameRole.police)}  🥷 ${count(GameRole.thief)}';
  }
}

class _ScreenShell extends StatelessWidget {
  const _ScreenShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: max(0, constraints.maxHeight - 40),
                ),
                child: IntrinsicHeight(child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoundHeader extends StatelessWidget {
  const _RoundHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
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
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(label),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.title,
    required this.color,
  });

  final GameRole? role;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final foreground = role == GameRole.thief ? Colors.white : Colors.black87;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: Card(
        key: ValueKey<String>(role?.id ?? 'hidden'),
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: role == null ? const Color(0xFFCBD5E1) : Colors.transparent,
          ),
        ),
        child: SizedBox(
          height: 220,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(role?.emoji ?? '🎴', style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerGrid extends StatelessWidget {
  const _PlayerGrid({required this.players, required this.itemBuilder});

  final List<GamePlayer> players;
  final Widget Function(GamePlayer player) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.05,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[for (final player in players) itemBuilder(player)],
    );
  }
}

class _PlayerSeatCard extends StatelessWidget {
  const _PlayerSeatCard({
    required this.playerName,
    required this.role,
    required this.color,
  });

  final String playerName;
  final GameRole? role;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final foreground = role == GameRole.thief ? Colors.white : Colors.black87;

    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: role == null ? const Color(0xFFCBD5E1) : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(role?.emoji ?? '🎴', style: const TextStyle(fontSize: 42)),
            const SizedBox(height: 8),
            Text(
              playerName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              role?.label ?? 'Hidden',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuspectButton extends StatelessWidget {
  const _SuspectButton({
    required this.name,
    required this.selected,
    required this.onPressed,
  });

  final String name;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      ),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(name),
      ),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        backgroundColor: selected ? const Color(0xFFE0F2FE) : Colors.white,
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.name,
    required this.role,
    required this.points,
    required this.total,
  });

  final String name;
  final GameRole role;
  final int points;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Text(role.emoji, style: const TextStyle(fontSize: 28)),
        title: Text(name),
        subtitle: Text(role.label),
        trailing: Text(
          '+$points\n$total total',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({
    required this.rank,
    required this.name,
    required this.score,
    required this.roleSummary,
  });

  final int rank;
  final String name;
  final int score;
  final String roleSummary;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(child: Text('$rank')),
        title: Text('$name - $score'),
        subtitle: Text(roleSummary),
      ),
    );
  }
}
