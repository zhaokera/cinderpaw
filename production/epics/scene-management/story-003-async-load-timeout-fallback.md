# Story 003: Async Load Request Lifecycle + Timeout Fallback

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/scene-management.md`
**Requirements**: `TR-scene-002`, `TR-scene-007`, `TR-scene-008`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0007: Scene management architecture

**ADR Decision Summary**: SceneManager owns asynchronous load requests through
Godot `ResourceLoader`, gates scene commits behind a 1-2 second transition
window, and handles timeout by retrying once before failing back to hub.

**Engine**: Godot 4.6.3 | **Risk**: MEDIUM

**Control Manifest Rules (Feature layer)**:
- Required: `ResourceLoader.load_threaded_request()` starts scene loads.
- Required: transition timing masks scene load for 1.5 seconds.
- Required: scene load timeout is 10 seconds, retry once, then return to hub.
- Guardrail: This story keeps logical SceneManager commit semantics from
  Story001; real scene-tree replacement, deferred unload/cache enforcement,
  transition visuals, and fast travel remain future stories.

---

## Acceptance Criteria

- [x] `request_scene_change(scene_id, spawn_point)` validates the registry and
  boss lock, starts one threaded request for the target scene path, enters
  loading state, and does not mutate the current scene/spawn immediately.
- [x] A loaded target scene does not commit before the 1.5 second transition gate.
  Once both the loader is complete and the transition gate has elapsed,
  SceneManager emits the existing loaded/changed signals and updates the
  logical current scene/spawn.
- [x] If the first load attempt remains in progress for 10 seconds,
  SceneManager retries the same target once without committing or corrupting
  current state.
- [x] If the retry also times out, SceneManager exits loading state, records the
  timeout reason, emits `on_scene_load_failed(scene_id, reason)`, and falls back
  to the hub scene using the hub registry `default_spawn`.
- [x] Unknown scene IDs, locked scene state, or an already-loading request reject
  new async scene changes without issuing loader calls or mutating current state.
- [x] Story001 `change_scene()` and Story002 title/load handoff behavior remain
  source-compatible for existing callers.

---

## Implementation Notes

- Add a test seam for threaded loading so GdUnit can drive deterministic loader
  statuses without sleeping or depending on editor import timing.
- Production behavior should default to Godot `ResourceLoader`:
  `load_threaded_request(path, "PackedScene", false, ResourceLoader.CACHE_MODE_REUSE)`,
  `load_threaded_get_status(path, progress)`, and `load_threaded_get(path)`.
- Use explicit diagnostics for pending scene/spawn, retry count, and last load
  error so tests and MCP runtime probes can verify state without relying on
  private fields.
- Keep `change_scene()` as the immediate logical commit helper for existing
  Story001/Story002 code. The async path may use an internal commit helper so
  `_loading` does not block its own completion.

---

## Out of Scope

- Real scene-tree unload/add/remove or `PackedScene.instantiate()` ownership.
- Deferred unload/cache eviction and max-two-resident-scenes enforcement.
- Fast travel portal animation or fast travel menu.
- Authored transition visuals, loading UI, audio fades, or image-generated
  transition assets.
- Real hub/area/boss scene split beyond the current registry paths.
- SaveSystem load ordering or title menu behavior beyond regression coverage.

---

## QA Test Cases

- **AC-1**: Async request starts without immediate commit.
  - Given: SceneManager is configured with the current hub/main registry and a
    fake threaded loader.
  - When: `request_scene_change("main", "east_gate")` is called.
  - Then: loader receives one request for `res://scenes/main.tscn`, loading is
    true, pending target is `main/east_gate`, and current scene remains `hub`.

- **AC-2**: Transition gate controls commit timing.
  - Given: the fake loader reports the target as loaded immediately.
  - When: SceneManager advances by 1.0 seconds.
  - Then: the current scene is still `hub`.
  - When: SceneManager advances by another 0.5 seconds.
  - Then: current scene becomes `main`, current spawn becomes `east_gate`, and
    existing SceneManager loaded/changed signals fire once.

- **AC-3**: Timeout retry and fallback.
  - Given: the fake loader remains in-progress.
  - When: SceneManager advances through the first 10 second timeout.
  - Then: the loader has received a second request for the same path and retry
    count is 1.
  - When: the retry also times out.
  - Then: loading stops, timeout is recorded, failure signal fires, and the
    logical current scene is hub/default spawn.

- **AC-4**: Rejection paths do not issue requests.
  - Given: SceneManager is locked, already loading, or given an unknown scene.
  - When: `request_scene_change()` is called.
  - Then: it returns false, does not call the loader, and leaves current state
    unchanged.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/scene/story_003_async_load_timeout_fallback_test.gd` RED then GREEN.
- Regression with SceneManager Story001 and MainScene Story002 save-load handoff.
- Godot headless main-scene smoke.
- Godot MCP verifies `/root/SceneManager`, async request diagnostics, timeout
  fallback path, clean logs, and non-empty game screenshot.

**Completed evidence**:
- RED: `reports/report_414/` failed because Story003 async SceneManager APIs did
  not exist yet.
- RED: `reports/report_418/` failed because a completed threaded load did not
  call `load_threaded_get()` before logical commit.
- GREEN: `reports/report_419/` passed focused Story003 suite `4/4`.
- Related regression: `reports/report_420/` passed `49/49` across Story003,
  SceneManager Story001, MainScene Story002, SaveSystem Story004, HUD save/load
  shell, HUDManager, and Death & Respawn no-loss handoff.
- Headless smoke: `reports/scene_story003_async_load_main_scene_smoke.log`
  exited `0`; error/warning scan returned no matches.
- Godot MCP: runtime probe verified `/root/SceneManager`, real
  `ResourceLoader` success path pending `main/mcp_async_gate_final` without
  committing before the 1.5 second gate, logical commit after gate, fake-loader
  timeout retry once, `main:timeout` failure signal, fallback to `hub/clan_base`,
  clean game/editor logs, and non-empty `640x360` screenshot.

**Status**: [x] Complete

---

## Dependencies

- Depends on: Scene Management Story 001.
- Depends on: Scene Management Story 002.
- Unlocks: transition presentation, deferred unload/cache eviction, fast travel
  preload, and real scene-tree swap stories.
