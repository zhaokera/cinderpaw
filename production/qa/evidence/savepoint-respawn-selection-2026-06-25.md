# QA Evidence: Death & Respawn Story 004 — Savepoint Respawn Selection

> Date: 2026-06-25
> Story: `production/epics/death-respawn/story-004-savepoint-respawn-selection.md`
> Epic: Death & Respawn
> Scope: `TR-respawn-002`, ADR-0007

## Result

PASS

## Summary

`GameFlowController` now selects respawn points through deterministic adapters:
valid last discovered savepoints are preferred, invalid or missing savepoints
fall back to the clan base, and active boss encounters keep higher-priority
boss entrance respawn. Runtime scene handoff goes through `SceneManager` instead
of `get_tree().reload_current_scene()` on the death path. `MainScene` persists
the last discovered savepoint in the SaveSystem runtime snapshot.

No new gameplay visual assets were required for this story.

## Acceptance Coverage

| AC | Result | Evidence |
|----|--------|----------|
| Last discovered savepoint is preferred when valid | PASS | Story004 unit test and MCP probe route to `main/mcp_savepoint`. |
| Clan base fallback is used when no/invalid savepoint exists | PASS | Story004 unit test and MCP probe route invalid savepoint to `hub/clan_base`. |
| Scene transition uses SceneManager | PASS | Story004 fake SceneManager records `change_scene`; MCP verifies root `SceneManager` state. |
| Respawn point selection is deterministic without full scene loading | PASS | Unit tests use injected savepoint and SceneManager adapters. |
| Boss entrance priority remains higher than discovered savepoint | PASS | Story004 unit test and MCP probe route boss death to `main/boss_entrance`. |

## TDD Evidence

### RED

- `reports/report_399/`: initial Story004 tests failed because
  `GameFlowController` lacked savepoint adapter/selection APIs and `MainScene`
  lacked savepoint persistence methods.
- `reports/report_404/`: added boss entrance scene ownership regression; test
  failed on missing `configure_boss_entrance_respawn()`.

### GREEN

Command:

```bash
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a tests/unit/gameplay/story_004_savepoint_respawn_selection_test.gd
```

Result: exit `0`, report `reports/report_405/`.

Summary: `4/4` passing, `0` errors, `0` failures.

## Regression Evidence

Command:

```bash
godot --headless --path . -s addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a tests/unit/gameplay/story_004_savepoint_respawn_selection_test.gd -a tests/unit/gameplay/game_flow_controller_test.gd -a tests/unit/gameplay/no_loss_respawn_state_contract_test.gd -a tests/unit/gameplay/simple_enemy_respawn_reset_test.gd -a tests/unit/scene/story_001_scene_manager_registry_api_test.gd -a tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd
```

Result: exit `0`, report `reports/report_406/`.

Summary: `24/24` passing, `0` errors, `0` failures.

## Headless Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/death_respawn_story004_main_scene_smoke.log
```

Result: exit `0`. Log scan found no `ERROR`, `WARNING`, `SCRIPT ERROR`,
`FATAL`, `Invalid call`, or `Invalid access` matches.

## Godot MCP Runtime Evidence

MCP checks:

- Godot MCP connected to Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, editor ready.
- Ran the current scene through MCP after clearing prior logs.
- Runtime `/root/SaveSystem`, `/root/SceneManager`, `/Main/GameFlowController`,
  and `/Main/Player` existed.
- Configured SaveSystem to synchronous test writes under
  `user://cinderpaw_mcp_story004/`.
- Saved and loaded a `main/mcp_savepoint` savepoint through MainScene runtime
  SaveSystem handoff.
- Drove three death paths through `GameFlowController`:
  - valid savepoint -> `SceneManager` current scene `main`, spawn
    `mcp_savepoint`, player position `(123, 456)`, HP `50`.
  - invalid savepoint -> `SceneManager` current scene `hub`, spawn
    `clan_base`, player position `(24, 42)`.
  - active boss encounter -> `SceneManager` current scene `main`, spawn
    `boss_entrance`, player position `(640, 384)`, HP `50`.
- Game logs contained only the MCP helper registration line.
- Editor logs returned `0` lines.
- Screenshot was non-empty and saved to
  `reports/visual/cinderpaw-mcp-savepoint-respawn-selection-20260625.png`.

## Notes

- `hub` currently maps to `res://scenes/main.tscn` in the logical SceneManager
  registry until a dedicated hub scene is implemented.
- Full async scene-tree replacement remains future SceneManagement work; this
  story only requires the logical SceneManager transition boundary.
