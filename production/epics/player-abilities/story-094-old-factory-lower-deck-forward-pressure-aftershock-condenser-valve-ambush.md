# Story 094: Old Factory Lower Deck Forward Pressure Aftershock Condenser Valve Ambush

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

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005 Combat
state machine; ADR-0007 Scene management; ADR-0018 Player abilities; ADR-0021
Save system.

Story093 ends with Cinderpaw crossing the aftershock cooling duct. Story094
turns that landing into an action beat instead of another static route marker:
the route extends to a generated condenser-valve/fan prop, reuses the existing
image-generated Factory Spark Rat and Factory Coil Rat `AnimatedSprite2D +
SpriteFrames` character scenes, and persists the secured landing without
replaying Story092/Story093.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserValve` exists in
  `factory_route_transition_shell.tscn`, starts hidden, uses a new imported
  image-generated transparent PNG, and becomes visible only after Story093's
  cooling duct has been crossed.
- [x] The lower-deck route extends to at least x `4560.0`: ground width,
  right-wall position, and player camera limit support the new condenser
  landing space.
- [x] The ambush is unavailable until
  `factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed=true`;
  locked activation returns `false` and keeps the valve hidden.
- [x] Once available, diagnostics expose node names, texture path, route
  extension, activation x `3920.0`, and route label
  `Aftershock Cooling Duct Crossed`.
- [x] Entering the activation point starts the ambush once, sets route feedback
  to `Secure Aftershock Condenser Landing`, and enables both enemies with
  process/physics and player attack targets.
- [x] The Spark Rat uses
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  and the Coil Rat uses
  `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`;
  each validated gameplay animation has at least 3 frames.
- [x] Defeating entities `2136` and `2137` persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_valve_activated`,
  `..._spark_rat_defeated`, `..._coil_rat_defeated`, and
  `..._cleared`, disables active combat, and sets route feedback to
  `Aftershock Condenser Landing Secured`.
- [x] Restoring cleared state keeps Story092 hatch opened, Story093 cooling
  duct crossed, cooling-duct hazard contact disabled, and route feedback on
  `Aftershock Condenser Landing Secured`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene reload, runtime helper,
  valve and enemy nodes, active/clear/restore diagnostics, clean logs, and a
  non-empty screenshot showing the generated valve plus animated enemies.

## Out of Scope

New enemy family art, new player ability, new reward cache, new savepoint,
SaveSystem schema changes, service-lift destination changes, minimap/fast
travel UI, authored audio, shaders, Boss2, and broad biome replacement.

## Implementation Notes

- Use entity ids `2136` and `2137` for the condenser landing Spark Rat and Coil
  Rat.
- Keep Story094 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Reuse the existing generated Factory Spark Rat and Factory Coil Rat
  `AnimatedSprite2D + SpriteFrames` resources instead of introducing static
  placeholder enemies.
- The landing is a route-progress combat slice: activation is driven by player
  x position and diagnostics, not by a modal interaction prompt.

## Asset Pipeline

New image-generated runtime prop:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_valve_imagegen_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_valve_imagegen_20260709.json`
- Runtime:
  `assets/environment/old_factory_aftershock_condenser_valve/env_old_factory_aftershock_condenser_valve_768.png`

Story094 reuses generated character animation resources:

- `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_valve_ambush_test.gd`
  - Initial RED: `reports/report_1229/` (missing Story094 API and
    diagnostics)
  - Focused GREEN: `reports/report_1230/` (`2/2`)
- Related regression:
  - Minimal related GREEN: `reports/report_1231/` (`6/6`) covering Story094,
    Story093 cooling duct, and Story092 hatch regression.
- Runtime evidence:
  Headless factory smoke
  `reports/old_factory_aftershock_condenser_valve_ambush_smoke.log` exited
  `0`; keyword scan found no project script/parse/invalid-call/access/
  missing-resource/resource-load errors.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed scene reload from disk,
  runtime helper live, condenser valve, Spark Rat, and Coil Rat nodes present,
  locked/ready/active/cleared/restored diagnostics, active enemies visible and
  targeted, persisted cleared state, clean final game/editor logs, and a
  non-empty `960x539` game screenshot showing the generated valve with
  animated enemies.

## Dependencies

- Depends on: Story093 Old Factory Lower Deck Forward Pressure Aftershock Cooling Duct Traverse
- Unlocks: deeper Old Factory route content beyond the aftershock condenser landing

## Verification Summary

Initial RED `reports/report_1229/` failed before Story094 API and diagnostics
existed. Focused GREEN `reports/report_1230/` passed `2/2`; related GREEN
`reports/report_1231/` passed `6/6`. Headless smoke and Godot MCP runtime
evidence passed under Godot 4.7 / Godot AI MCP 2.9.1.
