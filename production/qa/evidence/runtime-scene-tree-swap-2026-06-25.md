# QA Evidence: Runtime Scene-Tree Swap Ownership — 2026-06-25

## Scope

Verifies Scene Management Story 005. The slice adds the SceneManager-owned
runtime scene-tree swap seam after Story003 async loading and Story004 transition
presentation. It does not claim 3-second deferred unload timers, max-two cached
scene eviction, fast travel preload, audio fades, memory profiling, or dedicated
hub/area/boss scene splits.

## Story

- Story:
  `production/epics/scene-management/story-005-runtime-scene-tree-swap.md`
- Requirements: `TR-scene-003`, `TR-scene-004`, `TR-scene-007`
- New test fixture:
  - `tests/fixtures/scene_manager/stateful_runtime_scene.tscn`
  - `tests/fixtures/scene_manager/stateful_runtime_scene.gd`
- New public runtime diagnostics:
  - `configure_runtime_scene_root(root, current_scene_node)`
  - `is_runtime_scene_swap_enabled()`
  - `get_runtime_scene_root_node()`
  - `get_current_runtime_scene_node()`
  - `get_previous_runtime_scene_node()`

## Automated Evidence

### RED

Focused Story005 command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/scene/story_005_runtime_scene_tree_swap_test.gd \
  --ignoreHeadlessMode
```

RED results:

- `reports/report_424/` exited `100`; runtime scene-root APIs were missing.
- `reports/report_425/` exited `100`; runtime swap invalid-resource failure used
  hub fallback and changed logical state while the old runtime scene remained
  attached.
- `reports/report_429/` exited `100`; QA review expanded runtime diagnostics to
  require `get_runtime_scene_root_node()`.

### GREEN

Focused Story005 command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/scene/story_005_runtime_scene_tree_swap_test.gd \
  --ignoreHeadlessMode
```

Result: exit `0`, `4/4` passing, `0` errors/failures/skips/flakes/orphans,
`reports/report_430/`.

Covered behaviors:

- Runtime root configuration and current/previous/root diagnostics.
- Transition-gated loaded `PackedScene` instantiation into the configured root.
- Signal order remains `on_scene_loaded` then `on_scene_changed`, with the new
  runtime scene attached before the loaded signal.
- Outgoing runtime scene is detached and retained as previous runtime scene
  diagnostics for the later deferred-unload/cache story.
- Outgoing `get_local_state()` is captured; incoming cached state is restored
  through `set_local_state(state)`.
- Invalid loaded resources emit `invalid_packed_scene`, keep old runtime scene
  attached, preserve pre-request scene/spawn, and do not overwrite cached state.
- No runtime root preserves Story003 logical async commit behavior.

### Related Regression

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/scene/story_001_scene_manager_registry_api_test.gd \
  -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd \
  -a res://tests/unit/scene/story_005_runtime_scene_tree_swap_test.gd \
  -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd \
  -a res://tests/unit/gameplay/main_scene_title_load_handoff_test.gd \
  -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd \
  -a res://tests/unit/save/story_005_async_write_performance_budget_test.gd \
  -a res://tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd \
  -a res://tests/unit/presentation/hud_manager_test.gd \
  --ignoreHeadlessMode
```

Result: exit `0`, `60/60` passing, `0` errors/failures/skips/flakes/orphans,
`reports/report_431/`.

Note: the Godot process printed the existing ObjectDB-leak warning after the
successful GdUnit summary. The test report itself had zero orphans.

### Headless Smoke

Command:

```bash
godot --headless --path . \
  --scene res://scenes/main.tscn \
  --fixed-fps 60 \
  --quit-after 180 \
  --log-file reports/scene_story005_runtime_swap_main_scene_smoke.log

rg -n "ERROR|Error|error|WARNING|Warning|warning|Parse Error|SCRIPT ERROR|Invalid call|Failed" \
  reports/scene_story005_runtime_swap_main_scene_smoke.log || true
```

Result: Godot exited `0`; log scan returned no matches.

## Godot MCP Evidence

- `editor_state` connected to Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, readiness `ready`.
- `project_run(mode="current", autosave=true)` started the game and
  `game_capture_ready=true`.
- Success probe:
  - Configured a temporary runtime root under the running scene.
  - Configured SceneManager with the Story005 fixture registry.
  - Used a fake loader returning a `PackedScene`.
  - `advance_loading(1.0)` kept loading true and current scene `hub`.
  - `advance_loading(0.5)` completed the transition; current scene/spawn became
    `main/mcp_swap_clean`.
  - New runtime scene was attached to the root before `on_scene_loaded`.
  - Previous runtime scene was detached and retained.
  - Hub local state `{"hub_gate": "open"}` was captured.
  - Target state `{"crate": "broken"}` was restored through
    `set_local_state()`.
- Failure probe:
  - Used a fake loader returning `null` after loaded status.
  - Request `main/east_gate -> hub/clan_base` failed with
    `invalid_packed_scene`.
  - Runtime scene stayed attached.
  - Logical scene/spawn remained `main/east_gate`.
  - Cached `main` state remained `{"persisted": "safe"}`.
- Runtime logs after clean probes:
  - Game log contained only the MCP helper registration line.
  - Editor log contained no entries.
- Runtime scene tree still contained Player and Enemy `AnimatedSprite2D` nodes.
- Screenshot: `reports/visual/cinderpaw-mcp-runtime-scene-tree-swap-20260625.png`
  saved successfully at `1280x720`.

## Result

Story005 PASS for runtime scene-tree swap ownership. Remaining SceneManagement
work is deferred unload/cache eviction, fast travel preload, loading audio
fades, and memory-budget verification.
