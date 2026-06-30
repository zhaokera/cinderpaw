# Story 034: Factory Route Arrival Objective Handoff

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

Story033 completes the Boss2 victory chain into `area_03_factory /
factory_gate_entry`. The Old Factory scene already contains the entrance guard,
cache, steam vent, deep guard, deep-route endpoint, and Factory Spark Rat, but
arrival did not expose a single readable objective chain. This story makes the
first Factory Route arrival feel authored by showing and persisting a scene-local
objective handoff from entrance clear to deep-route combat completion.

## Acceptance Criteria

- [x] Loading `res://scenes/factory_route_transition_shell.tscn` immediately
  shows a visible `RouteLabel` objective `Clear Factory Entrance` and exposes
  deterministic route objective diagnostics.
- [x] Defeating `FactoryRatMinion` advances the current objective to
  `Reach Deep Guard` without adding a new quest system or autoload.
- [x] Defeating `FactoryDeepGuardRatMinion` advances the objective to
  `Open Deep Route Endpoint`; activating `FactoryDeepRouteEndpoint` advances it
  to `Defeat Spark Rat Patrol`.
- [x] Defeating `FactorySparkRat` marks the scene-local objective
  `factory_route_cleared`, shows `Factory Route Cleared`, and reports
  `is_factory_route_objective_complete() == true`.
- [x] `get_local_state()` / `set_local_state()` preserve the objective chain via
  existing scene-local state derivation; no SaveSystem schema or global quest
  system is added.
- [x] Existing Old Factory and Story033 route handoff behavior remains valid:
  entrance combat, deep route endpoint, unlock feedback, Spark Rat pacing, and
  Boss2 victory route request continue to pass focused related regression.
- [x] Godot MCP runtime evidence confirms the target scene, RouteLabel,
  objective diagnostics, Spark Rat `AnimatedSprite2D + SpriteFrames`, clean
  logs, and nonblank screenshot.

## Out of Scope

- New Old Factory rooms, minimap/savepoint gameplay, fast travel, new enemies,
  new player abilities, new visual or audio assets, a global quest/objective
  manager, SceneManager architecture changes, SaveSystem schema changes, and
  Spark Rat AI/stat tuning.

## Implementation Notes

- Keep the objective scene-local inside `OldFactoryEntranceScene`.
- Derive the objective from existing authoritative flags:
  entrance clear, deep guard defeated, endpoint activated, and Spark Rat
  defeated.
- Reuse existing generated Old Factory backdrop, endpoint, VFX, and
  Factory Spark Rat frame-animation assets. No new image generation is required
  for this slice.
- Surface diagnostics through `get_factory_route_objective_diagnostics()` and
  include them in `get_factory_entrance_diagnostics()` for MCP probes.

## Test Evidence

- Story034 RED focused: `reports/report_883/` failed as expected on missing
  route objective APIs.
- Story034 GREEN focused: `reports/report_884/` passed `2/2`.
- Related regression: `reports/report_885/` passed `21/21` across Story034,
  Old Factory entrance combat, deep route, unlock feedback, Spark Rat pacing,
  and Boss2 victory route handoff.
- Headless Factory scene smoke:
  `reports/old_factory_route_objective_handoff_factory_scene_smoke.log` exited
  `0`; keyword scan found no script, parse, invalid-call, missing-resource, or
  resource-load errors, with only Godot cleanup-time `resources still in use at
  exit`.
- Godot MCP 2.8.1 runtime evidence and screenshot:
  `production/qa/evidence/factory-route-arrival-objective-handoff-2026-06-30.md`.

**Status**: [x] Complete.
