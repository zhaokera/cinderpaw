# Story 086: Old Factory Lower Deck Forward Pressure Aftershock Exhaust Traverse

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

Story085 clears the Spark Rat + Coil Rat aftershock exit skirmish. Story086
turns that clear into a short side-scrolling traversal beat: pushing forward
starts an aftershock exhaust vent that cycles through grace, warning, active,
and safe windows. The player must read the timing, cross the vent, and reach
the completion point. This adds a visible ACT movement challenge without
another enemy wave, new generated art, a new reward cache, a new savepoint, or
a new room scene.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureAftershockExhaustVent` using the existing
  `FactorySteamVentHazard` script and the existing Old Factory steam vent
  texture.
- [x] The exhaust traverse is unavailable while
  `factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared=false`;
  the vent remains hidden, non-monitoring, non-contacting, and manual activation
  returns `false`.
- [x] Once Story085 is cleared, crossing activation x `2416.0` activates the
  traverse, makes the vent visible, starts deterministic phase timing
  `grace -> warning -> active -> safe`, assigns hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust`, and updates
  route feedback to `Cross Aftershock Exhaust`.
- [x] Only the `active` phase can damage the player through the existing steam
  contact path. Grace, warning, and safe phases do not damage the player, and
  non-player contact does not trigger damage.
- [x] Crossing completion x `2480.0` persists
  `factory_lower_deck_forward_pressure_aftershock_exhaust_activated=true` and
  `factory_lower_deck_forward_pressure_aftershock_exhaust_crossed=true`,
  disables the vent, marks the route objective complete, and updates route
  feedback to `Forward Pressure Aftershock Exhaust Crossed`.
- [x] Restoring completed state keeps Story086 inactive/crossed, keeps Story085
  cleared, keeps Story084 cache claimed, preserves the Story074 exit relay
  savepoint contract, does not replay Story068 clear burst or Story071
  reward-cache audio, and preserves `FactoryServiceLift` prompt `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene load, vent node,
  phase/activation/completion diagnostics, damage gating, clean logs, and a
  non-empty screenshot showing the active exhaust traverse.

## Out of Scope

New generated character art, new enemy family, new AI behavior tree, new reward
economy, new reward cache, new savepoint, SaveSystem schema changes,
service-lift route changes, minimap/fast travel UI, authored audio,
particles/shaders, Boss2, and broader lower-deck layout work.

## Implementation Notes

- Reuse the existing Old Factory steam vent hazard script and texture:
  `src/feature/factory_steam_vent_hazard.gd` and
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
- Keep Story086 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Use hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust`.
- Reuse the existing deterministic forward-pressure vent phase model where
  practical, but keep Story086 state separate from Story069.
- Keep the Story074 relay as the active non-boss respawn anchor; Story086 does
  not write a new savepoint contract.
- Do not lock `FactoryServiceLift`; the exhaust traverse is a forward-route
  movement beat, not a lift gate.

## Asset Pipeline

No new visual assets are required for this Story. It reuses imported,
image-generated environment assets:

- Old Factory steam vent hazard:
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`

Usage must be recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, this story, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_traverse_test.gd`;
  RED `reports/report_1187/`, focused GREEN `reports/report_1188/` (`3/3`).
- Related regression:
  Story086 focused + Story085, Story084, Story083, Story082, Story081,
  Story074, service-lift, and no-loss respawn suites. Final related GREEN
  `reports/report_1190/` passed `25/25`.
- Runtime evidence:
  Headless smoke
  `reports/old_factory_forward_pressure_aftershock_exhaust_traverse_smoke.log`
  exited `0` and its project error keyword scan was empty. Godot MCP runtime on
  Godot `4.7-stable` / Godot AI MCP `2.9.1` confirmed scene load, vent node,
  Story085-clear gating, activation x `2416.0`, completion x `2480.0`,
  deterministic `grace -> warning -> active -> safe` phases, active-only player
  steam damage, non-player contact ignored, crossed-state persistence, unchanged
  Story074 relay savepoint contract, service lift prompt `Call lift`, clean
  final game/editor logs, and a non-empty `960x539` screenshot with the active
  exhaust vent visible.

## Verification Summary

- RED focused `reports/report_1187/` failed as expected before Story086 scene
  APIs and diagnostics existed.
- Focused GREEN `reports/report_1188/` passed Story086 `3/3`.
- Final related GREEN `reports/report_1190/` passed Story086 plus Story085,
  Story084, Story083, Story069 steam traversal, Story074 relay, service-lift,
  audio no-replay, and no-loss respawn coverage `25/25`.
- Headless smoke
  `reports/old_factory_forward_pressure_aftershock_exhaust_traverse_smoke.log`
  exited `0` with no project script/parse/invalid-call/access/missing-resource
  or resource-load errors by keyword scan.
- Godot MCP runtime confirmed `FactoryLowerDeckForwardPressureAftershockExhaustVent`
  as an `Area2D` using `FactorySteamVentHazard`, texture
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`,
  hazard id `old_factory_lower_deck_forward_pressure_aftershock_exhaust`, damage
  `8`, cooldown `1.0`, route labels `Cross Aftershock Exhaust` and
  `Forward Pressure Aftershock Exhaust Crossed`, restored crossed-state
  inactivity, and clean final logs.

## Dependencies

- Depends on: Story085 Old Factory Lower Deck Forward Pressure Aftershock Exit Skirmish
- Unlocks: Deeper Old Factory route content after the aftershock exhaust traverse
