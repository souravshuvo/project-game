# Larder Labels Screenshot Production Brief

Last updated: 2026-08-14

Status: production-ready brief only. Final screenshot images were not generated because no real captured gameplay screenshots are available in this repository and emulator/device capture was not approved for Prompt S2B.

## Approved Screenshot Set

| Slot | Target filename | Real app state to capture | Overlay text | Alt text | Required truth check |
| --- | --- | --- | --- | --- | --- |
| 1 | `01-home-progress.png` | Home screen showing `Larder Labels`, Play/Continue, Help, Settings, and progress. | `50 shelves to clear` | Home screen showing Larder Labels with Play, Help, Settings, and level progress. | Must show only real available home controls and real level count. |
| 2 | `02-first-shelf-start.png` | Level 1, `First Shelf`, at the start with the HUD, full board, and empty 7-slot tray. | `Pick free labels` | Level 1 board with selectable label tiles and an empty tray. | Must use the actual first playable board, not a mock layout. |
| 3 | `03-match-three-tray.png` | Level 1 or 2 after selecting two matching labels into the tray, before selecting the third. | `Match three` | Gameplay screen showing label tiles in the tray before a triple match. | Must show real tray state with exactly two matching tiles visible. |
| 4 | `04-layered-labels.png` | Level 3, `Lifted Labels`, while layered or covered tiles are visible. | `Clear the top first` | Layered board showing covered tiles dimmed until upper labels are removed. | Must show the real covered/unselectable visual state. |
| 5 | `05-plan-the-tray.png` | Level 4, `Tight Tray`, or a later real level with a nearly full tray and the `Careful` warning. | `Plan the tray` | Puzzle screen with a nearly full tray and the Careful warning. | Must be a fair real gameplay state, not an impossible or staged fake layout. |
| 6 | `06-shelf-cleared.png` | Real win result panel after clearing a level. | `Shelf cleared` | Win result panel showing moves and the Next action. | Must show the actual result UI and real move count. |
| 7 | `07-try-new-order.png` | Optional real fail state after the tray is full. | `Try a new order` | Tray-full fail state with a Restart action. | Use only if the captured fail screen is clear, readable, and not misleading. |

## Export Specs

- Primary format: portrait phone screenshots.
- Target size: `1080 x 1920`.
- Google Play compatible files: JPEG or 24-bit PNG with no alpha channel.
- Minimum screenshot count: at least 2. Recommended game set: first 6 slots above, with slot 7 optional.
- Keep the longest side no more than twice the shortest side.
- Keep overlay text short, high contrast, and below 20% of the image area.
- Do not include debug banners, emulator controls, system notification shade, fake awards, fake rankings, fake reviews, fake downloads, fake rewards, unavailable modes, unavailable boosters, or unavailable maps.

## Source And Final File Plan

- Put untouched captured screenshots in `store_assets/screenshots/source/`.
- Put edited Play-ready screenshots in `store_assets/screenshots/final/`.
- Keep filename numbers stable so the Play Console order matches the storyboard.
- Use frames, background color, or layout treatment only around real screenshots. Do not redraw or replace the gameplay UI.

## Manual Capture Steps

These steps require explicit approval before running build, install, device launch, emulator launch, or device screenshot capture.

1. Use a release-candidate app build with the production package name `com.childhood.larderlabels`.
2. Start from a clean app state only if data clearing is explicitly approved.
3. Capture slot 1 from the real home screen before entering gameplay.
4. Capture slot 2 by opening Level 1, `First Shelf`, before selecting any tile.
5. Capture slot 3 by selecting two matching Level 1 labels, such as two `jar` labels, then stop before selecting the third.
6. Capture slot 4 by opening Level 3, `Lifted Labels`, while covered/dimmed tiles are visible.
7. Capture slot 5 by reaching a real near-full tray state in Level 4, `Tight Tray`, or another real level where the `Careful` warning appears.
8. Capture slot 6 immediately after a real level clear on the actual win result panel.
9. Capture slot 7 only if a real tray-full fail state is reached and the Restart action is visible.
10. Review every screenshot against the QA checklist before export.

Note: `tool/capture_store_screenshots.ps1` exists, but it uses `adb`, launches the app, clears package data, and currently covers only three screenshot slots. It was not run for S2B.

## QA Checklist

- Every screenshot comes from actual app UI or real captured gameplay evidence.
- Every visible feature is available in the current app.
- Every overlay line matches the real state shown behind it.
- No gameplay is recreated, composited, or invented.
- Touch targets, tray, HUD, result panels, and warning states remain readable after any framing.
- Text is legible at phone size and does not cover important controls or tiles.
- Screenshots are ordered from clear first impression to gameplay depth.
- Final exports meet Play screenshot size and format rules.
- Filename, overlay text, and alt text match this brief.

## Risks

- Final screenshot image assets remain blocked until real capture is approved or real screenshots are provided.
- The optional fail-state screenshot may be less marketable if it looks punitive; include it only if the UI reads as fair and recoverable.
- Automated capture tooling will need review before use because the existing script covers only part of this storyboard.
