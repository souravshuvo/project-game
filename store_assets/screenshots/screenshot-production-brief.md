# Dots and Boxes Screenshot Production Brief

This brief is for Google Play phone screenshots for `Dots and Boxes: Board Game`.
No final screenshot images are included here because no real gameplay captures
were available in the repository at the time this brief was created.

## Truthfulness Rules

- Use real app UI from the current build only.
- Do not fake board states, scores, captures, bot moves, or results.
- Do not show ads in screenshots.
- Do not show unavailable features such as online play, rankings, tournaments,
  shop, hints, undo, login, cloud sync, rewards, or persistent progress.
- Keep all overlay text short and away from the board, score strip, status
  message, and result buttons.

## Export Specs

- Device type: phone.
- Orientation: portrait.
- Target size: 1080 x 1920.
- Format: 24-bit PNG or JPEG.
- Alpha: none.
- Minimum set: 3 real gameplay screenshots.
- Recommended set: 6 real gameplay screenshots.

## Screenshot Set

| File name | Real capture state | Overlay copy | Alt text |
| --- | --- | --- | --- |
| 01-draw-first-line.png | Fresh 4x4 local match with empty board, score strip, and Player 1 active. | Draw the first line | Empty 4x4 dots and boxes board with Player 1 ready to draw a line. |
| 02-take-turns.png | Local two-player midgame with both blue and red lines visible. | Take turns on one device | Local match board with blue and red lines, scores, and current turn visible. |
| 03-close-boxes.png | Box capture moment with a claimed box highlighted. | Close boxes to score | A completed box is claimed on the board while the score updates. |
| 04-keep-turn.png | Scoring move where the same player remains active after capture. | Score and keep turn | A captured box is shown with the same player still active after scoring. |
| 05-practice-bots.png | Player vs Bot match in progress with bot mode header visible. | Practice against bots | Player vs Bot match with board, scores, and bot difficulty shown. |
| 06-final-score.png | Finished match with result banner, final score, Play Again, and Menu buttons. | Final score, quick rematch | Game-over result banner showing winner or draw, final score, Play Again and Menu buttons. |

## Manual Capture Steps

1. Launch the current app build.
2. Use a clean device state with no notification clutter.
3. Capture portrait screenshots at 1080 x 1920 or another Play-compatible 9:16
   size.
4. Capture the six states listed above from real gameplay.
5. If using overlay text, apply it after capture using a clean, readable
   sans-serif typeface.
6. Keep overlay text within the top or bottom safe area and outside active
   gameplay UI.
7. Export as 24-bit PNG or JPEG without alpha.

## Capture Notes

- For the capture moment, play a 4x4 local match until one box can be completed.
- For the extra-turn moment, capture immediately after a scoring move while the
  same player remains active.
- For the bot screenshot, use `Vs Bot` with either Casual or Tactical selected.
- For the result screenshot, use any truthful winner or draw produced by real
  gameplay.

## QA Checklist

- Screenshot shows the current app UI.
- Board, dots, lines, boxes, scores, and turn state are readable.
- Text does not overlap the board, HUD, status card, or result buttons.
- No fake score, fake rating, fake award, fake download count, or fake review.
- No unavailable feature appears in the image or overlay copy.
- No store badge, device frame, hand, or non-Android device is shown.
- Image is not blurry, stretched, skewed, rotated, or cropped awkwardly.
- File dimensions and format are Play-compatible.
- Alt text is 140 characters or less.

## Remaining Risks

- Real screenshots still need to be captured from the running app.
- Final screenshot files still need visual QA after capture and overlay export.
- If app UI changes before release, this brief must be rechecked against the
  final build.
