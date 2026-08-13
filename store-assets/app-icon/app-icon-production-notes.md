# Sixteen Breed App Icon Production Notes

## Approved Direction

Simple original game mark: a teal square background, tan Sholo Guti board surface, dark board lines, red and blue beads, and an amber capture cue. No text, no badges, no rankings, no price or sale claims.

## Generated Assets

- `sixteen-breed-launcher-icon-source-1024.png` - high-resolution launcher icon source.
- `sixteen-breed-play-icon-512.png` - Google Play icon export.
- `generate-app-icons.ps1` - reproducible local generator based on the current `BoardSpec` node and edge data.

## Launcher Update Notes

The existing Android and iOS launcher icon files were not overwritten. To update launcher icons later, use `sixteen-breed-launcher-icon-source-1024.png` as the source image in the chosen launcher-icon workflow, then verify the generated Android mipmap assets and iOS app icon set on small sizes.

Do not run icon replacement as part of store creative production unless launcher replacement is explicitly approved.

## QA Checklist

- Icon is readable at small size.
- Icon uses the real game palette and Sholo Guti board theme.
- Icon contains no tiny text.
- Icon contains no misleading badge, award, ranking, price, sale, or download claim.
- Play Store export is 512 x 512 PNG and under 1024 KB.
- Launcher source is preserved separately from generated platform icon files.
