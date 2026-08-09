class PuzzleLevel {
  const PuzzleLevel({
    required this.id,
    required this.name,
    required this.rows,
    required this.lesson,
  });

  final int id;
  final String name;
  final List<String> rows;
  final String lesson;
}
