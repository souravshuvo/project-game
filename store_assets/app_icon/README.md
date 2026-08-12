# Dots and Boxes App Icon

Final Google Play icon asset:

- `dots-and-boxes-play-store-icon-512.png`
- 512 x 512 px
- 32-bit PNG with alpha
- 25,756 bytes

Launcher icon source:

- `dots-and-boxes-launcher-source-1024.png`
- 1024 x 1024 px
- 32-bit PNG with alpha

Source:

- `generate-app-icon.ps1`

Concept used:

- Simple no-text Dots and Boxes mark.
- Three-by-three dot grid with blue and red completed-box shapes.
- Uses the real app palette from `lib/main.dart`: Player 1 blue, Player 2 red, slate dots, and light board surface.

Launcher icon update notes:

- Existing Android and iOS launcher icons were not overwritten.
- Use `dots-and-boxes-launcher-source-1024.png` as the source image when regenerating platform launcher icons later.
- Regenerate Android mipmap and iOS AppIcon sizes in a separate approved task, then verify on-device masking and small-size readability.

QA checklist:

- [x] Play Store icon export is 512 x 512.
- [x] Play Store icon is 32-bit PNG with alpha.
- [x] Play Store icon is under 1024 KB.
- [x] No text inside the icon.
- [x] No fake ranking, award, price, sale, Google Play badge, or promotional claim.
- [x] Original vector-style board mark, not copied from another game.
- [x] Readable at small size: dots, line colors, and captured boxes remain distinct.
- [x] Existing launcher icons preserved for separate update.
