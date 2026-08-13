# Cloud Courier Climb Preview Video Production Package

Prompt S5B package for the Google Play preview video. This package is ready for an editor or a later approved capture pass, but it does not include a final uploaded or rendered MP4 because real device/emulator recording was not approved.

## Production Status

| Item | Status | Notes |
| --- | --- | --- |
| Final MP4 | Not created | Avoids fake gameplay and respects the no-run/no-recording rule. |
| Real UI evidence | Included | Six approved app-rendered screenshots are copied into `assets/ui/`. |
| Motion capture | Still needed | Capture real gameplay from the app before final export. |
| Ads in video | Not allowed | Do not show rewarded revive, interstitials, ad buttons, or ad loading states. |
| Unavailable features | Not allowed | No skins, shop, leaderboard, login, cloud sync, events, or extra modes. |

## Target Render

| Setting | Value |
| --- | --- |
| Duration | 24 seconds target, acceptable range 20-30 seconds |
| Orientation | Portrait |
| Resolution | 1080 x 1920 |
| Frame rate | 30 fps |
| Container | MP4 |
| Video codec | H.264 |
| Audio codec | AAC |
| YouTube visibility | Public or unlisted |

## Real Source Evidence

| Asset | Use |
| --- | --- |
| `assets/ui/01_start_a_sky_route.png` | Main menu, first action, app name, start/help/settings availability. |
| `assets/ui/02_hold_to_steer.png` | Active game HUD and left/right touch controls. |
| `assets/ui/03_collect_signal_motes.png` | Pickup and score/progress moment. |
| `assets/ui/04_avoid_warning_sparks.png` | Visible hazard readability moment. |
| `assets/ui/05_complete_route_stamps.png` | Route complete/result state. |
| `assets/ui/06_restart_fast.png` | Game over/restart state. |

These screenshots may be used for storyboard, edit references, or still inserts. The final preview should prioritize real recorded gameplay motion from the app.

## 24 Second Shot List

| Time | Real capture action | Caption | Voiceover | Edit notes |
| --- | --- | --- | --- | --- |
| 0.0-2.5s | Show the main menu with `START RUN` visible. | Start a sky route | Start a small sky route. | Quick push-in from the menu. No fake buttons or store badges. |
| 2.5-5.5s | Tap `START RUN`; show the courier entering the first jumps. | Tap to begin | Tap start and keep the jump moving. | Use the actual tap and the first auto-jump. Keep debug banners hidden. |
| 5.5-9.0s | Hold LEFT, then RIGHT, and land on two pads. | Hold to steer | Hold left or right to steer each landing. | Show readable touch controls and one clean landing feedback moment. |
| 9.0-12.5s | Collect one or more gold signal motes while climbing. | Collect signal motes | Collect signal motes for route progress. | Let score/progress change be visible for at least 0.5s. |
| 12.5-16.5s | Approach a red warning spark, steer around it, and land safely. | Avoid warning sparks | Read the red sparks before you commit. | Hazard must be visible before the dodge. Do not show unfair hits. |
| 16.5-20.5s | Show route stamps/score increasing or route complete if captured naturally. | Complete route stamps | Finish the route and chase a cleaner climb. | Use real HUD/result state only. No unsupported win claims. |
| 20.5-24.0s | Show result screen and tap restart, or show a fast restart from game over. | Restart fast | Restart fast and try for your best score. | End on app title or restart action. Avoid ad/revive UI. |

## Caption Text

Use short, high-contrast captions near the upper safe area or lower third, away from HUD values and control buttons.

1. Start a sky route
2. Tap to begin
3. Hold to steer
4. Collect signal motes
5. Avoid warning sparks
6. Complete route stamps
7. Restart fast

## Voiceover Script

Voiceover is optional. If used, keep it calm and clear:

> Start a small sky route. Tap start and keep the jump moving. Hold left or right to steer each landing. Collect signal motes for route progress. Read the red sparks before you commit. Finish the route and chase a cleaner climb. Restart fast and try for your best score.

