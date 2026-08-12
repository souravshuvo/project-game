# Play Store Screenshot Production Brief

Use this brief to create the final Google Play phone screenshots for Rooftop
Rain Garden. Do not fake gameplay. Every final screenshot must be captured from
the current app build.

## Export Specs

- Target device set: phone
- Orientation: portrait
- Recommended size: 1080 x 1920 px or higher
- Format: PNG or JPEG
- Alpha: none for final Play uploads
- Overlay text: short, readable, and outside critical gameplay controls
- Final output folder suggestion: `store-assets/screenshots/phone/`

## Screenshot Manifest

| File | Real capture moment | Overlay text | Alt text |
| --- | --- | --- | --- |
| `01-start-rooftop-garden.png` | Garden home screen with Start or See Progress visible. | Start a Tiny Rooftop Garden | Home screen for Rooftop Rain Garden with start button and garden stats. |
| `02-plant-water-grow.png` | Main gameplay screen with HUD, crop picker, and 3x3 plot grid. | Plant, Water, Grow | Gameplay screen with resources, seed picker, and rooftop plot grid. |
| `03-tap-plot-to-plant.png` | Empty unlocked plot selected with Plant Sun Sprouts available. | Tap a Plot to Plant | Empty plot selected with Plant Sun Sprouts action available. |
| `04-watch-crops-grow.png` | Watered crop showing timer/progress on the plot grid. | Watch Crops Grow | Watered crop growing with timer and progress feedback. |
| `05-harvest-when-ready.png` | Ready crop selected with Harvest action visible. | Harvest When Ready | Ready crop selected with Harvest button and clear visual feedback. |
| `06-sell-crops-for-coins.png` | Market panel after harvest with Sell crate and seed buying visible. | Sell Crops for Coins | Market panel showing crate selling, seed buying, and save action. |
| `07-upgrade-the-garden.png` | Upgrade available or later-level garden with more plots/crops unlocked. | Upgrade the Garden | Garden upgrade panel showing more plots, crops, and water capacity. |
| `08-come-back-to-progress.png` | Return progress panel after time away. | Come Back to Progress | Return progress panel showing crops and water restored while away. |

## Capture Notes

- Use real app UI from the current release candidate.
- Prefer captures with the debug banner hidden.
- Keep the first three screenshots mostly actual UI, with minimal framing.
- Avoid showing notification content, personal device details, or test tooling.
- Do not show fake coins, fake rewards, fake rankings, fake reviews, fake
  downloads, or unavailable modes.
- Avoid active ad overlays if they make the gameplay harder to understand.
- If a banner ad is visible, it must not overlap or crowd the HUD, grid,
  action panel, or overlay copy.
- Crop and frame consistently across all screenshots.

## Overlay Guidance

- Keep overlay text to one short line.
- Place overlays in a consistent top or bottom safe area.
- Do not cover plot status labels, timer chips, buttons, or resource values.
- Use high-contrast text on a quiet solid or lightly shaded backing.
- Do not use calls to action such as "Download now", "Install", or "Play now".

## Manual Capture Steps

1. Resolve dependencies and run a release-like debug/profile build only after
   build/run approval.
2. Start with a fresh local save for screenshots 1-4.
3. Use real gameplay to plant, water, wait for the timer, and harvest.
4. Continue real gameplay or use an approved seeded debug state for screenshots
   6-8, as long as the state is achievable in the shipping game.
5. Capture each screenshot in portrait at 1080 x 1920 px or higher.
6. Apply only approved text overlays and light framing.
7. Export PNG or JPEG files with the exact manifest filenames.

## QA Checklist

- Every screenshot shows real app UI.
- First three screenshots clearly show the core gameplay experience.
- Overlay text is readable on phone screens.
- Overlay text does not exceed roughly 20% of the image area.
- No unavailable features appear.
- No fake rankings, awards, reviews, downloads, earnings, or reward claims
  appear.
- No third-party trademarks or copied assets appear.
- No screenshot is blurry, stretched, rotated, or cropped awkwardly.
- Alt text is present and under 140 characters.
- Final files match the target naming and format requirements.
