# QA Evidence: Save System Story 003 — Autosave Trigger Adapters

> Date: 2026-06-24
> Story: `production/epics/save-system/story-003-autosave-trigger-adapters.md`
> Epic: Save System
> Scope: `TR-save-006`

## Summary

Save System Story 003 is complete. `SaveTriggerAdapter` now converts savepoint,
boss defeat, key-event, and scene-change signals into slot 0 autosaves through a
single `SaveSystem.auto_save()` path. The adapter accepts a snapshot provider,
records `autosave_reason` and `autosave_context` under `world_state`, and emits
success/failure signals without depending on concrete gameplay classes.

## Acceptance Coverage

| AC | Result | Evidence |
|----|--------|----------|
| Savepoint entry signal writes slot 0 with provider snapshots | PASS | `test_savepoint_signal_writes_slot_zero_with_snapshot_and_context` |
| Boss defeat, key-event, scene-change share one autosave path and emit reason | PASS | `test_boss_key_and_scene_triggers_share_autosave_path_and_emit_reasons` |
| Invalid/failed triggers fail cleanly without manual slot writes | PASS | `test_invalid_and_failed_autosave_triggers_fail_without_manual_slot_write` |
| Adapter stays decoupled from concrete gameplay classes | PASS | Tests use mock signal emitters and a SaveSystem-like object only. |

## TDD Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_003_autosave_trigger_adapter_test.gd --ignoreHeadlessMode
```

Result: Exit 100 as expected. The first run failed because
`res://src/feature/save_trigger_adapter.gd` did not exist.

### GREEN

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_003_autosave_trigger_adapter_test.gd --ignoreHeadlessMode
```

Result: 3/3 tests passing, 0 errors, 0 failures, 0 orphans.

## Regression Evidence

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd -a res://tests/unit/save/story_002_version_migration_save_info_metadata_test.gd -a res://tests/unit/save/story_003_autosave_trigger_adapter_test.gd --ignoreHeadlessMode
```

Result: 10/10 tests passing, 0 errors, 0 failures, 0 orphans.

## Godot Runtime Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/save_story003_main_scene_smoke.log
```

Result: Exit 0. Log scan found no `ERROR`, `WARNING`, `SCRIPT ERROR`,
`Parse Error`, `Invalid access`, `Invalid call`, `Failed`, or `Cannot`.

## Godot MCP Runtime Evidence

MCP endpoint: `http://127.0.0.1:8000/mcp`
MCP session: `cinderpaw@c1b2`
Godot AI: 3.4.2
Godot: 4.6.3 stable

MCP checks:

- Initialized the MCP streamable HTTP session and activated `cinderpaw@c1b2`.
- Reimported `res://src/feature/save_trigger_adapter.gd`,
  `res://src/feature/save_system.gd`, and the Story 003 test.
- Opened and ran `res://scenes/main.tscn`.
- Created a temporary `SaveTriggerAdapter`, snapshot provider, and mock signal
  source in runtime `game_eval`.
- Bound savepoint and boss defeat signals, emitted both, and verified autosave.

Observed runtime result:

```json
{
  "bind_boss": true,
  "bind_savepoint": true,
  "context_boss": "rat_king",
  "file_size_positive": true,
  "has_auto": true,
  "has_manual_1": false,
  "hp": 71,
  "hud_scale": 1.25,
  "reason": "boss_defeat",
  "reasons": ["savepoint", "boss_defeat"]
}
```

Runtime logs: game log contained only the MCP helper registration line. Editor
log contained 0 warnings/errors after clearing stale dynamic-script warnings and
rerunning the probe with explicit signal emitter methods.

## Notes

- No visual assets were added in this story.
- MainScene runtime state provider and load handoff remain scoped to Save
  System Story 004.
