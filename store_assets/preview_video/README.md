# Dots and Boxes Preview Video Package

This folder contains the production package for the Google Play preview video.
It does not contain a final MP4 because real gameplay capture was not approved
for this task.

## Status

- Package type: production package only.
- Final video rendered: no.
- Gameplay footage captured: no.
- YouTube upload performed: no.
- App/device/emulator launched: no.

## Approved Direction Used

- Show real Dots and Boxes gameplay.
- Keep the first 30 seconds strong.
- Do not fake board states, scores, bot moves, match results, or animations.
- Do not show unavailable online play, leaderboards, shop, tournaments, login,
  cloud sync, hints, undo, live events, or rewards.
- Do not show ads in the video.
- Use the real app palette, board UI, menu flow, and result screen.

## Real Product Sources

- `README.md`: production v1 scope, modes, board presets, rule locks, ads/analytics notes.
- `lib/main.dart`: app title, menu flow, board/HUD screens, palette, result states.
- `lib/game/dots_and_boxes.dart`: rule engine for lines, boxes, scoring, extra turns, game over.
- `lib/game/dots_and_boxes_bot.dart`: Casual and Tactical bot difficulties.
- `store_assets/screenshots/screenshot-production-brief.md`: real capture states and truthfulness rules.
- `store_assets/feature_graphic/dots-and-boxes-feature-graphic.png`: Play feature graphic and optional YouTube thumbnail source.
- `store_assets/app_icon/dots-and-boxes-play-store-icon-512.png`: Play icon source.

## Files

- `production-package.md`: timeline, editing plan, shot list, audio, render specs, QA.
- `shot-list.md`: capture-ready shot table with exact app moments.
- `capture-checklist.md`: real gameplay capture steps.
- `captions.srt`: subtitle timing draft.
- `voiceover.txt`: optional voiceover script.
- `youtube-upload-checklist.md`: YouTube settings and policy checklist.
- `play-console-video-checklist.md`: Play Console preview video checklist.

## Recommended Output

- Orientation: portrait.
- Resolution: 1080 x 1920.
- Duration target: 24 seconds.
- Frame rate: 30 FPS.
- Format: MP4.
- Video codec: H.264.
- Audio codec: AAC.
- Subtitles: burned in.

## Important Limitation

All UI footage must be captured from the real current app before rendering.
Generated screens, manually edited board states, fake scores, and fake result
states are not allowed.
