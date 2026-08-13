import 'vector2.dart';

enum GameFeedbackKind {
  runStarted,
  foodCollected,
  brightFoodCollected,
  botCrashed,
  playerDied,
}

class GameFeedbackEvent {
  const GameFeedbackEvent({
    required this.id,
    required this.kind,
    required this.position,
    this.scoreDelta = 0,
  });

  final int id;
  final GameFeedbackKind kind;
  final Vec2 position;
  final int scoreDelta;
}
