# Play Store Metadata And Creative Package

Last updated: 2026-08-15

## App Identity

- App title: Weather Lab Sort
- Package name: `com.childhood.weatherlabsort`
- Game slug: `weatherlabsort`
- Category: Game / Puzzle
- Default language: English (United States)
- Current version: `1.0.0+1`
- Developer name: Childhood
- Target audience draft: General puzzle-game audience. Do not mark as child-directed unless the full Families/children policy review is completed.

## ASO Name Decision

Approved display name: Weather Lab Sort

Reason: short, readable, original, under 30 characters, truthful to the weather-essence sorting theme, and not keyword-stuffed.

## Short Description

Sort rain, sun, and mist into calm weather vessels.

Character count: 52 / 80

Alternative safe options:

- Sort weather essences in calm offline puzzles.
- Pour rain, sun, mist, cloud, and frost into order.
- A calm offline liquid sorting puzzle.

## Full Description

Weather Lab Sort is a calm offline liquid sorting puzzle about organizing rain, sun, mist, cloud, and frost essences into clean glass vessels.

Tap one vessel, then another, and pour matching top layers into place. Each level asks you to plan a small chain of moves, use empty vessels wisely, and finish with every weather essence sorted into its own vessel.

Features:

- Simple tap-to-pour puzzle controls
- 50 handcrafted v1 forecast levels
- Offline play
- Undo and restart
- Best-move, star, and pace tracking
- Lab Goals for clears, perfect forecast sets, and star progress
- Sound and haptic settings
- No login or online account required
- Ads never appear during active puzzle play

Weather Lab Sort is designed for short, readable puzzle sessions with no timers and no pressure.

## Screenshot Storyboard

Final screenshot upload candidates are in `store_assets/screenshots/weather_lab_sort_phone/final_png/`. They use real Weather Lab Sort widget UI captures with only the approved short storyboard headline added above each screen. Do not use the existing `store_assets/screenshots/phone/` files because they show the older Arrow Puzzle prototype and unavailable hint content. Do not upload `store_assets/screenshots/weather_lab_sort_phone/source_png/` directly because those files are raw 32-bit source captures and include stale historical files.

Recommended format: portrait phone screenshots, 1080 x 1920 or higher, JPEG or 24-bit PNG without alpha.

| Slot | Real screen or moment | Overlay copy | Alt text |
| --- | --- | --- | --- |
| 1 | Home dashboard with Weather Lab Sort title, continue card, progress, and Lab Goals | Calm Sorting Puzzles | Weather Lab Sort home screen with campaign progress, current mission, and lab goals. |
| 2 | Early gameplay with readable vessels, Pace HUD, guidance banner, and tap targets | Tap, Pour, Sort | Early level gameplay showing weather vessels, move pace, and tap-to-pour guidance. |
| 3 | Mid-game level with rain, sun, mist, cloud, and frost visible | Plan Each Pour | Harder weather sorting level with five essence colors and multiple vessels. |
| 4 | Invalid move feedback after a mismatch or full target | Clear Feedback | Gameplay screen showing an invalid move message and highlighted vessel feedback. |
| 5 | Level complete screen with stars, moves, par, best, next Lab Goal, next/replay | Beat Your Best | Level complete screen showing stars, best route progress, next lab goal, and replay options. |
| 6 | Campaign map showing five forecast sets and 50-level progression | 50 Forecast Levels | Campaign map showing completed, unlocked, and locked Weather Lab Sort forecast levels. |

## Screenshot Production Status

Final files created: `store_assets/screenshots/weather_lab_sort_phone/final_png/01-calm-sorting-puzzles.png` through `06-50-forecast-levels.png`.

Source template exists: `tool/store_screenshot_capture_test.dart` renders the six planned store screens from real app widgets and includes a preview mode via `--dart-define=SCREENSHOT_PREVIEW=true`.

Capture caveat: normal targeted widget screenshot capture still stalls during test teardown after image export. For asset production, use the capture-only exit flag:

```powershell
flutter test tool\store_screenshot_capture_test.dart --name "captures 02 early gameplay screenshot" --dart-define=SCREENSHOT_EXIT_AFTER_CAPTURE=true --reporter expanded
```

