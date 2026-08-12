# Play Store Screenshot Production Brief

S2B output for Dew Bubble Garden. Final screenshot image files were not created in this pass because there are no existing real app screenshots in the repository and emulator/device capture was not approved. Do not generate or draw fake gameplay to fill these slots.

## Current Status

| Item | Status | Notes |
| --- | --- | --- |
| Final screenshot PNG/JPEG files | Not created | Real capture is required first. |
| Approved screenshot count | 6 phone screenshots | Portrait-first game listing. |
| Recommended export size | 1080x1920 | 9:16 portrait, Play-compatible. |
| Required format | JPEG or 24-bit PNG, no alpha | Flatten any overlay/background before export. |
| Home screenshot readiness | Blocked | Current Home UI says `Offline / Ad-free`, but AdMob is wired in the repo. Fix before capture or do not use that frame. |
| Gameplay screenshots readiness | Capture needed | Must be captured from the running app or real gameplay recording frames. |

## Approved Screenshot Set

| # | Target filename | Real screen or moment | Overlay text | Alt text |
| --- | --- | --- | --- | --- |
| 1 | `01-home-start-in-garden.png` | Home screen with Dew Bubble card, progress, and Play button. | Start in the garden | Dew Bubble home screen with play button, level progress, stars, and best score. |
| 2 | `02-level-select-pick-a-puzzle.png` | Level select with unlocked levels, locked levels, saved stars, and scores. | Pick a puzzle | Dew Bubble Garden level select with unlocked levels, locked levels, stars, and scores. |
| 3 | `03-gameplay-line-up-bounce.png` | Gameplay board while aiming with the wall-bounce guide visible. | Line up the bounce | Gameplay screen showing the shooter, aim guide, wall bounce path, shots, score, and next bubble. |
| 4 | `04-match-three-clear.png` | Real shot resolving into a match, pop, and floating bubble drop. | Match 3 and clear | A dew bubble match pops on the board while unsupported bubbles drop from the garden grid. |
| 5 | `05-win-stars.png` | Real win result screen with stars, score, Next, Restart/Levels actions. | Win stars | Level complete screen showing earned stars, score, next level, restart, and level select actions. |
| 6 | `06-quick-retry-controls.png` | Pause/help/settings sheet with sound and haptic toggles. | Quick retry controls | Pause sheet with help, restart, sound feedback, and haptic feedback controls. |

## Capture Requirements

- Capture from a real emulator/device session or real gameplay recording.
- Do not use generated game boards, simulated progress, fake match effects, fake result screens, or edited-in HUD values.
- Do not show ads, rewarded ads, boosters, shops, map progression, characters, rankings, reviews, awards, or download claims.
- Do not show touch indicators, fingers, notifications, personal account information, debug banners, or service-provider status text.
- If overlay text is added, keep it short, localized later, and outside the active gameplay board/HUD.
- Do not capture the Home screen while it says `Offline / Ad-free` unless production ads are truly disabled and store disclosures match.

## Manual Capture Steps

1. Prepare a clean release-like build or internal test build.
2. Fix or remove the misleading `Offline / Ad-free` Home copy before capturing screenshot 1, unless ads are intentionally disabled for the shipped app.
3. Start from a clean install and capture the Home screen.
4. Play enough levels normally to create real progress/stars for the level select screenshot.
5. Open an unlocked level and hold an upward aim that shows the wall-bounce guide.
6. Record or repeatedly capture during a real match that pops bubbles and drops unsupported bubbles.
7. Complete a level and capture the real result panel.
8. Open the pause sheet and capture help/settings controls.
9. Crop/export each image to 1080x1920 without stretching.
10. Add the approved overlay copy only after verifying it does not cover gameplay, HUD, buttons, or important text.

## Overlay Style Guidance

- Place overlay text in the top safe area or bottom margin only if it does not cover app UI.
- Use one short line per screenshot.
- Use high-contrast rounded text treatment only if needed for readability.
- Keep overlay text below 20% of the screenshot area.
- Do not add call-to-action copy such as "Download now", "Install now", or "Play now".

## Export Specs

| Requirement | Value |
| --- | --- |
| Device type | Phone |
| Orientation | Portrait |
| Size | 1080x1920 recommended |
| Aspect ratio | 9:16 |
| Format | JPEG or 24-bit PNG |
| Alpha | None |
| Minimum screenshots | 2 required by Play; 6 planned here |
| Game recommendation target | At least 3 portrait gameplay screenshots at 1080x1920 |

## QA Checklist

- [ ] Each screenshot comes from the actual running app or a real gameplay recording frame.
- [ ] First three screenshots prioritize real app UI/gameplay.
- [ ] No unavailable features are visible.
- [ ] No misleading `Ad-free` claim is visible unless ads are removed/disabled for production.
- [ ] Text overlays are readable on a phone screen.
- [ ] Overlay text does not cover active gameplay, HUD, buttons, or dialogs.
- [ ] Images are not blurry, stretched, compressed, sideways, or pixelated.
- [ ] Status bar/notifications are clean or removed appropriately.
- [ ] Files are JPEG or 24-bit PNG with no alpha.
- [ ] Alt text is entered in Play Console for every screenshot.

## Remaining Risks

- The current Home UI contains `Offline / Ad-free`, which conflicts with AdMob-enabled code and should not appear in store assets.
- Final screenshots still require real capture; this brief is not an uploadable asset set.
- Small-screen text overlap and exact visual quality cannot be verified until screenshots are captured.
- Play Console upload readiness still depends on final icon, feature graphic, privacy/Data safety, and release build validation.

## Source Checked

- Google Play Help: Add preview assets to showcase your app: https://support.google.com/googleplay/android-developer/answer/9866151
