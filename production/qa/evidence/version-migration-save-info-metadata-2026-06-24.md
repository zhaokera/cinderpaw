# QA Evidence: Save System Story 002 — Version Migration + SaveInfo Metadata

> Date: 2026-06-24
> Story: `production/epics/save-system/story-002-version-migration-save-info-metadata.md`
> Epic: Save System
> Scope: `TR-save-002`, `TR-save-005`

## Summary

Save System Story 002 is complete. `SaveSystem` now exposes per-slot
`SaveInfo` metadata for UI/HUD consumers and migrates older save payloads through
registered callbacks before registered systems deserialize. Missing migrations
and future versions fail cleanly without overwriting `last_loaded_data`.

## Acceptance Coverage

| AC | Result | Evidence |
|----|--------|----------|
| Empty and populated `get_save_info(slot)` | PASS | Story 002 unit test verifies missing slot, manual slot, and autosave slot metadata. |
| Slot, autosave, timestamp, play time, save-point, version, summary, file size | PASS | Story 002 unit test verifies all fields and UI summary values. |
| Older versions migrate before deserialize | PASS | Version 0 fixture migrates to version 1 before `MockSerializable.deserialize()`. |
| Missing migration and future version fail cleanly | PASS | Story 002 unit test verifies `load_game()` returns false and `last_loaded_data` remains empty. |

## TDD Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_002_version_migration_save_info_metadata_test.gd --ignoreHeadlessMode
```

Result: Exit 100 as expected. The first run failed on missing
`get_save_info()`, missing `register_migration()`, and an old version 0 save
being loaded without a migration callback.

### GREEN

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_002_version_migration_save_info_metadata_test.gd --ignoreHeadlessMode
```

Result: 3/3 tests passing, 0 errors, 0 failures.

## Regression Evidence

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd -a res://tests/unit/save/story_002_version_migration_save_info_metadata_test.gd -a res://tests/unit/input/story_001_action_abstraction_test.gd --ignoreHeadlessMode
```

Result: 12/12 tests passing, 0 errors, 0 failures.

## Godot Runtime Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/save_story002_main_scene_smoke.log
```

Result: Exit 0. Log scan found no `ERROR`, `WARNING`, `SCRIPT ERROR`,
`Parse Error`, `Invalid access`, `Invalid call`, `Failed`, or `Cannot`.

## Godot MCP Runtime Evidence

MCP endpoint: `http://127.0.0.1:8000/mcp`
MCP session: `cinderpaw@c1b2`
Godot AI: 3.4.2
Godot: 4.6.3 stable

MCP checks:

- Stopped any running game instance.
- Confirmed `autoload/SaveSystem` is `*res://src/feature/save_system.gd`.
- Reimported `res://src/feature/save_system.gd`,
  `res://src/feature/save_info.gd`, and the Story 002 test.
- Opened and ran `res://scenes/main.tscn`.
- Evaluated runtime metadata and migration behavior through `SaveSystem`.

Observed runtime result:

```json
{
  "auto_is_auto": true,
  "info_exists": true,
  "info_file_size_positive": true,
  "info_hp": 55.0,
  "info_is_auto": false,
  "info_slot": 1.0,
  "loaded": true,
  "loaded_version": 1.0,
  "manual_ok": true,
  "migrated_energy": 31.0,
  "migrated_focus": false,
  "migration_ok": true
}
```

Runtime logs: game log contained only the MCP helper registration line; editor
log contained 0 errors.

## Notes

- `SaveInfo` is implemented as `class_name SaveInfo` extending `RefCounted`.
  `SaveSystem.get_save_info()` uses a `RefCounted` return annotation and a
  preloaded script instance so Godot headless Autoload compilation does not fail
  while resolving a newly added `class_name`.
- ADR-0021 is still marked Proposed in the architecture docs, but Save System
  Stories 001 and 002 already use it as the governing implementation contract.
- No visual assets were added in this story.