That command writes the requested source PNG, then exits the capture process. The Flutter test runner reports `did not complete`; treat that as a known asset-capture harness limitation, not a passing test result. Do not use mocked gameplay, fake UI, old Arrow Puzzle screenshots, or unavailable features.

## Feature Graphic

Current asset: `store_assets/feature_graphic/feature-graphic.png`

Status: final S3B asset regenerated and locally QA-checked on 2026-08-15. It is a 1024 x 500 24-bit PNG without alpha, shows Weather Lab Sort text, weather vessels, and real theme colors, and avoids fake claims or unavailable features. It still needs final Play Console upload preview for crop and safe-area fit.

Required export: 1024 x 500 JPEG or 24-bit PNG without alpha.

Recommended concept: Weather vessels arranged as a clean central puzzle scene, with rain, sun, mist, cloud, and frost layers visible in glass vessels. Use the app palette: weather blue, sunny yellow, mist green, cloud violet, frost cyan, and soft off-white. Keep all important visuals inside the central safe area.

Copy direction: either no text or one short line, `Weather Lab Sort`. Avoid claims such as "best", "#1", "free", "new", rankings, awards, downloads, or install calls.

Regeneration script: `tool/generate_weather_lab_feature_graphic.ps1`

Alt text: Weather Lab Sort feature graphic with weather vessels containing rain, sun, mist, cloud, and frost layers.

Production prompt if generating a bitmap alternative:

```text
Create a 1024 x 500 Google Play feature graphic for an original mobile puzzle game named Weather Lab Sort. Show a bright, clean weather-lab puzzle scene with glass vessels containing stacked liquid layers: rain blue, sun yellow, mist green, cloud violet, and frost cyan. Use a calm light background with subtle weather-line patterns. Keep the central vessels large and readable, no phone frame, no ranking badges, no fake awards, no Google Play badge, no sale or download call-to-action. Optional small text: Weather Lab Sort.
```

## App Icon Brief

Required Play icon export: 512 x 512, 32-bit PNG with alpha, max 1024 KB.

Current status: final S4B assets generated and locally QA-checked on 2026-08-15. Play upload icon is `store_assets/app_icon/play-icon-512.png`. Master source is `store_assets/app_icon/weather-lab-sort-icon-source-1024.png`. Android launcher PNGs and the iOS `AppIcon.appiconset` were regenerated from the same Weather Lab Sort source art.

Recommended concept: a compact square lab vessel silhouette with three stacked weather layers: blue rain drop, yellow sun band, and green mist swirl. Use strong contrast and no text. The icon should read clearly at small size and should not look like existing water-sort tube icons.

Alternative concepts:

- Weather droplet prism: a single rounded drop split into rain, sun, mist, cloud, and frost bands.
- Mini vessel trio: three small glass vessels with distinct weather icons, arranged in a clean triangular composition.
- Forecast flask: a simple flask containing layered weather essences with a small sparkle mark.

Production prompt if generating a bitmap asset:

```text
Create a 512 x 512 app icon for an original puzzle game named Weather Lab Sort. Use a simple rounded square composition with one stylized glass weather vessel containing three clear stacked layers: rain blue with a water drop, sun yellow with a small sun, and mist green with a wind swirl. Clean vector-like mobile icon style, high contrast, no text, no badges, no rankings, no price or sale labels, transparent-safe edges.
```

Regeneration script: `tool/generate_weather_lab_app_icons.ps1`

Launcher notes: Android manifest points to `@mipmap/ic_launcher`, which is generated in each `mipmap-*` density. iOS AppIcon PNGs are generated under `ios/Runner/Assets.xcassets/AppIcon.appiconset/`. Verify final launcher masking with a real build/device or store upload preview before release.

## Preview Video Script

Recommendation: useful after real footage capture because the pour interaction and completion feedback are easier to understand in motion.

Format: portrait, 20-30 seconds, built from real captured gameplay. Upload as one public or unlisted YouTube URL with ads disabled, no playlist URL, no extra URL parameters.

Production package: `store_assets/preview_video/`.

