enum RunPhase { ready, playing, paused, gameOver }

enum DeathReason {
  none,
  hazard,
  fall;

  String get message {
    return switch (this) {
      DeathReason.none => '',
      DeathReason.hazard => 'A warning spark ended the route.',
      DeathReason.fall => 'The courier slipped below the route.',
    };
  }
}
