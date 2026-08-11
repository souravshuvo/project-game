import 'level_goal.dart';

class PuzzleLevel {
  const PuzzleLevel({
    required this.id,
    required this.name,
    required this.rows,
    required this.moveLimit,
    required this.seed,
    required this.goals,
  });

  final int id;
  final String name;
  final List<String> rows;
  final int moveLimit;
  final int seed;
  final List<LevelGoal> goals;

  int get width => rows.first.length;

  int get height => rows.length;
}
