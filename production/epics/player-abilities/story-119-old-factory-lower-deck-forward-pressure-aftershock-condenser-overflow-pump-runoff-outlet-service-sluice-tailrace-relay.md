# Story 119: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Savepoint
> **Type**: Integration + Save/Respawn Runtime + UI/Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`,
`TR-respawn-004`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Story118 cleared the service-sluice tailrace Coil Rat. Story119 turns that
handoff into a short ACT-safe relay/savepoint beat so the long lower-deck
runoff/service-sluice chain has a nearby restart anchor before deeper factory
content continues.

## Acceptance Criteria

- [x] The tailrace relay stays hidden, unavailable, non-monitoring, and
  non-monitorable until the Story118 tailrace ambush is cleared.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelaySavepoint`
  exists in `factory_route_transition_shell.tscn` after the Coil Rat pocket,
  uses `src/feature/savepoint_runtime.gd`, and exposes savepoint id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay`.
- [x] Once available, the relay shows `Repair Tailrace Relay`, uses scene id
  `area_03_factory`, spawn point
  `lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay`,
  and reuses the generated lower-deck relay texture plus unlock spark VFX.
- [x] Activation requires the player to be within relay interaction range,
  succeeds exactly once, records the last discovered savepoint, spawns one VFX,
  persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated=true`,
  and updates route feedback to `Tailrace Relay Secured`.
- [x] Restoring only the Story119 relay flag backfills the Story106-118
  runoff/service-sluice chain, including tailrace crossed, exit hatch opened,
  and tailrace ambush cleared state, without replaying prior beats or VFX.
- [x] Death after relay activation requests scene `area_03_factory`, spawn
  point
  `lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay`,
  restores player HP to 50%, moves the player to the relay spawn, and shows
  `Returned to Tailrace Relay`.
- [x] Scene bounds support the relay handoff: right wall x `13720`, camera and
  background right `13740`, ground right edge x `13840`, and at least 58 route
  floor tiles.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4.

## Out of Scope

New enemies, new generated art, new character frame animations, new hazards,
reward economy changes, SaveSystem schema changes, minimap/fast-travel UI,
authored audio, particles, shaders, Boss2, and broader lower-deck biome art
replacement.

## Implementation Notes

- Story119 intentionally uses a relay/savepoint instead of another cache or
  combat encounter to give the service-sluice tailrace chain a clean restart
  point.
- The route objective now hands Story118 clear state forward to
  `Repair Tailrace Relay`, then closes on `Tailrace Relay Secured`.
- The SceneManager spawn mapping includes the new relay spawn, so direct entry
  into `area_03_factory` at the Story119 spawn lands at the relay and updates
  the respawn label.

## Asset Pipeline

No new visual or audio assets were generated. Story119 reuses existing
image-generated/imported assets:

- Tailrace relay visual:
  `assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`
- Unlock VFX:
  `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
- Route floor:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

## Test Evidence

- Focused RED: `reports/report_1350/` failed before Story119 diagnostics,
  activation API, scene node, state, and bounds existed.
- Focused GREEN: `reports/report_1360/` passed `2/2`, including the
  SceneManager-spawn regression for landing directly at the relay.
- Related GREEN: `reports/report_1361/` passed `21/21` across Story113-119
  service-sluice/tailrace suites plus savepoint and respawn sentinels.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_smoke.log`
  exited `0` and printed `service_sluice_tailrace_relay_smoke=passed`.
- Godot MCP 2.9.1 / Godot 4.7 runtime validation opened and ran
  `res://scenes/factory_route_transition_shell.tscn`, confirmed the relay node,
  savepoint group, script, texture, prompt, VFX, runtime activation, one-shot
  VFX count, last-savepoint payload, 58 floor visuals, clean current-run status,
  and a non-empty `960x539` game screenshot showing the Tailrace Relay.
- Story229 incoming handoff: `reports/report_2379/report_1/results.xml` passed
  its five-suite related set `7/7`; the `180`-frame production smoke and Godot
  AI MCP 3.0.4 run `r187717447-28` confirmed Story118 reveals this relay as
  visible, available, monitoring and unactivated with `Repair Tailrace Relay`.
- Story230 production closure: canonical RED `report_2381` exposed the stale
  prompt, missing immediate Story120 reveal and no-input runoff activation;
  focused GREEN `report_2382` passed `1/1` and six-suite related GREEN
  `report_2383` passed `8/8`. The updated `180`-frame smoke and Godot AI MCP
  3.0.4 run `r190526212-29` verified real contact, one-shot checkpoint/VFX,
  real death, 50% HP relay respawn and the idle Story120 handoff.

## Verification Summary

The Story119 relay implementation remains complete. Story229 verifies its
production incoming boundary after a real Story118 combat kill; Story230 now
closes real contact activation, death/respawn and the guarded Story120 outgoing
boundary without reopening Story118.
