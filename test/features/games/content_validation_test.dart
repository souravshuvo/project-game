import 'package:flutter_test/flutter_test.dart';
import 'package:rapid_jump/features/games/creative/balloon_pop_game_screen.dart';
import 'package:rapid_jump/features/games/creative/drawing_game_screen.dart';
import 'package:rapid_jump/features/games/creative/memory_match_game_screen.dart';
import 'package:rapid_jump/features/games/creative/shape_match_game_screen.dart';
import 'package:rapid_jump/features/games/game_catalog.dart';
import 'package:rapid_jump/features/games/logic/animal_finder_game_screen.dart';
import 'package:rapid_jump/features/games/logic/color_sort_game_screen.dart';
import 'package:rapid_jump/features/games/logic/counting_game_screen.dart';
import 'package:rapid_jump/features/games/logic/pattern_puzzle_game_screen.dart';
import 'package:rapid_jump/features/games/tracing/letter_tracing_game_screen.dart';
import 'package:rapid_jump/features/games/tracing/number_tracing_game_screen.dart';
import 'package:rapid_jump/features/tracing/domain/trace_definition.dart';

void main() {
  test('game catalog keeps ten unique production games', () {
    expect(kidsGameCatalog, hasLength(10));
    expect(
      kidsGameCatalog.map((game) => game.id).toSet(),
      hasLength(kidsGameCatalog.length),
    );
  });

  test('production v1 content counts meet KidsLand release target', () {
    expect(LetterTracingGameScreen.contentCount, 26);
    expect(NumberTracingGameScreen.contentCount, 10);
    expect(DrawingGameScreen.contentCount, greaterThanOrEqualTo(16));
    expect(MemoryMatchGameScreen.contentCount, greaterThanOrEqualTo(6));
    expect(BalloonPopGameScreen.contentCount, greaterThanOrEqualTo(5));
    expect(ShapeMatchGameScreen.contentCount, greaterThanOrEqualTo(10));
    expect(CountingGameScreen.contentCount, greaterThanOrEqualTo(10));
    expect(ColorSortGameScreen.contentCount, greaterThanOrEqualTo(10));
    expect(AnimalFinderGameScreen.contentCount, greaterThanOrEqualTo(10));
    expect(PatternPuzzleGameScreen.contentCount, greaterThanOrEqualTo(10));
  });

  test('letter and number tracing entries have valid unique geometry', () {
    _expectTraceEntriesValid(
      LetterTracingGameScreen.entries.map((entry) => entry.definition),
    );
    _expectTraceEntriesValid(
      NumberTracingGameScreen.entries.map((entry) => entry.definition),
    );

    expect(
      LetterTracingGameScreen.entries.map((entry) => entry.id).toSet(),
      hasLength(26),
    );
    expect(
      NumberTracingGameScreen.entries.map((entry) => entry.id).toSet(),
      hasLength(10),
    );
  });
}

void _expectTraceEntriesValid(Iterable<TraceDefinition> definitions) {
  for (final definition in definitions) {
    expect(definition.symbol.trim(), isNotEmpty);
    expect(definition.strokes, isNotEmpty);
    expect(
      definition.strokes.map((stroke) => stroke.id).toSet(),
      hasLength(definition.strokes.length),
    );

    for (final stroke in definition.strokes) {
      expect(stroke.checkpoints.length, greaterThanOrEqualTo(2));
      for (final checkpoint in stroke.checkpoints) {
        expect(checkpoint.point.x, inInclusiveRange(0, 1));
        expect(checkpoint.point.y, inInclusiveRange(0, 1));
      }
    }
  }
}
