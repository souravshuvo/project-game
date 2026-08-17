# Dew Bubble Garden Screenshot Source Templates

Final screenshot images are intentionally not included yet.

### S2B status
Final Play Store screenshots are blocked because no real device/emulator screenshots or real gameplay recording are available in this repository.
Widget-test captures from `.dart_tool` are not acceptable for final assets because they are synthetic renders and not proven real-play evidence.

Use `manifest.csv` as the approved capture/export template and only capture from the live app UI/real gameplay.

### Export requirements
- Device: Android phone
- Orientation: Portrait
- Play-compatible: `1080x1920` JPEG or 24-bit PNG (no alpha)
- Keep overlays outside active gameplay, HUD, buttons, dialogs, and score/interaction zones
- No ads, rewarded ads, unavailable boosters, fake rewards, fake ratings/claims, debug banners, touch traces, notifications, or personal data overlays

### Exact capture commands (if capture is approved)
From an already-installed, release-like app session:

```sh
mkdir docs\play-store-assets\screenshots\raw
mkdir docs\play-store-assets\screenshots\final
adb devices
adb shell mkdir -p /sdcard/dew_bubble_screens
adb shell screencap -p /sdcard/dew_bubble_screens/01-home-start-in-garden.png
adb pull /sdcard/dew_bubble_screens/01-home-start-in-garden.png docs/play-store-assets/screenshots/raw/01-home-start-in-garden.png

adb shell screencap -p /sdcard/dew_bubble_screens/02-garden-route-choose-stage.png
adb pull /sdcard/dew_bubble_screens/02-garden-route-choose-stage.png docs/play-store-assets/screenshots/raw/02-garden-route-choose-stage.png

adb shell screencap -p /sdcard/dew_bubble_screens/03-gameplay-line-up-bounce.png
adb pull /sdcard/dew_bubble_screens/03-gameplay-line-up-bounce.png docs/play-store-assets/screenshots/raw/03-gameplay-line-up-bounce.png

adb shell screencap -p /sdcard/dew_bubble_screens/04-match-three-drop-clusters.png
adb pull /sdcard/dew_bubble_screens/04-match-three-drop-clusters.png docs/play-store-assets/screenshots/raw/04-match-three-drop-clusters.png

adb shell screencap -p /sdcard/dew_bubble_screens/05-win-stars.png
adb pull /sdcard/dew_bubble_screens/05-win-stars.png docs/play-store-assets/screenshots/raw/05-win-stars.png

adb shell screencap -p /sdcard/dew_bubble_screens/06-quick-retry-controls.png
adb pull /sdcard/dew_bubble_screens/06-quick-retry-controls.png docs/play-store-assets/screenshots/raw/06-quick-retry-controls.png
``` 

Before capture, confirm each state in-manifest is reached with a live session (home, route, aim, match/clear, stage win, pause/settings), then export to a clean folder:
`docs/play-store-assets/screenshots/final/`.
