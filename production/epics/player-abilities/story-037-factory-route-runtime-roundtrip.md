# Story 037: Factory Route Runtime Roundtrip

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Scene Management
> **Type**: Integration + Gameplay Runtime + Scene Management
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-scene-001`, `TR-scene-003`,
`TR-scene-005`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system.

Stories033-036 connect Boss2 victory, Factory route entry, Old Factory route
clear, and service lift exit requests. This story validates and hardens the
player-visible end-to-end runtime-root loop:
`main -> area_03_factory -> main/scrap_roost`.

## Acceptance Criteria

- [x] From the real `scenes/main.tscn` runtime root, unlocking the Factory route
  and activating `FactoryRouteTransitionShell` requests
  `area_03_factory / factory_gate_entry`.
- [x] SceneManager async loading swaps the runtime root from `Main` to
  `FactoryRouteTransitionShellScene` and records current scene/spawn as
  `area_03_factory / factory_gate_entry`.
- [x] The authored Factory route can be cleared through existing public runtime
  APIs without replaying the full manual combat chain.
- [x] Activating `FactoryServiceLift` after route clear requests
  `main / scrap_roost`.
- [x] SceneManager returns the runtime root to `Main`, records current
  scene/spawn as `main / scrap_roost`, clears loading state, and preserves the
  Factory service lift exit request in `area_03_factory` scene state.
- [x] Returned `Main` exposes `Player`, `HUD`, `FactoryRouteTransitionShell`,
  and `ScrapRoostSavepoint`; the player lands near the Scrap Roost savepoint
  instead of remaining at the Factory route trigger.
- [x] `MainScene` implements the SceneManager local-state protocol
  (`get_local_state` / `set_local_state`) through its existing no-loss state
  snapshot.
- [x] Runtime scene swaps inject SceneManager into swapped scenes that expose
  `configure_scene_manager_runtime`, so cached scenes reconnected after
  `remove_child` can receive SceneManager signals.
- [x] Focused and related GdUnit regressions, headless main-scene smoke, and
  Godot MCP runtime evidence pass with no new project script errors.

## Out of Scope

- New rooms, new enemies, new visual assets, moving lift animation, global quest
  schema, SaveSystem schema changes, minimap updates, fast travel UI, and new
  combat encounters.

## Implementation Notes

- `MainScene.get_local_state()` and `MainScene.set_local_state()` are aliases
  over the existing `capture_no_loss_state()` / `restore_no_loss_state()`
  pathway.
- `MainScene` applies SceneManager spawn points for the main scene. The current
  authored spawn target is `scrap_roost`, mapped to `ScrapRoostSavepoint`.
- `SceneManager._swap_runtime_scene()` now calls
  `configure_scene_manager_runtime(self)` on swapped scenes that expose it.
  This fixes reused cached scenes that left the tree and disconnected their
  signals in `_exit_tree()`.
- No new visual assets were generated. The story reuses existing Cinderpaw,
  Boss2, Factory route, Old Factory, Spark Rat, and service lift assets.

## Test Evidence

- Story037 RED focused: `reports/report_902/` failed because returning to
  `main/scrap_roost` left the player at the Factory route trigger
  `(970, 352)` instead of near Scrap Roost.
- Story037 GREEN focused: `reports/report_906/` passed `1/1` with `0` orphans;
  pre-commit rerun `reports/report_907/` passed `1/1` with `0` orphans.
- Related regression: `reports/report_905/` passed `17/17` with `0` orphans
  across Story037, Factory route shell, service lift handoff/exit, Boss2 route
  handoff, and SceneManager Story003/005.
- Headless main scene smoke:
  `reports/factory_route_runtime_roundtrip_main_scene_smoke.log` exited `0`;
  keyword scan found no script, parse, invalid-call, invalid-access,
  missing-resource, resource-load, or `ERROR:` entries.
- Godot MCP runtime evidence:
  `production/qa/evidence/factory-route-runtime-roundtrip-2026-06-30.md`.

**Status**: [x] Complete.
