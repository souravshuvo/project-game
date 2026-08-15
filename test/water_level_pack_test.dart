import 'package:arrow_puzzle_tap_puzzle_games/features/weather_sort/data/local_water_level_pack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('campaign has five complete forecast sets', () {
    expect(localWaterLevelPack, hasLength(50));

    for (var set = 0; set < 5; set++) {
      final levels = localWaterLevelPack.skip(set * 10).take(10).toList();
      expect(levels, hasLength(10));
      expect(levels.every((level) => level.name.trim().isNotEmpty), isTrue);
      expect(levels.every((level) => level.lesson.trim().isNotEmpty), isTrue);
      expect(
        levels.every((level) => level.tubeSymbols.any((tube) => tube.isEmpty)),
        isTrue,
      );
    }
  });

  test('campaign boards and names are unique', () {
    final names = localWaterLevelPack.map((level) => level.name).toSet();
    final boards = localWaterLevelPack
        .map((level) => level.tubeSymbols.join('|'))
        .toSet();

    expect(names, hasLength(localWaterLevelPack.length));
    expect(boards, hasLength(localWaterLevelPack.length));
  });

  test('later forecast sets require at least the earlier move budget', () {
    final clearSkies = localWaterLevelPack.take(10);
    final pressureSystems = localWaterLevelPack.skip(30).take(10);
    final labMastery = localWaterLevelPack.skip(40).take(10);

    final openingMaximum = clearSkies
        .map((level) => level.parMoves)
        .reduce((left, right) => left > right ? left : right);
    final pressureMinimum = pressureSystems
        .map((level) => level.parMoves)
        .reduce((left, right) => left < right ? left : right);
    final masteryMinimum = labMastery
        .map((level) => level.parMoves)
        .reduce((left, right) => left < right ? left : right);

    expect(pressureMinimum, greaterThanOrEqualTo(openingMaximum));
    expect(masteryMinimum, greaterThanOrEqualTo(openingMaximum));
  });
}
