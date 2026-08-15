# KidsLand App Icon - S4B QA

## Final Assets

- Play Store icon: `docs/store-assets/app-icon/kidsland-play-icon-512.png`
- Launcher source: `docs/store-assets/app-icon/kidsland-launcher-icon-source-1024.png`
- Generated base: `docs/store-assets/app-icon/kidsland-app-icon-generated-base.png`
- Android launcher preview exports:
  - `docs/store-assets/app-icon/android-launcher-preview/mipmap-mdpi/ic_launcher.png`
  - `docs/store-assets/app-icon/android-launcher-preview/mipmap-hdpi/ic_launcher.png`
  - `docs/store-assets/app-icon/android-launcher-preview/mipmap-xhdpi/ic_launcher.png`
  - `docs/store-assets/app-icon/android-launcher-preview/mipmap-xxhdpi/ic_launcher.png`
  - `docs/store-assets/app-icon/android-launcher-preview/mipmap-xxxhdpi/ic_launcher.png`

## Export Specs

- Play icon size: 512 x 512 px
- Play icon format: PNG
- Play icon pixel format: 32-bit ARGB with alpha
- Play icon file size: under 1024 KB
- No text, ranking, sale, price, badge, Google Play symbol, or third-party logo

## Final Prompt

Create an original app icon for KidsLand, a preschool mini-games app, using
the approved Star Pencil Path concept. Use one large bright yellow rounded
star and a simple white pencil tracing path with one glowing dot on a
violet-to-pink rounded-square background. Make it polished, child-friendly,
high contrast, centered, simple, and readable at 48 px, 96 px, and 512 px.
Do not include letters, words, numbers, badges, rankings, price or sale claims,
Google Play symbols, copyrighted characters, third-party logos, watermarks,
fake UI, screenshots, or tiny unreadable details.

## Launcher Update Notes

The live Android and iOS launcher icons have been replaced with KidsLand icon
exports.

Android files updated:

- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

iOS files updated:

- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`

The iOS exports are opaque PNGs generated from
`kidsland-launcher-icon-source-1024.png`.

## QA Checklist

- Original and not copied from an existing app icon.
- Readable at small launcher sizes.
- Uses one clear symbol instead of crowded game objects.
- Matches KidsLand's violet, pink, yellow, playful preschool visual direction.
- No tiny text or unreadable details.
- No misleading claim, badge, ranking, price, sale, or app-store mark.
- Play icon is 512 x 512 and under 1024 KB.
- Play icon is 32-bit PNG with alpha.

## Remaining Risks

- Final Play Store asset QA should be re-run after fresh screenshots and
  preview video production are complete.
- If the icon artwork changes, regenerate Android and iOS launcher exports from
  the same approved source so Play, Android, and iOS stay visually consistent.
