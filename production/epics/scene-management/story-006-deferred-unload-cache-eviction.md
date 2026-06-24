# Story 006: Deferred Unload + Runtime Cache Eviction

> **Epic**: Scene Management
> **Type**: Integration
> **Status**: Complete
> **Traceability**: TR-scene-003, TR-scene-004, TR-scene-007
> **ADR**: ADR-0007

## Context

Story005 made SceneManager capable of instantiating async-loaded `PackedScene`
resources into a configured runtime scene root and detaching the outgoing scene.
ADR-0007 and the Scene Management GDD require that detached scene to remain
available for a short quick-return window, then unload after 3 seconds, while
never keeping more than two runtime scenes resident.

This story upgrades the Story005 previous-scene reference into a deferred runtime
cache with a countdown, quick-return reuse, and deterministic eviction.

## Acceptance Criteria

- [x] A successful runtime scene-tree swap detaches the outgoing runtime scene,
  stores it as the deferred cache, records its `scene_id`, and starts a 3.0
  second unload countdown.
- [x] While the countdown is below 3.0 seconds, the cached scene remains valid,
  is not parented under the runtime root, and is reported by SceneManager
  diagnostics.
- [x] When the countdown reaches 3.0 seconds, SceneManager queues the cached
  scene for free and clears cache diagnostics.
- [x] Runtime residency never exceeds two scene nodes: the current runtime scene
  plus at most one deferred cached scene.
- [x] If another successful runtime swap occurs while a deferred cache exists,
  the older cached scene is evicted immediately before caching the outgoing
  current scene.
- [x] If a request returns to the cached `scene_id` before its countdown expires,
  SceneManager reuses that cached node after the transition gate without issuing
  another threaded load request or instantiating a new `PackedScene`.
- [x] Scene-local state capture and restore from Story005 still run before
  detach/cache and after attach/reuse.
- [x] Invalid `PackedScene`, instantiate failure, timeout, and no-runtime-root
  paths preserve Story003/Story005 behavior.

## Out of Scope

- Fast travel preload and portal animation.
- Loading audio fade in/out.
- Real hub/area/boss scene splits.
- Platform memory profiler evidence.
- Low-memory emergency unload UI.
- Scene request queue coalescing during active loading.
- New character art, frame animation, or image-generated visual assets.

## Validation

- RED-first GdUnit coverage in
  `tests/unit/scene/story_006_deferred_unload_cache_eviction_test.gd`.
- Focused regression: SceneManagement Story003, Story005, and Story006 tests.
- Godot headless scene/script validation.
- Godot MCP runtime validation: project starts, logs are clean, SceneManager
  exists, cache diagnostics work through runtime probes, and screenshots are
  nonblank.

## Completion Evidence

- RED: `reports/report_432/results.xml` failed on missing deferred cache
  diagnostics/API, proving the new Story006 test was red first.
- GREEN focused: `reports/report_434/results.xml` passed Story006 `4/4` with
  `0` errors, `0` failures, `0` orphans.
- SceneManagement regression: `reports/report_437/results.xml` passed Story003,
  Story005, and Story006 `12/12` with `0` errors, `0` failures, `0` orphans.
- Related regression: `reports/report_438/results.xml` passed SceneManager,
  MainScene transition/title/load/save handoff, SaveSystem runtime handoff, and
  HUD tests `59/59` with `0` errors, `0` failures, `0` orphans.
- Headless smoke: `/opt/homebrew/bin/godot --headless --path . --quit-after 2`
  exited `0`.
- Godot MCP: project ran `res://scenes/main.tscn`, runtime probe confirmed
  `hub -> main` caches `hub` with resident count `2`, `main -> hub` reuses the
  same cached `hub` node, deferred unload clears previous cache, game logs are
  clean, editor logs are clean, and screenshot is nonblank with Player/Enemy
  `AnimatedSprite2D` nodes visible in the runtime scene tree.
