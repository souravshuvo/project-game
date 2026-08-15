# Weather Lab Sort App Icon

Last updated: 2026-08-15

## Final Assets

- Google Play icon: `play-icon-512.png`
- Master source PNG: `weather-lab-sort-icon-source-1024.png`
- Source script: `tool/generate_weather_lab_app_icons.ps1`

## Export Specs

- Play icon: 512 x 512, 32-bit PNG with alpha, under 1024 KB.
- Source icon: 1024 x 1024, 32-bit PNG with alpha.
- Android launcher PNGs: generated into `android/app/src/main/res/mipmap-*/ic_launcher.png`.
- iOS AppIcon PNGs: generated into `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.

## Concept

Forecast flask icon: one large glass weather vessel on a deep weather-blue
background, with rain blue, sun yellow, and mist green layers. The icon has no
text, no badges, no rankings, no price labels, and no sale labels.

## Regeneration

```powershell
.\tool\generate_weather_lab_app_icons.ps1
```

Use this after changing the icon script. Do not regenerate with old Arrow Puzzle
art.

## QA Checklist

- Original Weather Lab Sort visual, not copied from another app.
- Readable at 48 px launcher size.
- No text inside the icon.
- No fake awards, rankings, reviews, downloads, or promotional badges.
- Play icon is 512 x 512, 32-bit PNG with alpha, under 1024 KB.
- iOS AppIcon set no longer shows old Arrow Puzzle art.
- Android manifest points to the generated launcher mipmap icon.

## Remaining Check

Run a real build or Play Console upload preview later to verify launcher masking
and store rendering on actual surfaces.
