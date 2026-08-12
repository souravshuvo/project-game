import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/game_content.dart';
import '../domain/game_models.dart';
import '../domain/game_progress.dart';
import '../logic/game_ad_service.dart';
import '../logic/game_analytics.dart';
import '../logic/game_engine.dart';
import '../logic/game_progress_store.dart';

const String _humanPlayerId = 'p1';
const String _secretCardEmoji = '🎴';

String _shortDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

enum _PlayPhase {
  menu,
  help,
  settings,
  progress,
  shuffling,
  rolePeek,
  policeReveal,
  accusation,
  roundReveal,
  roundSummary,
  matchSummary,
}

class EmojiChorPoliceApp extends StatefulWidget {
  const EmojiChorPoliceApp({super.key, this.analytics, this.adService});

  final GameAnalytics? analytics;
  final GameAdService? adService;

  @override
  State<EmojiChorPoliceApp> createState() => _EmojiChorPoliceAppState();
}

class _EmojiChorPoliceAppState extends State<EmojiChorPoliceApp> {
  static const List<GamePlayer> _defaultPlayers = <GamePlayer>[
    GamePlayer(id: _humanPlayerId, name: 'You', seatIndex: 0, isBot: false),
    GamePlayer(id: 'p2', name: 'Bot Mira', seatIndex: 1, isBot: true),
    GamePlayer(id: 'p3', name: 'Bot Nilu', seatIndex: 2, isBot: true),
    GamePlayer(id: 'p4', name: 'Bot Rafi', seatIndex: 3, isBot: true),
  ];

  final GameEngine _engine = GameEngine(random: Random());
  final GameProgressStore _progressStore =
      const MethodChannelGameProgressStore();
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late final GameAnalytics _analytics =
      widget.analytics ?? GameAnalytics.localOnly();
  late final GameAdService _adService =
      widget.adService ?? GameAdService.disabled(analytics: _analytics);

  _PlayPhase _phase = _PlayPhase.menu;
  MatchPreset _selectedPreset = matchPresets.first;
  MatchPreset _activePreset = matchPresets.first;
  BotGuessStyle _selectedBotGuessStyle = BotGuessStyle.fairRandom;
  BotGuessStyle _activeBotGuessStyle = BotGuessStyle.fairRandom;
  List<GamePlayer> _players = const <GamePlayer>[];
  Map<String, GameRole> _assignments = const <String, GameRole>{};
  Map<String, int> _totals = const <String, int>{};
  Map<String, int> _roundPoints = const <String, int>{};
  List<GameRound> _history = const <GameRound>[];
  int _roundNumber = 0;
  bool _humanRoleVisible = false;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  GameProgress _progress = GameProgress.empty();
  List<ChallengeDefinition> _lastUnlockedChallenges =
      const <ChallengeDefinition>[];
  _PlayPhase? _returnPhaseAfterSettings;
  String? _policePlayerId;
  String? _selectedSuspectId;
  RoundResult? _roundResult;

  int get _totalRounds => _activePreset.rounds;

