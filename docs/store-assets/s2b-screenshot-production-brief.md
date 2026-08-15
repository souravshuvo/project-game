# KidsLand Screenshot Production Brief - S2B

Status: minimum real screenshot export set is complete. The stronger 8-shot
gameplay-variety set still needs fresh real capture for modes that are not
represented in the current evidence.

## Source Rule

Final screenshots must use actual KidsLand app UI captured from the runnable
app. Do not generate or mock gameplay. Do not show test ads, interstitials,
debug banners, notification clutter, fake device frames, fake ratings, awards,
rankings, or unavailable features.

Reference: Google Play preview asset guidance requires screenshots to show the
actual app/game experience, use JPEG or 24-bit PNG without alpha, avoid
misleading claims, and keep any additional tagline text small and readable.

## Final Export Specs

- Device type: phone screenshots.
- Orientation: portrait.
- Size: 1080 x 1920 px.
- Format: 24-bit PNG without alpha.
- Overlay text: none added; screenshots show real app UI only.
- Status/navigation bars: cropped out where practical.
- Minimum viable upload set: produced.
- Recommended full variety set: capture-needed.

## Produced Screenshot Set

| Slot | File Name | Real Screen Or Moment | Status | Alt Text |
| --- | --- | --- | --- | --- |
| 1 | `kidsland-01-letter-tracing.png` | Letter Tracing active canvas, letter A path visible | produce-now | Letter tracing gameplay with a large guided letter path and progress controls. |
| 2 | `kidsland-02-balloon-pop.png` | Balloon Pop active wave with balloons, score, streak, and progress visible | produce-now | Balloon popping gameplay with bright balloons, score, streak, and wave progress. |
| 3 | `kidsland-03-guided-hints.png` | Letter Tracing invalid-move hint showing "Nice try - find the glowing dot" | produce-now | Tracing gameplay showing a helpful hint after an incorrect touch. |
| 4 | `kidsland-04-game-hub.png` | KidsLand hub with next-up card, continue card, mission, and progress | produce-now | KidsLand game hub with next-up game, play plan, mission, and progress cards. |
| 5 | `kidsland-05-letter-paths.png` | Letter Tracing menu with letter cards and continue path | produce-now | Letter tracing menu showing colorful A to Z trace path cards. |

## Recommended Capture-Needed Set

| Slot | File Name | Real Gameplay Moment | Status |
| --- | --- | --- | --- |
| 6 | `kidsland-06-number-tracing.png` | Number Tracing active canvas, number 1 or 2 in progress | capture-needed |
| 7 | `kidsland-07-count-choose.png` | Count & Choose with objects visible and answer buttons shown | capture-needed |
| 8 | `kidsland-08-color-sorting.png` | Color Sorting with buckets and draggable pieces visible | capture-needed |
| 9 | `kidsland-09-shape-match.png` | Shape Match with shape homes and pieces visible | capture-needed |
| 10 | `kidsland-10-memory-match.png` | Memory Match mid-board with at least one revealed pair | capture-needed |
| 11 | `kidsland-11-magic-drawing.png` | Magic Drawing with prompt, canvas, and color tools visible | capture-needed |

## Capture Steps For Remaining Shots

1. Use a final stable build or approved capture build.
2. Disable ads for capture so no third-party ad creative appears.
3. Launch on a portrait phone device or emulator approved for capture.
4. Capture active mid-play moments instead of empty start states.
5. Export each image at 1080 x 1920 px or higher.
6. Save final screenshots to `docs/store-assets/screenshots/`.
7. Re-run this QA after any UI changes.

## QA Checklist

- Shows real KidsLand gameplay from the current app.
- No fake UI, fake gameplay, or generated gameplay.
- No unavailable feature shown.
- No ads, debug banners, or notification clutter.
- First two screenshots are real active gameplay.
- File format is JPEG or 24-bit PNG without alpha.
- Dimensions are 1080 x 1920 px or higher.
- Alt text is 140 characters or less.
- Visual style is consistent across all screenshots.

## Remaining Risks

- Current minimum set is truthful but weighted toward tracing; the stronger
  listing still needs more game-mode variety.
- The hub screenshot includes a naturally clipped horizontal quick-play card,
  which is okay as app UI but weaker than a clean full-card capture.
- If production AdMob remains enabled, store listing must declare ads, but
  screenshots should still avoid showing third-party ad creatives.
- If UI changes before upload, re-check every screenshot against the current
  app so the listing does not drift from real gameplay.
