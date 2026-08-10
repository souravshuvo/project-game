import 'dart:math' as math;

import 'pour_move.dart';
import 'pour_result.dart';
import 'water_board.dart';
import 'water_level.dart';
import 'weather_essence.dart';

class WaterSortEngine {
  const WaterSortEngine();

  WaterBoard parse(WaterLevel level) => level.toBoard();

  bool canPour(WaterBoard board, PourMove move) {
    return pour(board, move).isValid;
  }

  PourResult pour(WaterBoard board, PourMove move) {
    if (!board.containsTube(move.sourceIndex) ||
        !board.containsTube(move.destinationIndex)) {
      return PourResult.invalid(
        board: board,
        reason: PourInvalidReason.outOfRange,
      );
    }

    if (move.sourceIndex == move.destinationIndex) {
      return PourResult.invalid(
        board: board,
        reason: PourInvalidReason.sameTube,
      );
    }

    final source = board.tubeAt(move.sourceIndex);
    final destination = board.tubeAt(move.destinationIndex);
    final sourceTop = source.top;

    if (sourceTop == null) {
      return PourResult.invalid(
        board: board,
        reason: PourInvalidReason.sourceEmpty,
      );
    }

    if (destination.isFull) {
      return PourResult.invalid(
        board: board,
        reason: PourInvalidReason.destinationFull,
      );
    }

    final destinationTop = destination.top;
    if (destinationTop != null && destinationTop != sourceTop) {
      return PourResult.invalid(
        board: board,
        reason: PourInvalidReason.colorMismatch,
      );
    }

    final layersMoved = math.min(source.topGroupSize, destination.freeSlots);
    if (layersMoved <= 0) {
      return PourResult.invalid(
        board: board,
        reason: PourInvalidReason.noTransfer,
      );
    }

    final pouredLayers = List<WeatherEssence>.filled(layersMoved, sourceTop);
    final nextSource = source.removeFromTop(layersMoved);
    final nextDestination = destination.addToTop(pouredLayers);
    final nextTubes = board.tubes.toList(growable: false);
    nextTubes[move.sourceIndex] = nextSource;
    nextTubes[move.destinationIndex] = nextDestination;

    return PourResult.valid(
      board: WaterBoard(nextTubes),
      layersMoved: layersMoved,
      essence: sourceTop,
    );
  }

  List<PourMove> validMoves(WaterBoard board) {
    final moves = <PourMove>[];
    for (var source = 0; source < board.tubeCount; source++) {
      for (var destination = 0; destination < board.tubeCount; destination++) {
        final move = PourMove(
          sourceIndex: source,
          destinationIndex: destination,
        );
        if (canPour(board, move)) {
          moves.add(move);
        }
      }
    }

    return moves;
  }

  bool isSolved(WaterBoard board) {
    final completedEssences = <WeatherEssence>{};

    for (final tube in board.tubes) {
      if (tube.isEmpty) {
        continue;
      }
      if (!tube.isUniform) {
        return false;
      }

      final essence = tube.top;
      if (essence == null || !completedEssences.add(essence)) {
        return false;
      }
    }

    return true;
  }
}
