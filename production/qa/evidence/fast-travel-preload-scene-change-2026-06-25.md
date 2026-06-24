# QA Evidence: Fast Travel Preload + Scene Change

> **Date**: 2026-06-25
> **Epic**: Scene Management
> **Story**: 007 Fast Travel Preload + Scene Change
> **Traceability**: TR-scene-006, TR-scene-002, TR-scene-007, TR-scene-008

## Scope

Implemented the SceneManager fast-travel preload slice:

- `request_fast_travel_scene_change(scene_id, spawn_point)` starts the existing
  async `ResourceLoader` path with fast-travel metadata.
- Fast travel waits for a 2.0 second portal gate before committing, even when
  the loader finishes earlier.
- Fast travel emits started/completed/failed signals for future UI/audio
  consumers.
- Deferred runtime cache hits are reused after the 2.0 second gate without a new
  loader request or `load_threaded_get()` call.
- Timeout retry, hub fallback, runtime scene-tree swap, scene-state restore, and
  deferred unload behavior remain shared with regular async scene changes.

No new visual assets were added for this story; portal animation, particles, and
audio are explicitly out of scope for this integration slice.

## TDD Evidence

1. RED focused:
   `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene/story_007_fast_travel_preload_scene_change_test.gd --ignoreHeadlessMode`

   Result: exit `100`, `reports/report_439/results.xml`, failed because
   `request_fast_travel_scene_change`, `is_fast_travel_loading`,
   `get_fast_travel_portal_remaining_seconds`, and fast-travel signals did not
   exist yet.

2. RED metadata refinement:
   same command.

   Result: exit `100`, `reports/report_441/results.xml`, failed because
   fast-travel metadata did not include `transition_type="fast_travel"`.

3. GREEN focused:
   same command.

   Result: exit `0`, `reports/report_443/results.xml`, Story007 `6/6`, `0`
   errors, `0` failures, `0` orphans.

## Regression Evidence

SceneManagement regression:

```text
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd \
  -a res://tests/unit/scene/story_005_runtime_scene_tree_swap_test.gd \
  -a res://tests/unit/scene/story_006_deferred_unload_cache_eviction_test.gd \
  -a res://tests/unit/scene/story_007_fast_travel_preload_scene_change_test.gd \
  --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_444/results.xml`, `18/18`, `0` errors, `0`
failures, `0` orphans.

Related MainScene/HUD regression:

```text
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd \
  -a res://tests/unit/gameplay/main_scene_title_load_handoff_test.gd \
  -a res://tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd \
  -a res://tests/unit/presentation/hud_manager_test.gd \
  --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_445/results.xml`, `35/35`, `0` errors, `0`
failures, `0` orphans.

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
- Runtime `game_eval` probe against `/root/SceneManager`:
  - API/signals exist: `request_fast_travel_scene_change`,
    `on_fast_travel_preload_started`, `on_fast_travel_preload_completed`,
    `on_fast_travel_preload_failed`.
  - Request to `main/mcp_fast_travel_gate` succeeded and emitted
    `transition_type="fast_travel"`, `fast_travel=true`,
    `portal_duration_sec=2.0`, `transition_duration_sec=2.0`, and target path
    `res://scenes/main.tscn`.
  - At 1.99 seconds, current spawn remained `boss_entrance`, completion signal
    had not fired, and remaining portal time was approximately `0.01`.
  - After advancing past the gate and loader completion, loading cleared and
    current spawn became `mcp_fast_travel_gate`.
  - No fast-travel or scene-load failures were emitted.
- Runtime scene tree and screenshot:
  - `/Main/Player/Sprite` and `/Main/Enemy/Sprite` are `AnimatedSprite2D`.
  - `editor_screenshot(source="game")` returned a nonblank 1280x720 runtime
    image showing the game scene, HUD, player, and enemy.
- Logs:
  - `logs_read(source="game")`: only MCP helper registration info.
  - `logs_read(source="editor")`: empty after clearing logs before the run.

## Result

PASS. Story007 acceptance criteria are implemented and covered by RED/GREEN
GdUnit, SceneManagement regression, related MainScene/HUD regression, headless
smoke, and Godot MCP runtime validation.
