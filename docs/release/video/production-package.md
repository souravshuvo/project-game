# Trail Arena Play Preview Video Production Package

## S5B Decision

Final video rendering was not performed in this pass.

Reason: the repository does not contain real gameplay recordings, and
device/emulator recording was not approved. Prompt S5B requires a complete
production package instead of fake app footage in this case.

This package is ready for a later real capture and edit pass.

## Real Product Evidence

- Store name: Trail Arena.
- Package name: `com.childhood.trailarena`.
- Real v1 gameplay: offline arena, drag steering, seed collection, growth,
  score, local best score, two offline rival trails, Trail Goals, Glide/Chase/
  Surge pacing, pause, settings, help, game over, and retry.
- Existing store assets:
  - `docs/release/assets/trail-arena-feature-graphic.png`
  - `docs/release/assets/trail-arena-play-icon.png`
- No real gameplay video file exists in the repository yet.

## Delivery Mode

Production package only.

Do not render or upload the preview video until real app footage is captured
from a current build. Do not use generated UI, edited scores, mock gameplay, or
recordings from another game.

## Final Video Specs

- Duration target: 27 seconds.
- Orientation: portrait 9:16.
- Resolution target: 1080 x 1920.
- Frame rate: 30 FPS.
- Format: MP4.
- Video codec: H.264.
- Audio codec: AAC.
- Audio: optional clean app audio plus licensed/royalty-safe music only.
- Captions: burn short captions into the edit and upload the SRT file.
- Black bars: none.
- Device frame: none.

## Story Concept

Quick offline arena run: the player starts, learns drag steering, collects
seeds, grows, dodges offline rival trails, sees a local goal, crashes, and
retries.

This is a gameplay-first trailer, not a human lifestyle trailer. Do not include
people tapping a device because the game experience is fully on-screen.

## Shot List

| Time | Real capture | On-screen text | Optional voiceover | Editing notes |
| --- | --- | --- | --- | --- |
| 0.0-3.0s | Main menu with Play button and local goal progress | Offline trail arena | Enter a quick offline arena run. | Start with app identity, then tap Play quickly. |
| 3.0-7.0s | Ready countdown into first movement | Drag to steer | Guide the glowing trail with simple drag controls. | Show real drag response and the first turn. |
| 7.0-12.0s | Normal seeds and bright seed pickup if it appears naturally | Grow with every seed | Collect seeds, score points, and get longer. | Use real score changes and pickup feedback. |
| 12.0-17.0s | Rival trails near the player | Watch every turn | Dodge walls, yourself, and offline rivals. | Keep offline rivals framed as hazards, not multiplayer. |
| 17.0-22.0s | Active Trail Goal progress during gameplay | Complete Trail Goals | Chase local goals across quick sessions. | Show only real goal progress from the current save. |
| 22.0-27.0s | Game over result with score and Retry | Retry and improve | Crash, learn, and jump back in. | End on the real retry flow, not a download prompt. |

## Capture Steps

1. Capture only after dependency setup, app launch, and device/emulator
   recording are explicitly approved.
2. Use a current build of Trail Arena with package `com.childhood.trailarena`.
3. Record portrait at 1080 x 1920 or higher and 30 FPS or higher.
4. Enable Do Not Disturb and remove personal notifications from the recording.
5. Do not show interstitials, banners, rewarded prompts, or ad loading states.
   If an ad appears, discard that take and capture again with an approved
   ad-free/internal test setup.
6. Start from the real main menu. Do not edit best score, runs, goals, or save
   state to create fake progress.
7. Record at least one clean first run from menu through game over.
8. Record an additional longer run only if needed for a real Chase or Surge
   segment.
9. Keep all raw source clips with filenames that include date, build, device,
   and take number.
10. Export a notes file listing which raw clip and time range was used for each
    final shot.

## Raw Clip Targets

| Clip | Needed content | Minimum usable length |
| --- | --- | --- |
| `raw-01-menu-to-ready` | Main menu, tap Play, countdown | 8 seconds |
| `raw-02-seed-growth` | Steering, seed pickup, score growth | 12 seconds |
| `raw-03-rival-trails` | Offline rivals near player without unfair crash | 10 seconds |
| `raw-04-goal-progress` | Active Trail Goal visible in HUD | 8 seconds |
| `raw-05-game-over-retry` | Real crash, result screen, Retry button | 8 seconds |

## Captions

Use `docs/release/video/captions-en.srt` as the English caption source.

Caption-only sequence:

