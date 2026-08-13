# Sixteen Breed Screenshot Production Brief

Prompt: Play Store Creative Assets S2B

Status: production brief only. Final screenshot image files are not included because no real app screenshots are available in the repository and device/emulator capture was not approved for this prompt.

## Rules

- Use real app UI captures only.
- Do not fake gameplay states.
- Do not show online play, shop, rewards, rankings, tournaments, hints, undo, leaderboard, fake reviews, fake downloads, or fake awards.
- Keep the first three screenshots focused on real board gameplay.
- Keep overlay text short and readable on phone screens.
- Do not include interstitial ads in store screenshots.
- Remove debug banners, emulator controls, notifications, cursor artifacts, and broken states before export.

## Export Specs

- Device type: phone.
- Orientation: portrait.
- Recommended size: 1080 x 1920.
- Format: JPEG or 24-bit PNG.
- Alpha: no alpha.
- Minimum Google Play requirement: 320 px minimum dimension.
- Maximum Google Play requirement: 3840 px maximum dimension.
- Aspect guard: the longest side must not be more than twice the shortest side.
- Recommended set size: 8 screenshots.

## Screenshot Set

| Slot | File Name | Real App Moment To Capture | Overlay Text | Alt Text |
| --- | --- | --- | --- | --- |
| 1 | 01-offline-16-beads.png | Local 2 Player match at the starting board with 37 points, 16 red beads, 16 blue beads, and Player 1 turn visible. | Offline 16 Beads | Sixteen Breed match board with 37 points, red and blue beads, and Player 1 turn. |
| 2 | 02-legal-moves-highlighted.png | Player selects a bead and green legal move targets are visible before committing. | Legal Moves Highlighted | A selected bead on the board with green legal move targets highlighted. |
| 3 | 03-jump-to-capture.png | Amber capture path is highlighted before the move is committed. | Jump To Capture | Amber capture path highlighted across the Sholo Guti board before the jump is committed. |
| 4 | 04-chain-or-end-turn.png | After a capture, the optional capture chain state is visible with End Turn shown. | Chain Or End Turn | Optional capture chain state with End Turn visible after a capture. |
| 5 | 05-practice-vs-bot.png | Player vs Bot match or bot thinking state with board, bead counts, and real bot feedback. | Practice vs Bot | Player vs Bot match showing the board, bead counts, and bot turn feedback. |
| 6 | 06-rematch-fast.png | Match Complete panel with winner/result text and Rematch/Home actions. | Rematch Fast | Match Complete dialog showing the result plus Rematch and Home buttons. |
| 7 | 07-recent-match-history.png | Match History screen with real completed match entries. | Recent Match History | Match History screen listing completed matches, captures, and remaining beads. |
| 8 | 08-simple-rules.png | Rules screen explaining beads, move highlights, captures, and bot rules. | Simple Rules | Rules screen explaining beads, move highlights, captures, and bot rules. |

## Capture Steps

1. Start from a clean release-like build with debug banner hidden.
2. Open the app and verify the launcher/app label is Sixteen Breed.
3. Capture slot 1 from a new Local 2 Player match before any move.
4. Capture slot 2 after selecting a bead with green legal targets.
5. Capture slot 3 after reaching a real board state with an amber capture target.
6. Capture slot 4 immediately after a real capture that leaves another capture available for the same bead.
7. Capture slot 5 from a Player vs Bot match while the bot feedback is visible.
8. Capture slot 6 after a real match result appears.
9. Capture slot 7 after at least one real completed match is saved to local history.
10. Capture slot 8 from the Rules screen.

## Overlay Placement

- Place overlay copy in a top or bottom safe band outside the active board area.
- Do not cover bead counts, turn text, highlighted moves, End Turn, Rematch, Home, or history rows.
- Use high contrast text on a simple solid or lightly translucent background.
- Keep overlay text to one line when possible.
- Do not add device frames.

## QA Checklist

- Each screenshot is from the current Sixteen Breed app.
- Gameplay states are reachable by normal user actions.
- Board, beads, highlights, HUD, and buttons are readable.
- No fake UI, fake scores, fake reviews, fake rankings, or fake rewards.
- No unavailable features appear.
- No debug banner, emulator chrome, cursor, notification, or broken state appears.
- Overlay text does not obscure active gameplay.
- Image dimensions and format match Google Play requirements.
- Alt text is present and under 140 characters.
- First three screenshots clearly show real gameplay.

## Remaining Risk

Final screenshot assets still require approved real app capture. This brief is ready for screenshot production, but it is not a substitute for actual gameplay screenshots.
