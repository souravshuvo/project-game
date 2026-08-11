# Signal Workshop

A small offline Flutter match puzzle game.

## Version 1

- 20 offline 6x6 levels
- Five abstract tile types: Pulse, Coil, Lens, Node, Spark
- Adjacent swap match-3 rules
- Deterministic removal, gravity, refill, cascades, and reshuffle handling
- Collection goals, move limits, win, lose, restart, next level, and level select
- Local progress for unlocked and completed levels
- No ads, boosters, blockers, shop, map progression, login, or cloud sync

## Manual Test

1. Refresh dependencies if your local Flutter metadata is stale: `flutter pub get`
2. Run the app: `flutter run`
3. Swap adjacent tiles that create a row or column of 3+ matching tiles.
4. Confirm valid swaps spend one move and invalid swaps do not.
5. Watch matched tiles clear, tiles fall, and new tiles refill.
6. Use restart to reload the original level.
7. Complete the Pulse and Coil goals to win, or run out of moves to lose.
8. Continue through the next level and confirm progress unlocks are saved.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
