# Core Loop Prototype — Lab 3

**Core mechanic:** a minimal 2D PvP fighting-game loop. Both players move
and attack; landing a hit flashes and knocks back the opponent and ticks
down their health bar. At 0 HP both players reset to full health and their
starting positions, so the loop repeats indefinitely.

**Controls**
- Player 1: `W A S D` to move, `Space` to attack
- Player 2: Arrow keys to move, `/` to attack

Both players share one `Fighter.gd` script — movement keys, attack key,
and starting facing direction are set per-instance in `Main.tscn`.
