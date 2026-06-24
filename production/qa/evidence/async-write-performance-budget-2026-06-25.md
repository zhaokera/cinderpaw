# QA Evidence: Save System Story 005 — Async Write Performance Budget

> Date: 2026-06-25
> Story: `production/epics/save-system/story-005-async-write-performance-budget.md`
> Epic: Save System
> Scope: `TR-save-007`

## Result

PASS

## Summary

Save System Story 005 is complete. `SaveSystem` now defaults to asynchronous
slot writes, exposes pending-write and dispatch-duration diagnostics, rejects
concurrent save requests while one write is pending, reports write failures via
`on_save_write_failed(slot, reason)`, and preserves the synchronous fallback for
tests/platforms that disable async writes.

`MainScene` consumes `on_save_written` / `on_save_write_failed` so HUD save/load
feedback waits for actual write completion. A second save request during a
pending write keeps the original pending slot authoritative and leaves the UI in
`Saving...` instead of replacing the pending save or showing a false failure.

## Acceptance Coverage

| AC | Result | Evidence |
|----|--------|----------|
| Async dispatch returns inside the 100ms budget | PASS | Story005 unit test asserts dispatch duration `<100ms`; MCP runtime measured `0.965ms`. |
| Single-write lock rejects concurrent writes without corrupting the pending save | PASS | Story005 SaveSystem unit test and MainScene pending-slot test verify second requests do not replace slot 1. |
| Completion emits `on_save_written(slot)` and leaves valid JSON with backup semantics | PASS | Story005 unit tests verify completion, JSON validation, and `.bak` preservation. |
| Synchronous fallback remains deterministic | PASS | Story005 unit test disables async and verifies immediate file write + success signal. |
| Async failure clears pending state and reports failure | PASS | Story005 unit test and MainScene failure test verify pending cleanup and `Save failed` UI feedback. |

## TDD Evidence

### RED

- SaveSystem API RED: `reports/report_384/`
  - Command:
    ```bash
    godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_005_async_write_performance_budget_test.gd --ignoreHeadlessMode
    ```
  - Result: Exit 100 as expected. First failure was missing async API/signal
    surface.
- MainScene async menu RED: `reports/report_388/`
  - Same focused command against `main_scene_save_load_menu_runtime_test.gd`.
  - Result: Exit 100 as expected. UI showed `Game saved` before async
    completion and did not refresh slot labels on completion.
- MainScene pending guard RED: `reports/report_392/`
  - Result: Exit 100 as expected. A second save request during pending write
    replaced the pending slot and showed `Save failed`.

### GREEN

- Focused SaveSystem GREEN: `reports/report_386/`
  - Result: 5/5 passing.
- Focused MainScene save/load GREEN: `reports/report_393/`
  - Result: 4/4 passing.

## Regression Evidence

Focused SaveSystem + HUD/MainScene regression:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd -a res://tests/unit/save/story_002_version_migration_save_info_metadata_test.gd -a res://tests/unit/save/story_003_autosave_trigger_adapter_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd -a res://tests/unit/save/story_005_async_write_performance_budget_test.gd -a res://tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd -a res://tests/unit/presentation/hud_manager_test.gd --ignoreHeadlessMode
```

Result: Exit 0, 42/42 passing, 0 errors, 0 failures, 0 orphans.

Report: `reports/report_394/`.

## Headless Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/save_story005_async_write_smoke.log
```

Result: Exit 0. Log scan found no `ERROR`, `WARNING`, `SCRIPT ERROR`,
`Parse Error`, `Invalid access`, `Invalid call`, `Failed`, `Cannot`, or `ERR_`
matches.

## Godot MCP Runtime Evidence

MCP checks:

- Godot MCP connected to Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, editor ready.
- Opened `res://scenes/main.tscn` through MCP and ran the current scene.
- Runtime `game_eval` configured `/root/SaveSystem` to a fresh
  `user://cinderpaw_mcp_story005_clean_*/` directory, enabled async writes,
  connected write success/failure signals, routed `MainScene` to the runtime
  SaveSystem, opened the save/load menu, requested slot 1 save, requested slot 2
  while slot 1 was pending, then flushed completion for verification.

Observed runtime result:

```json
{
  "configured": true,
  "dispatch_duration_msec": 0.965,
  "failed_reasons": [],
  "flush_ok": true,
  "has_save_slot_1": true,
  "labels_after_request": [
    "Autosave: Empty",
    "Slot 1: Empty",
    "Slot 2: Empty",
    "Slot 3: Empty"
  ],
  "labels_final": [
    "Autosave: Empty",
    "Slot 1: Manual Save | HP 30 | cat_claw | Gears 0",
    "Slot 2: Empty",
    "Slot 3: Empty"
  ],
  "notification_after_request": "Saving...",
  "notification_after_second_request": "Saving...",
  "notification_final": "Game saved",
  "pending_after_request": true,
  "pending_after_second_request": true,
  "pending_final": false,
  "written_slots": [1]
}
```

Runtime logs contained only MCP/plugin informational lines and the game helper
registration line. MCP game screenshot was non-empty at 960x540 and showed the
save/load shell with slot 1 populated after completion.

## Notes

- No new visual assets were added in this story.
- HUD remains a passive save/load shell. It does not own SaveSystem state,
  pending-write state, file rules, or savepoint availability.
- The MCP hierarchy still shows player/enemy sprite nodes in the edited scene;
  that is outside Story005 and should be addressed in the next animation/visual
  polish slice under the `AGENTS.md` frame-animation rules.
