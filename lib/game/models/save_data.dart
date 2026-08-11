class SaveData {
  const SaveData({this.bestScore = 0});

  final int bestScore;

  SaveData copyWith({int? bestScore}) {
    return SaveData(bestScore: bestScore ?? this.bestScore);
  }
}
