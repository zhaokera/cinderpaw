# QA Evidence: Double Jump High Platform Gate Runtime - 2026-06-26

## Scope

Verifies Player Abilities Story003: Cinderpaw can consume the unlocked
`double_jump` ability once while airborne, reuse the imported `jump`
SpriteFrames animation, and unlock a player-visible high-platform
ExplorationGate in `res://scenes/main.tscn`.

This evidence does not claim the full factory area, Boss2 reward source, hidden
boss reward route, map UI, or other ability gates.

## Asset Pipeline

New visual asset generated for this slice:

- Source:
  `assets/generated/source/high_platform_gate_marker_imagegen_20260626.png`
- Runtime transparent PNG:
  `assets/environment/high_platform_gate/high_platform_gate_marker.png`
- Godot import metadata:
  `assets/environment/high_platform_gate/high_platform_gate_marker.png.import`

Prompt summary: pixel-art side-scroller high-platform Double Jump gate marker,
scrap-metal sign/marker, glowing upward cat-claw/paw jump marks, amber/blue
readability accents, generated on a flat chroma-key background for alpha
extraction.

Processing:

```bash
python3 /Users/zhaok/.codex/skills/.system/imagegen/scripts/remove_chroma_key.py \
  --input assets/generated/source/high_platform_gate_marker_imagegen_20260626.png \
  --out assets/environment/high_platform_gate/high_platform_gate_marker.png \
  --auto-key border --soft-matte --transparent-threshold 12 \
  --opaque-threshold 220 --despill
```

Import:

```bash
/opt/homebrew/bin/godot --headless --path . --import
```

Runtime screenshot evidence:
`reports/visual/cinderpaw-mcp-double-jump-high-platform-gate-20260626.png`.

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_double_jump_gate_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_611/`.

Summary: expected failure because `PlayerController` did not expose
`double_jump_started`, `request_double_jump()`, `set_airborne()`, or
`reset_air_abilities()`.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_double_jump_gate_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_613/`.

Summary: `3/3` passing, `0` errors, `0` failures. Covers Double Jump runtime
activation, imported jump frames, high-platform gate unlock, and save restore.

### Scene Sanity

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_double_jump_gate_runtime_test.gd -a res://tests/unit/gameplay/exploration_dash_gate_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_616/`.

Summary: `5/5` passing, confirming the final `main.tscn` contains both the new
Double Jump gate and the existing Dash gate.

### Related Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_double_jump_gate_runtime_test.gd -a res://tests/unit/ability/ability_component_runtime_gate_test.gd -a res://tests/unit/gameplay/player_dash_ability_runtime_test.gd -a res://tests/unit/gameplay/exploration_dash_gate_runtime_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd -a res://tests/unit/input/story_005_coyote_jump_buffer_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_618/`.

Summary: `19/19` passing, `0` errors, `0` failures. Godot still emitted
ObjectDB/resource cleanup messages at process exit in this mixed GdUnit run;
the test result itself was clean.

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/double_jump_high_platform_gate_runtime_smoke.log
rg -n "SCRIPT ERROR|Invalid call|Parse Error|FAILED|Failed loading resource|Resource not found|Node not found|Cannot|ERROR:" reports/double_jump_high_platform_gate_runtime_smoke.log
```

Result: Godot exited `0`; `rg` returned no matches for script, node, or
resource-load errors. The process still printed existing cleanup-time
ObjectDB/resource messages, consistent with prior story evidence.

## Godot MCP Evidence

Session:

- Session id: `cinderpaw@c1b2`.
- Godot version: `4.6.3-stable (official)`.
- Runtime launched through MCP with `project_run(mode="custom",
  scene="res://scenes/main.tscn", autosave=false)`.
- Runtime state: playing, game capture ready.

MCP scene tree check:

- `/Main` had `DoubleJumpExplorationGate` and `DashExplorationGate` present in
  the running game tree.
- `/Main/Player/Sprite` was `AnimatedSprite2D`.

MCP runtime probe:

```json
{
  "scene": "res://scenes/main.tscn",
  "sprite_class": "AnimatedSprite2D",
  "jump_frame_count": 3,
  "jump_frame_paths": [
    "res://assets/characters/cinderpaw/jump/cinderpaw_jump_000.png",
    "res://assets/characters/cinderpaw/jump/cinderpaw_jump_001.png",
    "res://assets/characters/cinderpaw/jump/cinderpaw_jump_002.png"
  ],
  "gate_id": "double_jump_high_platform",
  "required_ability": "double_jump",
  "target_area_id": "area_03_factory",
  "dash_gate_present": true,
  "initial_state": "locked",
  "initial_blocking": true,
  "unlockable_state": "unlockable",
  "unlockable_blocking": true,
  "request_double_jump": true,
  "activated_ids": ["double_jump"],
  "unlocked_state": "unlocked",
  "unlocked_blocking": false,
  "collision_disabled": true,
  "visual_texture": "res://assets/environment/high_platform_gate/high_platform_gate_marker.png",
  "visual_visible": true,
  "saved_gate_ids": ["double_jump_high_platform"],
  "gate_flag": true,
  "target_area_flag": true,
  "screenshot_save_error": 0
}
```

Final MCP clean-log probe after clearing eval warning noise:

```json
{
  "double_jump_gate_state": "unlocked",
  "double_jump_gate_blocking": false,
  "double_jump_gate_flag": true,
  "factory_area_flag": true,
  "dash_gate_present": true,
  "jump_frame_count": 3,
  "sprite_class": "AnimatedSprite2D"
}
```

Logs:

- `logs_read(source="game")`: only MCP helper registration and DataManager
  domain load info lines.
- `logs_read(source="editor")`: `0` lines after clearing the eval-script
  capture warning generated by an earlier probe attempt.
- No script errors, invalid calls, missing nodes, or resource-load errors were
  present in the final MCP log checks.

Screenshot:

- `reports/visual/cinderpaw-mcp-double-jump-high-platform-gate-20260626.png`
  is nonblank and shows Cinderpaw, the high-platform Double Jump marker, and
  the existing Dash gate in the running main scene.

## Acceptance Trace

| Criterion | Evidence | Status |
|-----------|----------|--------|
| Double Jump API/signal exists on PlayerController | `report_613`, `report_618` | PASS |
| Locked and grounded activation fail; airborne unlocked activation succeeds | `report_613`, `report_618` | PASS |
| Air-count resets through landing/reset flow | `report_613`, `report_618` | PASS |
| `jump` SpriteFrames has three imported frames | `report_613`, MCP probe | PASS |
| Main scene has visible Double Jump high-platform gate | `report_616`, MCP scene tree, screenshot | PASS |
| Ability unlock moves gate to unlockable; Double Jump activation unlocks it | `report_613`, MCP probe | PASS |
| Gate unlock persists in save snapshot and world flags | `report_613`, `report_618`, MCP probe | PASS |
| Generated visual asset imported through Godot pipeline | `.png.import`, asset manifest, MCP visual texture path | PASS |
| Runtime logs checked through MCP | MCP logs | PASS |
