# QA Evidence: Save System Story 004 — MainScene SaveSystem Runtime Handoff

> Date: 2026-06-24
> Story: `production/epics/save-system/story-004-main-scene-save-system-runtime-handoff.md`
> Epic: Save System
> Scope: `TR-save-001`, `TR-save-002`, `TR-save-006`

## Summary

Save System Story 004 is complete. `MainScene` now configures a SaveSystem-like
runtime service, registers itself as the `main_scene` serializable payload,
captures JSON-safe `player_state/world_state/settings`, writes manual slots
through `SaveSystem.manual_save()`, restores runtime state after
`SaveSystem.load_game()`, and routes boss defeat autosave through
`SaveTriggerAdapter`.

## Acceptance Coverage

| AC | Result | Evidence |
|----|--------|----------|
| MainScene configures SaveSystem runtime and registered `main_scene` payload | PASS | Story 004 unit test verifies injected SaveSystem registration and `systems.main_scene`. |
| JSON-safe snapshot includes player, world, and settings state | PASS | Story 004 unit test verifies HP, position, currency, weapon, world flag, and HUD scale. |
| Manual runtime save uses slots 1-3 and leaves slot 0 for autosave | PASS | Story 004 unit test writes slot 1 and verifies slot 0 remains absent until boss autosave. |
| Runtime load restores MainScene state | PASS | Story 004 unit test mutates HP, currency, weapon, world flag, and HUD scale before loading slot 1. |
| Boss defeat triggers slot 0 autosave through SaveTriggerAdapter | PASS | Story 004 unit test and MCP runtime probe verify `autosave_reason=\"boss_defeat\"`. |

## TDD Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd --ignoreHeadlessMode
```

Result: Exit 100 as expected. The first run failed because `MainScene` lacked
`configure_save_system_runtime()` and `save_runtime_to_slot()`.

### GREEN

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd --ignoreHeadlessMode
```

Result: 3/3 tests passing, 0 errors, 0 failures, 0 orphans.

## Regression Evidence

SaveSystem focused regression:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd -a res://tests/unit/save/story_002_version_migration_save_info_metadata_test.gd -a res://tests/unit/save/story_003_autosave_trigger_adapter_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd --ignoreHeadlessMode
```

Result: 13/13 tests passing, 0 errors, 0 failures, 0 orphans.

MainScene focused regression:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd -a res://tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: 7/7 tests passing, 0 errors, 0 failures, 0 orphans.

## Godot Runtime Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/save_story004_main_scene_smoke.log
```

Result: Exit 0. Log scan found no `ERROR`, `WARNING`, `SCRIPT ERROR`,
`Parse Error`, `Invalid access`, `Invalid call`, `Failed`, or `Cannot`.

## Godot MCP Runtime Evidence

MCP checks:

- Confirmed Godot `4.6.3-stable`, project ready, and current scene
  `res://scenes/main.tscn`.
- Reimported `res://src/gameplay/main_scene.gd` and
  `res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd`.
- Ran the current scene through MCP.
- Runtime `game_eval` configured `/root/SaveSystem` to
  `user://cinderpaw_mcp_story004/`, saved slot 1, mutated runtime state, loaded
  slot 1, and defeated the runtime boss to trigger autosave.

Observed runtime result:

```json
{
  "auto_boss": "shadow_beast",
  "auto_currency": 36,
  "auto_defeated_has_shadow": true,
  "auto_reason": "boss_defeat",
  "configured": true,
  "has_auto_0": true,
  "has_manual_1": true,
  "load_ok": true,
  "manual_hp": 78,
  "manual_hud_scale": 1.5,
  "manual_ok": true,
  "manual_weapon": "long_tail",
  "restored_currency": 11,
  "restored_flag": true,
  "restored_hp": 78,
  "restored_hud_scale": 1.5,
  "restored_weapon": "long_tail"
}
```

Runtime logs: game log contained only the MCP helper registration line; editor
log contained 0 warnings/errors. MCP game screenshot metadata was non-empty
(1280x720 source, 640x360 returned).

## Notes

- No visual assets were added in this story.
- Threaded async write hardening for `TR-save-007` remains a later SaveSystem
  performance follow-up; this story only verifies the MainScene runtime handoff
  path and small vertical-slice save/load usage.
