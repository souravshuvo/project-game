# Magnetic Marbles Preview Video Package

This folder contains the production package for the Google Play preview video.
It does not contain a final MP4 yet because real app capture, emulator launch,
device recording, upload, and final rendering were not approved for this step.

## Concept

Gate Choice Rush: a fast portrait gameplay cut that moves from home screen to
hold-and-drag launch, gate choice, crowd scaling, enemy clearing, level clear,
and the 30-level offline progression screen.

## Real Product Sources

- `docs/store_listing.md`: approved preview video script and shot list.
- `lib/features/home/presentation/home_screen.dart`: Home, Continue, Levels,
  progress chips, level select sheet, and tutorial copy.
- `lib/features/game/presentation/game_screen.dart`: active gameplay, pause,
  settings, HUD, result overlay, stars, Retry, Next, and Home.
- `lib/features/game/data/level_library.dart`: 30 offline v1 levels.
- `store_assets/feature_graphic/feature_graphic_1024x500.png`: Play feature
  graphic, not a replacement for real video footage.
- `store_assets/app_icon/play_store_icon_512.png`: Play listing icon.

## Delivery Status

- Production package: complete.
- Real gameplay captures: not included yet.
- Final MP4: not rendered.
- YouTube upload URL: not created.

## Target Render

- Orientation: portrait.
- Resolution: 1080 x 1920.
- Duration: 27 seconds.
- Frame rate: 30 FPS.
- Container: MP4.
- Video codec: H.264.
- Audio codec: AAC.
- Subtitles: burned in, high contrast, inside mobile-safe margins.

## Non-Negotiable Rules

- Use captured footage of the real app only.
- Do not include fake UI, mocked gameplay, edited impossible states, fake
  ratings, rankings, awards, downloads, shops, skins, leaderboards, or ads.
- Do not show device hands or generated phone footage.
- Do not use copyrighted music, sound effects, or video clips without rights.
- Do not use a YouTube Shorts URL, playlist URL, channel URL, or URL with
  timecode parameters for Play Console.

## Package Files

- `production-package.md`: complete timeline, capture plan, captions,
  voiceover, editing notes, upload checklist, and QA checklist.
- `shot-list.csv`: editor-friendly shot list.
- `assets/ui/README.md`: capture file naming and acceptance notes.
- `output/README.md`: expected final render outputs.
