# Store Assets

The existing generated screenshots are blocked for Play Console upload until replaced with assets captured from the current Tik Tak Toe build.

Do not upload any store asset unless it was regenerated or captured from the current Tik Tak Toe build and reviewed against the Play Store metadata policy.

Current blocked files:

- `screenshots/phone/01-home.png`
- `screenshots/phone/02-levels.png`
- `screenshots/phone/03-gameplay.png`
- `screenshots/phone/04-hint.png`

At least `screenshots/phone/01-home.png` visibly belongs to the previous Arrow Puzzle prototype, so none of the current screenshot files should be treated as production-ready for this game.

Generated current asset:

- `feature_graphic/feature-graphic.png` is the S3B Tik Tak Toe feature graphic, generated at 1024 x 500 as a 24-bit PNG without alpha.
- `app_icon/play-store-icon.png` is the S4B Tik Tak Toe Google Play icon, generated at 512 x 512 as a 32-bit PNG with alpha.
- `app_icon/icon-source-1024.png` is the S4B high-resolution icon source/reference.
- `preview_video/` is the S5B production package for a future real-gameplay preview video.

Required v1 assets:

- Real gameplay phone screenshots from the current app
- Tik Tak Toe feature graphic
- Tik Tak Toe launcher/app icon
- Optional portrait preview video captured from real gameplay
- Alt text for each uploaded asset

Screenshot production brief:

- `screenshots/phone/S2B_PRODUCTION_BRIEF.md`

Icon production notes:

- `app_icon/README.md`

Preview video production package:

- `preview_video/README.md`
- `preview_video/shot-list.md`
- `preview_video/captions.srt`
- `preview_video/voiceover-script.txt`
- `preview_video/youtube-play-checklist.md`

Use `docs/release/play-store-metadata.md` for the approved P5 listing copy, screenshot storyboard, feature graphic brief, icon brief, preview video script, and Play Console upload checklist.
