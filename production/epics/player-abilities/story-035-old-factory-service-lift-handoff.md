# Story 035: Old Factory Service Lift Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Scene Management / Presentation
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-scene-001`, `TR-scene-003`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Story034 closes the authored Factory Route objective chain when the player
defeats the Factory Spark Rat. This story adds a visible service lift call
console after that clear state so the Old Factory route has a concrete exit
handoff prop instead of ending only as text. This is a visual and scene-local
progression handoff only; it does not request a scene change.

## Acceptance Criteria

- [x] `res://scenes/factory_route_transition_shell.tscn` contains a visible
  `FactoryServiceLift` interactable prop using image-generated transparent PNG
  art, not a placeholder square, `ColorRect`, `Polygon2D`, or single-color
  shape.
- [x] `FactoryServiceLift` is locked before Spark Rat patrol clear and reports
  prompt text `Clear patrol`.
- [x] After Story034 completion state (`FactorySparkRat` defeated /
  `factory_route_cleared`), `FactoryServiceLift` becomes available and reports
  prompt text `Call lift`.
- [x] Calling the service lift once sets scene-local
  `factory_service_lift_activated == true`, updates the prop prompt to
  `Lift online`, shows `Service Lift Online`, and plays the existing one-shot
  unlock VFX once.
- [x] Repeated activation is idempotent: it returns false, does not replay the
  one-shot feedback, and does not grant rewards or request scene changes.
- [x] `get_local_state()` / `set_local_state()` preserve
  `factory_service_lift_activated` without adding SaveSystem schema fields,
  global quests, fast travel, or SceneManager registry entries.
- [x] `get_factory_service_lift_diagnostics()` exposes deterministic state and
  is included in `get_factory_entrance_diagnostics()` for tests and MCP probes.
- [x] Story034 route objective semantics remain unchanged:
  Spark Rat defeat still reports `factory_route_cleared`.

## Out of Scope

- New rooms, real service lift movement, scene transitions, cutscenes, minimap,
  savepoint/fast travel, new enemies, Spark Rat stat/AI tuning, global objective
  manager, SceneManager registry changes, and SaveSystem schema changes.

## Implementation Notes

- Reuse `FactoryDeepRouteEndpoint` as a generic scene-local endpoint component
  by mounting it as `FactoryServiceLift` with a distinct endpoint id and prompt
  copy.
- Keep the activation gate derived from the existing authoritative Spark Rat
  defeated / route complete state.
- Use `assets/environment/old_factory_service_lift/factory_service_lift_console.png`
  as the generated prop art and record the source prompt/processing metadata in
  `assets/generated/source/old_factory_service_lift_console_imagegen_20260630.json`.

## Test Evidence

- Story035 RED focused: `reports/report_886/` failed as expected on missing
  service lift asset, scene node, and scene APIs.
- Story035 GREEN focused: `reports/report_889/` passed `2/2`.
- Related regression: `reports/report_890/` passed Old Factory route objective,
  deep-route unlock feedback, Spark Rat pacing, and Story035 focused coverage.
- Headless Factory scene smoke:
  `reports/old_factory_service_lift_handoff_factory_scene_smoke.log` exited `0`
  with no script, parse, invalid-call, missing-resource, or resource-load
  errors; the only `ERROR:` scan hit is Godot cleanup-time
  `2 resources still in use at exit`.
- Godot MCP runtime evidence:
  `production/qa/evidence/old-factory-service-lift-handoff-2026-06-30.md`.

**Status**: [x] Complete.
