# Weather Lab Sort Preview Video Production Package

Last updated: 2026-08-15

## Status

No final preview video has been rendered or uploaded.

This package is ready for real footage capture and editing. It must be built
from real Weather Lab Sort gameplay recording. Do not make the final video from
static screenshots only, and do not show unavailable features.

## Target

- Format: portrait 9:16
- Recommended export: 1080 x 1920 MP4
- Duration: 28 seconds
- Destination: one public or unlisted YouTube URL for Google Play
- Audio: optional captured game feedback plus subtle royalty-safe background
  music; no copyrighted or ad-monetized music

## Approved Script

| Time | Real footage | On-screen text | Voiceover option |
| --- | --- | --- | --- |
| 0-3s | Real gameplay mid-pour or immediate valid pour | Sort the Forecast | Sort weather essences into clean routes. |
| 3-6s | Home dashboard, tap Play Forecast | Pick Up Fast | Jump into the next forecast. |
| 6-11s | Valid tap-pour sequence into empty or matching vessel | Tap. Pour. Plan. | Every pour matters. |
| 11-15s | Invalid move feedback, then corrected move | Clear Feedback | Mistakes are easy to read and quick to fix. |
| 15-20s | Harder board with multiple weather essences and Pace HUD | Chase 3 Stars | Beat par, build a cleaner route. |
| 20-24s | Pause/settings overlay with sound and haptic toggles | Play Your Way | Keep sessions calm and focused. |
| 24-28s | Level complete screen with stars, best route, replay/continue | Beat Your Best | Replay, improve, and continue the campaign. |

## Required Real Capture

Capture from a real installed app, physical device preferred. Use the current
package name:

```powershell
com.childhood.weatherlabsort
```

If the app is already installed on a connected Android device:

```powershell
adb shell monkey -p com.childhood.weatherlabsort 1
adb shell screenrecord --bit-rate 8000000 --time-limit 35 /sdcard/weather-lab-sort-preview-raw.mp4
adb pull /sdcard/weather-lab-sort-preview-raw.mp4 store_assets/preview_video/raw_capture/weather-lab-sort-preview-raw.mp4
adb shell rm /sdcard/weather-lab-sort-preview-raw.mp4
```

During recording, manually perform the shot list in order. Keep taps clean and
slow enough to read, but do not pause on static screens longer than the timing
requires.

If the app is not installed, build/install/run must be approved separately
before recording. Do not use old Arrow Puzzle footage.

## Edit Notes

- Start with gameplay motion, not a title card.
- Keep at least 80% of the video actual app UI/gameplay.
- Use quick cuts; avoid slow decorative transitions.
- Keep captions large, centered near the top or lower safe area, never over
  active vessels or primary buttons.
- Use the feature graphic only as the YouTube thumbnail or end-card reference,
  not as a substitute for gameplay footage.
- Do not include ads, app store badges, fake ratings, fake reviews, rankings,
  awards, download counts, sale labels, shops, events, boosters, online play, or
  unavailable rewards.

## Supporting Assets

- Feature graphic: `store_assets/feature_graphic/feature-graphic.png`
- App icon: `store_assets/app_icon/play-icon-512.png`
- Screenshot references: `store_assets/screenshots/weather_lab_sort_phone/final_png/`
- Captions: `captions.srt`
- Shot list: `shot-list.md`

## YouTube Upload Checklist

- Upload as public or unlisted, not private.
- Disable monetization and ads.
- Do not use copyrighted music that can trigger ads.
- Allow embedding.
- Do not age-restrict the video.
- Use the direct video URL, not a playlist/channel URL and not a URL with extra
  tracking parameters.
- Use the feature graphic or a real gameplay frame as the thumbnail.

## Play Console Video Checklist

- Paste one YouTube URL in the preview video field.
- Confirm the first 10 seconds show actual gameplay and app UI.
- Confirm no black bars.
- Confirm the video reflects the current app version.
- Confirm no unavailable features or fake claims appear.
- Confirm audio is not essential to understanding because autoplay can be muted.
- Confirm the feature graphic still works as the video cover image.

## Final QA Checklist

- Real Weather Lab Sort gameplay appears in every gameplay shot.
- Home, gameplay, invalid feedback, pause/settings, and result screens are shown.
- Text overlays are readable on phone screens.
- Touch targets, HUD, vessels, and results are not obscured by captions.
- Sound/haptic settings are shown truthfully, without claiming custom music or
  unavailable audio features.
- No old Arrow Puzzle UI appears.
- No ads appear in the preview video.
- No fake rewards, rankings, reviews, downloads, or install calls appear.

## Remaining Risk

Final video rendering is blocked until real motion footage is captured from an
installed app. Static screenshots are available for reference, but they are not
enough to produce a truthful preview video by themselves.
