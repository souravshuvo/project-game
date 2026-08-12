import 'package:pocket_observatory_xo/features/tic_tac_toe/ai/balanced_ai_strategy.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/application/game_mode.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/application/tic_tac_toe_ad_service.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/application/tic_tac_toe_controller.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/application/tic_tac_toe_settings.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/application/tic_tac_toe_telemetry.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/data/tic_tac_toe_match_history_store.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/data/tic_tac_toe_settings_store.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/game_score.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/match_format.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/match_record.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/round_outcome.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/tic_tac_toe_engine.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/tic_tac_toe_mark.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('next round in a best-of match clears board and keeps match score', () {
    final controller = _buildController();
    controller.selectMatchFormat(MatchFormat.bestOfThree);
    controller.startGame();

    _playXWin(controller);

    expect(controller.round.outcome.status, RoundStatus.won);
    expect(controller.score.xWins, 1);
    expect(controller.isMatchComplete, isFalse);

    controller.restartRound();

    expect(controller.round.board.availableCells, List.generate(9, (i) => i));
    expect(controller.round.moveCount, 0);
    expect(controller.round.currentMark, TicTacToeMark.o);
    expect(controller.score.xWins, 1);
    expect(controller.score.draws, 0);
  });

  test('vs AI mode makes a deterministic balanced response', () {
    final controller = _buildController();

    controller.selectMode(GameMode.vsAi);
    controller.startGame();
    controller.tapCell(0);

    expect(controller.round.board.cellAt(0), TicTacToeMark.x);
    expect(controller.round.board.cellAt(4), TicTacToeMark.o);
    expect(controller.round.currentMark, TicTacToeMark.x);
    expect(controller.round.moveCount, 2);
  });

  test('vs AI mode records AI win in session score', () {
    final controller = _buildController();

    controller.selectMode(GameMode.vsAi);
    controller.startGame();
    controller.tapCell(0);
    controller.tapCell(1);
    controller.tapCell(3);

    expect(controller.round.outcome.status, RoundStatus.won);
    expect(controller.round.outcome.winner, TicTacToeMark.o);
    expect(controller.score.oWins, 1);
  });

  test('single round saves history and rematch starts a fresh match', () {
    final historyStore = _MemoryMatchHistoryStore();
    final controller = _buildController(historyStore: historyStore);
    controller.startGame();

    _playXWin(controller);

    expect(controller.isMatchComplete, isTrue);
    expect(controller.recentMatches, hasLength(1));
    expect(historyStore.saved, hasLength(1));
    expect(controller.recentMatches.single.winner, TicTacToeMark.x);
    expect(controller.score.xWins, 1);

    controller.restartRound();

    expect(controller.isMatchComplete, isFalse);
    expect(controller.score.xWins, 0);
    expect(controller.round.moveCount, 0);
  });

  test('best of three saves history only after target wins', () {
    final historyStore = _MemoryMatchHistoryStore();
    final controller = _buildController(historyStore: historyStore);

    controller.selectMatchFormat(MatchFormat.bestOfThree);
    controller.startGame();
    _playXWin(controller);

    expect(controller.isMatchComplete, isFalse);
    expect(controller.recentMatches, isEmpty);

    controller.restartRound();
    _playXWin(controller);

    expect(controller.isMatchComplete, isTrue);
    expect(controller.score.xWins, 2);
    expect(controller.recentMatches, hasLength(1));
    expect(controller.recentMatches.single.format, MatchFormat.bestOfThree);
    expect(controller.recentMatches.single.score.xWins, 2);
  });

  test('initial recent match history is capped at ten records', () {
    final records = List.generate(12, _matchRecord);
    final controller = _buildController(initialRecentMatches: records);

    expect(controller.recentMatches, hasLength(10));
    expect(
      controller.recentMatches.first.completedAt,
      records.first.completedAt,
    );
  });

  test('shared preferences history store saves and loads records', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPreferencesTicTacToeMatchHistoryStore();
    final record = _matchRecord(0);

    await store.saveRecentMatches([record]);
    final loaded = await store.loadRecentMatches();

    expect(loaded, hasLength(1));
    expect(loaded.single.format, record.format);
    expect(loaded.single.score.xWins, record.score.xWins);
    expect(loaded.single.winner, record.winner);
  });

  test('invalid tap increments feedback sequence each time', () {
    final controller = _buildController();
    controller.startGame();

    controller.tapCell(0);
    controller.tapCell(0);
    final firstInvalidSequence = controller.invalidTapSequence;
    controller.tapCell(0);

    expect(firstInvalidSequence, 1);
    expect(controller.invalidTapSequence, 2);
    expect(controller.round.moveCount, 1);
  });

  test('score reset clears wins and draws', () {
    final controller = _buildController();
    controller.startGame();

    for (final move in [0, 3, 1, 4, 2]) {
      controller.tapCell(move);
    }
    controller.resetScore();

    expect(controller.score.xWins, 0);
    expect(controller.score.oWins, 0);
    expect(controller.score.draws, 0);
  });

  test('help screen returns to setup when opened before a game', () {
    final controller = _buildController();

    controller.showHelp();
    expect(controller.screen, TicTacToeScreen.help);

    controller.closeHelp();
    expect(controller.screen, TicTacToeScreen.setup);
  });

  test('help screen returns to active game when opened during a round', () {
    final controller = _buildController();

    controller.startGame();
    controller.showHelp();
    expect(controller.screen, TicTacToeScreen.help);

    controller.closeHelp();
    expect(controller.screen, TicTacToeScreen.playing);
    expect(controller.round.moveCount, 0);
  });

  test(
    'help opened from settings returns to settings, then original screen',
    () {
      final controller = _buildController();

      controller.showSettings();
      controller.showHelp();
      controller.closeHelp();
      expect(controller.screen, TicTacToeScreen.settings);

      controller.closeSettings();
      expect(controller.screen, TicTacToeScreen.setup);
    },
  );

  test('settings toggles persist through controller', () {
    final store = _MemorySettingsStore();
    final controller = _buildController(store: store);

    controller.toggleSound(false);
    controller.toggleHaptics(false);

    expect(controller.soundEnabled, isFalse);
    expect(controller.hapticsEnabled, isFalse);
    expect(store.saved.soundEnabled, isFalse);
    expect(store.saved.hapticsEnabled, isFalse);
  });

  test('post-match ad hook runs only when a match is complete', () {
    final adService = _RecordingAdService();
    final controller = _buildController(adService: adService);

    controller.selectMatchFormat(MatchFormat.bestOfThree);
    controller.startGame();
    _playXWin(controller);

    expect(controller.isMatchComplete, isFalse);
    expect(adService.completedMatchCounts, isEmpty);

    controller.restartRound();
    _playXWin(controller);

    expect(controller.isMatchComplete, isTrue);
    expect(adService.completedMatchCounts, [1]);
    expect(adService.safeToShowSnapshots, [true]);
  });

  test('records match and difficulty analytics events', () {
    final telemetry = _RecordingTelemetry();
    final controller = _buildController(telemetry: telemetry);

    controller.selectMode(GameMode.vsAi);
    controller.selectMatchFormat(MatchFormat.bestOfFive);
    controller.startGame();

    expect(
      telemetry.events.map((event) => event.name),
      containsAllInOrder([
        'app_opened',
        'mode_selected',
        'match_format_selected',
        'round_started',
      ]),
    );

    final roundStarted = telemetry.events.firstWhere(
      (event) => event.name == 'round_started',
    );
    expect(roundStarted.parameters['mode'], 'vs_ai');
    expect(roundStarted.parameters['match_format'], 'best_of_five');
    expect(roundStarted.parameters['ai_difficulty'], 'balanced');
  });
}

