# QA Evidence: Deferred Unload + Runtime Cache Eviction

> **Date**: 2026-06-25
> **Epic**: Scene Management
> **Story**: 006 Deferred Unload + Runtime Cache Eviction
> **Traceability**: TR-scene-003, TR-scene-004, TR-scene-007

## Scope

Implemented the SceneManager runtime deferred unload/cache slice:

- Outgoing runtime scene is detached and retained as a deferred cache for 3
  seconds.
- Cache diagnostics expose previous scene node/id, remaining seconds, and
  resident runtime scene count.
- Cached quick return reuses the same Node instance without another threaded
  load request.
- New swaps evict the older cache before caching the outgoing current scene.
- Runtime resident count remains current scene + at most one cached scene.

No new visual assets were added for this story.

## TDD Evidence

1. RED focused:
   `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene/story_006_deferred_unload_cache_eviction_test.gd --ignoreHeadlessMode`

   Result: exit `100`, `reports/report_432/results.xml`, failed because
   `get_previous_runtime_scene_id`, `get_deferred_unload_remaining_seconds`,
   `get_resident_runtime_scene_count`, and `advance_deferred_unload` did not
   exist yet.

2. GREEN focused:
   same command.

   Result: exit `0`, `reports/report_434/results.xml`, Story006 `4/4`, `0`
   errors, `0` failures, `0` orphans.

## Regression Evidence

SceneManagement regression:

```text
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd \
  -a res://tests/unit/scene/story_005_runtime_scene_tree_swap_test.gd \
  -a res://tests/unit/scene/story_006_deferred_unload_cache_eviction_test.gd \
  --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_437/results.xml`, `12/12`, `0` errors, `0`
failures, `0` orphans.

Related SceneManager/MainScene/HUD regression:

```text
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/scene/story_001_scene_manager_registry_api_test.gd \
  -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd \
  -a res://tests/unit/scene/story_005_runtime_scene_tree_swap_test.gd \
  -a res://tests/unit/scene/story_006_deferred_unload_cache_eviction_test.gd \
  -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd \
  -a res://tests/unit/gameplay/main_scene_title_load_handoff_test.gd \
  -a res://tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd \
  -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd \
  -a res://tests/unit/presentation/hud_manager_test.gd \
  --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_438/results.xml`, `59/59`, `0` errors, `0`
failures, `0` orphans. Godot printed one ObjectDB cleanup warning on process
exit, while GdUnit reported no orphan nodes.

Headless smoke:

```text
/opt/homebrew/bin/godot --headless --path . --quit-after 2
```

Result: exit `0`; DataManager manifest/domains loaded; no script errors.

## Godot MCP Evidence

- `editor_state`: Godot MCP connected, Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, editor readiness `ready`.
- `project_run(mode="current", autosave=true)`: project started and
  `game_capture_ready=true`.
- Runtime probe using `game_eval` created a temporary fixture runtime root and
  drove `hub -> main -> hub`:
  - first swap: `current_scene=main`, `previous_id=hub`,
    `previous_same_hub=true`, `previous_parent_is_null=true`,
    `resident_count=2`, remaining seconds approximately `2.99`.
  - quick return: `current_scene=hub`, `current_reused_hub=true`,
    `previous_id=main`, `resident_count=2`.
  - cleanup: deferred unload left `previous=null` and resident count `1`.
- `editor_screenshot(source="game")`: nonblank 1280x720 runtime image captured;
  Player and Shadow Beast enemy were visible in the scene.
- `game_manage.get_scene_tree(depth=3)`: runtime tree includes
  `/Main/Player/Sprite` and `/Main/Enemy/Sprite` as `AnimatedSprite2D`.
- `logs_read(source="game")`: only MCP helper registration info.
- `logs_read(source="editor")`: empty after clearing a temporary probe-script
  unused-variable warning.
- `project_manage(op="stop")`: stopped cleanly and editor returned to `ready`.

## Result

PASS. Story006 acceptance criteria are implemented and covered by RED/GREEN
GdUnit, related regression, headless smoke, and Godot MCP runtime validation.
