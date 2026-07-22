# Story 110: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Traverse + Hazard Timing
> **Type**: Integration + Gameplay Runtime + Visual Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005 Combat
state machine; ADR-0007 Scene management; ADR-0018 Player abilities; ADR-0021
Save system.

Story109 opens the overflow pump runoff exit gate. Story110 converts that
handoff into a short movement-pressure pocket: the route extends farther right,
a reused generated duct visual appears, and a reused steam vent cycles through
the standard timing window before the player crosses the new runoff outlet.

## Acceptance Criteria

- [x] The factory route extends far enough for the new pocket: right wall,
  camera limit, ground collision, and floor visuals cover the runoff outlet
  traversal area.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletDuct`
  exists in `factory_route_transition_shell.tscn`, starts hidden, and reuses an
  imported image-generated aftershock cooling duct texture.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletSteamVent`
  exists in the same scene, starts hidden/non-contacting, uses the existing
  steam vent script, and reuses the imported steam vent texture.
- [x] The outlet traverse stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened=true`;
  locked diagnostics report unavailable/hidden and activation returns `false`.
- [x] Once the gate is open, the duct and vent become visible while the vent
  remains non-contacting until traversal activation.
- [x] Production activation requires frame-start availability, held
  `move_right`, fresh positive x displacement and x `8480`; restoring,
  teleporting, stationary frames or no-input placement cannot start it. Route
  feedback changes to `Cross Overflow Pump Runoff Outlet` on activation.
- [x] The steam vent uses the existing `grace -> warning -> active -> safe`
  timing cycle; only `active` contact enables the environment collision mask and
  applies `8` steam damage under source
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet`.
- [x] Completion at x `9060` persists the outlet crossed state, disables vent
  contact, advances route feedback to `Overflow Pump Runoff Outlet Crossed`,
  and reveals Story111 without starting it in the crossing frame.
- [x] Restoring the crossed state backfills the Story106/107/108/109 runoff
  chain, keeps the Story109 gate open, and prevents prior cache/skirmish/duct
  replay.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemies, new generated visual assets, new reward cache, new savepoint,
minimap, fast travel, authored audio, particles/shaders, Boss2, SaveSystem
schema changes, and broader lower-deck art replacement.

## Implementation Notes

- The slice intentionally follows prior timed traversal patterns but keeps the
  scope narrow after Story108 combat and Story109 reward/gate handoff.
- `set_local_state` restores the Story110 traverse flags and backfills the
  Story106/107/108/109 overflow pump chain when the outlet is active or crossed.
- Route objective priority places Story110 active/crossed states before Story109
  gate-opened state so the HUD does not remain stuck on the prior handoff.

## Asset Pipeline

No new visual asset was generated for Story110.

Reused image-generated/imported runtime assets:

- Duct:
  `assets/environment/old_factory_aftershock_cooling_duct/env_old_factory_aftershock_cooling_duct_768.png`
- Steam vent:
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Floor:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

All reused assets were already imported through the Godot asset pipeline.

## Test Evidence

- Focused RED: `reports/report_1297/` failed because Story110 diagnostics and
  traversal APIs did not exist yet.
- Focused GREEN: `reports/report_1298/` passed `2/2`.
- Related GREEN: `reports/report_1299/` passed `9/9` across Story110, Story109,
  Story108, Story107, and the route floor/platform visual pass.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_traverse_smoke.log` exited
  `0`; keyword scan found no Story110 script, parse, invalid-call/access,
  missing-resource, or resource-load errors. Godot emitted only known shutdown
  ObjectDB/resource cleanup noise.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed disk scene reload,
  edited scene target nodes, duct texture path, vent script/hazard ID/damage,
  runtime helper live, `current_run_errors=[]`, runtime tree containing both
  target nodes, current game log containing only helper registration, editor log
  since current-run cursor empty, and a non-empty `960x539` game screenshot.
- Story222 production closure: canonical/boundary RED reports `2344` and
  `2348` exposed production movement and stable-handoff gaps; final focused
  `reports/report_2349/results.xml` passed `1/1` and seven-suite related
  `reports/report_2350/results.xml` passed `11/11`. The dedicated `180`-frame
  smoke exited `0`.
- Godot MCP 3.0.4 accepted run `r165369444-9` rejected no-input x `8484`, used
  actual `move_right` x `8475.334 -> 8482` to activate, reached active physical
  contact at HP `100 -> 92`, and crossed x `9055.334 -> 9060.223` while
  Story111 remained available/inactive/hidden.

## Dependencies

- Depends on: Story109 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Runoff Exit Reward Cache
- Unlocks: deeper Old Factory route content after the runoff outlet traverse

## Verification Summary

Story110 followed thin TDD: focused RED `reports/report_1297/` failed before
runtime support existed, focused GREEN `reports/report_1298/` passed `2/2`, and
related GREEN `reports/report_1299/` passed `9/9`. Headless smoke exited `0`.
Godot MCP runtime validation passed under Godot 4.7 and Godot AI MCP 2.9.1.
Story222 adds current Godot AI MCP 3.0.4 production movement, physical hazard
and non-consuming Story111 handoff evidence.
