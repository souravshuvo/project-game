import 'package:pocket_observatory_xo/features/tic_tac_toe/ai/balanced_ai_strategy.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/application/game_mode.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/application/tic_tac_toe_controller.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/application/tic_tac_toe_settings.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/data/tic_tac_toe_settings_store.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/round_outcome.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/tic_tac_toe_engine.dart';
import 'package:pocket_observatory_xo/features/tic_tac_toe/domain/tic_tac_toe_mark.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restart clears board and keeps current session score', () {
    final controller = _buildController();
    controller.startGame();

    for (final move in [0, 3, 1, 4, 2]) {
      controller.tapCell(move);
    }

    expect(controller.round.outcome.status, RoundStatus.won);
    expect(controller.score.xWins, 1);

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
}

TicTacToeController _buildController({_MemorySettingsStore? store}) {
  return TicTacToeController(
    engine: const TicTacToeEngine(),
    aiStrategy: const BalancedAiStrategy(),
    settingsStore: store ?? _MemorySettingsStore(),
    initialSettings: const TicTacToeSettings.initial(),
    enableFeedback: false,
    aiDelay: Duration.zero,
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
