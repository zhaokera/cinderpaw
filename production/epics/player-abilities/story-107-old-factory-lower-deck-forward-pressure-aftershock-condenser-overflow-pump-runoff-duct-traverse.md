# Story 107: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Duct Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Traverse + Hazard
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-10

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005 Combat
state machine; ADR-0007 Scene management; ADR-0018 Player abilities; ADR-0021
Save system.

Story106 opens the overflow pump runoff hatch. Story107 turns that handoff into
a short playable horizontal ACT traversal pocket: the route extends beyond the
hatch, a visible duct appears, and a timed steam vent cycles through warning and
active pressure windows before the crossed state persists.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffDuct`
  exists in `factory_route_transition_shell.tscn`, starts hidden, and reuses the
  existing imported image-generated aftershock cooling duct texture.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffSteamVent`
  exists in the same scene, starts hidden/non-contacting, and reuses the
  imported image-generated Old Factory steam vent texture.
- [x] The runoff duct stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened=true`;
  locked diagnostics report unavailable/hidden and activation returns `false`.
- [x] Once the hatch is open, the duct and vent become visible, route geometry
  extends to at least ground width `7680`, right wall x `7660`, and camera
  limit right `7680`.
- [x] Activation at x `7160` starts the traversal once, advances route feedback
  to `Cross Overflow Pump Runoff Duct`, and begins in `grace` phase.
- [x] Deterministic time advance cycles `grace -> warning -> active -> safe`;
  only `active` enables contact.
- [x] Active-phase contact applies `8` steam damage with cooldown `1.0` and
  source id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct`.
- [x] Crossing x `7560` persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated=true`
  and
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed=true`,
  disables contact, keeps the duct visible, and advances route feedback to
  `Overflow Pump Runoff Duct Crossed`.
- [x] Restoring crossed state keeps the Story106 hatch opened/unblocked,
  prevents cache/hatch replay, and leaves `FactoryServiceLift` prompt at
  `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene reload, runtime helper,
  duct/vent diagnostics, active-window damage, persistence, current-run logs,
  and a non-empty runtime screenshot.

## Out of Scope

New image generation, new enemy family, new reward/economy payload, new
savepoint, minimap, fast travel, authored audio, particles/shaders, Boss2,
SaveSystem schema changes, and broader lower-deck art replacement.

## Implementation Notes

- The slice intentionally follows the existing Story093/096/098 timed traversal
  pattern instead of adding a new hazard framework.
- `set_local_state` restores the runoff duct flags and backfills the required
  Story099/106 upstream state when a completed runoff traversal is loaded.
- The route objective keeps Story106 intact: hatch open alone still reports
  `Overflow Pump Runoff Hatch Open`; active traversal reports
  `Cross Overflow Pump Runoff Duct`; crossed state reports
  `Overflow Pump Runoff Duct Crossed`.

## Asset Pipeline

No new visual asset was generated for Story107.

Reused image-generated/imported runtime assets:

- Duct:
  `assets/environment/old_factory_aftershock_cooling_duct/env_old_factory_aftershock_cooling_duct_768.png`
- Steam vent:
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Route floor extension:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

All reused assets were already imported through the Godot asset pipeline.
Story107 only wires them into new runtime duct/vent nodes and extends the
existing route floor tiling.

## Test Evidence

- Focused RED: `reports/report_1286/` failed because Story107 methods,
  diagnostics, and scene nodes did not exist yet.
- Focused GREEN: `reports/report_1287/` passed `2/2`.
- Related GREEN: `reports/report_1288/` passed `9/9` across Story107,
  Story106 overflow pump reward cache, Story099 overflow pump skirmish,
  Story098 outlet drip vent, and Story102 floor/platform visual suites.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_duct_smoke.log` exited `0`;
  keyword scan found no Story107 script, parse, invalid-call/access,
  missing-resource, or resource-load errors. Godot emitted only known shutdown
  ObjectDB/resource cleanup noise.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed disk scene reload,
  edited scene nodes, right wall x `7660`, camera limit right `7680`, runtime
  helper live, `current_run_errors=[]`, current game log containing only helper
  registration, editor log since current-run cursor empty, active-window damage
  `100 -> 92`, correct hazard source id, crossed local-state persistence, and a
  non-empty `960x539` game screenshot showing the runoff duct and steam vent.

## Dependencies

- Depends on: Story106 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Reward Cache
- Unlocks: deeper Old Factory route content after the runoff duct traverse

## Verification Summary

Story107 followed thin TDD: focused RED `reports/report_1286/` failed before
runtime support existed, focused GREEN `reports/report_1287/` passed `2/2`, and
related GREEN `reports/report_1288/` passed `9/9`. Headless smoke exited `0`.
Godot MCP runtime validation passed under Godot 4.7 and Godot AI MCP 2.9.1.