TicTacToeController _buildController({
  _MemorySettingsStore? store,
  _MemoryMatchHistoryStore? historyStore,
  List<MatchRecord> initialRecentMatches = const [],
  TicTacToeTelemetry telemetry = const NoOpTicTacToeTelemetry(),
  TicTacToeAdService adService = const NoOpTicTacToeAdService(),
}) {
  return TicTacToeController(
    engine: const TicTacToeEngine(),
    aiStrategy: const BalancedAiStrategy(),
    settingsStore: store ?? _MemorySettingsStore(),
    matchHistoryStore: historyStore ?? _MemoryMatchHistoryStore(),
    initialSettings: const TicTacToeSettings.initial(),
    initialRecentMatches: initialRecentMatches,
    telemetry: telemetry,
    adService: adService,
    enableFeedback: false,
    aiDelay: Duration.zero,
  );
}

void _playXWin(TicTacToeController controller) {
  final moves = controller.round.currentMark == TicTacToeMark.x
      ? [0, 3, 1, 4, 2]
      : [3, 0, 4, 1, 6, 2];

  for (final move in moves) {
    controller.tapCell(move);
  }
}

MatchRecord _matchRecord(int index) {
  return MatchRecord(
    completedAt: DateTime(2026, 8, 12, 10, index),
    modeName: GameMode.localTwoPlayer.analyticsName,
    modeLabel: GameMode.localTwoPlayer.label,
    format: MatchFormat.singleRound,
    score: const GameScore(xWins: 1, oWins: 0, draws: 0),
    winner: TicTacToeMark.x,
  );
}

class _MemorySettingsStore implements TicTacToeSettingsStore {
  TicTacToeSettings saved = const TicTacToeSettings.initial();

  @override
  Future<TicTacToeSettings> load() async => saved;

  @override
  Future<void> save(TicTacToeSettings settings) async {
    saved = settings;
  }
}

class _MemoryMatchHistoryStore implements TicTacToeMatchHistoryStore {
  List<MatchRecord> saved = const [];

  @override
  Future<List<MatchRecord>> loadRecentMatches() async => saved;

  @override
  Future<void> saveRecentMatches(List<MatchRecord> records) async {
    saved = records;
  }
}

class _RecordingTelemetry implements TicTacToeTelemetry {
  final events = <TicTacToeTelemetryEvent>[];

  @override
  void track(TicTacToeTelemetryEvent event) {
    events.add(event);
  }
}

class _RecordingAdService implements TicTacToeAdService {
  final completedMatchCounts = <int>[];
  final safeToShowSnapshots = <bool>[];

  @override
  bool get usesTestAds => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> preloadInterstitial() async {}

  @override
  Future<void> onMatchCompleted({
    required int completedMatchesThisSession,
    required AdSafetyCheck canShowNow,
  }) async {
    completedMatchCounts.add(completedMatchesThisSession);
    safeToShowSnapshots.add(canShowNow());
  }

  @override
  void dispose() {}
}
