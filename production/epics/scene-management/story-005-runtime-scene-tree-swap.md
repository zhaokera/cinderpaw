# Story 005: Runtime Scene-Tree Swap Ownership

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/scene-management.md`
**Requirements**: `TR-scene-003`, `TR-scene-004`, `TR-scene-007`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0007: Scene management architecture

**ADR Decision Summary**: SceneManager owns the runtime scene lifecycle. After
the asynchronous load and transition gate finish, it must instantiate the loaded
`PackedScene`, attach it to a configured runtime scene root, save the outgoing
scene's local state, detach the outgoing scene from the tree, restore the target
scene's local state, and then emit the existing logical loaded/changed signals.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

**Control Manifest Rules (Feature layer)**:
- Required: scene state persistence uses `get_local_state()` /
  `set_local_state()` on scene roots.
- Required: scene changes use async loading plus transition timing.
- Required: real scene ownership must stay inside SceneManager; callers use the
  existing SceneManager boundary.
- Guardrail: This story adds the runtime scene-tree ownership seam only.
  Deferred unload timers, two-scene cache eviction, fast travel preload, and
  audio fades remain later stories.

---

## Acceptance Criteria

- [x] `SceneManager` can be configured with a runtime scene root node and reports
  whether runtime scene-tree swapping is enabled.
- [x] When an async load completes after the transition gate, the loaded
  `PackedScene` is instantiated and added to the configured runtime scene root
  before `on_scene_loaded` / `on_scene_changed` are emitted.
- [x] The outgoing runtime scene root child is removed from the tree and retained
  as the previous runtime scene reference for the later deferred-unload/cache
  story, while the new scene becomes the current runtime scene.
- [x] Before removing the outgoing runtime scene, SceneManager captures
  `get_local_state()` into the existing scene-state cache; after adding the new
  scene, it applies cached state through `set_local_state(state)` when present.
- [x] If the loaded resource is missing or not a `PackedScene`, SceneManager
  fails the request through `on_scene_load_failed(scene_id, reason)`, keeps the
  old runtime scene attached, preserves the pre-request logical scene/spawn, and
  does not corrupt saved scene-local state.
- [x] If no runtime scene root is configured, Story003 logical async behavior
  remains source-compatible for existing tests and callers.

---

## Implementation Notes

- Keep `request_scene_change()` as the public async API and complete real
  scene-tree work from the existing `_finish_pending_load()` path.
- Add a small runtime-scene-root configuration API instead of letting gameplay
  callers directly add/remove scene nodes.
- Do not call `get_tree().change_scene_to_file()` or
  `get_tree().change_scene_to_packed()` from gameplay code; SceneManager owns
  instantiation and root attachment.
- Unit tests should use a fake loader returning deterministic in-memory
  `PackedScene` resources and fake scene root nodes with `get_local_state()` /
  `set_local_state()` methods.
- Preserve existing signal order: `on_scene_loaded(scene_id)` before
  `on_scene_changed(old_scene, new_scene)`.

---

## Out of Scope

- The 3-second deferred unload timer and max-two-resident-scenes eviction policy.
- Fast travel menus, portal animations, target-scene preload scheduling, or
  savepoint thumbnails.
- Loading audio fade-out/fade-in.
- Rebuilding `scenes/main.tscn` into separate playable hub/area/boss scene
  files.
- New player/enemy character animation assets; existing visible characters
  remain under the `AnimatedSprite2D + SpriteFrames` audit contract.

---

## QA Test Cases

- **AC-1**: Runtime root configuration.
  - Given: SceneManager is configured with a test runtime root.
  - When: the root is accepted.
  - Then: runtime scene swapping is enabled and diagnostics expose the configured
    root/current runtime node state.

- **AC-2**: Async loaded PackedScene is instantiated into the runtime root.
  - Given: the fake loader returns a `PackedScene` for `main`.
  - When: `request_scene_change("main", "east_gate")` completes after 1.5
    seconds.
  - Then: the runtime root contains the instantiated target scene, current
    scene/spawn become `main/east_gate`, and loaded/changed signals fire in the
    existing order.

- **AC-3**: Outgoing local state is captured and incoming local state restored.
  - Given: the current runtime scene implements `get_local_state()` and a cached
    state already exists for `main`.
  - When: the swap completes.
  - Then: hub local state is stored, the new scene receives the cached `main`
    state through `set_local_state()`, and the old scene is detached but kept as
    previous runtime scene diagnostics.

- **AC-4**: Invalid loaded resources fail without detaching the current scene.
  - Given: the fake loader reports loaded but returns no `PackedScene` while the
    runtime is already on a non-hub scene.
  - When: the transition gate completes.
  - Then: the request fails with a clear reason, the current runtime scene
    remains attached, scene-local state is not overwritten by a failed target,
    and logical scene/spawn remain at the pre-request values.

- **AC-5**: No runtime root preserves Story003 behavior.
  - Given: SceneManager has no runtime root configured.
  - When: async loading completes.
  - Then: the logical scene transition still commits as it did in Story003.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/scene/story_005_runtime_scene_tree_swap_test.gd` RED then GREEN.
- Regression with SceneManagement Story001/003/004 and MainScene transition UI.
- Godot headless main-scene smoke.
- Godot MCP verifies `/root/SceneManager`, async request completion, runtime
  diagnostics, clean logs, and non-empty game screenshot.

**Completed evidence**:
- RED: `reports/report_424/` failed because the runtime scene-root API did not
  exist yet.
- RED: `reports/report_425/` failed because invalid loaded resources still used
  Story003 hub fallback, creating a runtime/logical mismatch for runtime swap
  failures.
- RED: `reports/report_429/` failed after QA review expanded diagnostics to
  include the configured runtime root getter.
- GREEN: `reports/report_430/` passed focused Story005 suite `4/4` with zero
  errors, failures, skips, flakes, or orphans.
- Related regression: `reports/report_431/` passed `60/60` across SceneManager
  Story001/003/005, MainScene transition/title/load/save handoff, SaveSystem
  Story004/005, and HUDManager. The process still printed the existing
  ObjectDB-leak warning after successful completion; test results had zero
  orphans.
- Headless smoke:
  `reports/scene_story005_runtime_swap_main_scene_smoke.log` exited `0`; error
  and warning scan returned no matches.
- Godot MCP: runtime probes configured a temporary runtime root, validated
  transition-gated `PackedScene` instantiation, previous-scene detachment,
  state capture/restore, invalid-resource failure preserving pre-request
  runtime/logical state, clean game/editor logs, and a non-empty screenshot:
  `reports/visual/cinderpaw-mcp-runtime-scene-tree-swap-20260625.png`.

Full evidence:
`production/qa/evidence/runtime-scene-tree-swap-2026-06-25.md`.

**Status**: [x] Complete

---

## Dependencies

- Depends on: Scene Management Story 001.
- Depends on: Scene Management Story 003.
- Depends on: Scene Management Story 004.
- Unlocks: deferred unload/cache eviction, fast travel preload, dedicated
  hub/area/boss scene split, and scene memory-budget verification.
