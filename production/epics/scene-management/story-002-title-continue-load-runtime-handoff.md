# Story 002: Title/Continue/Load Runtime Handoff

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

**ADR Governing Implementation**: ADR-0007: Scene management architecture,
ADR-0021: Save system architecture

**ADR Decision Summary**: SceneManager is the Feature-layer boundary for
runtime scene IDs and spawn points. SaveSystem restores persisted runtime state.
This story closes the title/menu save-load handoff so player-facing New Game,
Continue, and Load Slot paths route through SceneManager before gameplay state
is applied.

**Engine**: Godot 4.6.3 | **Risk**: MEDIUM

**Control Manifest Rules (Feature layer)**:
- Required: Gameplay callers use SceneManager as the scene-transition boundary.
- Required: Save loads restore scene and spawn deterministically from saved
  state.
- Required: Invalid, locked, or unknown scene targets fail without partially
  restoring MainScene state.
- Guardrail: This story keeps SceneManager's Story001 logical transition
  baseline; real scene-tree swap, async loading, transition screens, and cache
  eviction remain later stories.

---

## Acceptance Criteria

- [x] New Game from the main menu requests the default playable scene
  `main/default` through SceneManager before hiding the title shell.
- [x] Continue loads the first available slot in slot order, with autosave slot
  0 first, and then routes the loaded scene/spawn through SceneManager.
- [x] Load Slot restores the selected slot, not the Continue default slot, and
  uses saved `last_savepoint.scene_id/spawn_point` when present.
- [x] If a save has no valid savepoint target, load falls back to saved
  `world_state.scene_id`, then saved `player_state.scene_id`, then
  `main/default`.
- [x] If SceneManager rejects the target because the scene is unknown, locked,
  or unavailable, MainScene returns `false`, keeps the menu visible, reports a
  load failure, and does not restore player/world/settings state.
- [x] Existing SaveSystem Story004 runtime save/load behavior remains covered
  while adding SceneManager handoff assertions.

---

## Implementation Notes

- Add a MainScene helper that resolves `{scene_id, spawn_point}` from a loaded
  snapshot without mutating gameplay state.
- Temporarily keep MainScene and SceneManager out of SaveSystem's
  registered-system deserialization while `load_runtime_from_slot()` performs
  pre-restore scene validation; then re-register them and apply the snapshot only
  after the SceneManager handoff succeeds.
- Continue intentionally uses deterministic slot order for this vertical slice:
  autosave slot `0`, then manual slots `1-3`. "Most recent save" sorting remains
  out of scope until save metadata ordering is promoted into a later UX story.
- Failure feedback stays in the existing HUD shell through `show_notification()`
  and refreshed main/save-load menus.

---

## Out of Scope

- Full `TitleScene` creation or project boot scene replacement.
- Async `ResourceLoader` request lifecycle, timeout retry, or transition
  animation.
- Real scene-tree unload/add/remove.
- Fast travel UI, boss arena scene split, or dedicated hub scene split.
- New save slot sorting by timestamp.
- New character art or animation resources.

---

## QA Test Cases

- **AC-1**: New Game handoff.
  - Given: MainScene with a fake SceneManager.
  - When: HUD emits `menu_new_game_requested`.
  - Then: SceneManager receives `change_scene("main", "default")`, the menu is
    hidden, and pause is released.

- **AC-2**: Continue chooses the first available slot and hands off scene/spawn.
  - Given: only slot 0 exists with `last_savepoint.scene_id="main"` and
    `spawn_point="scrap_roost"`.
  - When: HUD emits `menu_continue_requested`.
  - Then: SaveSystem loads slot 0, SceneManager receives
    `main/scrap_roost`, and gameplay state is restored.

- **AC-3**: Load Slot targets the selected slot.
  - Given: slots 0 and 1 have different spawn points.
  - When: HUD emits `menu_load_slot_requested(1)`.
  - Then: SaveSystem loads slot 1, not slot 0, and SceneManager receives slot
    1's scene/spawn.

- **AC-4**: SceneManager rejection is atomic from MainScene's perspective.
  - Given: slot 1 targets an unknown scene.
  - When: `load_runtime_from_slot(1)` is called through the menu.
  - Then: the method returns false, MainScene player/world/settings state
    remains unchanged, and the menu remains visible with load-failure feedback.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/gameplay/main_scene_title_load_handoff_test.gd` RED then GREEN.
- Regression with SaveSystem Story004, MainScene save/load menu shell, and
  SceneManager Story001 tests.
- Godot headless main-scene smoke.
- Godot MCP verifies `/root/SaveSystem`, `/root/SceneManager`, HUD title shell,
  Continue/Load Slot handoff, failure-path menu visibility, clean logs, and
  non-empty screenshot.

**Completed evidence**:
- RED: `reports/report_408/` failed because New Game did not call
  SceneManager.
- GREEN: `reports/report_412/` passed Story002 focused suite `7/7`,
  covering New Game, Continue, selected Load Slot, fallback order, locked/
  rejected/unknown scene failure, and registered-system deserialize skipping.
- Related regression: `reports/report_413/` passed `47/47` across Story002,
  SaveSystem Story004, HUD save/load shell, HUDManager, SceneManager Story001,
  and Death & Respawn savepoint handoff.
- Headless smoke: `reports/scene_story002_title_load_handoff_main_scene_smoke.log`
  exited `0`; error/warning scan returned no matches.
- Godot MCP: runtime probe verified `/root/SaveSystem`, `/root/SceneManager`,
  New Game `main/default`, Continue autosave `mcp_continue_roost`, selected Load
  Slot `mcp_load_roost`, failure slot menu visibility + `Load failed` feedback,
  no half-restore, final positive HP/currency/spawn state, clean game/editor
  logs, and non-empty `640x360` game screenshot.

**Status**: [x] Complete

---

## Dependencies

- Depends on: Scene Management Story 001.
- Depends on: Save System Story 004 and Story 005.
- Depends on: HUD/UI Story 005.
- Unlocks: async scene loading story, transition presentation, real hub/area
  scene split, fast travel handoff.
