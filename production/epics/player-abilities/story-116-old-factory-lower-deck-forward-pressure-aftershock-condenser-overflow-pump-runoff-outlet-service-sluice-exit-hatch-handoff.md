# Story 116: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Exit Hatch Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Handoff
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

Story115 grants the payoff cache after the service sluice Spark Rat. Story116
turns that payoff into a forward handoff by adding a once-only service sluice
exit hatch. The hatch appears after the cache is claimed, opens in range, plays
unlock feedback, clears collision, persists state, and backfills the
Story106-115 runoff/service-sluice chain on restore.

## Acceptance Criteria

- [x] The exit hatch is hidden and unavailable until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed=true`.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceExitHatch`
  exists in `factory_route_transition_shell.tscn`, starts hidden, uses
  `factory_deep_route_endpoint.gd`, and is placed at `Vector2(11680, 392)`.
- [x] The hatch uses endpoint id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch`.
- [x] The hatch prompt progresses from `Claim service sluice cache` to
  `Open Service Exit` to `Service Exit Open`.
- [x] Opening succeeds once for an in-range player, rejects duplicate opens,
  plays one unlock VFX, clears collision blocking, and persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened=true`.
- [x] Route feedback progresses from `Open Service Sluice Exit` to
  `Service Sluice Exit Opened`; Story115 keeps its immediate
  `Service Sluice Cache Claimed +20 Gears` claim feedback.
- [x] Restoring opened state backfills the Story106-115 runoff/service-sluice
  chain so previous traversal, hatch, skirmish, and reward states do not replay.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemies, new route traversal hazards, new savepoints, minimap, fast travel,
authored audio, particles, shaders, new image generation, and broader
lower-deck biome art replacement.

## Implementation Notes

- Story116 reuses `FactoryDeepRouteEndpoint` for the endpoint state machine,
  prompt text, activation range, and one-shot unlock VFX.
- The scene bounds now extend to right wall x `11900`, camera/background right
  `11920`, and ground support through x `12000`.
- `get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics()`
  provides deterministic scene/runtime assertions for GdUnit and MCP eval.
- Compatibility wrappers were added for older condenser-outlet helper names
  surfaced by the editor log buffer; they delegate to the current helper names.

## Asset Pipeline

No new visual or audio assets were generated. Story116 reuses existing
image-generated/imported assets:

- Hatch texture:
  `assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
- Unlock VFX:
  `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
- Service sluice landing context:
  `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`
- Route floor:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

## Test Evidence

- Focused RED: `reports/report_1339/` failed before Story116 diagnostics and
  open API existed.
- Focused GREEN: `reports/report_1340/report_2/` passed `2/2`.
- Related GREEN: `reports/report_1342/report_1/` passed `10/10` across
  Story116, Story115, Story114, Story113, and Story112.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_exit_hatch_smoke.log`
  exited `0` and printed `service_sluice_exit_hatch_smoke=passed`.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed the disk-reloaded hatch
  node, script, endpoint id, prompt text, texture, unlock VFX, runtime
  locked/available/opened diagnostics, collision blocking before open,
  collision cleared after open, local-state persistence, current game log
  without errors, no new editor log rows after cursor `9`, and a non-empty game
  screenshot response.

## Dependencies

- Depends on: Story115 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Runoff Outlet Service Sluice Reward Cache
- Unlocks: deeper Old Factory route content beyond the service sluice handoff

## Verification Summary

Story116 followed thin TDD: focused RED `reports/report_1339/` failed before
runtime support existed, focused GREEN `reports/report_1340/report_2/` passed
`2/2`, and related GREEN `reports/report_1342/report_1/` passed `10/10`.
Godot MCP runtime validation passed under Godot 4.7 and Godot AI MCP 2.9.1, with
the exit hatch visible and interactive after the service sluice cache claim.
