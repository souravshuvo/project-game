# Trail Arena Release Checklist

## Build Readiness

- [ ] Confirm `com.childhood.trailarena` is the final package ID before first Play upload.
- [ ] Add real `android/key.properties` and release keystore locally.
- [ ] Add Firebase config files and confirm analytics events reach DebugView.
- [ ] Replace AdMob test IDs with production IDs only through approved config.
- [ ] Build signed release app bundle.
- [ ] Confirm target SDK and compile SDK 36 are installed locally.
- [ ] Install on a physical Android phone.
- [ ] Test fresh install after uninstalling older prototype package IDs.

## Gameplay Readiness

- [ ] New user survives at least 30 seconds after one or two tries.
- [ ] Average manual test run lands near 60-120 seconds.
- [ ] Boundary, self, bot trail, and bot head deaths feel fair.
- [ ] Trail Goals progress, complete, display, and persist correctly.
- [ ] Glide, Chase, and Surge pace phases are understandable and fair.
- [ ] Pause, resume, background, foreground, retry, and menu flows work.
- [ ] No ads appear during active gameplay.
- [ ] Banner ads appear only on menu and game-over/result surfaces.
- [ ] Interstitials appear only on game-over retry/menu transitions and obey caps.

## Store Readiness

- [ ] Capture real gameplay screenshots from the current build.
- [x] Create 1024 x 500 feature graphic matching the real game theme.
- [ ] Review listing text for no fake multiplayer, rankings, rewards, or unavailable features.
- [ ] Complete content rating, target audience, app access, ads declaration, and Data safety.
- [ ] Add hosted privacy policy URL.
- [ ] Complete consent/privacy review for AdMob, Firebase Analytics, and Google advertising ID usage.

## Closed Testing

- [ ] Recruit real testers.
- [ ] Use internal testing before closed testing.
- [ ] Collect feedback on controls, fairness, crashes, and run length.
- [ ] Fix serious issues before production access.
