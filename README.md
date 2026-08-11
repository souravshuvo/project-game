# Rapid Jump

Rapid Jump is an offline Flutter Sholo Guti / 16 Beads game.

## Version 1 Scope

- Local two-player mode.
- Player vs bot mode.
- Validated 37-node board graph.
- 16 beads per player.
- Legal move and capture highlighting.
- Optional multi-capture chains.
- Rule-safe hints.
- Full-turn undo.
- In-memory settings and match history.
- No ads, accounts, online play, shop, chat, or leaderboard.

## Manual QA

1. Open the app and start a local match.
2. Confirm Player 1 starts from the bottom and Player 2 starts from the top.
3. Select beads and confirm only legal moves/captures highlight.
4. Make normal moves and captures.
5. Continue or end an optional capture chain.
6. Use undo before game over.
7. Restart the match.
8. Start a bot match and confirm the bot moves only after Player 1.
9. Change settings and confirm theme/hint behavior changes.
10. Complete a match and confirm it appears in match history.

## Release Notes

This repository intentionally keeps version 1 offline and dependency-light. Release signing, Play Console data safety, content rating, and real store assets must be completed outside the source code before production release.
