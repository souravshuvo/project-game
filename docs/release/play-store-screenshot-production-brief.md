# Play Store Screenshot Production Brief

## S2B Decision

Final screenshot image files were not generated in this pass.

Reason: the repository does not contain real captured gameplay screenshots or
video frames, and emulator/device capture was not approved. Prompt S2B requires
a production-ready brief instead of fake final screenshots in this case.

This brief is the approved screenshot production package for Trail Arena. It
must be used with real captures from the current app build before Play Console
upload.

## Source Evidence Checked

- Existing release docs under `docs/release`.
- App UI text in `lib/features/trail_arena`.
- Image and video files currently present in the repository.

Only launcher/web icons and generated build resources were found. No real
gameplay screenshot or preview video asset was available.

## Export Specs

- Orientation: portrait phone.
- Target size: 1080 x 1920 or higher, 9:16.
- Play-compatible format: JPEG or 24-bit PNG without alpha.
- Minimum count: 4 screenshots.
- Recommended count for this game: 8 screenshots.
- Keep every overlay short and readable on phone screens.
- Keep overlays outside HUD, controls, hazards, score text, and ad placements.
- Do not show interstitial ads, fake results, fake rankings, or unavailable
  features.

## Final Screenshot Set

| Slot | Capture moment | Overlay copy | Alt text | Capture notes |
| --- | --- | --- | --- | --- |
| 1 | Ready countdown in the arena | Drag to steer | Ready countdown in Trail Arena with the player trail ready to move | Capture after tapping Play, before movement hides the first-time hint. |
| 2 | Early movement with touch indicator | Simple touch control | Player trail turning through the arena with a visible drag control indicator | Show a clean turn with the control indicator visible and no UI overlap. |
| 3 | Normal seed pickup | Collect seeds | Player trail collecting seeds while the score increases | Capture a real pickup moment with the seed and score both readable. |
| 4 | Bright seed pickup or glow feedback | Grow your trail | Bright seed pickup glowing near the player trail as the trail grows | Use only if the bright seed appears in the actual run. |
| 5 | Rival trails visible | Dodge rival trails | Player trail weaving around two offline rival trails | Show rival trails as offline hazards, not multiplayer opponents. |
| 6 | Active Trail Goal progress in HUD | Complete local goals | Gameplay HUD showing progress toward a local Trail Goal | Capture only a real goal/progress state from the current save. |
| 7 | Late-run Chase or Surge phase | Survive the surge | Long player trail avoiding walls, seeds, and rival trails in a faster phase | Capture a real late-session phase; avoid claiming a separate mode. |
| 8 | Game-over result screen | Retry quick runs | Game over screen showing score, best score, and retry button | Use a real score from the run; no edited scores or fake best score. |

## Capture Steps

1. Use a current build of Trail Arena after dependency setup and launch are
   explicitly approved.
2. Capture on a portrait phone or emulator at 1080 x 1920 or higher.
3. Start from a clean first-time run if possible, then tap Play.
4. Capture Slot 1 during the countdown or first ready state.
5. Drag to steer and capture Slot 2 during a readable turn.
6. Collect normal seeds for Slot 3.
7. Continue until a bright seed appears, then capture Slot 4.
8. Continue until both offline rival trails are visible for Slot 5.
9. Capture a real Trail Goal progress state for Slot 6.
10. Continue into Chase or Surge pacing for Slot 7.
11. Crash naturally, then capture the result screen for Slot 8.
12. Save the original raw captures separately before adding any overlay text.

## Overlay Placement

- Use one short line per screenshot.
- Recommended placement: top or lower safe band, whichever avoids the HUD and
  action in that capture.
- Use high-contrast text with a subtle solid or translucent backing only if the
  capture needs it.
- Do not cover the player trail, active hazards, score, goal progress, pause
  button, retry button, or ad slot.

## File Naming

Use these names for the final exported assets after real capture:

| Slot | Export filename |
| --- | --- |
| 1 | `trail-arena-01-drag-to-steer.png` |
| 2 | `trail-arena-02-simple-touch-control.png` |
| 3 | `trail-arena-03-collect-seeds.png` |
| 4 | `trail-arena-04-grow-your-trail.png` |
| 5 | `trail-arena-05-dodge-rival-trails.png` |
| 6 | `trail-arena-06-complete-local-goals.png` |
| 7 | `trail-arena-07-survive-the-surge.png` |
| 8 | `trail-arena-08-retry-quick-runs.png` |

Suggested storage path after capture: `docs/release/screenshots/`.

## Truthfulness Rules

- Use actual app UI and real gameplay only.
- Do not composite gameplay positions that did not happen.
- Do not edit score, best score, goal progress, ad state, or run result.
- Do not imply online multiplayer; rivals are offline bots.
- Do not show skins, shops, login, cloud sync, leaderboards, purchases, or
  battle pass features.
- Do not use existing game names, copied UI, copied characters, copied maps, or
  copied branding.

## QA Checklist

- [ ] Every screenshot came from the current app build.
- [ ] At least the first 4 screenshots show real gameplay clearly.
- [ ] Overlay text is short, readable, and does not hide important UI.
- [ ] No unavailable feature is visible or implied.
- [ ] No multiplayer claim is made.
- [ ] No fake ranking, award, review, download, or earnings claim is made.
- [ ] No interstitial ad appears.
- [ ] Banner ads, if visible, do not overlap gameplay or screenshot copy.
- [ ] Each image is portrait 9:16 at 1080 x 1920 or higher.
- [ ] Each image is JPEG or 24-bit PNG without alpha.
- [ ] Final copy still matches the Play Store listing text.

## Remaining Risks

- Final screenshots still require approved device/emulator capture.
- Visual QA cannot be completed until real captures exist.
- Google Play asset requirements should be rechecked against the current
  official Play Console guidance before upload.
- If gameplay, ads, HUD, or progression changes, the captures and copy must be
  revalidated.

## Skipped Heavy Checks

- `flutter pub get`: skipped by instruction.
- `flutter run`: skipped by instruction.
- `flutter build`: skipped by instruction.
- Device/emulator launch or screenshot capture: skipped by instruction.
- Install or release packaging: skipped by instruction.
