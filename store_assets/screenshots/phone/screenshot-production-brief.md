# Signal Reef screenshot production brief

Status: ready for real capture. Final screenshot PNGs are not created yet because no real app screenshots or gameplay capture exist in the repository, and device/emulator capture was not approved for this pass.

## Export target

- Device type: phone
- Orientation: portrait
- Size target: 1080 x 1920
- Format: 24-bit PNG or JPEG, no alpha
- Source: real current Signal Reef app UI or real gameplay capture only
- Overlay text: optional, short, high-contrast, and under 20% of the image

## Final screenshot set

| File name | Required real capture | Overlay copy | Alt text |
| --- | --- | --- | --- |
| `01-drag-to-dodge.png` | Active gameplay with HUD, player, enemies, and shots visible. | Drag to dodge | Player dodges enemies in a Signal Reef wave with score, hull, and wave HUD visible. |
| `02-bounce-signal-shots.png` | Gameplay frame where a player shot visibly bounces off a side wall. | Bounce signal shots | A signal shot bounces through enemies in the dark teal space arena. |
| `03-read-the-wave.png` | Later wave with Pulse Seed pressure or a red enemy projectile and readable dodge space. | Read the wave | The player avoids a red enemy shot while clearing a harder Signal Reef wave. |
| `04-quick-offline-runs.png` | Home screen showing Signal Reef title, Play button, 20 waves, best score, and best wave. | Quick offline runs | Signal Reef home screen with Play button, 20 waves, best score, and best wave progress. |
| `05-chase-your-best-run.png` | Result screen after a real completed or lost run. Do not fabricate score values. | Chase your best run | Result screen showing score, waves cleared, wave reached, best score, and Play again button. |
| `06-clear-controls.png` | Settings or help screen showing controls plus sound and haptic toggles. | Clear controls | Settings screen explaining drag steering, auto-fire, hull, score, sound, and haptics. |

## Capture notes

- Prioritize the first three screenshots as real gameplay.
- Keep the player ship, enemies, score, wave number, hull, and important buttons unobscured.
- Capture with no debug banner, no notifications, no service provider clutter, and no test-only labels.
- If ads appear on home or result screens, use a build/configuration appropriate for Play review and do not crop misleadingly.
- Use the existing `tool/capture_store_screenshots.ps1` only as a starting point; it currently does not capture result or settings screens.

## Forbidden content

- Fake scores, fabricated results, or staged gameplay states that cannot occur in the current build
- Bosses, ship upgrades, shops, leaderboards, cloud save, live events, rewarded ads, extra ships, multiplayer, or other unavailable features
- Device frames, hands, fake ratings, fake reviews, awards, download counts, rankings, or calls to action such as "download now"
- Old Arrow Puzzle screenshots or unrelated app screens

## QA checklist

- [ ] Every screenshot is from the current Signal Reef build.
- [ ] First three screenshots show real in-game UI or gameplay.
- [ ] Overlay text is readable and does not cover HUD, player, enemies, bullets, buttons, or result data.
- [ ] Overlay text uses the exact approved copy above or is removed.
- [ ] Image dimensions are 1080 x 1920, or another Play-compatible 9:16 size.
- [ ] File format is JPEG or 24-bit PNG with no alpha.
- [ ] No screenshot contains debug banners, notifications, test clutter, or unavailable features.
- [ ] Alt text is available for every uploaded asset and stays under 140 characters.
