# Story 007: Fast Travel Preload + Scene Change

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/scene-management.md`
**Requirements**: `TR-scene-006`, `TR-scene-002`, `TR-scene-007`, `TR-scene-008`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0007: Scene management architecture

**ADR Decision Summary**: SceneManager owns asynchronous scene requests through
Godot `ResourceLoader`, masks loading behind transition animation, preserves
runtime scene state, and enforces deferred cache constraints. Fast travel uses a
2.0 second portal animation window to preload the target scene before switching.

**Engine**: Godot 4.6.3 | **Risk**: MEDIUM

**Control Manifest Rules (Feature layer)**:
- Required: fast travel preloads the target scene during a 2-second portal
  animation.
- Required: fast travel uses the existing `ResourceLoader.load_threaded_request()`
  async path rather than synchronous scene switching.
- Required: boss scene lock and active loading state reject new fast-travel
  requests.
- Required: existing timeout retry, runtime scene swap, scene-state restore,
  deferred unload, and max-two-resident behavior remain intact.

---

## Acceptance Criteria

- [x] `request_fast_travel_scene_change(scene_id, spawn_point)` validates the
  registry, boss lock, and active loading state, starts one threaded request for
  the target scene path, emits fast-travel preload metadata, and does not mutate
  the current scene/spawn immediately.
- [x] A loaded fast-travel target does not commit before the 2.0 second portal
  animation gate. Once the loader is complete and the portal gate has elapsed,
  SceneManager consumes the loaded `PackedScene` once and emits the existing
  loaded/changed signals.
- [x] When runtime scene-tree swap is configured, the fast-travel completion path
  instantiates the loaded target scene into the runtime root, detaches/caches the
  outgoing scene through Story006 deferred unload, and keeps resident runtime
  scenes at current plus one cached scene.
- [x] Unknown scene IDs, locked scene state, normal loading, or another active
  fast-travel request reject without issuing additional loader calls or mutating
  current state.
- [x] Fast-travel loads inherit the Story003 10-second timeout retry and hub
  fallback behavior, while also emitting a fast-travel failure signal for future
  UI/audio consumers.
- [x] Existing `request_scene_change()`, transition loading UI, runtime swap,
  and deferred cache behavior remain source-compatible.

---

## Implementation Notes

- Add a dedicated fast-travel request API instead of overloading regular portal
  transitions. The API may share the existing pending-load state machine, but the
  transition gate must be 2.0 seconds and metadata must clearly mark the request
  as `fast_travel`.
- Reuse the loader adapter seam from Story003 so tests can drive deterministic
  `ResourceLoader` statuses.
- Reuse `_finish_pending_load()` and runtime swap helpers so scene-local state,
  deferred unload, and invalid `PackedScene` behavior stay centralized.
- Emit fast-travel-specific started/completed/failed signals with no more than
  three payload fields per ADR-0002 signal rules.

---

## Out of Scope

- Fast travel menu, savepoint discovery UI, thumbnails, or map integration.
- Authored portal animation scene, particles, audio, or image-generated visual
  assets.
- Loading audio fade in/out.
- Real hub/area/boss scene splits beyond current registry paths.
- Platform memory profiler evidence.
- Scene request queue coalescing or cancellation.
- New character art, frame animation, or gameplay tuning.

---

## QA Test Cases

- **AC-1**: Fast travel preload starts without immediate commit.
  - Given: SceneManager is configured with hub/main registry and a fake threaded
    loader.
  - When: `request_fast_travel_scene_change("main", "east_gate")` is called.
  - Then: loader receives one request for the target path, fast-travel metadata
    reports a 2.0 second portal duration, loading is true, and current scene
    remains `hub`.

- **AC-2**: Portal gate controls fast-travel completion timing.
  - Given: the fake loader reports the target as loaded immediately.
  - When: SceneManager advances by less than 2.0 seconds.
  - Then: current scene is still `hub` and `load_threaded_get()` has not been
    consumed.
  - When: SceneManager advances past 2.0 seconds.
  - Then: current scene becomes `main`, spawn becomes `east_gate`, and
    `load_threaded_get()` is called exactly once.

- **AC-3**: Runtime swap and deferred cache remain intact.
  - Given: a runtime scene root owns the current hub scene.
  - When: fast travel completes into `main`.
  - Then: the new runtime scene is attached, the old hub runtime scene is cached
    for deferred unload, and resident runtime count is two.

- **AC-4**: Rejection paths do not issue requests.
  - Given: SceneManager is locked, already loading, or given an unknown scene.
  - When: fast travel is requested.
  - Then: it returns false, does not call the loader, and leaves current state
    unchanged.

- **AC-5**: Timeout retry/fallback remains compatible.
  - Given: the fake loader remains in progress.
  - When: fast travel exceeds the timeout twice.
  - Then: SceneManager retries once, emits failure, clears fast-travel state, and
    falls back to hub/default spawn.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/scene/story_007_fast_travel_preload_scene_change_test.gd` RED then GREEN.
- Focused regression with SceneManagement Story003, Story005, Story006, and
  Story007.
- Related regression for MainScene transition UI/title-load handoff where
  practical.
- Godot headless main-scene smoke.
- Godot MCP verifies `/root/SceneManager`, fast-travel runtime probe, clean logs,
  non-empty screenshot, and visible `AnimatedSprite2D` player/enemy runtime
  nodes.

**Completed evidence**:
- RED: `reports/report_439/results.xml` failed because the fast-travel API and
  signals did not exist yet.
- RED: `reports/report_441/results.xml` failed because fast-travel metadata did
  not expose `transition_type="fast_travel"` for downstream presentation/audio
  consumers.
- GREEN focused: `reports/report_443/results.xml` passed Story007 `6/6` with
  `0` errors, `0` failures, `0` orphans.
- SceneManagement regression: `reports/report_444/results.xml` passed
  Story003, Story005, Story006, and Story007 `18/18` with `0` errors, `0`
  failures, `0` orphans.
- Related MainScene/HUD regression: `reports/report_445/results.xml` passed
  MainScene transition UI, title/load handoff, save/load menu, and HUD tests
  `35/35` with `0` errors, `0` failures, `0` orphans.
- Headless smoke: `/opt/homebrew/bin/godot --headless --path . --quit-after 2`
  exited `0`.
- Godot MCP: project ran `res://scenes/main.tscn`; runtime probe confirmed
  `/root/SceneManager` exposes fast-travel API/signals, emits
  `transition_type="fast_travel"` and 2.0 second portal metadata, does not
  commit before 1.99 seconds, commits to `main/mcp_fast_travel_gate` after the
  portal gate and loader completion, emits no failures, keeps Player/Enemy as
  `AnimatedSprite2D`, game/editor logs are clean, and game screenshot is
  nonblank.

**Status**: [x] Complete

---

## Dependencies

- Depends on: Scene Management Story 003.
- Depends on: Scene Management Story 005.
- Depends on: Scene Management Story 006.
- Unlocks: fast travel menu integration, portal animation/audio presentation,
  and scene memory-budget verification.
