# Dew Bubble Garden Preview Video Production Package

S5B output for Google Play preview video production. This package does not include a final rendered video because real app capture, emulator/device launch, and screen recording were not approved. Do not create the final video until every required clip below is captured from the actual running app.

## Recommendation

Create a short portrait Google Play preview video. Dew Bubble Garden is a phone-first portrait game, and the core value is easiest to understand when viewers see the aim line, wall bounce, match pop, floating drop, and win result in motion.

## Delivery Specs

| Item | Spec |
| --- | --- |
| Target duration | 28 seconds |
| Orientation | Portrait |
| Suggested edit canvas | 1080x1920 |
| Frame rate | 30 FPS |
| Format for local master | MP4, H.264 video, AAC audio |
| Play Console input | Standard YouTube video URL |
| Audio | Real app sounds plus optional light royalty-free music |
| Subtitles | Burned in or uploaded captions; must work muted |

## Real Capture Inputs Required

Place final captured clips in `docs/play-store-assets/preview-video/captures/` before editing:

| Clip ID | Expected filename | Required real content | Status |
| --- | --- | --- | --- |
| C01 | `c01-home-open.mp4` | Home screen opening Dew Bubble Garden. | Needed |
| C02 | `c02-garden-route.mp4` | Garden Route with real unlocked/locked stages and saved stars. | Needed |
| C03 | `c03-aim-bounce.mp4` | Gameplay aiming with wall-bounce guide visible. | Needed |
| C04 | `c04-shot-match-drop.mp4` | Shot attaching, match popping, floating bubbles dropping. | Needed |
| C05 | `c05-win-result.mp4` | Real win result with stars, score, Next Stage, Replay Stage, Route, and Home actions. | Needed |
| C06 | `c06-pause-help-settings.mp4` | Pause/help/settings sheet with sound and haptic toggles. | Needed |

Important: C01 should be captured only after confirming the Home screen has no ad-free or offline-only claim unless production ads and analytics are disabled.

### Exact capture commands (real-footage only)

When capture is permitted, use these minimal ADB steps and pull each clip to the project.

```sh
adb devices
adb shell mkdir -p /sdcard/dewbubble/captures
adb shell screenrecord /sdcard/dewbubble/captures/c01-home-open.mp4
adb pull /sdcard/dewbubble/captures/c01-home-open.mp4 docs/play-store-assets/preview-video/captures/c01-home-open.mp4
adb shell rm /sdcard/dewbubble/captures/c01-home-open.mp4

adb shell screenrecord /sdcard/dewbubble/captures/c02-garden-route.mp4
adb pull /sdcard/dewbubble/captures/c02-garden-route.mp4 docs/play-store-assets/preview-video/captures/c02-garden-route.mp4
adb shell rm /sdcard/dewbubble/captures/c02-garden-route.mp4

adb shell screenrecord /sdcard/dewbubble/captures/c03-aim-bounce.mp4
adb pull /sdcard/dewbubble/captures/c03-aim-bounce.mp4 docs/play-store-assets/preview-video/captures/c03-aim-bounce.mp4
adb shell rm /sdcard/dewbubble/captures/c03-aim-bounce.mp4

adb shell screenrecord /sdcard/dewbubble/captures/c04-shot-match-drop.mp4
adb pull /sdcard/dewbubble/captures/c04-shot-match-drop.mp4 docs/play-store-assets/preview-video/captures/c04-shot-match-drop.mp4
adb shell rm /sdcard/dewbubble/captures/c04-shot-match-drop.mp4

adb shell screenrecord /sdcard/dewbubble/captures/c05-win-result.mp4
adb pull /sdcard/dewbubble/captures/c05-win-result.mp4 docs/play-store-assets/preview-video/captures/c05-win-result.mp4
adb shell rm /sdcard/dewbubble/captures/c05-win-result.mp4

adb shell screenrecord /sdcard/dewbubble/captures/c06-pause-help-settings.mp4
adb pull /sdcard/dewbubble/captures/c06-pause-help-settings.mp4 docs/play-store-assets/preview-video/captures/c06-pause-help-settings.mp4
adb shell rm /sdcard/dewbubble/captures/c06-pause-help-settings.mp4
```

## Timeline

| Time | Source | Visual | On-screen text | Voiceover |
| --- | --- | --- | --- | --- |
| 0.0-2.5s | C01 | Home screen transitions into the game. | Dew Bubble Garden | Step into a calm bubble garden. |
| 2.5-5.5s | C02 | Garden Route, choose an unlocked stage. | Pick a puzzle | Choose a short garden stage. |
| 5.5-11.5s | C03 | Aim line and wall bounce preview. | Line up the bounce | Aim, bounce, and plan the clear. |
| 11.5-18.0s | C04 | Shot lands, match pops, floating bubbles drop. | Match 3 and clear | Match three dew bubbles and drop loose clusters. |
| 18.0-23.0s | C05 | Win result with score and stars. | Win stars | Clear the board before shots run out. |
| 23.0-28.0s | C06 | Pause/help/settings or next-level glimpse. | Quick retries | Replay, adjust feedback, or keep going. |

### Optional render workflow (finalized clips present)

1. Verify all six clips exist and are captured at or above 1080x1920 with no overlays covering game UI.
2. Normalize duration and trim in your editor, matching the timeline table above.
3. Render as one 28-second MP4 with readable captions/subtitles.
4. Export with h.264, AAC, and `yuv420p` for broad playback.

Command template (if using FFmpeg locally):

