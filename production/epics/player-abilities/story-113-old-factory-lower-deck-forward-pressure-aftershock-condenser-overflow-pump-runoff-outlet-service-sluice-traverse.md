# Story 113: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Traverse
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

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005 Combat
state machine; ADR-0007 Scene management; ADR-0018 Player abilities; ADR-0021
Save system.

Story112 opens the runoff outlet service hatch. Story113 extends the playable
route into the next service sluice pocket with a new image-generated industrial
landing, a reused steam vent hazard loop, route objective handoff, persistence,
and Godot MCP runtime validation.

## Acceptance Criteria

- [x] The route only exposes the service sluice after
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened=true`.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceDuct`
  exists in `factory_route_transition_shell.tscn`, uses
  `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`,
  and starts hidden before the service hatch is opened.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceSteamVent`
  exists, uses `factory_steam_vent_hazard.gd`, hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice`,
  damage `8`, cooldown `1.0`, and only enables damaging collision during the
  active steam phase.
- [x] The route extends to activation x `10160`, completion x `10720`, right
  wall x `10940`, camera limit right `10960`, background width at least
  `10960`, and floor coverage at least `45` visual tiles / `12800` px wide.
- [x] Opening the hatch advances route feedback to
  `Runoff Outlet Service Hatch Open`; activating the traverse advances feedback
  to `Cross Runoff Outlet Service Sluice`; completing it advances feedback to
  `Runoff Outlet Service Sluice Crossed`.
- [x] Restoring service sluice active/crossed state backfills the Story106-112
  overflow pump runoff chain so previous duct, exit, outlet, skirmish, reward,
  and hatch states do not replay.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4.

## Out of Scope

New enemy, new savepoint, minimap, fast travel, authored audio, particles,
shader work, new player/enemy frame animations, and broader lower-deck visual
replacement beyond the generated service sluice landing.

## Implementation Notes

- Story113 adds three floor visuals and extends the existing route shell bounds
  without changing the main scene.
- The traverse reuses the existing timed steam pressure helper behavior and
  adds a new hazard id so save/combat diagnostics can distinguish this pocket.
- `get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics()`
  provides deterministic scene/runtime assertions for tests and MCP eval.
- Route objective priority now checks service sluice active/crossed/hatch-open
  states before the earlier runoff outlet cache/skirmish/outlet handoffs.

## Asset Pipeline

New image-generated visual asset:

- Asset id: `old_factory_runoff_service_hatch_landing`
- Source:
  `assets/generated/source/old_factory_runoff_service_hatch_landing_imagegen_20260710.png`
- Alpha source:
  `assets/generated/source/old_factory_runoff_service_hatch_landing_alpha_20260710.png`
- Metadata:
  `assets/generated/source/old_factory_runoff_service_hatch_landing_imagegen_20260710.json`
- Runtime import:
  `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`
- Manifest:
  `design/assets/asset-manifest.md`

Story113 adds no new player-visible character, so it does not add or modify
`AnimatedSprite2D + SpriteFrames` character animation resources.

## Test Evidence

- Focused RED: `reports/report_1323/` failed before Story113 runtime asset and
  APIs existed.
- Parse/import cleanup REDs: `reports/report_1325/`, `reports/report_1326/`,
  and `reports/report_1327/` captured transient indentation/objective-priority
  failures while wiring the new slice.
- Focused GREEN: `reports/report_1328/` passed `2/2`.
- Related GREEN: `reports/report_1329/` passed `10/10` across Story113,
  Story112, Story111, Story110, and Story109.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_script_smoke.log`
  exited `0` and printed `service_sluice_smoke=passed`. The log also contains
  Godot shutdown cleanup noise (`ObjectDB instances were leaked at exit`,
  `resources still in use at exit`) after the pass marker.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed disk scene reload,
  service sluice duct/steam vent nodes, runtime helper live,
  `current_run_errors=[]`, service hatch open diagnostics, activation,
  active hazard contact window, completion/crossed state, texture/hazard id,
  current game log without errors, no new editor log rows after cursor `9`, and
  a non-empty game screenshot showing the service hatch, generated sluice
  landing, and steam vent.
- Story224 production traversal: focused `report_2357` passed `1/1`, bounded
  related `report_2360` passed `10/10`, and Factory smoke recorded
  `story224_smoke=passed frames=180`. MCP 3.0.4 accepted run `r169905919-15`
  proved no-input x `10164` rejection, real positive-x `move_right` activation,
  warning/active/safe phases, real vent `Area2D` HP `100 -> 92` contact with the
  exact hazard source, and real crossing through x `10720`.

## Dependencies

- Depends on: Story112 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Runoff Outlet Reward Cache
- Unlocks: deeper Old Factory route content beyond the runoff outlet service
  sluice

## Verification Summary

Story113 followed thin TDD: focused RED `reports/report_1323/` failed before
runtime support existed, focused GREEN `reports/report_1328/` passed `2/2`, and
related GREEN `reports/report_1329/` passed `10/10`. Godot MCP runtime
validation passed under Godot 4.7 and Godot AI MCP 2.9.1, with a visible
image-generated service sluice landing replacing placeholder geometry.
Story224 adds current Godot AI MCP 3.0.4 evidence for production movement,
physical contact damage and the crossed handoff without changing persistence.
