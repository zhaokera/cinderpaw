# Story 036: Old Factory Service Lift SceneManager Exit

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

Story035 made the Old Factory service lift visible and interactable after the
Spark Rat patrol clear. This story connects that handoff prop to SceneManager so
the final Old Factory route state requests the registered main scene and returns
the player to the Scrap Roost savepoint context instead of ending at a local
visual-only activation.

## Acceptance Criteria

- [x] Before Spark Rat patrol clear, service lift activation returns false and
  does not request SceneManager.
- [x] After the authored Factory route is cleared and the provider is in range,
  service lift activation calls `SceneManager.request_scene_change(&"main",
  &"scrap_roost")`.
- [x] A SceneManager loading, locked, missing, or unknown-scene rejection keeps
  `factory_service_lift_activated == false`, does not play the one-shot unlock
  VFX, and records a deterministic rejection reason.
- [x] Successful activation records
  `factory_service_lift_exit_requested == true`,
  `factory_service_lift_exit_scene_id == "main"`, and
  `factory_service_lift_exit_spawn_point == "scrap_roost"` in scene-local state.
- [x] `get_factory_service_lift_diagnostics()` exposes exit target, spawn,
  request status, rejection reason, SceneManager loading state, pending scene,
  and pending spawn for tests and MCP probes.
- [x] Repeated activation stays idempotent and does not send duplicate
  SceneManager requests or replay feedback.
- [x] Existing Old Factory objective, deep-route, Spark Rat, route shell, Boss2
  route handoff, and SceneManager Story003/005 tests remain green.
- [x] Godot MCP runtime probe launches the Factory scene, clears the route,
  triggers the service lift, observes `pending_scene == "main"` and
  `pending_spawn == "scrap_roost"`, and sees no new game log errors.

## Out of Scope

- New art, new rooms, savepoint authoring, fast travel UI, moving lift
  animation, global quest schema, SaveSystem schema changes, and a new
  SceneManager registry entry. Directly launching the Factory scene through MCP
  validates the request contract; end-to-end runtime-root scene-tree swap remains
  under the main scene/runtime SceneManager pipeline.

## Implementation Notes

- The service lift target is the existing registered `main` scene. The spawn id
  is `scrap_roost`, matching the visible `ScrapRoostSavepoint` context in
  `scenes/main.tscn`.
- `OldFactoryEntranceScene.configure_scene_manager_runtime()` supports focused
  tests and MCP/runtime adapter injection while production resolves
  `/root/SceneManager`.
- No new visual assets were generated in this story. It reuses the Story035
  image-generated service lift console and existing Old Factory environment art.

## Test Evidence

- Story036 RED focused: `reports/report_893/` failed as expected before request
  semantics were wired.
- Story036 GREEN focused: `reports/report_894/` passed `2/2`.
- Story035 + Story036 focused regression: `reports/report_895/` passed `4/4`.
- Related regression: `reports/report_896/` passed `28/28` across Old Factory
  route objective, deep-route unlock feedback, Spark Rat pacing, route shell,
  Boss2 route handoff, and SceneManager Story003/005.
- Headless Factory scene smoke:
  `reports/old_factory_service_lift_scene_manager_exit_factory_scene_smoke.log`
  exited `0` with no script, parse, invalid-call, missing-resource, or
  resource-load errors found by keyword scan.
- Godot MCP runtime evidence:
  `production/qa/evidence/old-factory-service-lift-scene-manager-exit-2026-06-30.md`.

**Status**: [x] Complete.
