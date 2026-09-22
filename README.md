# Core Loop Prototype — Lab 3

**Core mechanic:** a minimal 2D PvP fighting-game loop on a shared
platform. Both players move, jump, and attack; landing a hit flashes and
knocks back the opponent and ticks down their health bar. At 0 HP both
players reset to full health and their starting positions, so the loop
repeats indefinitely.

Player 1 is a ninja, Player 2 is a samurai (`assets/ninja.png`,
`assets/samurai.png`), animated via `AnimatedSprite2D` with idle/run/jump/
attack/hurt/death states driven by `Fighter.gd`.

**Controls**
- Player 1: `A` / `D` to move, `W` to jump, `S` to fast-fall, `Space` to attack
- Player 2: Left/Right arrows to move, `Up` to jump, `Down` to fast-fall, `/` to attack

Both players share one `Fighter.gd` script — movement/jump/attack keys and
starting facing direction are set per-instance in `Main.tscn`.
