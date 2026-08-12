# Tik Tak Toe Preview Video Shot List

Approved length target: 24-27 seconds.

No final video should be rendered from this package without real captured gameplay clips.

## Timeline

| Time | Source clip | Real app footage required | On-screen caption | Edit notes |
| --- | --- | --- | --- | --- |
| 0.0-3.0s | `raw/01-setup.mp4` | Setup screen showing `Tik Tak Toe`, `Two Players`, `Vs AI`, `Match Format`, and `Start Round`. | Pick a quick X/O match | Start on live UI. No logo-only intro. |
| 3.0-8.0s | `raw/02-local-round.mp4` | Local two-player round. Tap an open cell as X, then show O turn state after a real move. | Pass-and-play rounds | Show tap feedback and turn banner clearly. |
| 8.0-13.0s | `raw/03-vs-ai.mp4` | Vs AI round after the player places a real move and the balanced AI responds. | One balanced AI opponent | Do not imply multiple AI levels. |
| 13.0-18.0s | `raw/04-result.mp4` | Real win or draw result with score update and result panel visible. | Clear results | Board, result text, score, and rematch controls must be real. |
| 18.0-23.0s | `raw/05-history-or-settings.mp4` | Recent Matches after a real completed match. If history is not visible, use Settings with Sound, Vibration, and How to Play. | Local history and controls | Show only implemented settings or real history. |
| 23.0-26.5s | `raw/06-title-return.mp4` | Setup/title screen or a short hold on real app UI. | Tik Tak Toe | No install CTA, ranking, award, price, or review claim. |

## Capture Steps

1. Prepare the current app build with package `com.childhood.tiktaktoe`.
2. Disable or avoid ad display for capture. If an ad appears, discard that take.
3. Fresh launch and capture the setup screen for `raw/01-setup.mp4`.
4. Start `Two Players`, place real moves, and capture turn feedback for `raw/02-local-round.mp4`.
5. Return to setup, choose `Vs AI`, start a round, place a move, wait for the balanced AI response, and capture `raw/03-vs-ai.mp4`.
6. Complete a real win or draw and capture the result panel with updated score for `raw/04-result.mp4`.
7. Return to setup after at least one completed match and capture Recent Matches for `raw/05-history-or-settings.mp4`; use Settings only if history cannot be captured cleanly.
8. Capture a final short setup/title hold for `raw/06-title-return.mp4`.
9. Trim each clip to the timing table. Do not modify gameplay state.

## Editing Notes

- Use straight cuts or very short crossfades only.
- Keep captions in a consistent bottom-safe area that does not cover the board, turn banner, score, or result controls.
- Keep caption text on screen long enough to read.
- Use app tap/result sounds if they are clean.
- Use only licensed or original background music.
- Keep music low enough that tap/result sounds remain clear.
- Do not include a device frame, app store badge, Google Play badge, award seal, review stars, or download call to action.

## Required Real Evidence

The final edit should be reviewable against the raw captures. Keep raw footage files in a local production folder until Play asset QA is complete.
