# Trail Arena

An original offline Flutter snake arena game.

Version 1 focuses on the core loop: steer, collect food, grow, avoid your own
trail and simple offline bots, then retry for a better local score.

## Current Scope

- Offline play only.
- One arena.
- One controllable glowing trail.
- Two simple bots.
- Food, growth, score, best score, pause, game over, and retry.
- No ads, login, shop, skins, cloud sync, or online multiplayer.

## Manual QA

- Fresh install opens to the main menu.
- Play starts with a short ready countdown.
- Drag inside the arena to steer.
- Food increases score and trail length.
- Boundary, self-trail, bot-trail, and bot-head collisions end the run.
- Pause/resume works, including app backgrounding.
- Retry starts a clean run.
- Best score persists between app launches.

Do not add monetization until gameplay has been tested and tuned.
