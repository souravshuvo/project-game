# Pencil Pitch Screenshot Production Package

Prompt S2B status: production-ready screenshot brief only. Final screenshot images are not created in this pass because the repository does not contain real gameplay screenshots and emulator/device capture was not explicitly approved.

## Source Of Truth

- App name in UI: `Pencil Pitch`.
- Store title: `Pencil Pitch: Pen Cricket`.
- Real shipped screens to capture: main menu, practice innings, target chase, challenge ladder, progress panel, help/settings, spinner gameplay, delivery result, and match result.
- Do not show unavailable features: online play, tournaments, teams, rosters, shop, leaderboard, login, cloud sync, betting, prizes, fake rankings, fake reviews, fake downloads, or fake awards.

## Export Specs

- Device class: phone screenshots.
- Orientation: portrait.
- Target size: `1080 x 1920` or higher.
- File type: JPEG or 24-bit PNG without alpha.
- Aspect ratio: 9:16 portrait.
- Text overlay limit: keep added tagline text under 20% of the image height.
- Status bar: no notifications, no service provider clutter, full battery/Wi-Fi/cell indicators if visible.
- Ads: do not include live ad creative in screenshots unless the capture is intentionally validating the ad layout. Prefer capture moments where gameplay and controls are not obscured.

## Final Screenshot Set

| File | Real app capture | Overlay copy | Caption placement | Alt text |
| --- | --- | --- | --- | --- |
| `01-main-menu.png` | Main menu showing title, match preset selector, Practice innings, Target chase, Challenge ladder preview, Progress, Sound, and Haptics. | `Pick a quick match` | Top band or top safe area, not over buttons. | `Pencil Pitch main menu with match presets, practice, target chase, progress, and settings.` |
| `02-spinner-gameplay.png` | Practice innings spinner screen with score HUD, overs, wickets, and large spinner visible. Spinner may be idle or spinning. | `Tap to spin, tap to stop` | Bottom band below spinner controls, if space allows. | `Pen cricket spinner screen with score, wickets, balls, overs, and a large tappable wheel.` |
| `03-delivery-result.png` | A real delivery result after stopping the spinner. Any genuine run, wicket, wide, or no-ball is acceptable. | `Every ball is clear` | Top safe area, leaving result card and scoreboard readable. | `Delivery result card showing the outcome and updated cricket score.` |
| `04-target-chase.png` | Target chase innings break or chase start with target visible and Start chase action available. | `Set it, then chase it` | Top band, not over target or action controls. | `Target chase screen showing the first innings target and chase controls.` |
| `05-challenge-ladder.png` | Challenge ladder sheet showing real locked, unlocked, or completed local challenge states. | `24 offline challenges` | Top band or bottom band, not covering mission goals. | `Offline challenge ladder with mission cards and local progress.` |
| `06-match-result.png` | Match complete result panel showing final score summary plus Restart and menu actions. | `Finish and restart fast` | Top safe area, leaving result summary visible. | `Match result screen with final score summary, restart, and menu actions.` |

## Backup Screenshots

| File | Real app capture | Overlay copy | Alt text |
| --- | --- | --- | --- |
| `07-progress.png` | Progress panel with match count, best practice score, best chase score, chase wins, and recent history. | `Track local progress` | `Local progress panel with best scores, chase wins, matches played, and recent history.` |
| `08-help-settings.png` | How-to-play or settings sheet with scoring rules plus Sound and Haptics toggles. | `Simple rules, quick settings` | `How-to-play and settings screen with scoring rules, sound, and haptic controls.` |

## Manual Capture Steps

1. Launch the real app on a clean phone-sized portrait device or emulator after screenshot capture is explicitly approved.
2. Confirm the title reads `Pencil Pitch`.
3. Capture `01-main-menu.png` before starting a match.
4. Select `Notebook Classic` unless a different preset is intentionally being shown.
5. Start `Practice innings`.
6. Capture `02-spinner-gameplay.png` with the spinner and score HUD clearly visible.
7. Spin and stop the wheel once. Capture `03-delivery-result.png` from the real outcome. Do not edit the score or force a specific result.
8. Return to the menu and start `Target chase`.
9. Finish the first innings naturally, then capture `04-target-chase.png` on the target/innings-break screen.
10. Open `Challenge ladder` and capture `05-challenge-ladder.png`.
11. Complete any match naturally and capture `06-match-result.png`.
12. Capture backup progress/help screenshots only if the first six images need replacement.

## Overlay Style

- Use the app palette: green `#0F8B63`, paper `#F8F7F1`, charcoal `#17201C`, yellow `#F7C948`, and red `#E44835`.
- Use short, large text only.
- Use a simple translucent paper or green caption band if needed.
- Do not place text over the spinner pointer, score HUD, delivery result card, target value, or action buttons.
- Do not use device frames, store badges, star ratings, awards, download claims, or call-to-action text.

## Supporting Asset Rules

Generated visuals may be used only as a background, frame, or caption support around real captured app UI. Do not generate fake app screens, fake scoreboards, fake spinner states, fake ad views, or fake challenge progress.

## QA Checklist

- Each screenshot is from the actual app UI.
- First three screenshots prioritize real app/menu/gameplay UI.
- No unavailable features are visible or implied.
- No fake rankings, awards, reviews, downloads, earnings, betting, or prize claims.
- Overlay text is short and readable on a phone.
- Overlay text does not cover controls, HUD, spinner, result cards, or important values.
- File dimensions meet the selected portrait target.
- Export has no alpha channel.
- No blur, distortion, stretching, skew, or sideways rotation.
- Notification/status bar is clean.
- Alt text is under 140 characters.
- Screenshots match the current app version intended for upload.

## Remaining Risks

- Final screenshot files are still missing until real capture is approved and performed.
- Device-specific layout issues cannot be checked without capture.
- Ad banner appearance in screenshots is unknown until the app is run.
- Any future UI change should trigger screenshot recapture.
