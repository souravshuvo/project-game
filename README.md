# Dots and Boxes

Offline production v1 candidate for local two-player Dots and Boxes matches.

## Scope

- Main menu with local two-player matches.
- Board presets: 2x2, 3x3, and 4x4 scoreable boxes.
- Pure Dart move validation, box completion, scoring, and extra-turn rules.
- Pure Dart board scaling and hit testing.
- Flutter `CustomPainter` board with `GestureDetector` tap input.
- Legal-line touch preview and invalid tap feedback.
- No ads or network-backed gameplay in version 1.

## Rule Locks

- Drawing an already drawn line is rejected without changing turn or score.
- A shared line can complete two adjacent boxes and awards both.
- Scoring grants an extra turn; non-scoring moves pass the turn.
- Taps near a line are accepted within tolerance, while ambiguous taps near dot intersections are ignored.

## Validation

Focused tests live in `test/dots_and_boxes_game_test.dart`.

Release signing uses `android/key.properties`, which is intentionally ignored by
git. Copy `android/key.properties.example` to `android/key.properties` and fill
it with upload-keystore values before creating a release build.

## Manual Test

1. Open the app.
2. Choose `2x2`, `3x3`, or `4x4`.
3. Tap `Start Local Match`.
4. Draw lines around boxes.
5. Confirm non-scoring moves switch turns.
6. Confirm completed boxes update score and keep the same player active.
7. Confirm ambiguous taps do not draw the wrong line.
8. Finish the board and confirm the winner or draw banner appears.
9. Use `Restart` or `Play Again` to start a clean match.
