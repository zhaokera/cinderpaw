# Main Scene Sequential Boss Handoff Evidence

- Story: Player Abilities Story156
- Date: 2026-07-14
- Engine: Godot 4.7-stable (official)
- Godot AI MCP: plugin/server 2.9.2

## Runtime Result

Fresh Main now keeps Echo Guardian hidden, targetless and non-colliding while
Rat King owns the Boss HUD. Its arena frame, room seals, camera lock and reward
remain inactive. The alternative hidden Double Jump flag does not activate the
mainline Boss2 encounter.

Rat King defeat enters the existing `victory_pending` presentation without
activating Boss2. Loading the persisted Rat King defeat progress into a playing
Main atomically hides Rat King and enables Echo Guardian AI/target/collision,
the existing `AnimatedSprite2D + SpriteFrames`, arena frame, Echo Guardian HUD,
camera lock and both room seals. Existing Boss2 defeat, reward and Factory route
tests continue to pass.

## Automated Evidence

- RED: `reports/report_1640/results.xml` - `1` case, `1` expected failure.
- Focused GREEN: `reports/report_1641/results.xml` - `1/1`.
- Related GREEN A: `reports/report_1644/results.xml` - `21/21`.
- Related GREEN B: `reports/report_1645/results.xml` - `28/28`.
- Smoke: `tests/smoke/main_scene_sequential_boss_handoff_smoke.gd` exited `0`
  with `main_scene_sequential_boss_handoff_smoke=passed`.
- `git diff --check` exited `0`.

GdUnit/headless exits retain only the known engine cleanup-time ObjectDB/resource
messages; accepted reports contain no test errors, failures, skips or orphans.
No full suite was run because the changed surface is bounded to Main/Boss2
activation and its direct consumers.

## MCP Evidence

Final MCP run `r22661784-28` launched Main with `autosave=false`.

- Fresh state: Rat King visible at `300/300`; Boss2 hidden, encounter inactive,
  target absent, collision layer/mask `0/0`, arena frame/seals/camera lock off.
- Handoff state: Rat King hidden; Echo Guardian visible at `36/36`, encounter
  active, player target present, collision layer/mask `2/17`, `run` animation
  with `3` frames, arena frame/seals/camera lock on.
- Game log: `3` info-only lines (game helper and two DataManager domains).
- Editor log: `0` lines.
- Stop result: `stopped=true`, readiness `ready`.

Screenshots:

- `reports/visual/cinderpaw-mcp-main-rat-king-initial-handoff-20260714.png`
  (`1278x718`, SHA-256
  `e390b1afd2f544faac4af8fb323282b95dfd738ff7dd935bf2d464370ef42eeb`).
- `reports/visual/cinderpaw-mcp-main-echo-guardian-handoff-20260714.png`
  (`1278x718`, SHA-256
  `7385e0f2e1a7a73c56045e2588fa41fd9a6f7971e0f537d7acdf4133d57d579d`).

Both screenshots are non-empty and were visually inspected. The first shows
the authored Rat King encounter without Echo Guardian; the second shows the
authored Echo Guardian, arena frame, Boss portrait/HUD and room seals without
Rat King.

## Asset Pipeline

No new visual or audio asset was required. Story156 reuses the existing
image-generated Rat King, Echo Guardian, Boss2 arena frame, room seal, reward
source and HUD portrait assets already tracked by the project asset pipeline.