  @override
  void initState() {
    super.initState();
    unawaited(_loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Emoji Chor-Police',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D8C83),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F6),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: _buildPhase(context),
                ),
              ),
              if (_shouldShowBannerAd)
                GameBannerAdSlot(
                  adService: _adService,
                  analytics: _analytics,
                  placement: 'phase_${_phase.name}',
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _shouldShowBannerAd {
    switch (_phase) {
      case _PlayPhase.menu:
      case _PlayPhase.help:
      case _PlayPhase.settings:
      case _PlayPhase.progress:
      case _PlayPhase.matchSummary:
        return _adService.canRequestBanner;
      case _PlayPhase.shuffling:
      case _PlayPhase.rolePeek:
      case _PlayPhase.policeReveal:
      case _PlayPhase.accusation:
      case _PlayPhase.roundReveal:
      case _PlayPhase.roundSummary:
        return false;
    }
  }

  Widget _buildPhase(BuildContext context) {
    switch (_phase) {
      case _PlayPhase.menu:
        return _buildMenu(context);
      case _PlayPhase.help:
        return _buildHelp(context);
      case _PlayPhase.settings:
        return _buildSettings(context);
      case _PlayPhase.progress:
        return _buildProgress(context);
      case _PlayPhase.shuffling:
        return _buildShuffling(context);
      case _PlayPhase.rolePeek:
        return _buildRolePeek(context);
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
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'One phone. One player. Three bots.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 28),
          _RolePreviewRow(colorForRole: _roleColor),
          const SizedBox(height: 28),
          _MenuButton(
            icon: Icons.play_arrow_rounded,
            label: 'Start match',
            onPressed: _handleStartMatch,
          ),
          const SizedBox(height: 14),
          _InfoPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Match setup',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                _ChoicePills<MatchPreset>(
                  values: matchPresets,
                  selected: _selectedPreset,
                  labelFor: (preset) => '${preset.label} ${preset.rounds}',
                  onSelected: _selectPreset,
                ),
                const SizedBox(height: 10),
                Text(
                  _selectedPreset.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Bot style',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                _ChoicePills<BotGuessStyle>(
                  values: BotGuessStyle.values,
                  selected: _selectedBotGuessStyle,
                  labelFor: (style) => style.label,
                  onSelected: _selectBotGuessStyle,
                ),
                const SizedBox(height: 10),
                Text(
                  _selectedBotGuessStyle.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _openProgress,
                icon: const Icon(Icons.emoji_events_rounded),
                label: const Text('Progress'),
              ),
              OutlinedButton.icon(
                onPressed: _openHelp,
                icon: const Icon(Icons.help_outline_rounded),
                label: const Text('How to play'),
              ),
              OutlinedButton.icon(
                onPressed: _openSettings,
                icon: const Icon(Icons.settings_rounded),
                label: const Text('Settings'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoPanel(
            child: Text(
              'Reveal only your own card. Bots keep roles hidden and never inspect the current Thief.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHelp(BuildContext context) {
    return _ScreenShell(
      key: const ValueKey<String>('help'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PageTitle(
            title: 'How to play',
            subtitle: 'Reveal your role, wait for Police, then see who scores.',
          ),
          const SizedBox(height: 18),
          _HelpStep(
            icon: Icons.style_rounded,
            title: '1. Secret roles',
            body: 'You get one hidden role. The three bots stay hidden.',
          ),
          _HelpStep(
            icon: Icons.local_police_rounded,
            title: '2. Police reveals',
            body:
                'If you are Police, choose one bot. If a bot is Police, it guesses randomly.',
          ),
          _HelpStep(
            icon: Icons.emoji_events_rounded,
            title: '3. Scores',
            body:
                'King gets 1000, Minister gets 800. Police gets 500 only if the Thief is caught. Thief gets 500 only if they escape.',
          ),
          _HelpStep(
            icon: Icons.tune_rounded,
            title: '4. Presets and bots',
            body:
                'Choose 5, 7, or 10 rounds. Bot styles use only public scores and earlier revealed history.',
          ),
          const SizedBox(height: 18),
          _RoleScoreTable(colorForRole: _roleColor),
          const Spacer(),
          FilledButton.icon(
            onPressed: _handleStartMatch,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start match'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _goHome,
            icon: const Icon(Icons.home_rounded),
            label: const Text('Main menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    return _ScreenShell(
      key: const ValueKey<String>('progress'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _PageTitle(
            title: 'Progress',
            subtitle: 'Local match history and challenge goals.',
          ),
          const SizedBox(height: 18),
          _ProgressStats(progress: _progress),
          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Score history',
            trailing: '${_progress.history.length}/$maxSavedMatchHistory',
          ),
          const SizedBox(height: 10),
          if (_progress.history.isEmpty)
            const _InfoPanel(
              child: Text(
                'Finish a match to save your first score history entry.',
                textAlign: TextAlign.center,
              ),
            )
          else
            for (final entry in _progress.history.take(5)) ...<Widget>[
              _HistoryCard(entry: entry),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 10),
          _SectionTitle(
            title: 'Challenges',
            trailing:
                '${_progress.unlockedChallengeCount}/${gameChallenges.length}',
          ),
          const SizedBox(height: 10),
          for (final challenge in gameChallenges) ...<Widget>[
            _ChallengeTile(challenge: challenge, progress: _progress),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _handleStartMatch,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start match'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _goHome,
            icon: const Icon(Icons.home_rounded),
            label: const Text('Main menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    final isReturningToGame = _returnPhaseAfterSettings != null;

    return _ScreenShell(
      key: const ValueKey<String>('settings'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _PageTitle(
            title: 'Settings',
            subtitle: 'Feedback is lightweight and can be turned off anytime.',
          ),
          const SizedBox(height: 18),
          _SettingsSwitch(
            icon: Icons.volume_up_rounded,
            title: 'System sound',
            subtitle: 'Small tap and result sounds.',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              _showMessage(value ? 'Sound on' : 'Sound off');
              if (value) {
                _playTapFeedback();
              }
            },
          ),
          const SizedBox(height: 10),
          _SettingsSwitch(
            icon: Icons.vibration_rounded,
            title: 'Haptics',
            subtitle: 'Gentle vibration for reveal, selection, and results.',
            value: _hapticsEnabled,
            onChanged: (value) {
              setState(() => _hapticsEnabled = value);
              _showMessage(value ? 'Haptics on' : 'Haptics off');
              if (value) {
                _playTapFeedback();
              }
            },
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _playScoreFeedback,
            icon: const Icon(Icons.notifications_active_rounded),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Text('Test feedback'),
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: isReturningToGame ? _closeSettings : _goHome,
            icon: Icon(
              isReturningToGame ? Icons.arrow_back_rounded : Icons.home_rounded,
            ),
            label: Text(isReturningToGame ? 'Back to game' : 'Main menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildShuffling(BuildContext context) {
    return _ScreenShell(
      key: const ValueKey<String>('shuffling'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Spacer(),
          _GameHeader(
            roundNumber: min(_roundNumber + 1, _totalRounds),
            totalRounds: _totalRounds,
            title: 'Shuffling cards',
            subtitle: 'A new secret role is being dealt.',
          ),
          const SizedBox(height: 28),
          const _ShufflePreview(),
          const SizedBox(height: 28),
          const LinearProgressIndicator(),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildRolePeek(BuildContext context) {
    final humanRole = _assignments[_humanPlayerId]!;

    return _ScreenShell(
      key: ValueKey<String>('role-peek-$_humanRoleVisible'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _GameHeader(
            roundNumber: _roundNumber,
            totalRounds: _totalRounds,
            title: 'Your secret card',
            subtitle: 'Only your role is shown on this phone.',
          ),
          const SizedBox(height: 14),
          _ScoreStrip(players: _players, totals: _totals),
          const SizedBox(height: 20),
          _RoleCard(
            role: _humanRoleVisible ? humanRole : null,
            title: _humanRoleVisible ? humanRole.label : 'Tap to reveal',
            color: _humanRoleVisible ? _roleColor(humanRole) : Colors.white,
            footer: _humanRoleVisible
                ? _roleHint(humanRole)
                : 'Bots stay hidden. No one else opens a card.',
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _humanRoleVisible
                ? _continueFromRolePeek
                : _revealHumanRole,
            icon: Icon(
              _humanRoleVisible
                  ? Icons.arrow_forward_rounded
                  : Icons.visibility_rounded,
            ),
            label: Text(_humanRoleVisible ? 'Continue' : 'Reveal my card'),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: _goHome, child: const Text('Main menu')),
        ],
      ),
    );
  }

  Widget _buildPoliceReveal(BuildContext context) {
    final police = _playerById(_policePlayerId!);
    final isHumanPolice = police.id == _humanPlayerId;

    return _ScreenShell(
      key: const ValueKey<String>('police-reveal'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _GameHeader(
            roundNumber: _roundNumber,
            totalRounds: _totalRounds,
            title: 'Police reveal',
            subtitle: '${police.name} is the Police.',
          ),
          const SizedBox(height: 14),
          _ScoreStrip(
            players: _players,
            totals: _totals,
            activePlayerId: police.id,
          ),
          const SizedBox(height: 10),
          _QuickActions(
            onRestart: _handleStartMatch,
            onSettings: _openSettings,
            onHome: _goHome,
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
                badge: isPolice ? 'Police' : 'Hidden',
                highlighted: isPolice,
                footer: '${_totals[player.id] ?? 0} pts',
              );
            },
          ),
          const SizedBox(height: 18),
          _InfoPanel(
            child: Text(
              isHumanPolice
                  ? 'Choose one bot as the suspected Thief.'
                  : '${police.name} uses ${_activeBotGuessStyle.label}. Bots cannot see hidden roles.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isHumanPolice ? _openAccusation : _submitBotAccusation,
            icon: Icon(
              isHumanPolice ? Icons.search_rounded : Icons.smart_toy_rounded,
            ),
            label: Text(isHumanPolice ? 'Choose suspect' : 'Let bot guess'),
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
          _GameHeader(
            roundNumber: _roundNumber,
            totalRounds: _totalRounds,
            title: 'Find the Thief',
            subtitle: '${police.name} must accuse one hidden player.',
          ),
          const SizedBox(height: 14),
          _ScoreStrip(
            players: _players,
            totals: _totals,
            activePlayerId: police.id,
          ),
          const SizedBox(height: 10),
          _QuickActions(
            onRestart: _handleStartMatch,
            onSettings: _openSettings,
            onHome: _goHome,
          ),
          const SizedBox(height: 16),
          for (final suspect in suspects) ...<Widget>[
            _SuspectButton(
              name: suspect.name,
              score: _totals[suspect.id] ?? 0,
              selected: suspect.id == _selectedSuspectId,
              onPressed: () => _selectSuspect(suspect.id),
            ),
            const SizedBox(height: 10),
          ],
          const Spacer(),
          FilledButton.icon(
            onPressed: _selectedSuspectId == null
                ? _warnNoSuspectSelected
                : () => _confirmAccusation(_selectedSuspectId!),
            icon: const Icon(Icons.gavel_rounded),
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
          _GameHeader(
            roundNumber: _roundNumber,
            totalRounds: _totalRounds,
            title: result.wasCorrect ? 'Thief caught' : 'Thief escaped',
            subtitle: result.wasCorrect
                ? '${accused.name} was the Thief.'
                : '${accused.name} was accused, but ${thief.name} was the Thief.',
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
                badge: _revealBadgeFor(player.id, result),
                highlighted:
                    player.id == result.accusedPlayerId ||
                    player.id == result.thiefPlayerId,
                footer: '+${_roundPoints[player.id] ?? 0} pts',
              );
            },
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _showRoundSummary,
            icon: const Icon(Icons.leaderboard_rounded),
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
          _GameHeader(
            roundNumber: _roundNumber,
            totalRounds: _totalRounds,
            title: 'Round $_roundNumber scores',
            subtitle: result.wasCorrect
                ? 'Police guessed correctly.'
                : 'Police guessed wrong.',
          ),
          const SizedBox(height: 14),
          _InfoPanel(
            child: Text(
              'Police: ${_playerById(result.policePlayerId).name}\n'
              'Accused: ${_playerById(result.accusedPlayerId).name}\n'
              'Thief: ${_playerById(result.thiefPlayerId).name}',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          _QuickActions(
            onRestart: _handleStartMatch,
            onSettings: _openSettings,
            onHome: _goHome,
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
                ? _finishMatch
                : _handleNextRound,
            icon: Icon(
              _roundNumber >= _totalRounds
                  ? Icons.emoji_events_rounded
                  : Icons.arrow_forward_rounded,
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
          _GameHeader(
            roundNumber: _totalRounds,
            totalRounds: _totalRounds,
            title: '${winner.name} wins',
            subtitle:
                '${_activePreset.label} match - final score: ${_totals[winner.id]}',
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < ranked.length; i++)
            _RankingRow(
              rank: i + 1,
              name: ranked[i].name,
              score: _totals[ranked[i].id] ?? 0,
              roleSummary: _roleSummaryFor(ranked[i].id),
            ),
          const SizedBox(height: 14),
          _InfoPanel(
            child: Text(
              'Saved locally. You unlocked ${_lastUnlockedChallenges.length} new challenge${_lastUnlockedChallenges.length == 1 ? '' : 's'}.',
              textAlign: TextAlign.center,
            ),
          ),
          if (_lastUnlockedChallenges.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            for (final challenge in _lastUnlockedChallenges.take(4))
              _UnlockedChallengeCard(challenge: challenge),
          ],
          const Spacer(),
          FilledButton.icon(
            onPressed: _handleStartMatch,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Play again'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _goHome,
            icon: const Icon(Icons.home_rounded),
            label: const Text('Main menu'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartMatch() async {
    _playTapFeedback();
    if (_phase == _PlayPhase.matchSummary) {
      await _adService.maybeShowInterstitialAtSessionBreak(
        placement: 'match_summary_play_again',
      );
    }
    await _startMatch();
  }

  Future<void> _handleNextRound() async {
    _playTapFeedback();
    await _startNextRound();
  }

  void _revealHumanRole() {
    _playRevealFeedback();
    _logEvent(
      'role_revealed',
      parameters: <String, Object?>{
        'round_number': _roundNumber,
        'human_role': _assignments[_humanPlayerId]?.id,
      },
    );
    setState(() => _humanRoleVisible = true);
  }

  void _continueFromRolePeek() {
    _playTapFeedback();
    _logEvent(
      'police_reveal',
      parameters: <String, Object?>{
        'round_number': _roundNumber,
        'police_is_human': _policePlayerId == _humanPlayerId,
      },
    );
    setState(() => _phase = _PlayPhase.policeReveal);
  }

  void _openAccusation() {
    _playTapFeedback();
    setState(() => _phase = _PlayPhase.accusation);
  }

  void _selectSuspect(String playerId) {
    _playValidFeedback();
    setState(() => _selectedSuspectId = playerId);
  }

  void _warnNoSuspectSelected() {
    _playInvalidFeedback();
    _showMessage('Choose a suspect first.');
  }

  void _selectPreset(MatchPreset preset) {
    _playValidFeedback();
    _logEvent(
      'match_preset_selected',
      parameters: <String, Object?>{
        'preset_id': preset.id,
        'rounds': preset.rounds,
      },
    );
    setState(() => _selectedPreset = preset);
  }

  void _selectBotGuessStyle(BotGuessStyle style) {
    _playValidFeedback();
    _logEvent(
      'bot_style_selected',
      parameters: <String, Object?>{'bot_style': style.id},
    );
    setState(() => _selectedBotGuessStyle = style);
  }

  void _showRoundSummary() {
    _playTapFeedback();
    setState(() => _phase = _PlayPhase.roundSummary);
  }

  void _finishMatch() {
    final topScore = _totals.values.fold<int>(0, max);
    final humanWon = (_totals[_humanPlayerId] ?? 0) >= topScore;
    final progressUpdate = recordCompletedMatch(
      current: _progress,
      players: _players,
      rounds: _history,
      totals: _totals,
      humanPlayerId: _humanPlayerId,
      preset: _activePreset,
      botGuessStyle: _activeBotGuessStyle,
    );

    if (humanWon) {
      _playWinFeedback();
    } else {
      _playLossFeedback();
    }
    _adService.registerMatchCompleted();
    _logEvent(
      'match_finish',
      parameters: <String, Object?>{
        'preset_id': _activePreset.id,
        'rounds': _history.length,
        'bot_style': _activeBotGuessStyle.id,
        'human_score': _totals[_humanPlayerId] ?? 0,
        'human_won': humanWon,
        'unlocked_count': progressUpdate.newUnlocks.length,
      },
    );
    for (final challenge in progressUpdate.newUnlocks) {
      _logEvent(
        'challenge_unlocked',
        parameters: <String, Object?>{'challenge_id': challenge.id},
      );
    }
    setState(() {
      _progress = progressUpdate.progress;
      _lastUnlockedChallenges = progressUpdate.newUnlocks;
      _phase = _PlayPhase.matchSummary;
    });
    unawaited(_progressStore.save(progressUpdate.progress));
  }

  void _openSettings() {
    _playTapFeedback();
    _logEvent(
      'settings_open',
      parameters: <String, Object?>{'phase': _phase.name},
    );
    setState(() {
      _returnPhaseAfterSettings = _phase == _PlayPhase.menu ? null : _phase;
      _phase = _PlayPhase.settings;
    });
  }

  void _openHelp() {
    _playTapFeedback();
    _logEvent('help_open');
    setState(() => _phase = _PlayPhase.help);
  }

  void _openProgress() {
    _playTapFeedback();
    _logEvent(
      'progress_open',
      parameters: <String, Object?>{
        'matches_played': _progress.matchesPlayed,
        'challenges_unlocked': _progress.unlockedChallengeCount,
      },
    );
    setState(() => _phase = _PlayPhase.progress);
  }

  void _closeSettings() {
    _playTapFeedback();
    setState(() {
      _phase = _returnPhaseAfterSettings ?? _PlayPhase.menu;
      _returnPhaseAfterSettings = null;
    });
  }

  void _goHome() {
    _playTapFeedback();
    _resetToMenu();
  }

  void _playTapFeedback() {
    _playSystemSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.selectionClick);
  }

  void _playRevealFeedback() {
    _playSystemSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.lightImpact);
  }

  void _playValidFeedback() {
    _playSystemSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.lightImpact);
  }

  void _playInvalidFeedback() {
    _playSystemSound(SystemSoundType.alert);
    _playHaptic(HapticFeedback.mediumImpact);
  }

  void _playScoreFeedback({bool showMessage = true}) {
    _playSystemSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.mediumImpact);
    if (showMessage) {
      _showMessage('Feedback is working.');
    }
  }

  void _playWinFeedback() {
    _playSystemSound(SystemSoundType.click);
    _playHaptic(HapticFeedback.heavyImpact);
  }

  void _playLossFeedback() {
    _playSystemSound(SystemSoundType.alert);
    _playHaptic(HapticFeedback.mediumImpact);
  }

  void _playRoundOutcomeFeedback(RoundResult result) {
    final humanRole = _assignments[_humanPlayerId];
    final humanScoredWell =
        humanRole == GameRole.king ||
        humanRole == GameRole.minister ||
        (humanRole == GameRole.police && result.wasCorrect) ||
        (humanRole == GameRole.thief && !result.wasCorrect);

    if (humanScoredWell) {
      _playScoreFeedback(showMessage: false);
    } else {
      _playLossFeedback();
    }
  }

  void _playSystemSound(SystemSoundType type) {
    if (!_soundEnabled) {
      return;
    }
    unawaited(SystemSound.play(type).catchError(_ignoreFeedbackError));
  }

  void _playHaptic(Future<void> Function() feedback) {
    if (!_hapticsEnabled) {
      return;
    }
    unawaited(feedback().catchError(_ignoreFeedbackError));
  }

  void _ignoreFeedbackError(Object error, StackTrace stackTrace) {}

  void _showMessage(String message) {
    final messenger = _messengerKey.currentState;
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  void _logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) {
    unawaited(_analytics.logEvent(name, parameters: parameters));
  }

  Future<void> _loadProgress() async {
    final progress = await _progressStore.load();
    if (!mounted) {
      return;
    }
    setState(() => _progress = progress);
    _logEvent(
      'app_start',
      parameters: <String, Object?>{
        'matches_played': progress.matchesPlayed,
        'rounds_played': progress.roundsPlayed,
        'challenges_unlocked': progress.unlockedChallengeCount,
      },
    );
  }

  Future<void> _startMatch() async {
    _logEvent(
      'match_start',
      parameters: <String, Object?>{
        'preset_id': _selectedPreset.id,
        'rounds': _selectedPreset.rounds,
        'bot_style': _selectedBotGuessStyle.id,
      },
    );
    setState(() {
      _activePreset = _selectedPreset;
      _activeBotGuessStyle = _selectedBotGuessStyle;
      _players = _defaultPlayers;
      _totals = <String, int>{
        for (final player in _defaultPlayers) player.id: 0,
      };
      _history = <GameRound>[];
      _roundNumber = 0;
      _returnPhaseAfterSettings = null;
      _lastUnlockedChallenges = const <ChallengeDefinition>[];
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
      _humanRoleVisible = false;
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
      _phase = _PlayPhase.rolePeek;
    });
    _logEvent(
      'round_start',
      parameters: <String, Object?>{
        'round_number': _roundNumber,
        'rounds': _totalRounds,
        'preset_id': _activePreset.id,
        'bot_style': _activeBotGuessStyle.id,
        'human_role': assignments[_humanPlayerId]?.id,
      },
    );
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

    _playRoundOutcomeFeedback(roundScore.result);
    _logEvent(
      'round_finish',
      parameters: <String, Object?>{
        'round_number': _roundNumber,
        'preset_id': _activePreset.id,
        'bot_style': _activeBotGuessStyle.id,
        'police_is_human': _policePlayerId == _humanPlayerId,
        'was_correct': roundScore.result.wasCorrect,
        'human_role': _assignments[_humanPlayerId]?.id,
        'human_points': roundPoints[_humanPlayerId] ?? 0,
      },
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
              onPressed: () {
                _playTapFeedback();
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _playValidFeedback();
                Navigator.of(context).pop(true);
              },
              child: const Text('Accuse'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }
    _logEvent(
      'human_accusation_submitted',
      parameters: <String, Object?>{
        'round_number': _roundNumber,
        'suspect_id': accusedPlayerId,
      },
    );
    _submitAccusation(accusedPlayerId);
  }

  void _submitBotAccusation() {
    _playValidFeedback();
    final accusedPlayerId = _engine.chooseBotSuspect(
      players: _players,
      policePlayerId: _policePlayerId!,
      style: _activeBotGuessStyle,
      currentTotals: _totals,
      history: _history,
    );
    _logEvent(
      'bot_accusation_submitted',
      parameters: <String, Object?>{
        'bot_style': _activeBotGuessStyle.id,
        'round_number': _roundNumber,
      },
    );
    _submitAccusation(accusedPlayerId);
  }

  void _resetToMenu() {
    setState(() {
      _phase = _PlayPhase.menu;
      _players = const <GamePlayer>[];
      _assignments = const <String, GameRole>{};
      _totals = const <String, int>{};
      _roundPoints = const <String, int>{};
      _history = const <GameRound>[];
      _roundNumber = 0;
      _humanRoleVisible = false;
      _returnPhaseAfterSettings = null;
      _lastUnlockedChallenges = const <ChallengeDefinition>[];
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

  String _roleHint(GameRole role) {
    switch (role) {
      case GameRole.king:
        return 'Scores 1000 points after reveal.';
      case GameRole.minister:
        return 'Scores 800 points after reveal.';
      case GameRole.police:
        return 'Find the Thief to score 500 points.';
      case GameRole.thief:
        return 'Escape the Police guess to score 500 points.';
    }
  }

  String _revealBadgeFor(String playerId, RoundResult result) {
    if (playerId == result.thiefPlayerId && result.wasCorrect) {
      return 'Caught';
    }
    if (playerId == result.thiefPlayerId) {
      return 'Escaped';
    }
    if (playerId == result.accusedPlayerId) {
      return 'Accused';
    }
    if (playerId == result.policePlayerId) {
      return 'Police';
    }
    return 'Revealed';
  }

  String _roleSummaryFor(String playerId) {
    int count(GameRole role) {
      return _history
          .where((round) => round.assignments[playerId] == role)
          .length;
    }

    return '${GameRole.king.emoji} ${count(GameRole.king)}  '
        '${GameRole.minister.emoji} ${count(GameRole.minister)}  '
        '${GameRole.police.emoji} ${count(GameRole.police)}  '
        '${GameRole.thief.emoji} ${count(GameRole.thief)}';
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

class _PageTitle extends StatelessWidget {
  const _PageTitle({required this.title, required this.subtitle});

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
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
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
      padding: const EdgeInsets.only(bottom: 10),
      child: _InfoPanel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: const Color(0xFF256B62)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoicePills<T> extends StatelessWidget {
  const _ChoicePills({
    required this.values,
    required this.selected,
    required this.labelFor,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final value in values)
          ChoiceChip(
            label: Text(labelFor(value)),
            selected: value == selected,
            onSelected: (_) => onSelected(value),
          ),
      ],
    );
  }
}

class _ProgressStats extends StatelessWidget {
  const _ProgressStats({required this.progress});

  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _StatTile(
          label: 'Matches',
          value: '${progress.matchesPlayed}',
          icon: Icons.sports_esports_rounded,
        ),
        _StatTile(
          label: 'Wins',
          value: '${progress.matchesWon}',
          icon: Icons.emoji_events_rounded,
        ),
        _StatTile(
          label: 'Best',
          value: '${progress.bestMatchScore}',
          icon: Icons.trending_up_rounded,
        ),
        _StatTile(
          label: 'Challenges',
          value: '${progress.unlockedChallengeCount}/${gameChallenges.length}',
          icon: Icons.task_alt_rounded,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: _InfoPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: const Color(0xFF256B62)),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        _SmallBadge(label: trailing, dark: false),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});

  final MatchHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.history_rounded, color: Color(0xFF256B62)),
        title: Text(
          '${entry.presetLabel} - ${entry.humanScore} pts',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${_shortDate(entry.completedAt)} - Rank #${entry.humanRank} - Winner: ${entry.winnerName}\n'
          '${entry.botStyleLabel} bots - Police ${entry.policeCorrectGuesses}/${entry.policeAttempts}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({required this.challenge, required this.progress});

  final ChallengeDefinition challenge;
  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    final current = challenge.currentValue(progress);
    final unlocked =
        progress.unlockedChallengeIds.contains(challenge.id) ||
        challenge.isUnlocked(progress);
    final value = challenge.target == 0
        ? 1.0
        : (current / challenge.target).clamp(0.0, 1.0).toDouble();

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: unlocked ? const Color(0xFF2D8C83) : const Color(0xFFDDE6E4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              unlocked
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: unlocked ? const Color(0xFF0F766E) : Colors.black45,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    challenge.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(challenge.description),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE8EFED),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${min(current, challenge.target)}/${challenge.target}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnlockedChallengeCard extends StatelessWidget {
  const _UnlockedChallengeCard({required this.challenge});

  final ChallengeDefinition challenge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _InfoPanel(
        child: Row(
          children: <Widget>[
            const Icon(Icons.emoji_events_rounded, color: Color(0xFFB7791F)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    challenge.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(challenge.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleScoreTable extends StatelessWidget {
  const _RoleScoreTable({required this.colorForRole});

  final Color Function(GameRole role) colorForRole;

  @override
  Widget build(BuildContext context) {
    return _InfoPanel(
      child: Column(
        children: <Widget>[
          for (final role in GameRole.values)
            _RoleScoreLine(role: role, color: colorForRole(role)),
        ],
      ),
    );
  }
}

class _RoleScoreLine extends StatelessWidget {
  const _RoleScoreLine({required this.role, required this.color});

  final GameRole role;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scoring = switch (role) {
      GameRole.police => '500 if correct',
      GameRole.thief => '500 if escapes',
      _ => '${role.maxPoints} points',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: Text(role.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              role.label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Text(scoring, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _InfoPanel(
      child: Row(
        children: <Widget>[
          Icon(icon, color: const Color(0xFF256B62)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onRestart,
    required this.onSettings,
    required this.onHome,
  });

  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        OutlinedButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Restart'),
        ),
        OutlinedButton.icon(
          onPressed: onSettings,
          icon: const Icon(Icons.settings_rounded, size: 18),
          label: const Text('Settings'),
        ),
        OutlinedButton.icon(
          onPressed: onHome,
          icon: const Icon(Icons.home_rounded, size: 18),
          label: const Text('Home'),
        ),
      ],
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.roundNumber,
    required this.totalRounds,
    required this.title,
    required this.subtitle,
  });

  final int roundNumber;
  final int totalRounds;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _StatusChip(label: 'Solo match', icon: Icons.person_rounded),
            _StatusChip(
              label: 'Round $roundNumber/$totalRounds',
              icon: Icons.flag_rounded,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD9E5E2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: const Color(0xFF256B62)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ScoreStrip extends StatelessWidget {
  const _ScoreStrip({
    required this.players,
    required this.totals,
    this.activePlayerId,
  });

  final List<GamePlayer> players;
  final Map<String, int> totals;
  final String? activePlayerId;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final player in players)
          DecoratedBox(
            decoration: BoxDecoration(
              color: player.id == activePlayerId
                  ? const Color(0xFFDFF7F0)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: player.id == activePlayerId
                    ? const Color(0xFF2D8C83)
                    : const Color(0xFFDDE6E4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                '${player.name}: ${totals[player.id] ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
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
        border: Border.all(color: const Color(0xFFDDE6E4)),
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

class _RolePreviewRow extends StatelessWidget {
  const _RolePreviewRow({required this.colorForRole});

  final Color Function(GameRole role) colorForRole;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final role in GameRole.values) ...<Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 0.82,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorForRole(role),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(role.emoji, style: const TextStyle(fontSize: 34)),
                ),
              ),
            ),
          ),
          if (role != GameRole.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _ShufflePreview extends StatelessWidget {
  const _ShufflePreview();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _MiniSecretCard(
              angle: -0.12 + (0.08 * value),
              offset: Offset(-22 + (22 * value), 10 * (1 - value)),
            ),
            const SizedBox(width: 8),
            _MiniSecretCard(
              angle: 0.06 - (0.05 * value),
              offset: Offset(-8 + (8 * value), -8 * (1 - value)),
            ),
            const SizedBox(width: 8),
            _MiniSecretCard(
              angle: -0.04 + (0.06 * value),
              offset: Offset(8 - (8 * value), -6 * (1 - value)),
            ),
            const SizedBox(width: 8),
            _MiniSecretCard(
              angle: 0.12 - (0.08 * value),
              offset: Offset(22 - (22 * value), 10 * (1 - value)),
            ),
          ],
        );
      },
    );
  }
}

class _MiniSecretCard extends StatelessWidget {
  const _MiniSecretCard({required this.angle, this.offset = Offset.zero});

  final double angle;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDE6E4)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                blurRadius: 12,
                color: Color(0x1F000000),
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const SizedBox(
            width: 62,
            height: 86,
            child: Center(
              child: Text(_secretCardEmoji, style: TextStyle(fontSize: 32)),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.title,
    required this.color,
    required this.footer,
  });

  final GameRole? role;
  final String title;
  final Color color;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final foreground = role == GameRole.thief ? Colors.white : Colors.black87;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
      child: Card(
        key: ValueKey<String>(role?.id ?? 'hidden'),
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: role == null ? const Color(0xFFD4E0DE) : Colors.transparent,
          ),
        ),
        child: SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  role?.emoji ?? _secretCardEmoji,
                  style: const TextStyle(fontSize: 78),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  footer,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: foreground.withValues(alpha: 0.78)),
                ),
              ],
            ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 460;

        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          childAspectRatio: isWide ? 0.72 : 1.02,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[for (final player in players) itemBuilder(player)],
        );
      },
    );
  }
}

class _PlayerSeatCard extends StatelessWidget {
  const _PlayerSeatCard({
    required this.playerName,
    required this.role,
    required this.color,
    required this.badge,
    required this.footer,
    this.highlighted = false,
  });

  final String playerName;
  final GameRole? role;
  final Color color;
  final String badge;
  final String footer;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final foreground = role == GameRole.thief ? Colors.white : Colors.black87;

    return AnimatedScale(
      scale: highlighted ? 1.02 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            width: highlighted ? 2 : 1,
            color: highlighted
                ? const Color(0xFF0F766E)
                : const Color(0xFFD4E0DE),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: _SmallBadge(label: badge, dark: role == GameRole.thief),
              ),
              const Spacer(),
              Text(
                role?.emoji ?? _secretCardEmoji,
                style: const TextStyle(fontSize: 42),
              ),
              const SizedBox(height: 8),
              Text(
                playerName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role?.label ?? 'Hidden',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: foreground),
              ),
              const SizedBox(height: 6),
              Text(
                footer,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label, required this.dark});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? Colors.white24 : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: dark ? Colors.white : Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SuspectButton extends StatelessWidget {
  const _SuspectButton({
    required this.name,
    required this.score,
    required this.selected,
    required this.onPressed,
  });

  final String name;
  final int score;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        backgroundColor: selected ? const Color(0xFFDFF7F0) : Colors.white,
        side: BorderSide(
          color: selected ? const Color(0xFF0F766E) : const Color(0xFFD4E0DE),
          width: selected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: <Widget>[
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text('$score pts'),
          ],
        ),
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
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(role.label),
        trailing: Text(
          '+$points\n$total total',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w800),
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
