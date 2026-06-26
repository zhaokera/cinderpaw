# QA Evidence: Death & Respawn Story 007 — Main Scene Savepoint Runtime

> Date: 2026-06-26
> Story: `production/epics/death-respawn/story-007-main-scene-savepoint-runtime.md`
> Epic: Death & Respawn
> Scope: `TR-respawn-002`, `TR-respawn-005`, `TR-save-006`

## Result

PASS

## Summary

`res://scenes/main.tscn` now includes a visible generated `ScrapRoostSavepoint`
prop near the starting platform. The savepoint has a runtime trigger script,
stable savepoint IDs, an `Area2D` interaction volume, enabled collision, and a
prompt label. Player contact discovers the savepoint through `MainScene`,
writes autosave slot `0`, records `world_state.last_savepoint`, and lets
non-boss deaths respawn at `main/scrap_roost`.

## Acceptance Coverage

| AC | Result | Evidence |
|----|--------|----------|
| Main scene has visible non-placeholder savepoint art | PASS | `reports/report_752/`; MCP scene hierarchy and screenshot. |
| Savepoint IDs are stable | PASS | `savepoint_id=scrap_roost`, `scene_id=main`, `spawn_point=scrap_roost` in MCP node properties. |
| Player contact discovers savepoint and writes autosave slot 0 | PASS | `reports/report_752/`; MCP `game_eval` returned `has_autosave_slot_0=true`, `autosave_reason=savepoint`. |
| Autosave records last savepoint | PASS | MCP `last_savepoint.id=scrap_roost`, position `(210, 432)`. |
| Non-boss death respawns at savepoint | PASS | Unit test and MCP `respawn.source=savepoint`, `scene_id=main`, `spawn_point=scrap_roost`. |
| Related save/title/load contracts remain intact | PASS | `reports/report_755/` passed 29/29. |

## Asset Evidence

Prompt summary:

```text
Pixel-art cozy cat-nest savepoint shrine for a wasteland side-scroller:
rusted metal paw-frame, warm amber cat-eye lantern core, small scrap roof,
cloth strips, clear silhouette, transparent-ready chroma-key background.
```

Files:

- Source: `assets/generated/source/scrap_roost_savepoint_imagegen_20260626.png`
- Alpha-matted source:
  `assets/generated/source/scrap_roost_savepoint_alpha_20260626.png`
- Runtime PNG:
  `assets/environment/savepoints/scrap_roost_savepoint.png`
- Godot import:
  `assets/environment/savepoints/scrap_roost_savepoint.png.import`
- Manifest entry: `design/assets/asset-manifest.md`

The generated prop was chroma-keyed to transparency, trimmed/resized to
`256x256`, imported through Godot, and referenced by `ScrapRoostSavepoint/Visual`.

## TDD Evidence

### RED

- `reports/report_739/`: focused runtime test failed on missing
  `ScrapRoostSavepoint`.
- `reports/report_740/`: scene failed to load before the new savepoint PNG was
  imported through Godot.

### GREEN

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_savepoint_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_752/`.

Summary: `3/3` passing, `0` errors, `0` failures.

## Regression Evidence

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_003_autosave_trigger_adapter_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd -a res://tests/unit/save/story_005_async_write_performance_budget_test.gd -a res://tests/unit/gameplay/story_004_savepoint_respawn_selection_test.gd -a res://tests/unit/gameplay/game_flow_controller_test.gd -a res://tests/unit/gameplay/no_loss_respawn_state_contract_test.gd -a res://tests/unit/gameplay/main_scene_title_load_handoff_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_755/`.

Summary: `29/29` passing, `0` errors, `0` failures.

## Headless Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --quit-after 3
```

Result: exit `0`.

Output loaded DataManager, `boss_configs`, and `enemy_stats` successfully. No
script, parse, invalid-call, invalid-access, or missing-resource failures were
printed. Godot emitted known cleanup-time ObjectDB/resource messages after
process exit.

## Godot MCP Runtime Evidence

MCP checks:

- MCP session `cinderpaw@c1b2`, Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, editor ready.
- Reopened `res://scenes/main.tscn` through MCP to ensure the editor loaded the
  disk version after external file edits.
- Scene hierarchy contained `/Main/ScrapRoostSavepoint`,
  `/Main/ScrapRoostSavepoint/Visual`,
  `/Main/ScrapRoostSavepoint/InteractionArea`, and enabled
  `/Main/ScrapRoostSavepoint/InteractionArea/CollisionShape2D`.
- Node properties confirmed:
  - script: `res://src/feature/savepoint_runtime.gd`
  - texture: `res://assets/environment/savepoints/scrap_roost_savepoint.png`
  - `savepoint_id="scrap_roost"`
  - `scene_id="main"`
  - `spawn_point="scrap_roost"`
- Runtime `game_eval` configured SaveSystem sync writes under
  `user://cinderpaw_mcp_main_scene_savepoint_runtime/`, moved the player onto
  the savepoint, emitted `InteractionArea.body_entered`, loaded autosave slot
  `0`, and then drove a non-boss death through `GameFlowController`.
- Runtime returned:
  - `discovered.id="scrap_roost"`
  - `has_autosave_slot_0=true`
  - `autosave_reason="savepoint"`
  - `last_savepoint.id="scrap_roost"`
  - `respawn.source="savepoint"`
  - `respawn.scene_id="main"`
  - `respawn.spawn_point="scrap_roost"`
  - `player_position=(210, 432)`
- Game logs contained only MCP/DataManager info lines.
- Editor logs returned `0` lines after clearing an eval-only shadow warning.
- Screenshot saved to
  `reports/visual/cinderpaw-mcp-main-scene-savepoint-runtime-20260626.png`.

## Notes

- The savepoint is an environment prop, not a character animation asset.
  Visible player and enemy characters remain `AnimatedSprite2D + SpriteFrames`.
- Full savepoint network, savepoint UI polish, minimap icons, fast travel, and
  dedicated hub scene are future work.