If no voiceover is used, use light UI tap sounds and subtle music only after checking Play policy and licensing. Do not use unlicensed music or copied sound effects.

## Editing Notes

- Open with the app name or start screen within the first second.
- Keep every cut grounded in real app footage or the approved app-rendered screenshots.
- Use simple cuts, short push-ins, and light speed ramps only where the real gameplay remains understandable.
- Do not add fake particles, fake scores, fake route labels, fake unlocks, fake awards, or fake social proof.
- Do not add ads, monetization prompts, or rewarded revive shots.
- Keep captions readable on a phone preview. Avoid placing text over HUD counters or the LEFT/RIGHT controls.
- Use the game colors honestly: teal sky, gold signal motes, pale platforms, and red warning sparks.
- End with a clean result/restart moment, not a long failure state.
- Do not show people interacting with a device, desktop cursor movement, emulator chrome, or recording controls.
- Keep at least 80% of the final video representative of the actual in-game experience.

## Real Gameplay Capture Steps

1. Use a production-like app build with the final app name and package name.
2. Disable debug banners and developer overlays.
3. Disable live ads or use an ad-free preview build so no ad UI appears.
4. Start from the main menu.
5. Record portrait video at 1080 x 1920 or the device native portrait size.
6. Capture one clean run that includes start, steering, landing, pickup collection, hazard avoidance, score/progress change, result, and restart.
7. Capture extra takes for close timing: one pickup collection, one near-hazard dodge, one route complete/result screen, and one restart.
8. Reject takes with accidental ad prompts, unavailable screens, unreadable HUD, clipped controls, debug banners, frame drops, or visible recording UI.
9. Export only real captured app footage, optionally mixed with the approved real screenshots as still inserts.

## YouTube Upload Checklist

- Upload the final MP4 to YouTube only after QA passes.
- Use public or unlisted visibility. Do not use a private video.
- Use a direct watch URL, such as `https://www.youtube.com/watch?v=VIDEO_ID`.
- Do not use a playlist, channel, Shorts-only, redirected URL, or a URL with timecode/query parameters.
- Confirm the video is embeddable.
- Confirm the video is not age-restricted.
- Title suggestion: `Cloud Courier Climb - Gameplay Preview`.
- Description should avoid fake claims, awards, rankings, download counts, reviews, or unsupported features.
- Turn off monetization and avoid copyrighted music/content that could create monetization claims or ads.

## Play Console Video Checklist

- Preview video matches the actual app and current store listing.
- Core gameplay appears within the first 10 seconds.
- First 30 seconds show real gameplay clearly.
- No ads appear in the video.
- No fake gameplay, fake UI, fake rankings, fake awards, fake download counts, or fake reviews.
- No skins, shops, leaderboards, login, cloud sync, live events, or extra modes appear unless they are actually in the app.
- Captions are readable on mobile.
- Package and app identity remain consistent with `com.childhood.cloudcourierclimb` and Cloud Courier Climb.

## Final QA Checklist

- Video opens with a clear first action in under 3 seconds.
- The final edit is mostly real gameplay, not title cards or promotional filler.
- Controls are understandable from footage alone.
- Hazards are visible before they matter.
- Score/progress feedback is visible.
- Result/restart flow is visible.
- No HUD, caption, button, or overlay overlap makes gameplay hard to read.
- No debug banner, emulator chrome, notification shade, recording dot, cursor, or desktop UI is visible.
- Audio is licensed, optional, and not louder than voiceover.
- Export is MP4, H.264, AAC, portrait, and within 20-30 seconds.

## Remaining Risks

- A final Play-ready preview URL still requires approved real gameplay recording and MP4 export.
- Current included screenshots are real app-rendered evidence, but they are not a substitute for true gameplay motion if the final preview is expected to show movement.
- Final QA should be repeated after any UI, gameplay, app name, package, ad, or store listing change.