Current status: S5B production package created on 2026-08-15 with shot list, captions, voiceover text, capture steps, YouTube checklist, and Play Console QA checklist. No final preview video has been rendered or uploaded because truthful video production requires real motion footage from an installed app.

| Time | Real footage | On-screen text | Voiceover option |
| --- | --- | --- | --- |
| 0-3s | Home dashboard, then tap Play Forecast | Start sorting | Sort weather essences at your pace. |
| 3-8s | Early valid pour into an empty or matching vessel | Tap, pour, sort | Tap, pour, and plan each move. |
| 8-13s | Invalid move feedback on full or mismatched vessel | Clear feedback | The game shows what can move next. |
| 13-19s | Mid-level puzzle with more colors and Pace HUD visible | 50 forecast levels | New weather essences appear as levels grow. |
| 19-25s | Level complete screen with stars, next Lab Goal, replay/continue | Beat your best | Finish cleanly, replay, and improve your score. |
| 25-28s | Campaign map or home Lab Goals panel | Weather Lab Sort | Calm offline sorting puzzles. |

Do not include ads, fake ratings, fake reviews, fake downloads, unavailable boosters, maps, shops, story, events, or any old Arrow Puzzle footage.

## Keywords To Use Carefully

- water sort
- liquid sort
- color puzzle
- logic puzzle
- relaxing puzzle

Avoid keyword stuffing or repeating phrases unnaturally in the title or description.

## Graphics Checklist

- App icon: Play 512 x 512 icon generated at `store_assets/app_icon/play-icon-512.png`; local specs verified.
- Launcher icons: Android mipmap icons and iOS AppIcon set regenerated from Weather Lab Sort source art.
- Feature graphic: produced at `store_assets/feature_graphic/feature-graphic.png`; local specs verified, Play Console crop/safe-area preview still required.
- Phone screenshots: 6 portrait upload candidates created in `store_assets/screenshots/weather_lab_sort_phone/final_png/`.
- Screenshot source must be real Weather Lab Sort gameplay/UI, not old Arrow Puzzle captures.
- Current screenshot source template: `tool/store_screenshot_capture_test.dart`.
- Capture harness caveat: capture-only commands write files but report `did not complete`; see Screenshot Production Status.
- Existing old Arrow Puzzle screenshot PNGs and raw `source_png/` files are not upload-ready.
- Preview video: production package exists in `store_assets/preview_video/`; final video still requires real gameplay recording and YouTube upload.

## Review Notes Draft

No login is required. All current content is available through normal gameplay progression. The game stores puzzle progress locally on-device. Ads may appear only at level-end transitions, and analytics records gameplay/ad events without names, email, contacts, precise location, photos, or free-text input.

## Play Console Upload Checklist

- Confirm display name is `Weather Lab Sort`.
- Confirm package name is `com.childhood.weatherlabsort`.
- Do not upload stale Arrow Puzzle store assets.
- Do not upload raw `source_png/` captures or stale `06-30-handcrafted-levels.png`.
- Use the final Weather Lab Sort screenshots in `store_assets/screenshots/weather_lab_sort_phone/final_png/`.
- Keep screenshot overlays below 20% of the image area.
- Upload app icon: 512 x 512 PNG with alpha, max 1024 KB.
- Upload feature graphic: 1024 x 500 JPEG or 24-bit PNG without alpha.
- Upload at least 3 game screenshots; use 6 portrait screenshots for this v1 listing.
- Add alt text for each screenshot and graphic, 140 characters or less.
- If adding preview video, use a public or unlisted YouTube URL with ads disabled and no extra URL parameters.
- Do not show unavailable boosters, maps, shops, events, rewards, rankings, awards, reviews, downloads, or earnings.
- Complete Ads declaration, Data safety, target audience, content rating, app access, support email, and privacy policy before release.

## Official References

- Google Play store listing best practices: https://support.google.com/googleplay/android-developer/answer/13393723
- Google Play preview asset requirements: https://support.google.com/googleplay/android-developer/answer/9866151
- Google Play asset library: https://support.google.com/googleplay/android-developer/answer/16386748
