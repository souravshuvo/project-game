# Real Gameplay Capture Checklist

No capture was performed in this task. Use this checklist only when app launch
and recording are explicitly approved.

## Setup

- Use the current release-candidate app build.
- Use a clean portrait phone capture at 1080 x 1920 if available.
- Use a quiet device state: no notifications, no status distractions, no debug banner.
- Keep the app in portrait; do not rotate mid-recording.
- Do not enable OS touch indicators if they make the video look like a tutorial
  overlay or cover the board.
- Record app UI only; do not film hands, device bezels, or a physical device.
- Avoid recording any ad surface. If an ad appears after a match, discard that
  segment and capture again.

## Capture Sequence

1. Open the app to the main menu.
2. Select the 4x4 board preset.
3. Select local two-player.
4. Start a match.
5. Capture a clean first line draw by Player 1.
6. Continue the match until both player colors are visible.
7. Create a real three-sided box setup through legal moves.
8. Record the fourth side being drawn and the box being captured.
9. Hold immediately after the capture to show the extra turn state.
10. Return to the menu and start a Player vs Bot match with Casual or Tactical.
11. Capture a real bot match state with the bot label visible.
12. Finish a match and capture the real result screen.
13. Stop recording before any post-match interstitial appears.

## Required Capture Evidence

- Fresh board.
- Legal line draw.
- Two-player turn state.
- Box capture.
- Extra-turn state after scoring.
- Bot mode state.
- Game-over result state.

## Reject And Re-Capture If

- A board state is manually edited or recreated outside the app.
- Scores, captured boxes, or turn labels are altered after capture.
- The wrong mode appears in captions or UI.
- Debug banners, emulator controls, notification overlays, or cursor artifacts appear.
- Captions cover gameplay or make claims not visible in the app.
- Ads, store badges, awards, ratings, download counts, or ranking claims appear.
