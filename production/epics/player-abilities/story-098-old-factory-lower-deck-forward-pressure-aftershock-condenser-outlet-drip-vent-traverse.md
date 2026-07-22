# Story 098: Old Factory Lower Deck Forward Pressure Aftershock Condenser Outlet Drip Vent Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Contact Hazard
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story097 clears the aftershock condenser outlet clamp ambush. Story098 turns the
next right-side pocket into a visible route traversal beat: a newly generated
transparent drain gantry prop defines the space, while the existing
image-generated Old Factory steam vent prop becomes a deterministic active-window
drip vent hazard.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserDrainGantry` exists in
  `factory_route_transition_shell.tscn`, starts hidden, uses the newly generated
  transparent `768x320` PNG, and extends the playable route to x `6400.0`.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOutletDripVentHazard`
  exists as an `Area2D` hazard, starts hidden/non-contacting, reuses the imported
  Old Factory steam vent texture, and exposes hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent`.
- [x] The drip vent stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared=true`;
  locked activation returns `false`, the gantry is hidden, and the hazard has no
  active contact.
- [x] Once Story097 is cleared, diagnostics expose availability, visibility,
  generated gantry texture path, reused vent texture path, route width `6400`,
  right wall x `6380`, camera limit `6400`, activation x `5840`, exit x `6260`,
  hazard damage `8`, cooldown `1.0`, and route label
  `Outlet Clamp Ambush Cleared`.
- [x] Crossing the activation point starts the traverse, advances route feedback
  to `Cross Outlet Drip Vent`, and cycles deterministic `grace -> warning ->
  active -> safe` phases.
- [x] Production auto-activation requires Story098 to be available at frame
  start, held `move_right`, and fresh positive x movement; Story097's killing
  frame and a stationary follow-up cannot consume the traverse.
- [x] Only the active phase enables contact damage; the grace/warning/safe phases
  show the vent but reject contact damage.
- [x] Crossing the exit point persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_activated=true`
  and `..._crossed=true`, disables hazard contact, and advances route feedback
  to `Outlet Drip Vent Crossed`.
- [x] Restoring crossed local state keeps Story094, Story095, Story096, and
  Story097 intact without replaying them; the service lift prompt remains
  `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4, including scene reload, runtime helper,
  generated prop, real-movement activation, real `Area2D` damage, Story099
  handoff isolation, clean current-run logs, and a non-empty screenshot showing
  the generated drain gantry and reused vent.

## Out of Scope

New enemy family, new character animation art, new AI behavior, reward cache,
savepoint, minimap, fast travel, authored audio, particles/shaders, Boss2,
SaveSystem schema changes, and broader lower-deck art replacement.

## Implementation Notes

- Activation is gated by
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared`.
- Route geometry extends the factory shell from x `5760.0` to x `6400.0`.
- The drain gantry sits at x `6040.0`; the drip vent hazard shares the same route
  anchor and uses completion x `6260.0`.
- MCP runtime validation exposed a current-run Godot error when player death
  changed collision state during `area_entered` query flushing. The fix defers
  `CollisionShape2D.disabled` and hurtbox `monitorable` changes during physics
  frames while preserving immediate non-physics test behavior.

## Asset Pipeline

New image-generated runtime prop:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_drain_gantry_imagegen_20260709.png`
- Alpha source:
  `assets/generated/source/old_factory_aftershock_condenser_drain_gantry_alpha_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_drain_gantry_imagegen_20260709.json`
- Runtime:
  `assets/environment/old_factory_aftershock_condenser_drain_gantry/env_old_factory_aftershock_condenser_drain_gantry_768.png`

The hazard reuses the imported image-generated Old Factory steam vent prop at
`assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_traverse_test.gd`
  - Initial RED: `reports/report_1244/` (missing Story098 asset/API)
  - Focused GREEN: `reports/report_1245/` (`2/2`)
  - Commit-prep focused GREEN: `reports/report_1249/report_1/` (`2/2`)
- Related regression:
  - Initial related GREEN: `reports/report_1246/` (`20/20`) covering Story098,
    Story097, Story096, Story095, Story094, Story093, Story092, savepoint
    respawn selection, and no-loss respawn state.
  - Final related GREEN after deferred collision-state fix:
    `reports/report_1248/` (`32/32`) covering the Story098 chain plus collision
    hurtbox state, entity death cleanup, and player respawn visual feedback.
- Runtime evidence:
  Headless factory smoke
  `reports/old_factory_aftershock_condenser_outlet_drip_vent_traverse_smoke.log`
  exited `0`. The log contains no project script/parse/invalid-call/access,
  missing-resource/resource-load, flushing-query, or in/out-signal state-change
  errors; Godot still reports exit-time resource cleanup noise.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed scene reload from disk,
  plugin/server version `2.9.1`, runtime helper live, drain gantry and drip vent
  nodes present, generated gantry texture path mounted on `Sprite2D`, locked and
  ready diagnostics, activation range semantics, `grace/warning/active/safe`
  phases, active-only `8` damage, crossed-state persistence, restored state,
  runtime player death/respawn through the active vent without new game/editor
  errors, final game log containing only helper registration, no editor entries
  after cursor `9`, and a non-empty `960x539` screenshot showing the generated
  drain gantry and reused vent prop.
- Story217 production handoff isolation:
  `reports/report_2319/results.xml` passed `6/6`; MCP 3.0.4 run
  `r155047659-13` kept Story098 available/visible in `idle` through the lethal
  and stationary frames, then started `grace` only after fresh movement x
  `5848.0 -> 5852.0`.
- Story218 production traversal and Story099 handoff:
  `reports/report_2327/report_1/results.xml` passed the canonical real-overlap
  path `1/1`; `reports/report_2329/report_1/results.xml` passed the bounded
  Story217/098/099/218 regression `6/6`. Godot MCP 3.0.4 run
  `r156727664-15` confirmed Story099 remained inactive after the vent crossing
  and activated only on a later fresh `move_right` plus positive-x frame.

## Dependencies

- Depends on: Story097 Old Factory Lower Deck Forward Pressure Aftershock Condenser Outlet Clamp Ambush
- Unlocks: deeper Old Factory route content after the outlet drip vent traverse

## Verification Summary

Story098 followed thin TDD: RED `reports/report_1244/` failed before asset/API
support existed, focused GREEN `reports/report_1245/` passed `2/2`, commit-prep
focused GREEN `reports/report_1249/report_1/` passed `2/2`, initial related
GREEN `reports/report_1246/` passed `20/20`, and final related GREEN
`reports/report_1248/` passed `32/32` after fixing the MCP-exposed physics query
state-change error. Headless smoke exited `0`. Godot MCP runtime validation
passed under Godot 4.7 and Godot AI MCP 2.9.1.

The original Story098 runtime acceptance was recorded with MCP 2.9.1.
Story217 and Story218 add current Godot 4.7 / MCP 3.0.4 production proof for
fresh-movement entry, real `Area2D` damage and the non-consuming Story099
handoff without changing the established hazard FSM or values.
