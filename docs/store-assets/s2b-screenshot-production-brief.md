# KidsLand Screenshot Production Brief - S2B

Status: production-ready brief only. No final screenshot image files were
created because the repository does not contain real captured gameplay
screenshots, and emulator/device capture was not approved for this pass.

## Source Rule

Final screenshots must use actual KidsLand app UI captured from the final
runnable app. Do not generate or mock gameplay. Do not show test ads,
interstitials, debug banners, notification clutter, fake device frames,
fake ratings, awards, rankings, or unavailable features.

Reference: Google Play preview asset guidance says screenshots should depict
the actual in-app or in-game experience, use captured footage of the app or
game itself, avoid call-to-action copy, and keep taglines small and readable.

## Export Specs

- Device type: phone screenshots.
- Orientation: portrait.
- Target size: 1080 x 1920 px or higher.
- Format: JPEG or 24-bit PNG without alpha.
- Minimum viable set: 4 portrait screenshots.
- Recommended set: all 8 approved gameplay screenshots below.
- Text overlay area: keep under 20 percent of each screenshot.
- Status bar: clean, no notifications, full battery/Wi-Fi/cell indicators if
  status bar is visible.

## Approved Screenshot Set

| Slot | File Name | Real Gameplay Moment | Overlay Copy | Alt Text |
| --- | --- | --- | --- | --- |
| 1 | `kidsland-01-letter-tracing.png` | Letter Tracing active canvas, letter A or B with path progress visible | Trace letters | Letter tracing gameplay with a large guided letter path and progress controls. |
| 2 | `kidsland-02-number-tracing.png` | Number Tracing active canvas, number 1 or 2 in progress | Trace numbers | Number tracing gameplay with a large guided number path. |
| 3 | `kidsland-03-count-choose.png` | Count & Choose with objects visible and answer buttons shown | Count and choose | Counting gameplay with objects to count and large answer buttons. |
| 4 | `kidsland-04-color-sorting.png` | Color Sorting with buckets and draggable pieces visible | Sort colors | Color sorting gameplay with colored baskets and movable shapes. |
| 5 | `kidsland-05-shape-match.png` | Shape Match with shape homes and pieces visible | Match shapes | Shape matching gameplay with colorful shape homes and pieces. |
| 6 | `kidsland-06-memory-match.png` | Memory Match mid-board with at least one revealed pair | Find pairs | Memory matching gameplay with cards and revealed matching symbols. |
| 7 | `kidsland-07-balloon-pop.png` | Balloon Pop during an active wave, before all balloons are popped | Pop balloons | Balloon popping gameplay with bright balloons in a touch grid. |
| 8 | `kidsland-08-magic-drawing.png` | Magic Drawing with prompt, canvas, and color tools visible | Draw prompts | Drawing gameplay with a prompt, canvas, and color tools. |

## Capture Steps

1. Resolve dependencies and release blockers before capture.
2. Use a final stable build or approved capture build.
3. Disable ads for capture so no third-party ad creative appears.
4. Launch on a portrait phone device or emulator approved for capture.
5. Capture each gameplay state from the table above.
6. Prefer active mid-play moments over empty start states.
7. Export each image at 1080 x 1920 px or higher.
8. Add only the approved overlay copy, using large readable text.
9. Save final screenshots to `docs/store-assets/screenshots/`.

## Overlay Style

- Position: top or bottom safe area, never covering active controls.
- Type: bold rounded sans serif, high contrast.
- Background: subtle solid or translucent band only if needed for readability.
- Copy: use the exact short phrases in the approved set.
- Avoid: "best", "#1", "top", "new", "free", "download now",
  "install now", ratings, awards, or review-style claims.

## QA Checklist

- Shows real KidsLand gameplay from the current app.
- No fake UI, fake gameplay, or generated gameplay.
- No unavailable feature shown.
- No ads, debug banners, or notification clutter.
- First three screenshots are real gameplay.
- Overlay text is readable on a phone and uses less than 20 percent of image.
- Important UI is not covered by overlay text.
- File format is JPEG or 24-bit PNG without alpha.
- Dimensions are 1080 x 1920 px or higher.
- Alt text is 140 characters or less.
- Visual style is consistent across all screenshots.

## Remaining Risks

- Final screenshots still need real capture.
- Current launcher icon is still the default Flutter icon, so screenshot
  styling should be rechecked after final icon and feature graphic work.
- If production AdMob remains enabled, store listing must declare ads, but
  screenshots should still avoid showing third-party ad creatives.
- If UI changes before capture, re-check every screenshot against the current
  app so the listing does not drift from real gameplay.