1. Offline trail arena.
2. Drag to steer.
3. Grow with every seed.
4. Watch every turn.
5. Complete Trail Goals.
6. Retry and improve.

## Voiceover

Voiceover is optional. Caption-only is acceptable if the music and game audio
carry the pace.

Use the approved lines only:

1. Enter a quick offline arena run.
2. Guide the glowing trail with simple drag controls.
3. Collect seeds, score points, and get longer.
4. Dodge walls, yourself, and offline rivals.
5. Chase local goals across quick sessions.
6. Crash, learn, and jump back in.

Do not use AI voice or text-to-speech as final audio unless the voice license
and quality are confirmed. If guide voice is used during editing, label it as
temporary and replace it before upload.

## Audio Plan

- Use clean in-app sound effects if captured without distortion.
- Music must be licensed, royalty-safe, and free of monetization claims.
- Keep music below voiceover and subtitles readable when muted.
- Do not use copyrighted songs, copied game music, or recognizable audio from
  other games.
- Do not include ad audio.

## Editing Notes

- Show actual gameplay within the first 10 seconds.
- Keep at least 80% of the final video as real gameplay or real app UI.
- Use quick, smooth transitions only where they help pacing.
- Keep text overlays short, large, and high contrast.
- Do not cover the trail, score, active goal strip, pause button, result score,
  or retry button.
- Do not add visual effects that change gameplay meaning.
- Use the feature graphic only as a YouTube thumbnail or optional opening
  poster frame, not as a substitute for gameplay.

## Supporting Assets

- Feature graphic/possible YouTube thumbnail:
  `docs/release/assets/trail-arena-feature-graphic.png`
- Play icon/reference brand mark:
  `docs/release/assets/trail-arena-play-icon.png`

No generated human plates, fake phone mockups, or fake UI assets are approved
for this Play preview video.

## YouTube Upload Checklist

- [ ] Upload only after final MP4 is rendered from real gameplay footage.
- [ ] Use one YouTube video URL, not a playlist or channel URL.
- [ ] Do not include timecode or tracking parameters in the Play Console URL.
- [ ] Set visibility to public or unlisted, not private.
- [ ] Disable monetization and ads on the video.
- [ ] Avoid copyrighted audio that could still trigger ads through claims.
- [ ] Do not age restrict the video.
- [ ] Confirm the video is embeddable.
- [ ] Use a truthful thumbnail, preferably the approved feature graphic.
- [ ] Keep title/description free of fake rankings, awards, or download claims.

## Play Console Video Checklist

- [ ] URL is a single clean YouTube URL.
- [ ] Feature graphic is uploaded because it is used as the video cover.
- [ ] Video shows real app UI and gameplay.
- [ ] Core gameplay appears within the first 10 seconds.
- [ ] No ads appear in the video.
- [ ] No online multiplayer claim is implied.
- [ ] No unavailable skins, shop, leaderboard, login, cloud sync, or purchases
  are shown.
- [ ] Captions are available for muted/loud-environment viewing.
- [ ] No black bars, upside-down footage, debug banners, device frames, or
  notification clutter are visible.

## QA Checklist

- [ ] Final MP4 exists and is playable.
- [ ] Duration is 20-30 seconds.
- [ ] Resolution is 1080 x 1920 or better.
- [ ] Frame rate is 30 FPS.
- [ ] Codec is H.264 video with AAC audio.
- [ ] Captions are readable on a phone.
- [ ] First 10 seconds show real game experience.
- [ ] At least 80% of the video is representative gameplay or real app UI.
- [ ] All scores, goals, results, and crashes are from real captured runs.
- [ ] No fake UI, fake awards, fake ranking, fake reviews, or fake downloads.
- [ ] No copied art, maps, characters, music, branding, or existing game names.

## Remaining Risks

- Final MP4 cannot be produced until real device/emulator recording is approved.
- Current package cannot verify video duration, codec, audio, captions, or
  frame quality because no final video exists.
- If ads appear on menu/result screens during capture, a clean ad-free take is
  required before upload.
- Store video should be revalidated after any gameplay, HUD, ad, or progression
  change.

## Skipped Heavy Checks

- `flutter pub get`: skipped by instruction.
- `flutter run`: skipped by instruction.
- `flutter build`: skipped by instruction.
- Install/device/emulator launch: skipped by instruction.
- Device screen recording: skipped by instruction.
- Video render/upload: skipped because real captured footage is not available
  and uploading is explicitly disallowed.
