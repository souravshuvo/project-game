# Signal Reef preview video production package

Status: ready for real capture and edit. No final video was rendered because there is no real gameplay footage in the repository, and device/emulator recording was not approved for this pass.

## Export target

- Purpose: Google Play preview video
- Duration: 20-30 seconds
- Recommended final length: 29 seconds
- Orientation: portrait 9:16
- Working resolution: 1080 x 1920
- Frame rate: 30 fps
- Source footage: real current Signal Reef app UI and gameplay only
- Delivery: upload one public or unlisted YouTube video URL, not a playlist or channel URL
- Audio: clean captured app feedback or light licensed arcade/synth music

## Shot list

| Time | Required real capture | On-screen text | Voiceover option | Editing notes |
| --- | --- | --- | --- | --- |
| 0:00-0:03 | Home screen with Signal Reef title visible; tap Play if the tap itself is captured by the screen recorder. | Signal Reef | Enter a quick signal run. | Open with real UI. Keep any ad area out of frame or use an ad-free capture configuration. |
| 0:03-0:06 | Ready overlay into the first wave. | Drag anywhere | Drag anywhere to steer. | Show the real onboarding hint before motion begins. |
| 0:06-0:11 | Early gameplay with the player dodging Drift Nodes while auto-firing. | Auto-fire shots | Shots fire automatically. | Use a clean moment with HUD, player, and enemies readable. |
| 0:11-0:16 | A signal shot visibly bounces off a side wall and travels toward enemies. | Bounce through waves | Bounce shots through compact waves. | This is the hook shot. Hold long enough for the bounce to be understood. |
| 0:16-0:21 | Pulse Seed or red projectile pressure with clear dodge space. | Read the danger | Watch the pattern, then slip through. | Avoid chaotic footage. Danger should look fair, not random. |
| 0:21-0:25 | Score increase or wave clear moment from a real run. | Clear 20 waves | Clear waves and chase your score. | Only use if the score/wave state is real and visible. |
| 0:25-0:29 | Result screen after a real win or loss with Play again visible. | Chase your best | Retry fast and improve your run. | Do not fabricate result values. Avoid showing ads. |

## Caption track

Use `captions-en.srt` as the starting caption file. If the final edit timing changes, update the SRT timestamps to match the rendered video exactly.

## Capture steps

1. Use the current Signal Reef build with package `com.childhood.signalreef`.
2. Record in portrait at 1080 x 1920 or a clean 9:16 source resolution.
3. Start from a fresh app state if possible so the home screen and first action are clear.
4. Capture the home screen, ready overlay, early gameplay, bounce shot, Pulse Seed pressure, score/wave clear, and result screen.
5. Do not record fingers, device frames, notification shade, system popups, debug banners, test labels, or unrelated apps.
6. Do not include banner, interstitial, rewarded, or test ads in the preview video.
7. If ads appear on home or result screens during capture, redo the recording with an appropriate ad-free capture configuration or avoid those frames.
8. Keep all gameplay footage from states that can occur naturally in the current build.

## Editing notes

- Put real gameplay in the first 10 seconds.
- Keep at least 80% of the video representative of real app use.
- Use hard cuts or very short fades only.
- Keep overlays large, high contrast, and away from HUD, player, enemies, bullets, buttons, and result data.
- Do not use fake explosions, fake UI, fake rewards, cinematic scenes, or generated gameplay.
- Do not include calls to action such as "download now", "install now", "play now", or "try now".
- Do not include awards, ratings, review quotes, rankings, price claims, sale claims, or download counts.

## Production assets

- Required source recording: real portrait gameplay capture
- Optional overlay text: use the exact shot-list copy
- Optional closed captions: `captions-en.srt`
- Optional audio: licensed music or captured game feedback only
- Cover/thumbnail: use the approved feature graphic or a real gameplay frame

## YouTube upload checklist

- [ ] Upload a single video, not a playlist or channel.
- [ ] Set privacy to public or unlisted, not private.
- [ ] Disable ads/monetization for the video.
- [ ] Ensure the video is embeddable.
- [ ] Do not age-restrict the video.
- [ ] Do not add timecode or tracking parameters to the URL used in Play Console.
- [ ] Confirm no copyrighted music or footage can trigger monetization claims.
- [ ] Confirm captions match the final edit timing.

## Play Console video checklist

- [ ] Preview video URL is a YouTube video URL.
- [ ] First 10 seconds show real Signal Reef UI/gameplay.
- [ ] Portrait video has no black bars.
- [ ] No unavailable bosses, upgrades, shops, leaderboards, multiplayer, cloud sync, extra ships, or live events are shown.
- [ ] No ads are visible in the video.
- [ ] Claims match the actual current build.
- [ ] Feature graphic still works as the video cover image.
- [ ] Final video has been watched end-to-end before upload.

## Remaining risks

- Final video cannot be QA-approved until real footage is recorded.
- Home and result screens may include ad placements in some configurations; preview footage must avoid visible ads.
- If gameplay balance or UI changes before upload, recapture the affected shots.
