# Signal Workshop v1 Release Checklist

Do not mark v1 ready until each command and manual check passes on the final
release candidate.

## Code And Build

- [ ] Run `flutter pub get` after dependency or package-name changes.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Build a release artifact with real release signing.
- [ ] Confirm Android package id is final: `com.signalworkshop.puzzle`.
- [ ] Confirm version name and build number are correct.

## Gameplay

- [ ] Complete Levels 1-20 from a fresh install.
- [ ] Confirm invalid swaps never spend moves.
- [ ] Confirm valid swaps spend exactly one move.
- [ ] Confirm cascades resolve without freezes.
- [ ] Confirm no-move reshuffle does not falsely report a shuffle.
- [ ] Confirm restart restores the current level.
- [ ] Confirm next-level unlocks are saved after app restart.

## Store And Privacy

- [ ] Capture screenshots from actual gameplay only.
- [ ] Produce a 1024 x 500 feature graphic from actual gameplay.
- [ ] Produce a 512 x 512 Play app icon.
- [ ] Add privacy policy URL.
- [ ] Complete Google Play Data safety truthfully.
- [ ] Do not mention ads, boosters, blockers, maps, events, or rewards.

## Decision

- [ ] Internal testing passed.
- [ ] Closed testing passed.
- [ ] No known crash, signing, store asset, or gameplay correctness blockers.
