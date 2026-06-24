# QA Evidence: Scene Management Story 002 — Title/Continue/Load Runtime Handoff

Date: 2026-06-25
Story: `production/epics/scene-management/story-002-title-continue-load-runtime-handoff.md`

## Summary

Scene Management Story002 closes the player-facing save-load handoff for the
current vertical slice. New Game, Continue, and selected Load Slot now route
through SceneManager before MainScene applies loaded player/world/settings
snapshots. Load failure paths keep the menu visible, show `Load failed`, and do
not partially restore runtime state.

This story intentionally keeps SceneManager's Story001 logical transition
baseline. Async ResourceLoader requests, real scene-tree replacement, transition
presentation, deferred unload/cache eviction, fast travel, and dedicated hub/area
scene splits remain future SceneManagement stories.

## Acceptance Result

| Acceptance Criterion | Result | Evidence |
|---|---:|---|
| New Game routes to `main/default` through SceneManager. | PASS | Story002 focused GdUnit; MCP New Game probe. |
| Continue loads the first available slot in slot order, autosave slot 0 first. | PASS | Story002 focused GdUnit; MCP autosave Continue probe. |
| Load Slot restores the selected slot instead of Continue's default slot. | PASS | Story002 focused GdUnit; MCP selected slot probe. |
| Missing savepoint falls back through `world_state.scene_id`, `player_state.scene_id`, then `main/default`. | PASS | `test_load_slot_uses_scene_fallback_order_when_savepoint_is_missing`. |
| Unknown, locked, or rejected SceneManager targets fail atomically. | PASS | `test_load_slot_rejection_keeps_menu_visible_and_does_not_restore_state`; `test_locked_or_rejected_scene_manager_keeps_load_atomic`. |
| SaveSystem registered-system deserialize cannot half-restore MainScene before handoff. | PASS | `test_registered_system_deserialize_is_skipped_until_scene_handoff_succeeds`. |
| SaveSystem Story004, HUD save/load shell, SceneManager Story001, and Death & Respawn handoff remain green. | PASS | Related regression `47/47`. |

## TDD Evidence

- RED: `reports/report_408/`
  - `main_scene_title_load_handoff_test.gd` failed because New Game did not call
    SceneManager (`change_calls.size() == 0`).
- GREEN focused: `reports/report_412/`
  - `7/7` passing in
    `tests/unit/gameplay/main_scene_title_load_handoff_test.gd`.
- Related regression: `reports/report_413/`
  - `47/47` passing across:
    - `tests/unit/gameplay/main_scene_title_load_handoff_test.gd`
    - `tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd`
    - `tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd`
    - `tests/unit/presentation/hud_manager_test.gd`
    - `tests/unit/scene/story_001_scene_manager_registry_api_test.gd`
    - `tests/unit/gameplay/story_004_savepoint_respawn_selection_test.gd`

## Headless Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 2 --log-file reports/scene_story002_title_load_handoff_main_scene_smoke.log
```

Result:

- Exit code: `0`
- Log file: `reports/scene_story002_title_load_handoff_main_scene_smoke.log`
- Error/warning scan:

```bash
rg -n "ERROR|Error|error|WARNING|Warning|warning|Parse Error|SCRIPT ERROR|Invalid access|Invalid call" reports/scene_story002_title_load_handoff_main_scene_smoke.log || true
```

No matches.

## Godot MCP Runtime Evidence

MCP session:

- Editor state: Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, game capture ready.
- Runtime nodes verified: `/root/SaveSystem`, `/root/SceneManager`,
  `/Main/HUD`, `/Main/Player`.
- SaveSystem test directory:
  `user://mcp_scene_story002_title_load/`.

Runtime probes:

- New Game:
  - HUD `menu_new_game_requested` routed SceneManager to `main/default`.
  - Menu hidden after successful handoff.
- Continue:
  - Slot 0 autosave written with savepoint `mcp_continue_roost`.
  - HUD `menu_continue_requested` loaded slot 0.
  - SceneManager current spawn became `mcp_continue_roost`.
  - Player HP and currency restored from the autosave snapshot.
- Selected Load Slot:
  - Slot 1 written with savepoint `mcp_load_roost`.
  - HUD `menu_load_slot_requested(1)` loaded slot 1, not slot 0.
  - SceneManager current spawn became `mcp_load_roost`.
  - Currency restored to the selected slot state.
- Failure path:
  - Slot 2 was written with `deleted_scene/deleted_spawn`.
  - HUD `menu_load_slot_requested(2)` kept the save/load menu visible.
  - Notification text was `Load failed`.
  - Player HP, currency, and SceneManager spawn were preserved.
- Final positive-state probe:
  - Player restored to `100/100`.
  - Runtime currency restored to `31`.
  - SceneManager current scene/spawn: `main/mcp_final_roost`.
  - HUD menu hidden.

Logs and screenshot:

- Game log: only MCP capture registration line after final clear.
- Editor log: empty after final clear.
- Screenshot: MCP game screenshot returned non-empty image
  `640x360` from a `1280x720` framebuffer showing the main scene, Cinderpaw,
  Shadow Beast, HUD HP, boss bar, currency, and special meter.

## Parallel Review Notes

Two read-only subagents ran in parallel while implementation continued:

- QA review confirmed the Story002 scope should remain Title/Continue/Load
  handoff and identified missing fallback, locked/rejected, and registered
  deserialize half-restore tests. These were added before final regression.
- Art/animation review confirmed current player-visible Player and Enemy
  runtime visuals already use `AnimatedSprite2D + SpriteFrames`; no new visual
  asset was required for this SceneManagement story.

## Residual Risk

- Continue currently uses deterministic slot order (`0`, then `1-3`) rather than
  latest timestamp. This is documented in Story002 and should be promoted into a
  later UX/save metadata story if the desired behavior changes.
- SceneManager still performs logical scene changes only. Async loading,
  transition timing, timeout retry, deferred unload, and real scene-tree
  replacement remain future SceneManagement stories.
