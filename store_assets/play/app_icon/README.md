# Cloud Courier Climb App Icon

Final app icon assets for Cloud Courier Climb.

## Export Specs

- Google Play icon: `play_icon_512.png`
- Dimensions: 512x512
- Format: PNG
- Pixel format: 32-bit ARGB with alpha
- File size: under 1024 KB
- Source image: `launcher_icon_source_1024.png`
- Source script: `create_app_icon.ps1`

## Concept

Original courier parcel centered inside a gold signal ring, with a teal sky background and gold platform. No text, badges, rankings, sale claims, or copied icon elements.

## Alt Text

Cloud Courier Climb icon with courier parcel, gold signal ring, teal sky, and gold platform.

## Launcher Icon Update Notes

Existing Android and iOS launcher icons were inspected but not overwritten. To update launcher icons later, use `launcher_icon_source_1024.png` as the source and export platform-specific sizes for:

- Android mipmap launcher densities.
- Android adaptive icon foreground/background, if adopted.
- iOS `AppIcon.appiconset` sizes.

After replacing launcher files, rerun a lightweight launcher-icon visual QA pass on small sizes before release packaging.

## QA Checklist

- Confirm `play_icon_512.png` is exactly 512x512.
- Confirm file size is below 1024 KB.
- Confirm icon remains readable at 48x48 and 72x72.
- Confirm no text, fake badges, awards, rankings, price, or sale claims appear.
- Confirm the icon matches real game visuals: courier, signal, platform, teal/gold palette.
- Confirm launcher icons are updated separately only after explicit approval.
