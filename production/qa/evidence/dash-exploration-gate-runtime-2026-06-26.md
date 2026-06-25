# QA Evidence: Dash Exploration Gate Runtime - 2026-06-26

## Scope

Verifies Player Abilities Story002: Rat King's `dash` reward now opens a
player-visible ExplorationGate in `res://scenes/main.tscn`. The slice adds a
scene-level `ExplorationGate` component, a Dash-required electric fence in the
main scene, runtime state transitions from `locked` to `unlockable` to
`unlocked`, save/restore persistence, and MCP runtime evidence.

This evidence does not claim the full exploration system, minimap update,
hidden rooms, shortcuts, or other ability gates.

## Asset Pipeline

No new visual asset was generated for this slice. The Dash electric fence
reuses the existing image-generated and Godot-imported runtime asset:

- `res://assets/environment/rat_king_arena/electric_leak.png`
- Source: `assets/generated/source/rat_king_arena_mutations_imagegen_20260625.png`
- Alpha source: `assets/generated/source/rat_king_arena_mutations_alpha_20260625.png`

The reuse is recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`. This is a replaceable baseline for a later
authored gate-specific image generation pass.

Runtime screenshot evidence:
`reports/visual/cinderpaw-mcp-dash-exploration-gate-runtime-20260626.png`.

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/exploration_dash_gate_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_599/`.

Summary: expected failure because
`res://src/feature/exploration_gate.gd` did not exist.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/exploration_dash_gate_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_604/`.

Summary: `2/2` passing, `0` errors, `0` failures. This covers the
`ExplorationGate` state machine and MainScene gate persistence.

### Related Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/exploration_dash_gate_runtime_test.gd -a res://tests/unit/ability/ability_component_runtime_gate_test.gd -a res://tests/unit/gameplay/player_dash_ability_runtime_test.gd -a res://tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_606/`.

Summary: `12/12` passing, `0` errors, `0` failures. Godot still emitted
ObjectDB/resource cleanup warnings at process exit in this mixed GdUnit run;
the test result itself was clean.

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/exploration_gate_dash_main_scene_smoke.log
rg -n "SCRIPT ERROR|Invalid call|Parse Error|FAILED|Failed loading resource|Cannot|Resource not found|Node not found" reports/exploration_gate_dash_main_scene_smoke.log
```

Result: Godot exited `0`; `rg` returned no matches for script or resource-load
errors. The process still printed cleanup-time ObjectDB/resource messages,
consistent with existing Godot cleanup noise seen in prior stories.

## Godot MCP Evidence

Session:

- Godot version: `4.6.3-stable (official)`.
- Runtime launched through MCP with `project_run(mode="custom",
  scene="res://scenes/main.tscn", autosave=false)`.
- Runtime state: playing, game capture ready.

MCP runtime probe:

```json
{
  "scene": "Main",
  "has_player": true,
  "has_ability_component": true,
  "has_player_dash_animation": true,
  "dash_frame_count": 3,
  "has_gate": true,
  "gate_id": "dash_gate_commercial_street",
  "required_ability": "dash",
  "target_area_id": "area_02_sewer",
  "has_visual": true,
  "has_collision": true,
  "has_dash_before": false,
  "locked_state": "locked",
  "locked_prompt": "Requires Dash",
  "locked_blocking": true,
  "unlockable_state": "unlockable",
  "unlockable_prompt": "Dash through",
  "unlockable_blocking": true,
  "in_range_before_dash": true,
  "dash_result": true,
  "unlocked_state": "unlocked",
  "unlocked_blocking": false,
  "unlocked_prompt_visible": false,
  "save_gate_state": {"unlocked": ["dash_gate_commercial_street"]},
  "world_flags": {
    "area_02_sewer_unlocked": true,
    "gate_dash_gate_commercial_street_unlocked": true
  },
  "screenshot_error": 0,
  "screenshot_size": {"x": 1280, "y": 720}
}
```

Logs:

- MCP plugin log included `mcp:hello from game_helper`.
- Game log included MCP helper registration plus DataManager domain load lines.
- No script errors, invalid calls, missing nodes, or resource-load errors were
  present in `logs_read(source="all", count=120, include_details=true)`.

Screenshot:

- `reports/visual/cinderpaw-mcp-dash-exploration-gate-runtime-20260626.png`
  is nonblank and shows Cinderpaw near the right-side electric gate after Dash
  unlock.

## Acceptance Trace

| Criterion | Evidence | Status |
|-----------|----------|--------|
| `ExplorationGate` scene component exists and exposes state/query APIs | `report_604`, `report_606`, MCP probe | PASS |
| Main scene has a visible Dash electric fence gate | `scenes/main.tscn`, MCP probe, screenshot | PASS |
| No Dash -> `locked`, collision enabled, prompt shown | `report_604`, MCP probe | PASS |
| Dash reward / `unlock_ability("dash")` -> `unlockable` without restart | `report_606`, MCP probe | PASS |
| Dash near gate -> `unlocked`, collision disabled, prompt hidden | `report_604`, MCP probe | PASS |
| Gate unlock persists through `world_state.exploration_gates` | `report_604`, MCP probe | PASS |
| Runtime logs checked through MCP | MCP logs | PASS |
