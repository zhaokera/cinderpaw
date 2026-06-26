# QA Evidence: Parry Laser Gate Runtime

Date: 2026-06-26

Story:
`production/epics/player-abilities/story-019-parry-laser-gate-runtime.md`

## Scope

This slice connects the GDD laser-gate mapping (`激光网 -> 弹反`) to playable
runtime behavior. Cinderpaw can request `parry`, enter the Core combat
`PARRYING` state, play a generated three-frame `AnimatedSprite2D` animation,
consume the 0.3s AbilityComponent cooldown only after Core combat allows the
action, and unlock the new main-scene `ParryLaserExplorationGate` in range.

The story adds new player-facing visual frames for Cinderpaw's parry state. The
laser gate itself currently reuses the existing generated electric-leak gate
texture as a replaceable baseline.

## Generated Asset Pipeline

Source prompt summary:

- 3-frame pixel-art sprite strip of Cinderpaw performing a defensive parry
  stance, side-view, facing right, 96x96 cells, transparent-ready flat green
  chroma-key background, orange/charcoal Cinderpaw silhouette with cyan/gold
  parry energy accents, no text or watermark.

Source and runtime files:

- Source strip:
  `assets/characters/cinderpaw/source/cinderpaw_parry_strip_imagegen_20260626.png`
- Alpha-matted source:
  `assets/characters/cinderpaw/source/cinderpaw_parry_strip_alpha_20260626.png`
- Runtime frames:
  `assets/characters/cinderpaw/parry/cinderpaw_parry_000.png`
  through `_002.png`
- SpriteFrames resource:
  `assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`

Asset checks:

- Runtime frames are transparent PNGs.
- Runtime frames are consistently 96x96.
- Runtime frame names are consecutive and match the AGENTS.md character-frame
  rule.
- Godot import was forced with `/opt/homebrew/bin/godot --headless --path . --import`
  before focused GREEN verification.

## Automated Tests

- RED: `reports/report_726/`
  - Command: `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_parry_laser_gate_runtime_test.gd --ignoreHeadlessMode`
  - Result: expected failure on missing Cinderpaw `parry` SpriteFrames
    animation and parry laser gate behavior.
- RED import refinement: `reports/report_727/`
  - Same focused command.
  - Result: exposed that the new PNG frames needed Godot import metadata before
    SpriteFrames could load them.
- GREEN focused before cooldown-order refinement: `reports/report_728/`
  - Same focused command.
  - Result: exit `0`, Story019 `3/3`.
- Related regression before cooldown-order refinement: `reports/report_729/`
  - Suites: Story019, Player Dash, Player Double Jump gate, ExplorationGate
    feedback, Core parry timing, MainScene player attack chain, and player
    dodge animation.
  - Result: exit `0`, `25/25`.
- RED cooldown-order refinement: `reports/report_730/`
  - Same focused command after adding a blocked-combat regression test.
  - Result: expected failure because a blocked Core combat state still emitted
    `ability_activated("parry")` and consumed the 0.3s cooldown.
- Final focused: `reports/report_731/`
  - Same focused command.
  - Result: exit `0`, Story019 `4/4`.
  - Notes: Existing Godot process-exit ObjectDB/resource cleanup warnings
    appeared after the GdUnit result; test result itself passed.
- Final related regression: `reports/report_732/`
  - Same related suites as above.
  - Result: exit `0`, `26/26`.
  - Notes: Existing Godot process-exit ObjectDB/resource cleanup warnings
    appeared after the GdUnit result; test result itself passed.

## Headless Smoke

- Main scene:
  - Command: `/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/parry_laser_gate_runtime_main_scene_smoke.log`
  - Result: exit `0`.
- Log keyword scan:
  - `rg -n "SCRIPT ERROR|Parse Error|Invalid call|Invalid access|Resource file not found|Failed loading resource|missing resource|Cannot open|ERROR:" reports/parry_laser_gate_runtime_main_scene_smoke.log`
  - Result: no matches.
  - Notes: the console still printed the project's known cleanup-time
    ObjectDB/resource warning after process exit; the smoke log itself contained
    no script, parse, invalid-call, or resource-load errors.

## Godot MCP Runtime

Session: `cinderpaw@c1b2`, Godot `4.6.3-stable`, custom run scene
`res://scenes/main.tscn`, `autosave=false`.

MCP evidence:

- Runtime tree confirmed `/Main/ParryLaserExplorationGate` exists.
- Runtime tree confirmed `/Main/Player/Sprite` is `AnimatedSprite2D`.
- Runtime probe before parry:
  - `gate_id="parry_laser_central_tower"`
  - `required_ability="parry"`
  - `target_area_id="area_05_central_tower"`
  - gate state `unlockable`
  - collision blocking `true`
  - player has initial `parry` ability
  - SpriteFrames resource path
    `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`
  - `parry` frame count `3`
  - frame paths:
    `res://assets/characters/cinderpaw/parry/cinderpaw_parry_000.png`,
    `_001.png`, `_002.png`
- Runtime probe after placing player in range and calling `request_parry()`:
  - `request_ok=true`
  - gate state `unlocked`
  - collision blocking `false`
  - sprite animation `parry`
  - sprite playing `true`
  - CombatComponent state `3` (`PARRYING`)
  - parry cooldown remaining `0.3`
  - save snapshot contains
    `exploration_gates.unlocked=["parry_laser_central_tower"]`
  - save snapshot contains
    `gate_parry_laser_central_tower_unlocked=true`
  - save snapshot contains `area_05_central_tower_unlocked=true`
- MCP game logs contained only game helper registration and DataManager
  `boss_configs` / `enemy_stats` load lines.
- MCP editor logs were empty.
- Runtime screenshot was written by the running game to
  `reports/visual/cinderpaw-mcp-parry-laser-gate-runtime-20260626.png`;
  screenshot is `1280x720`, nonblank, and shows the main scene, Cinderpaw,
  Boss HUD, and ability gates.

## Acceptance Mapping

| Acceptance item | Evidence | Status |
| --- | --- | --- |
| `request_parry()` routes through AbilityComponent and Core combat | `report_731`, `report_732`, MCP runtime probe | PASS |
| Blocked Core combat does not consume cooldown | RED `report_730`, GREEN `report_731` | PASS |
| Cinderpaw parry uses `AnimatedSprite2D + SpriteFrames` with 3 generated frames | `report_731`, MCP runtime probe | PASS |
| MainScene contains the parry laser gate with correct ids | `report_731`, MCP runtime tree/probe | PASS |
| Runtime parry unlocks the gate in range | `report_731`, MCP runtime probe | PASS |
| Gate unlock persists through world-state snapshot | `report_731`, MCP runtime probe | PASS |
| Generated source/runtime assets are imported and documented | Asset manifest, this evidence doc, MCP probe | PASS |
| Main scene runs under MCP with clean logs and nonblank screenshot | Headless smoke, MCP logs, MCP screenshot | PASS |
