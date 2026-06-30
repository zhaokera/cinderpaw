# Story 040: Old Factory Return Patrol Ambush

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Scene Management / Combat
> **Type**: Integration + Gameplay Runtime + Visual/Feel
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

Stories037-039 make the loop
`main -> area_03_factory -> main/scrap_roost -> Return to Factory Route`
understandable and persistent. Re-entering the Old Factory after that loop
should not feel like an empty cleared room. This story adds a one-time return
patrol ambush inside the existing Old Factory route: a reused Spark Rat blocks
the service lift until defeated, then the lift can be called again.

## Acceptance Criteria

- [x] A first-time Old Factory clear does not spawn the return patrol and keeps
  existing Story034-036 route-clear and service-lift semantics intact.
- [x] Restoring `area_03_factory` with the full service-lift return contract
  back to `main / scrap_roost` spawns and activates a visible
  `FactoryReturnSparkRat`.
- [x] `FactoryReturnSparkRat` uses `AnimatedSprite2D + SpriteFrames` through
  the existing Factory Spark Rat asset, with `idle`, `run`, `attack_tell`,
  `attack`, `hurt`, and `death` animations at least 3 frames each.
- [x] While the return patrol is active, the route objective shows
  `Clear Return Patrol`, `FactoryServiceLift` remains locked with prompt
  `Clear patrol`, and activation records rejection reason
  `return_patrol_active` without requesting SceneManager.
- [x] Defeating the return patrol sets
  `factory_return_patrol_defeated=true`, shows `Return Patrol Cleared`, and
  re-enables `FactoryServiceLift` prompt `Call lift`.
- [x] `get_local_state()` / `set_local_state()` persist return patrol
  activation and defeat without adding SaveSystem schema fields or global quest
  state.
- [x] After the return patrol is defeated, service lift activation again
  requests `main / scrap_roost`, and restoring that state does not respawn the
  patrol.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass with no new project script or resource errors.

## Out of Scope

- New rooms, minimap/savepoint gameplay, fast travel UI, new enemy family,
  Spark Rat stat tuning, new player abilities, new SceneManager registry
  entries, SaveSystem schema changes, global quest/objective manager, new audio,
  service-lift movement animation, or new visual assets.

## Implementation Notes

- Reuse the existing `res://src/gameplay/factory_spark_rat.tscn` and
  `res://scenes/characters/factory_spark_rat.tscn` assets. No image generation
  is needed because this story adds a second encounter instance, not a new
  character or prop.
- Treat the existing service-lift return contract in Factory scene-local state
  as the return-visit trigger:
  `factory_service_lift_exit_requested == true`,
  `factory_service_lift_exit_scene_id == "main"`, and
  `factory_service_lift_exit_spawn_point == "scrap_roost"`.
- Keep all behavior inside `OldFactoryEntranceScene`; do not add a global quest
  system or SaveSystem fields.
- Surface deterministic diagnostics through
  `get_factory_return_patrol_diagnostics()` and include them in
  `get_factory_entrance_diagnostics()` for tests and MCP probes.

## Test Evidence

- Focused RED:
  - `reports/report_928/` failed `1/3` on the new assertion that
    `get_factory_route_objective_diagnostics().complete` must become `true`
    after the return patrol is defeated.
- Focused GREEN:
  - `reports/report_929/` passed Story040 `3/3` with `0` errors, failures, or
    orphans on Godot `4.7.stable.official.5b4e0cb0f`.
- Related regression:
  - `reports/report_930/` passed `14/14` across Story040 plus Story034 route
    objective, Story035 service lift, Story036 service lift exit, Story037
    roundtrip, Story038 return prompt, and Story039 Scrap Roost hub.
- Headless Factory scene smoke:
  - `reports/old_factory_return_patrol_ambush_factory_scene_smoke.log` exited
    `0`; keyword scan found no script, parse, invalid-call, invalid-access,
    missing-resource, or resource-load errors.
- Godot MCP runtime evidence:
  - `production/qa/evidence/old-factory-return-patrol-ambush-2026-06-30.md`.

**Status**: [x] Complete.
