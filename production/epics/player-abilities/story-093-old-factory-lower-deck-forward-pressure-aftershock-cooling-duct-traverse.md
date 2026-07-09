# Story 093: Old Factory Lower Deck Forward Pressure Aftershock Cooling Duct Traverse

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-09

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story092 opens the aftershock exhaust exit hatch at the far right of the Old
Factory lower-deck forward-pressure route. Story093 extends that exit into a
player-facing traverse instead of ending on another static door: after the hatch
is opened, a generated cooling-duct environment prop becomes visible, a timed
steam vent creates a warning/active/safe hazard window, and crossing the duct
persists route progress without replaying the previous hatch, combat, relay, or
service-lift state.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCoolingDuct` exists in
  `factory_route_transition_shell.tscn`, starts hidden, uses a new imported
  image-generated transparent PNG, and becomes visible only after Story092's
  exhaust exit hatch is opened.
- [x] The lower-deck route extends to at least x `3840.0`: ground width,
  right-wall position, and player camera limit all support the new traverse
  space.
- [x] `FactoryLowerDeckForwardPressureAftershockCoolingDuctVent` exists as a
  steam hazard with id
  `old_factory_lower_deck_forward_pressure_aftershock_cooling_duct`, damage
  `8`, cooldown `1.0`, and the reused imported steam-vent hazard visual.
- [x] The cooling duct is unavailable until
  `factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened=true`;
  locked activation returns `false` and keeps the duct and hazard hidden.
- [x] Once available, the duct exposes diagnostics with node names, texture
  paths, hazard timing, activation x `3240.0`, exit x `3740.0`, route label
  `Aftershock Exhaust Exit Opened`, and hidden contact damage during the
  initial grace/warning phases.
- [x] Entering the activation point starts the traverse once, sets route
  feedback to `Cross Aftershock Cooling Duct`, and cycles the hazard through
  `grace`, `warning`, `active`, and `safe` phases.
- [x] During the `active` phase, applying steam contact deals `8` player damage
  and records the cooling-duct hazard source. During `safe`, contact damage is
  disabled.
- [x] Crossing the exit point persists
  `factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated=true`
  and
  `factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed=true`,
  disables contact damage, keeps the generated duct visible, and sets route
  feedback to `Aftershock Cooling Duct Crossed`.
- [x] Restoring crossed state keeps the Story092 hatch opened, preserves
  previous aftershock escape/breaker state, keeps the Story074 exit relay
  savepoint contract stable, and preserves `FactoryServiceLift` prompt
  `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene load, duct/hazard
  nodes, diagnostics, hazard phase behavior, clean logs, and a non-empty
  screenshot showing the generated duct and steam vent in game.

## Out of Scope

New character/enemy art, new enemy family, new reward cache, new savepoint,
SaveSystem schema changes, service-lift destination changes, minimap/fast
travel UI, authored audio, shaders, Boss2, and broad biome replacement.

## Implementation Notes

- Use hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_cooling_duct`.
- Keep Story093 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Keep the generated cooling duct as an environment prop and reuse the existing
  `FactorySteamVentHazard` script for the timed damage window.
- The traverse is a route-progress slice: it should be driven by player x
  thresholds and route diagnostics, not by a blocking modal interaction.

## Asset Pipeline

New image-generated runtime prop:

- Source:
  `assets/generated/source/old_factory_aftershock_cooling_duct_imagegen_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_cooling_duct_imagegen_20260709.json`
- Runtime:
  `assets/environment/old_factory_aftershock_cooling_duct/env_old_factory_aftershock_cooling_duct_768.png`

Story093 also reuses the imported image-generated steam vent hazard:

- `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_cooling_duct_traverse_test.gd`
  - Initial RED: `reports/report_1223/` (`2` tests, missing Story093 API)
  - Import RED: `reports/report_1224/` (scene could not load before Godot
    imported the new PNG)
  - Focused GREEN: `reports/report_1225/` (`2/2`)
- Related regression:
  - Minimal related GREEN: `reports/report_1226/` (`4/4`) covering Story093
    plus Story092 hatch regression.
  - Post-warning-fix related GREEN: `reports/report_1227/` (`4/4`)
  - Final auto-complete GREEN: `reports/report_1228/` (`4/4`) covering the
    `_process`-driven exit crossing completion path.
- Runtime evidence:
  Headless factory smoke
  `reports/old_factory_aftershock_cooling_duct_traverse_smoke.log` exited `0`;
  keyword scan found no project script/parse/invalid-call/access/
  missing-resource/resource-load/shadowed-variable errors.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed scene reload from disk,
  runtime helper live, duct and vent nodes present, new PNG texture path,
  route extension to x `3840.0`, locked/ready/active/crossed diagnostics,
  `_process` activation and automatic exit completion, active hazard contact
  damage enabled only during `active`, persisted crossed state, clean final
  game/editor logs, and a non-empty `960x539` game screenshot showing the
  generated duct and steam vent.

## Dependencies

- Depends on: Story092 Old Factory Lower Deck Forward Pressure Aftershock Exhaust Exit Hatch Handoff
- Unlocks: deeper Old Factory route content beyond the aftershock cooling duct

## Verification Summary

Initial RED `reports/report_1223/` failed before Story093 API and diagnostics
existed. `reports/report_1224/` then exposed the missing Godot import for the
new generated PNG. Focused GREEN `reports/report_1225/` passed `2/2`; related
GREEN `reports/report_1226/` and `reports/report_1227/` passed `4/4`. Final
auto-complete GREEN `reports/report_1228/` passed `4/4` after the runtime
`_process` path was added. Headless smoke and Godot MCP runtime evidence passed
under Godot 4.7 / Godot AI MCP 2.9.1.
