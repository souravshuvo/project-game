# Tik Tak Toe Screenshot Production Brief

Status: production brief only. Final screenshot PNG/JPEG files were not created in this pass because the repository does not contain real current Tik Tak Toe screenshots, and emulator/device capture was not explicitly approved for this prompt.

Do not upload the existing PNG files in this folder. They show the previous Arrow Puzzle app, not Tik Tak Toe gameplay.

## Export Target

- Device type: phone
- Orientation: portrait
- Recommended size: 1080 x 1920 or higher
- Play-compatible format: JPEG or 24-bit PNG without alpha
- Text overlays: optional, short, readable, and outside active board controls
- Screenshot source: captured current app UI only

## Approved Screenshot Set

| File | Real app state to capture | Overlay text | Alt text |
| --- | --- | --- | --- |
| `01-setup.png` | Setup screen showing `Tik Tak Toe`, `Two Players`, `Vs AI`, `Match Format`, and `Start Round`. | Choose a quick X/O match | Tik Tak Toe setup screen with two-player, AI, and match format choices. |
| `02-local-round.png` | Local two-player round after real moves have placed both X and O, with turn banner and score visible. | Pass-and-play on one device | Tic tac toe board showing a local two-player round with the current turn and score. |
| `03-vs-ai.png` | Vs AI round after a real player move and the balanced AI response have both appeared. | Face a balanced AI | Tic tac toe board in AI mode with X and O moves on a cosmic grid. |
| `04-result.png` | Result state after a real win or draw, with updated score and restart/rematch controls visible. | Clear results, fast rematch | Match result panel with score, winner or draw message, and rematch controls. |
| `05-recent-matches.png` | Setup screen after at least one real completed match, showing Recent Matches. If history cannot be shown, use Settings with Sound, Vibration, and How to Play. | Recent matches stay local | Recent match history or settings screen showing local progress and sound controls. |

## Capture Requirements

- Capture from package `com.childhood.tiktaktoe`.
- Use the current app build only.
- Complete real rounds before capturing result or history states.
- Do not edit board marks, scores, winners, history rows, ads, or UI states into screenshots.
- Do not show unavailable features: online multiplayer, leaderboard, shop, skins, login, cloud sync, rewards, or multiple AI difficulties.
- Do not show ads unless the final release requires ad disclosure in screenshots; if shown, capture only a real natural post-match placement.
- Hide notification content and avoid distracting status bar states before final upload.

## Manual Capture Script Notes

The existing `tool/capture_store_screenshots.ps1` is only a starting point. Before using it for final assets, verify it captures all five approved states above and does not overwrite this brief with invalid or partial screenshots.

Required manual flow:

1. Fresh launch: capture setup.
2. Start `Two Players`: place real X and O moves, then capture active round.
3. Return to setup, select `Vs AI`, start round, place a move, wait for AI, then capture.
4. Complete a real win or draw, then capture result panel and updated score.
5. Return to setup after a completed match and capture Recent Matches.

## Overlay Template

- Canvas: 1080 x 1920.
- Use the real screenshot as the full-screen base.
- Place overlay copy in a high-contrast top or bottom band that does not cover the board, score, turn banner, or action buttons.
- Keep overlay text under 32 characters where possible.
- Do not add app store badges, price claims, ranking claims, review stars, or install calls to action.

## QA Checklist

- [ ] Screenshot shows Tik Tak Toe, not Arrow Puzzle.
- [ ] Screenshot is from real app UI, not a mockup.
- [ ] Gameplay state was reached through real taps.
- [ ] Board marks, scores, and result text are not edited in.
- [ ] Overlay text is readable on a phone screen.
- [ ] Overlay text does not cover active gameplay controls.
- [ ] File is JPEG or 24-bit PNG without alpha.
- [ ] Minimum dimension is at least 320 px.
- [ ] Maximum dimension is no more than 3840 px.
- [ ] Long side is no more than twice the short side.
- [ ] No unsupported features or misleading claims appear.
- [ ] Alt text is 140 characters or less.
