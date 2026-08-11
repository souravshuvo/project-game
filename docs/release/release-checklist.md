# Trail Arena Release Checklist

## Build Readiness

- [ ] Confirm `com.trailarena.game` is the final package ID before first Play upload.
- [ ] Add real `android/key.properties` and release keystore locally.
- [ ] Build signed release app bundle.
- [ ] Confirm target SDK and compile SDK 36 are installed locally.
- [ ] Install on a physical Android phone.
- [ ] Test fresh install after uninstalling older prototype package IDs.

## Gameplay Readiness

- [ ] New user survives at least 30 seconds after one or two tries.
- [ ] Average manual test run lands near 60-120 seconds.
- [ ] Boundary, self, bot trail, and bot head deaths feel fair.
- [ ] Pause, resume, background, foreground, retry, and menu flows work.
- [ ] No ads appear during gameplay.

## Store Readiness

- [ ] Capture real gameplay screenshots from the current build.
- [ ] Create 1024 x 500 feature graphic from real gameplay.
- [ ] Review listing text for no fake multiplayer, rankings, rewards, or unavailable features.
- [ ] Complete content rating, target audience, app access, ads declaration, and Data safety.
- [ ] Add hosted privacy policy URL.

## Closed Testing

- [ ] Recruit real testers.
- [ ] Use internal testing before closed testing.
- [ ] Collect feedback on controls, fairness, crashes, and run length.
- [ ] Fix serious issues before production access.
