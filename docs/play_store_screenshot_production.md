# Play Store Screenshot Production Package

## Source Rule

Use only real app UI from the final running build. Do not draw, mock, compose, or
edit gameplay states that cannot occur in Magnetic Marbles. Do not show ads,
shops, skins, upgrades, leaderboards, base-building, fake rewards, fake reviews,
rankings, download counts, or any unavailable feature.

Final screenshot image files are not included in this package because no real
device, emulator, or app capture was approved for this pass.

## Export Targets

- Orientation: portrait phone screenshots.
- Size target: 1080 x 1920.
- Format: JPEG or 24-bit PNG without alpha.
- Count: 6 required for a strong v1 listing, 8 if every capture is clean.
- UI language: English.

## Approved Screenshot Set

| File name | Capture moment | Overlay copy | Alt text |
| --- | --- | --- | --- |
| `01_home_progress.png` | Home screen with app title, Continue, Levels, unlocked progress, and stars visible. | Quick marble levels | Home screen with Continue button, level progress, and star progress |
| `02_start_hint.png` | Level 1 ready state with launcher, gates, enemies, HUD, and "Hold and drag to launch" hint. | Hold and drag | Gameplay lane showing launcher, gates, enemies, and hold-to-launch hint |
| `03_gate_choice.png` | Active marble stream approaching a real add/multiply gate choice. | Choose a gate | Marble stream approaching two math gates during gameplay |
| `04_crowd_growth.png` | Immediately after a gate effect, with the crowd count and floating feedback visible. | Grow the crowd | Marble crowd after passing a gate with crowd feedback visible |
| `05_enemy_collision.png` | Marble crowd colliding with a real enemy cluster or line, with enemy strength visible. | Clear clusters | Marble crowd colliding with an enemy cluster that shows remaining strength |
| `06_level_clear.png` | Level clear result overlay showing score, stars, Retry, Next, and Home. | Fast level clears | Level clear screen showing stars, score, retry, next, and home buttons |
| `07_level_select.png` | Level select sheet showing multiple unlocked/locked levels and star progress. | 30 offline levels | Level select grid with unlocked levels, locked levels, and star progress |
| `08_settings.png` | Settings overlay showing Sound effects and Haptics toggles. | Sound and haptics | Settings screen showing sound effects and haptics toggles |

## Capture Steps

1. Use the final release-candidate app build.
2. Start from a clean install for screenshots 1 and 2 unless progress needs to
   be seeded for screenshot 7.
3. Capture screenshots without notification noise, private data, debug banners,
   emulator chrome, or device frames.
4. For gameplay shots, play the level normally and capture live moments. Do not
   pause and edit values into the image.
5. Keep any overlay copy short, large, and outside active HUD/gate/enemy areas.
6. Export the final images to `store_assets/screenshots/phone/`.

## Layout Guidance

- The first three screenshots should prioritize unframed real app UI.
- If decorative frames are used later, keep them subtle and do not crop the
  gameplay lane, HUD chips, result buttons, or level select grid.
- Use the same typography, color palette, and overlay placement across all
  screenshots.
- Keep overlay copy to one short line. Avoid paragraphs.

## Truthfulness QA

- Screenshot shows real app UI from the current build.
- Shown level, gates, enemies, score, stars, and progress are achievable in the
  app.
- No unavailable modes or economy systems are shown.
- No ads are shown in screenshots.
- No fake ratings, rankings, awards, reviews, or download counts are shown.
- Text does not claim "best", "#1", "top", "new", "sale", or "download now".
- Notification bar is clean if visible.
- Screenshot is not blurry, stretched, compressed, rotated, or letterboxed.
- Overlay copy is readable at phone thumbnail size.
- Alt text is under 140 characters.

## S2B Completion Status

- Final screenshot assets: not created because real app capture was not approved.
- Screenshot storyboard: complete.
- Copy and alt text: complete.
- Capture and QA checklist: complete.
- Next step: approve real build/device or emulator capture, then create the
  final screenshot image files from actual gameplay.
