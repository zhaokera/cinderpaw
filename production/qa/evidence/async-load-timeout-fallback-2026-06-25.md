# QA Evidence: Async Load Request Lifecycle + Timeout Fallback

> **Story**: `production/epics/scene-management/story-003-async-load-timeout-fallback.md`
> **Date**: 2026-06-25
> **Engine**: Godot 4.6.3
> **Result**: PASS

## Scope

Validated the SceneManager async request lifecycle slice:

- `request_scene_change(scene_id, spawn_point)` starts a threaded request without
  immediately mutating current scene/spawn.
- Loaded scenes wait for the 1.5 second transition gate before logical commit.
- Completed loads call `load_threaded_get()` before commit.
- A 10 second in-progress load retries once, then emits
  `on_scene_load_failed(scene_id, "timeout")` and falls back to the hub registry
  default spawn.
- Locked, unknown, or already-loading requests reject without side effects.

Out of scope for this evidence: real scene-tree swap, deferred unload/cache,
fast travel, authored transition visuals, loading UI/audio, and memory peak
verification.

## Automated Evidence

### RED

- `reports/report_414/`
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd --ignoreHeadlessMode`
  - Expected failure: missing Story003 async SceneManager APIs.

- `reports/report_418/`
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd --ignoreHeadlessMode`
  - Expected failure: loaded request did not call `load_threaded_get()` before
    logical commit.

### GREEN

- `reports/report_419/`
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd --ignoreHeadlessMode`
  - Result: `4/4` passed.

### Related Regression

- `reports/report_420/`
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd -a res://tests/unit/scene/story_001_scene_manager_registry_api_test.gd -a res://tests/unit/gameplay/main_scene_title_load_handoff_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd -a res://tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd -a res://tests/unit/presentation/hud_manager_test.gd -a res://tests/unit/gameplay/no_loss_respawn_state_contract_test.gd --ignoreHeadlessMode`
  - Result: `49/49` passed.

## Headless Smoke

- `reports/scene_story003_async_load_main_scene_smoke.log`
  - Command:
    `godot --headless --path . --quit-after 2 scenes/main.tscn > reports/scene_story003_async_load_main_scene_smoke.log 2>&1`
  - Exit code: `0`
  - Error/warning scan:
    `rg -n "ERROR|SCRIPT ERROR|Parse Error|Invalid call|Invalid access|WARNING" reports/scene_story003_async_load_main_scene_smoke.log`
  - Result: no matches.

## Godot MCP Evidence

MCP connection:

- `editor_state`: ready/playing on `res://scenes/main.tscn`
- Godot version: `4.6.3-stable`
- `api_manage(ResourceLoader)` confirmed:
  - `load_threaded_request(path, type_hint, use_sub_threads, cache_mode)`
  - `load_threaded_get_status(path, progress)`
  - `load_threaded_get(path)`
  - `THREAD_LOAD_IN_PROGRESS = 1`, `THREAD_LOAD_FAILED = 2`,
    `THREAD_LOAD_LOADED = 3`

Runtime probe:

- `/root/SceneManager` existed in the running game.
- Success path:
  - after request: `loading=true`, current `hub/clan_base`, pending
    `main/mcp_real_gate_final`
  - after 1.0 seconds: current still `hub/clan_base`, no loaded/changed events
  - after 1.5+ seconds: current `main/mcp_real_gate_final`, events
    `loaded:main`, `changed:hub>main`
- Loaded-resource completion seam:
  - fake loaded adapter committed to `main/mcp_fake_loaded`
  - `load_threaded_get()` calls: `["res://scenes/main.tscn"]`
- Timeout path:
  - after first 10 seconds: `loading=true`, `retry_count=1`,
    `request_count=2`, current `hub/clan_base`
  - after retry timeout: `loading=false`, `last_error=timeout`,
    failures `main:timeout`, fallback `hub/clan_base`, no loaded resource get
    on failed load

Logs:

- Game logs after final probe: only MCP helper registration info.
- Editor logs after final probe: empty.

Screenshot:

- `editor_screenshot(source="game", max_resolution=640)` returned non-empty
  `640x360` PNG metadata, with the main scene visible.

## Asset Note

No image-generated visual asset was required for this logic/integration slice.
Transition visuals, loading UI, and authored scene-change effects remain future
SceneManagement stories and should follow the image2/image generation asset
pipeline when implemented.
