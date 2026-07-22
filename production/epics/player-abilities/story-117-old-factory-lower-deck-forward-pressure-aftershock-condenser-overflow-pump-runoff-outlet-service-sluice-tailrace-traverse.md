# Story 117: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Traversal Hazard
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

Story116 opens the service sluice exit hatch. Story117 makes that handoff
playable by placing a short tailrace traversal pocket beyond the hatch. The
player moves right through a reused authored service-sluice duct and a timed
steam vent window, then persists the crossed state so the Story113-116 chain
does not replay after restore.

## Acceptance Criteria

- [x] The tailrace stays hidden, unavailable, and non-contacting until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened=true`.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceDuct`
  and `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceVent`
  exist in `factory_route_transition_shell.tscn` beyond the service sluice exit
  hatch and reuse imported image-generated service-sluice/steam-vent assets.
- [x] The tailrace activates only after the player reaches activation x
  `12020.0`, shows route feedback `Cross Service Sluice Tailrace`, and uses a
  unique hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace`.
- [x] The steam vent uses the established `grace -> warning -> active -> safe`
  cadence and enables monitoring/collision/contact damage only during `active`.
- [x] Reaching exit x `12480.0` completes the traverse once, disables contact,
  persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed=true`,
  and advances feedback to `Service Sluice Tailrace Crossed`.
- [x] Scene bounds extend past the pocket: right wall x `12700`, camera and
  background right `12720`, ground support through x `12800`, and at least 53
  route floor tiles.
- [x] Restoring crossed state backfills the Story106-116 runoff/service-sluice
  chain, including the exit hatch opened state, without replaying prior
  traversal, skirmish, cache, or hatch interactions.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4.

## Out of Scope

New enemies, new enemy families, AI behavior changes, new reward caches, gear
economy changes, savepoints, SaveSystem schema changes, service-lift routing,
minimap, fast travel, authored audio, particles, shaders, new image generation,
Boss2, and broader lower-deck biome art replacement.

## Implementation Notes

- Story117 follows the established traversal hazard pattern from Story113,
  using dedicated state flags and deterministic diagnostics for tests and MCP.
- The new tailrace objective intentionally appears only after activation; before
  activation the route label can remain `Service Sluice Exit Opened`.
- The runtime hazard is registered in the factory steam hazard list and the
  steam hazard id whitelist so contact damage works in actual play, not only in
  diagnostics.

## Asset Pipeline

No new visual or audio assets were generated. Story117 reuses existing
image-generated/imported assets:

- Service sluice/tailrace duct:
  `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`
- Steam vent hazard:
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Route floor:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

## Test Evidence

- Focused RED: `reports/report_1344/` failed before Story117 diagnostics and
  tailrace activation/completion APIs existed.
- Focused GREEN: `reports/report_1345/` passed `2/2`.
- Related GREEN: `reports/report_1346/` passed `12/12` across Story117,
  Story116, Story115, Story114, Story113, and Story112.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_smoke.log`
  exited `0` and printed `service_sluice_tailrace_smoke=passed`.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed the disk-reloaded
  tailrace duct/vent nodes, hazard id, active-only contact, route bounds,
  locked/ready/active/crossed runtime diagnostics, persisted local crossed
  state, clean current game log, empty editor log after cursor `9`, and a
  non-empty `960x539` game screenshot response.
- Story227 production handoff: Godot AI MCP `3.0.4` real input opened Story116
  and exposed this tailrace as visible/available but inactive. Stationary frames
  and no-input x `12024` remained inactive; final six-suite related GdUnit
  passed `9/9`, and run `r182022878-24` had a helper-only game log plus an empty
  editor delta after cursor `2`.
- Story228 production traverse: canonical RED `report_2372`, focused GREEN
  `report_2373`, and final five-suite related `report_2377` passed `7/7`.
  Godot AI MCP `3.0.4` run `r184730101-26` used real positive-x movement,
  exercised all steam phases, applied exact physical HP `100 -> 92`, rejected
  no-input completion, crossed at x `12480`, and left Story118 inactive.

## Dependencies

- Depends on: Story116 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Runoff Outlet Service Sluice Exit Hatch Handoff
- Unlocks: deeper Old Factory route content beyond the service sluice tailrace

## Verification Summary

Story117 followed thin TDD and was subsequently hardened by Story227/228. The
current production path requires prior availability, held `move_right` and real
positive-x displacement for both activation and completion, routes damage
through the physical vent overlap, and hands off without starting Story118.
Final related GdUnit passed `7/7` and runtime acceptance passed under Godot 4.7
/ Godot AI MCP 3.0.4.
