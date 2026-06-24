# Story 001: SceneManager Registry + Public API Baseline

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/scene-management.md`
**Requirements**: `TR-scene-001`, `TR-scene-004`, `TR-scene-005`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0007:
Scene management architecture
**ADR Decision Summary**: SceneManager is the Feature-layer Autoload that owns
scene IDs, registry lookup, transition requests, scene-state cache, boss scene
locks, and SceneManager signals. This story implements a logical baseline; real
threaded scene-tree replacement and transition presentation remain future work.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Autoload APIs are stable. `ResourceLoader` async behavior is
reserved for later stories so this story can stay deterministic and unit-testable.

**Control Manifest Rules (Feature layer)**:
- Required: Scene registry maps `scene_id` to `{path, type, preload}`.
- Required: SceneManager exposes `lock_scene()` / `unlock_scene()` for boss
  battle scene locks.
- Required: Scene state uses JSON-safe dictionaries and SaveSystem-compatible
  `serialize()` / `deserialize(data, version)` callbacks.
- Forbidden: Do not use synchronous scene switching from gameplay callers.
- Guardrail: Story001 may track logical load state only; it must not claim
  async ResourceLoader, deferred unload, timeout/retry, or memory-budget work is
  complete.

---

## Acceptance Criteria

- [x] `project.godot` registers `SceneManager` after `SaveSystem` and before the
  MCP helper. `AudioSystem` remains an existing ADR drift, not a Story001 scope
  item.
- [x] `data/scene_registry.json` is registered in `data/manifest.json`, passes
  schema validation, and contains temporary `hub` and `main` entries pointing to
  existing `res://scenes/main.tscn`.
- [x] `SceneManager` exposes ADR-0007 public API plus testable getters:
  `configure_scene_registry()`, `preload_scene()`, `is_scene_loaded()`,
  `change_scene()`, `get_current_scene()`, `get_current_spawn_point()`,
  `get_scene_state()`, `set_scene_state()`, `lock_scene()`, `unlock_scene()`,
  `is_scene_locked()`, `serialize()`, and `deserialize(data, version)`.
- [x] `preload_scene(scene_id)` validates the registry and marks logical load
  state without swapping the live scene tree.
- [x] `change_scene(scene_id, spawn_point)` returns `true` only for valid,
  unlocked requests, emits `on_scene_loaded` before `on_scene_changed`, updates
  current scene/spawn state, and does not perform real tree replacement.
- [x] Invalid scene IDs or locked scene state reject `change_scene()` with
  `false`, no signal emissions, and no current state mutation.
- [x] `set_scene_state()` / `get_scene_state()` deep-copy JSON-safe dictionaries.
- [x] `serialize()` / `deserialize(data, version)` round-trip current
  scene/spawn and scene states, and are callable by the existing SaveSystem
  registered-system path.

---

## Implementation Notes

- Implement `res://src/feature/scene_manager.gd` as a `Node` usable both as an
  Autoload and as a direct GdUnit instance.
- The initial registry is a deterministic data-domain baseline. Because no
  dedicated hub scene exists yet, `hub` is a temporary alias to
  `res://scenes/main.tscn`; `main` remains its own scene ID for existing runtime
  saves.
- `change_scene()` has logical transition semantics in this story: it validates
  and records the scene/spawn target. It must not call
  `get_tree().change_scene_to_*()` or reload the current scene.
- Signal order is part of the contract: `on_scene_loaded(scene_id)` first,
  `on_scene_changed(old_scene, new_scene)` second.
- SaveSystem currently calls `deserialize(data, version)`, so SceneManager must
  accept the version argument even if it does not use it yet.

---

## Out of Scope

- Real `ResourceLoader.load_threaded_request()` scene-tree replacement.
- Transition animation, loading UI, audio fades, or visual polish.
- Deferred unload/cache eviction and the max-two-resident-scenes budget.
- Load timeout, retry, and hub fallback failure handling.
- Fast travel UI/portal animation.
- Death & Respawn savepoint priority selection.
- Real hub, area, boss arena, or savepoint scene creation.

---

## QA Test Cases

- **AC-1**: `project.godot` registers SceneManager after SaveSystem.
  - Given: the project settings file is loaded as text.
  - When: the `[autoload]` section is inspected.
  - Then: `SceneManager="*res://src/feature/scene_manager.gd"` appears after
    `SaveSystem` and before `_mcp_game_helper`.
  - Edge cases: missing script path fails the same test.

- **AC-2**: Registry data loads through DataManager.
  - Given: a fresh DataManager instance.
  - When: it loads the project manifest.
  - Then: domain `scene_registry` exists with `hub` and `main`, and both point
    to existing scene paths.
  - Edge cases: schema mismatch must fail DataManager validation tests.

- **AC-3**: Logical preload and scene change update state predictably.
  - Given: a SceneManager instance configured with the registry.
  - When: `preload_scene("main")` and `change_scene("main", "clan_base")`
    are called.
  - Then: `is_scene_loaded("main")` is true, current scene is `main`, current
    spawn is `clan_base`, and signals fire once in loaded→changed order.

- **AC-4**: Locks and invalid IDs reject changes without side effects.
  - Given: current scene is `hub`.
  - When: `lock_scene()` then `change_scene("main", "default")` is called.
  - Then: the call returns false, current state remains `hub`, and no signals
    fire.
  - Edge cases: unknown scene IDs behave the same way.

- **AC-5**: Scene state and SaveSystem serialization are JSON-safe.
  - Given: nested scene state is stored for `main`.
  - When: callers mutate their original dictionary and later mutate the returned
    dictionary.
  - Then: SceneManager's stored state does not change until `set_scene_state()`
    is called again.
  - Edge cases: SaveSystem can register SceneManager under key `scene` and call
    `deserialize(data, version)` during `load_game()`.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/scene/story_001_scene_manager_registry_api_test.gd` must exist
  and pass.
- Godot headless main-scene smoke must run after Autoload registration.
- Godot MCP must verify `/root/SceneManager`, scene registry availability,
  runtime logs without new errors, and a non-empty game screenshot.

**Evidence**:
- `production/qa/evidence/scene-manager-registry-api-baseline-2026-06-25.md`
- RED: `reports/report_396/`
- GREEN: `reports/report_397/`
- Regression: `reports/report_398/`
- Headless smoke: `reports/scene_manager_story001_main_scene_smoke.log`
- Godot MCP runtime probe verified `/root/SceneManager`, logical
  `change_scene()`, clean logs, and a non-empty game screenshot.

**Status**: [x] Complete

---

## Dependencies

- Depends on: DataManager manifest/domain cache, SaveSystem serializable
  registration, ADR-0001, ADR-0007.
- Unlocks: Death & Respawn Story 004 savepoint respawn selection; future
  SceneManagement async scene swap story.
