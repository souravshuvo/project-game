# Weather Lab Sort Screenshot Package

Last updated: 2026-08-15

## Status

Final Play upload candidates are in `final_png/`.

These files are 1080 x 1920, portrait, 24-bit PNG without alpha. They use real
Weather Lab Sort widget UI captures as the source, with only the approved S2
storyboard headline added above each screen.

Do not upload:

- `store_assets/screenshots/phone/` because those files show the older Arrow Puzzle prototype.
- `source_png/` directly because those files are raw 32-bit capture sources.
- `source_png/06-30-handcrafted-levels.png` because it is stale and refers to the older 30-level state.

## Final Files

| Slot | Final file | Overlay copy | Alt text |
| --- | --- | --- | --- |
| 1 | `final_png/01-calm-sorting-puzzles.png` | Calm Sorting Puzzles | Weather Lab Sort home screen with campaign progress, current mission, and lab goals. |
| 2 | `final_png/02-tap-pour-sort.png` | Tap, Pour, Sort | Early level gameplay showing weather vessels, move pace, and tap-to-pour guidance. |
| 3 | `final_png/03-plan-each-pour.png` | Plan Each Pour | Harder weather sorting level with rain, sun, mist, and cloud vessels visible. |
| 4 | `final_png/04-clear-feedback.png` | Clear Feedback | Gameplay screen showing an invalid move message and highlighted vessel feedback. |
| 5 | `final_png/05-improve-your-score.png` | Beat Your Best | Level complete screen showing stars, best route progress, next lab goal, and replay options. |
| 6 | `final_png/06-50-forecast-levels.png` | 50 Forecast Levels | Campaign map showing completed, unlocked, and locked Weather Lab Sort forecast levels. |

## Source Template

The widget screenshot template is:

```powershell
flutter test tool\store_screenshot_capture_test.dart
```

Normal targeted widget-test capture still stalls during test teardown after the
image has been written. For asset production, run each named capture with the
capture-only exit flag:

```powershell
flutter test tool\store_screenshot_capture_test.dart --name "captures 02 early gameplay screenshot" --dart-define=SCREENSHOT_EXIT_AFTER_CAPTURE=true --reporter expanded
```

That command writes the requested source PNG, then exits the capture process.
The Flutter test runner reports `did not complete`; treat that as a known
asset-capture harness limitation, not a passing test result.

## Final Export QA

- Final files are 1080 x 1920.
- Final files are 24-bit PNG without alpha.
- Text and icons render as readable glyphs.
- No debug banner is visible.
- No old Arrow Puzzle gameplay is shown.
- No fake gameplay, unavailable boosters, ratings, awards, reviews, downloads, or install calls are shown.

## Optional Device Capture Path

If device screenshots are required later, after a build/install or device run is explicitly approved, use:

```powershell
.\tool\capture_store_screenshots.ps1 -Package com.childhood.weatherlabsort -OutputDirectory store_assets/screenshots/weather_lab_sort_phone/device_png
```

Review every captured image for readable text, clean status/navigation bars, no debug banner, no overlap, no fake gameplay, and no unavailable features.
