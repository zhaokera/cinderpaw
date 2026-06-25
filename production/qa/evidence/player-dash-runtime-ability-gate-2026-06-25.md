# QA Evidence: Player Dash Runtime Ability Gate - 2026-06-25

## Scope

Verifies Player Abilities Story001: Rat King's `dash` reward is now consumable
by the playable Cinderpaw runtime. The slice adds data-driven ability registry
loading, Player-mounted `AbilityComponent`, Dash runtime gating/cooldown, Dash
SpriteFrames animation, MainScene unlock synchronization, and MCP runtime
evidence.

This evidence does not claim skill-tree spending UI, ExplorationGate doors, or
authored Dash-only final art.

## Asset Pipeline

Dash runtime frames are stored at:

- `assets/characters/cinderpaw/dash/cinderpaw_dash_000.png`
- `assets/characters/cinderpaw/dash/cinderpaw_dash_001.png`
- `assets/characters/cinderpaw/dash/cinderpaw_dash_002.png`

The three frames are transparent 96x96 PNGs, imported through Godot as texture
resources, and referenced by `assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`
under the `dash` animation.

Asset source: derivative reuse of the existing image-generated Cinderpaw dodge
strip at `assets/characters/cinderpaw/source/cinderpaw_dodge_strip_imagegen_20260624.png`.
This gives the newly playable Dash reward a dedicated dash-folder asset path and
SpriteFrames animation while remaining replaceable by a later authored Dash-only
generation pass.

Runtime screenshot evidence:
`reports/visual/cinderpaw-mcp-player-dash-ability-runtime-20260625.png`.

## Automated Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/ability/ability_component_runtime_gate_test.gd -a res://tests/unit/gameplay/player_dash_ability_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `105`.

Summary: expected failure because
`res://src/core/ability_component.gd` did not exist. Earlier player-runtime RED
also produced `reports/report_596/`, where the Dash animation check failed
before `SpriteFrames` had a `dash` animation.

### GREEN Focused

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/ability/ability_component_runtime_gate_test.gd -a res://tests/unit/gameplay/player_dash_ability_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_597/`.

Summary: `6/6` passing, `0` errors, `0` failures.

### Related Regression

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/ability/ability_component_runtime_gate_test.gd -a res://tests/unit/gameplay/player_dash_ability_runtime_test.gd -a res://tests/unit/gameplay/player_dodge_animation_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd -a res://tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd -a res://tests/unit/boss/story_005_desperation_reward_test.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd -a res://tests/unit/input/story_001_action_abstraction_test.gd -a res://tests/unit/input/story_003_buffer_queue_preinput_test.gd -a res://tests/unit/input/story_004_combo_conflicts_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_598/`.

Summary: `40/40` passing, `0` errors, `0` failures. Godot still emitted
ObjectDB/resource cleanup warnings at process exit in this mixed GdUnit run;
the test result itself was clean.

## Headless Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/player_dash_runtime_main_scene_smoke.log
rg -n "ERROR|SCRIPT ERROR|WARNING|Invalid call|Parse Error|FAILED|Failed loading resource|Cannot" reports/player_dash_runtime_main_scene_smoke.log
```

Result: Godot exited `0`; `rg` returned no matches in the log file. The process
stderr still printed cleanup-time ObjectDB/resource messages, consistent with
existing Godot cleanup noise.

## Godot MCP Evidence

Session:

- Session id: `cinderpaw@c1b2`.
- Godot version: `4.6.3-stable (official)`.
- Editor scene: `res://scenes/main.tscn`.
- Runtime state: playing, game capture ready.

Runtime tree:

- `/Main/Player`: `CharacterBody2D`.
- `/Main/Player/Sprite`: `AnimatedSprite2D`.
- `/Main/Player/AbilityComponent`: present.
- `/Main/CombatPresentation`: present.

MCP Dash probe:

```json
{
  "player_class": "CharacterBody2D",
  "sprite_class": "AnimatedSprite2D",
  "ability_class": "AbilityComponent",
  "has_dash_animation": true,
  "dash_frame_count": 3,
  "dash_paths": [
    "res://assets/characters/cinderpaw/dash/cinderpaw_dash_000.png",
    "res://assets/characters/cinderpaw/dash/cinderpaw_dash_001.png",
    "res://assets/characters/cinderpaw/dash/cinderpaw_dash_002.png"
  ],
  "initial_locked_request": false,
  "has_dash_after_unlock": true,
  "dash_request_result": true,
  "animation_after_request": "dash",
  "animation_after_frame": "dash",
  "cooldown_after_request": 1.0,
  "cooldown_after_frame": 0.983333333333333,
  "velocity_after_request": {"x": 620.0, "y": 0.0},
  "dash_on_cooldown": true,
  "afterimage_count": 3,
  "screenshot_error": 0,
  "screenshot_size": {"x": 1280, "y": 720}
}
```

Logs:

- `logs_read(source="game", count=80)` returned MCP helper registration plus
  DataManager `boss_configs` and `enemy_stats` load lines only.
- `logs_read(source="editor", count=80)` returned `0` lines.

Screenshot:

- Saved at
  `reports/visual/cinderpaw-mcp-player-dash-ability-runtime-20260625.png`.
- Screenshot is nonblank and shows Cinderpaw in gameplay with Dash
  afterimages while the HUD and Rat King boss scene remain visible.

## Acceptance Verdict

| Criterion | Evidence | Status |
|-----------|----------|--------|
| Ability registry data exists, validates, and loads | `report_597`, DataManager logs | PASS |
| Initial abilities unlocked and dash locked | `report_597` | PASS |
| Dash unlock, activation, event, and 1.0s cooldown | `report_597`, MCP Dash probe | PASS |
| Player scene mounts AbilityComponent | `report_597`, MCP tree | PASS |
| PlayerController delegates runtime ability checks | `report_597`, MCP Dash probe | PASS |
| Dash uses three dash-folder SpriteFrames | `report_597`, MCP Dash probe | PASS |
| MainScene unlock sync makes dash playable | `report_597`, `report_598`, MCP Dash probe | PASS |
| Dodge, Rat King reward, Save, and Input regressions remain green | `report_598` | PASS |
| MCP runtime logs and gameplay screenshot clean | MCP logs and screenshot | PASS |
