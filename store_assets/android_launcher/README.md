# Android Launcher Icon Candidates

These launcher icon PNGs were generated from:

- `../google_play/app_icon_source_1024x1024.png`

They are staging assets only. The live Android launcher icons in `android/app/src/main/res/mipmap-*` were not overwritten during Prompt S4B.

## Generated Sizes

- `mipmap-mdpi/ic_launcher.png` - 48 x 48
- `mipmap-hdpi/ic_launcher.png` - 72 x 72
- `mipmap-xhdpi/ic_launcher.png` - 96 x 96
- `mipmap-xxhdpi/ic_launcher.png` - 144 x 144
- `mipmap-xxxhdpi/ic_launcher.png` - 192 x 192

## Replacement Step

After final visual approval, copy each staged `ic_launcher.png` into the matching Android resource folder:

- `android/app/src/main/res/mipmap-mdpi/`
- `android/app/src/main/res/mipmap-hdpi/`
- `android/app/src/main/res/mipmap-xhdpi/`
- `android/app/src/main/res/mipmap-xxhdpi/`
- `android/app/src/main/res/mipmap-xxxhdpi/`

Then verify on a real launcher before release.
