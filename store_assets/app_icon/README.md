# Tik Tak Toe App Icon Assets

Status: generated in Prompt S4B from the approved icon brief.

## Files

- `play-store-icon.png`: Google Play app icon export.
- `icon-source-1024.png`: high-resolution source/reference icon.

## Export Specs

| File | Size | Format | Notes |
| --- | --- | --- | --- |
| `play-store-icon.png` | 512 x 512 | 32-bit PNG with alpha | Intended for Google Play app icon upload. |
| `icon-source-1024.png` | 1024 x 1024 | 24-bit PNG without alpha | Source/reference export for future launcher regeneration. |

## Launcher Assets

The S4B generator also refreshed:

- Android launcher PNGs in `android/app/src/main/res/mipmap-*`.
- iOS app icon PNGs in `ios/Runner/Assets.xcassets/AppIcon.appiconset`.

## QA Checklist

- [ ] Icon is readable at 48 x 48.
- [ ] Icon contains no text.
- [ ] Icon contains no ranking, price, sale, badge, or Google Play category claim.
- [ ] Icon uses the Tik Tak Toe palette: midnight background, cream board, gold X/star, teal O.
- [ ] Icon is visually distinct from the old Arrow Puzzle launcher icon.
- [ ] Play Store export is 512 x 512.
- [ ] Play Store export is 32-bit PNG with alpha.
- [ ] Play Store export is under 1024 KB.
