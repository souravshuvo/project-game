# Pencil Pitch

Pencil Pitch is an offline pen cricket spinner game built with Flutter. Version 1 focuses on quick, family-friendly practice innings and target chases with clear cricket scoring.

## Current v1 scope

- Main menu
- Practice innings
- Target chase
- Tap-to-spin and tap-to-stop spinner
- Runs, wickets, legal balls, overs, extras, and target display
- Wide and no-ball extras without consuming legal deliveries
- Innings end and match result
- Restart and menu return
- Basic haptics setting
- No ads, shop, login, leaderboard, cloud sync, or online play

## Manual QA checklist

1. Open the app and confirm the title is Pencil Pitch.
2. Start Practice innings and play until 2 overs or 3 wickets.
3. Confirm wides and no-balls add 1 extra without advancing balls.
4. Restart from a completed practice innings.
5. Start Target chase and complete the first innings.
6. Confirm the target is first-innings score + 1.
7. Start the chase and confirm win, tie, and defended results across repeated plays.
8. Tap rapidly during spin, settling, and result feedback; confirm scoring happens once per delivery.
9. Confirm menu/restart/start-chase controls are disabled during delivery feedback.
10. Check phone-sized and landscape layouts for readable score and spinner labels.

## Release notes

Android release signing expects `android/key.properties`, based on `android/key.properties.example`. Do not commit signing secrets or keystore files.
