# Story 115: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Reward Cache

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Payoff
> **Type**: Integration + Gameplay Runtime + UI/Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-10

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story114 clears the Spark Rat guarding the runoff outlet service sluice pocket.
Story115 adds the immediate route payoff: a once-only service sluice reward
cache that appears after the skirmish, grants gears, updates route feedback, and
persists without replaying the Story106-114 runoff chain.

## Acceptance Criteria

- [x] The cache is locked and hidden until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared=true`.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceRewardCache`
  exists in `factory_route_transition_shell.tscn`, starts hidden, uses
  `factory_combat_cache.gd`, and is placed at `Vector2(11360, 410)`.
- [x] The cache uses id/source
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache`,
  grants `20` gears, and displays `+20 Gears` when claimable.
- [x] Claiming succeeds once, rejects duplicate claims, stores the reward
  payload and feedback, and persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed=true`.
- [x] Route feedback remains `Service Sluice Spark Rat Cleared` before claim
  and becomes `Service Sluice Cache Claimed +20 Gears` after claim.
- [x] Restoring claimed state backfills the Story106-114 runoff/service-sluice
  chain so previous traversal, reward, hatch, sluice, and Spark Rat states do
  not replay.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemy, new route gate, new savepoint, minimap, fast travel, authored audio,
particles, shaders, new image generation, and broader lower-deck biome art
replacement.

## Implementation Notes

- Story115 reuses the existing `FactoryCombatCache` helper and the imported
  lower-deck cache texture.
- `get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics()`
  provides deterministic scene/runtime assertions for GdUnit and MCP eval.
- Route objective priority now places the claimed payoff label before the
  Story114 cleared label.
- The cache uses the Story114 route bounds: right wall x `11500`, camera and
  background right `11520`, and ground support through x `11700`.

## Asset Pipeline

No new visual or audio assets were generated. Story115 reuses previously
generated/imported assets:

- Reward cache texture:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`
- Service sluice landing context:
  `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`
- Route floor:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

## Test Evidence

- Focused RED: `reports/report_1336/` failed before Story115 diagnostics and
  claim API existed.
- Focused GREEN: `reports/report_1337/` passed `2/2`.
- Related GREEN: `reports/report_1338/` passed `8/8` across Story115, Story114,
  Story113, and Story112.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_reward_cache_smoke.log`
  exited `0`. The log contains only known Godot shutdown cleanup noise after
  the scene run.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed disk-reloaded cache
  node, script, texture, cache id/source, reward `20`, position
  `Vector2(11360, 410)`, locked/available/claimed runtime diagnostics,
  duplicate claim rejection, route label update, local-state persistence,
  current game log without errors, no new editor log rows after cursor `9`, and
  a non-empty game screenshot showing Cinderpaw and the service sluice reward
  cache in the same pocket.

## Dependencies

- Depends on: Story114 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Runoff Outlet Service Sluice Skirmish
- Unlocks: deeper Old Factory route content beyond the service sluice payoff

## Verification Summary

Story115 followed thin TDD: focused RED `reports/report_1336/` failed before
runtime support existed, focused GREEN `reports/report_1337/` passed `2/2`, and
related GREEN `reports/report_1338/` passed `8/8`. Godot MCP runtime validation
passed under Godot 4.7 and Godot AI MCP 2.9.1, with visible cache payoff art
reused from the existing generated asset set.
