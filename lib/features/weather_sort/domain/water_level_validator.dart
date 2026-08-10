import 'dart:collection';

import 'pour_move.dart';
import 'water_board.dart';
import 'water_level.dart';
import 'water_sort_engine.dart';
import 'weather_essence.dart';

class WaterLevelValidator {
  const WaterLevelValidator({this.maxVisitedStates = 200000});

  final int maxVisitedStates;

  List<String> validate(WaterLevel level) {
    final errors = <String>[];

    if (level.id <= 0) {
      errors.add('Level id must be positive.');
    }
    if (level.name.trim().isEmpty) {
      errors.add('Level name cannot be empty.');
    }
    if (level.capacity <= 0) {
      errors.add('Level capacity must be positive.');
    }
    if (level.parMoves <= 0) {
      errors.add('Level par moves must be positive.');
    }
    if (level.tubeSymbols.length < 3) {
      errors.add('A level needs at least three tubes.');
    }
    if (!level.tubeSymbols.any((symbols) => symbols.isEmpty)) {
      errors.add('A level needs at least one empty helper tube.');
    }

    final WaterBoard board;
    try {
      board = level.toBoard();
    } on FormatException catch (error) {
      errors.add(error.message);
      return errors;
    }

    final counts = _essenceCounts(board);
    if (counts.isEmpty) {
      errors.add('A level needs at least one weather essence.');
    }
    for (final entry in counts.entries) {
      if (entry.value != level.capacity) {
        errors.add(
          '${entry.key.label} appears ${entry.value} times; expected ${level.capacity}.',
        );
      }
    }

    const engine = WaterSortEngine();
    if (engine.isSolved(board)) {
      errors.add('A level cannot start solved.');
    }
    if (engine.validMoves(board).isEmpty) {
      errors.add('A level needs at least one valid first move.');
    }
    if (shortestSolution(level).isEmpty) {
      errors.add('A level must have a validated solution.');
    }

    return errors;
  }

  List<PourMove> shortestSolution(WaterLevel level) {
    final start = level.toBoard();
    const engine = WaterSortEngine();
    final queue = Queue<_SearchNode>()
      ..add(_SearchNode(board: start, path: const []));
    final seen = <String>{_boardKey(start)};

    while (queue.isNotEmpty && seen.length <= maxVisitedStates) {
      final node = queue.removeFirst();
      if (engine.isSolved(node.board)) {
        return node.path;
      }

      for (final move in engine.validMoves(node.board)) {
        final result = engine.pour(node.board, move);
        final nextBoard = result.board;
        final key = _boardKey(nextBoard);
        if (seen.add(key)) {
          queue.add(_SearchNode(board: nextBoard, path: [...node.path, move]));
        }
      }
    }

    return const [];
  }

  Map<WeatherEssence, int> _essenceCounts(WaterBoard board) {
    final counts = <WeatherEssence, int>{};
    for (final tube in board.tubes) {
      for (final layer in tube.layers) {
        counts[layer] = (counts[layer] ?? 0) + 1;
      }
    }

    return counts;
  }

  String _boardKey(WaterBoard board) => board.toSymbolRows().join('|');
}

class _SearchNode {
  const _SearchNode({required this.board, required this.path});

  final WaterBoard board;
  final List<PourMove> path;
}