```powershell
mkdir docs\play-store-assets\preview-video\render
@(
  "file 'captures/c01-home-open.mp4'",
  "file 'captures/c02-garden-route.mp4'",
  "file 'captures/c03-aim-bounce.mp4'",
  "file 'captures/c04-shot-match-drop.mp4'",
  "file 'captures/c05-win-result.mp4'",
  "file 'captures/c06-pause-help-settings.mp4'"
) | Set-Content docs/play-store-assets/preview-video/render/preview-list.txt

ffmpeg -f concat -safe 0 -i docs/play-store-assets/preview-video/render/preview-list.txt `
  -vf "fps=30,scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" `
  -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -c:a aac -b:a 160k `
  docs/play-store-assets/preview-video/render/dew-bubble-garden-preview.mp4

ffmpeg -i docs/play-store-assets/preview-video/render/dew-bubble-garden-preview.mp4 `
  -vf "subtitles=docs/play-store-assets/preview-video/captions-en.srt:force_style='Fontsize=36,Alignment=2'" `
  -c:a copy `
  docs/play-store-assets/preview-video/render/dew-bubble-garden-preview-captioned.mp4
```

## Editing Notes

- Start with real app UI within the first 2 seconds.
- Keep at least 80% real app UI/gameplay footage.
- Use the feature graphic only as a poster frame or a very short opening/ending card, not as the main video.
- Do not show ads, rewarded ads, shop, boosters, map progression, characters, reviews, ratings, awards, download counts, or fake rewards.
- Do not show people tapping a device, touch indicators, debug banners, notifications, or private account data.
- Keep cuts simple: straight cuts or quick dissolves. Avoid slow decorative transitions.
- Text overlays should stay inside safe margins and avoid covering the board, HUD, buttons, result actions, or pause controls.
- If captured sound is noisy, mute clip audio and use only clean app sounds/music that you have rights to use.

## Voiceover

Use voiceover only if it sounds natural and does not fight the app sounds. If a high-quality voice is not available, use captions only.

Final voiceover script:

1. Step into a calm bubble garden.
2. Choose a short garden stage.
3. Aim, bounce, and plan the clear.
4. Match three dew bubbles and drop loose clusters.
5. Clear the board before shots run out.
6. Replay, adjust feedback, or keep going.

## Caption Text

Use these exact captions unless the final edit timing changes:

1. Dew Bubble Garden
2. Pick a puzzle
3. Line up the bounce
4. Match 3 and clear
5. Win stars
6. Quick retries

## Audio Direction

- Use real game feedback sounds where captured cleanly.
- Optional music: gentle, bright, short-loop instrumental with clear rights for YouTube and Google Play use.
- Do not use copyrighted commercial music.
- Do not let music overpower pop/drop/win feedback.
- Avoid sudden loud sounds; keep the mix comfortable for child-friendly gameplay.

## Supporting Assets

Existing assets that may be used:

- `docs/play-store-assets/feature-graphic-dew-bubble-garden.png` as YouTube thumbnail or poster frame.
- `docs/play-store-assets/app-icon-dew-bubble-garden-play-512.png` only in end slate if needed.

No generated UI or fake gameplay support assets are approved for this video.

## Capture Steps

1. Use a clean release-like or internal-test build.
2. Confirm no ad-free or offline-only claim is visible unless ads and analytics are disabled.
3. Disable debug banners and screen-recording touch indicators.
4. Start with fresh progress for C01, then play naturally to create real progress for C02 and C05.
5. Record C03 with a clearly visible upward aim and wall-bounce line.
6. Record C04 from a real level where a match and floating drop happens naturally.
7. Record C05 immediately after a real win.
8. Record C06 from the pause sheet with sound/haptic controls visible.
9. Trim clips without changing UI values, positions, scores, stars, or game state.
10. Export the master and review it on a phone-sized screen before upload.

## YouTube Upload Checklist

- [ ] Upload as a standard YouTube video, not a Short.
- [ ] Set visibility to public or unlisted, not private.
- [ ] Disable monetization/ads for the video.
- [ ] Ensure the video is not age-restricted.
- [ ] Ensure embedding is allowed.
- [ ] Use a direct video URL, not a playlist, channel, Shorts URL, or URL with time parameters.
- [ ] Avoid copyrighted music or visuals that can trigger monetization claims.
- [ ] Use the feature graphic or a real gameplay frame as the thumbnail.
- [ ] Localize captions/video later for other store locales.

## Play Console Video Checklist

- [ ] Feature graphic exists and is uploaded before/with the preview video.
- [ ] Preview video URL is a direct YouTube video URL.
- [ ] First 10 seconds show real gameplay/app experience.
- [ ] At least 80% of video is real app UI/gameplay.
- [ ] No ads appear in the video.
- [ ] No unsupported features or misleading claims appear.
- [ ] No calls to action like "download now" or "install now".
- [ ] Captions are readable with muted autoplay.
- [ ] The final video sets accurate expectations for Dew Bubble Garden.

## QA Checklist

- [ ] Final duration is 20-30 seconds.
- [ ] No black bars.
- [ ] All UI footage is real captured gameplay.
- [ ] Gameplay is readable on a phone screen.
- [ ] Overlay text is short and readable.
- [ ] Subtitles/captions are synchronized.
- [ ] Audio is present or intentionally caption-only.
- [ ] Audio is not clipped or too loud.
- [ ] The Home shot does not show an inaccurate ad-free or offline-only claim.
- [ ] No debug UI, emulator chrome, notifications, or personal data are visible.
- [ ] YouTube settings match Google Play preview video requirements.

## Remaining Risks

- No final video can be rendered until real capture clips exist.
- Final Home footage still needs a real capture pass after production ads and analytics settings are finalized.
- Real capture may reveal layout, contrast, or animation issues that are not visible from static code inspection.
- YouTube upload settings and copyright/monetization status cannot be verified until upload.

## Source Checked

- Google Play Help: Add preview assets to showcase your app: https://support.google.com/googleplay/android-developer/answer/9866151
