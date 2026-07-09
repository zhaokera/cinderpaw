# Story 108: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Exit Skirmish

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Combat
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

Story107 leaves the player at the crossed overflow pump runoff duct. Story108
turns that route handoff into the next visible ACT pressure beat: the route
extends again, a Coil Rat skirmish arms after the duct is crossed, and the clear
state persists without replaying the runoff duct or reward-cache chain.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffExitCoilRat`
  exists in `factory_route_transition_shell.tscn`, starts hidden, and instances
  the existing Coil Rat character scene.
- [x] The skirmish stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed=true`;
  locked diagnostics report unavailable and activation returns `false`.
- [x] Once the duct is crossed, the route geometry extends to at least ground
  width `8320`, right wall x `8300`, and camera limit right `8320`.
- [x] Activation at x `7800` starts the skirmish once, makes the Coil Rat
  visible, assigns the player as target, and advances route feedback to
  `Clear Overflow Pump Runoff Exit`.
- [x] The Coil Rat uses `AnimatedSprite2D` with
  `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`.
- [x] Required animations `idle`, `run`, `attack_tell`, `attack`, `hurt`, and
  `death` each have at least 3 frames.
- [x] Activation starts Coil Rat pacing in `opening_grace` with total/opening
  grace frames `10`.
- [x] Defeating entity id `2140` persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated=true`,
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated=true`,
  and
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_cleared=true`.
- [x] Restoring cleared state keeps the Story106/107 overflow pump reward,
  hatch, and runoff duct state backfilled, prevents duct replay, hides the Coil
  Rat, and advances route feedback to `Overflow Pump Runoff Exit Cleared`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene reload, runtime helper,
  Coil Rat `AnimatedSprite2D`/SpriteFrames binding, route bounds, current-run
  logs, and a non-empty runtime screenshot.

## Out of Scope

New enemy family, new reward/economy payload, new savepoint, minimap, fast
travel, authored audio, particles/shaders, Boss2, SaveSystem schema changes,
and broader lower-deck art replacement.

## Implementation Notes

- The slice reuses the existing Factory Coil Rat combat implementation and
  frame-animation asset instead of adding another temporary placeholder.
- `set_local_state` restores the runoff-exit flags and backfills the required
  Story099/106/107 upstream state when an active or cleared runoff-exit skirmish
  is loaded.
- The route objective keeps the prior handoff readable: crossed runoff duct
  still reports `Overflow Pump Runoff Duct Crossed`; active skirmish reports
  `Clear Overflow Pump Runoff Exit`; cleared state reports
  `Overflow Pump Runoff Exit Cleared`.

## Asset Pipeline

No new visual asset was generated for Story108.

Reused image-generated/imported runtime assets:

- Coil Rat SpriteFrames:
  `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- Coil Rat frame folders:
  `assets/characters/factory_coil_rat/{idle,run,attack_tell,attack,hurt,death}/`
- Route floor extension:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

All reused assets were already imported through the Godot asset pipeline.
Story108 wires the existing multi-frame Coil Rat into the new runoff-exit
runtime skirmish and extends the route floor tiling.

## Test Evidence

- Focused RED: `reports/report_1289/` failed because Story108 methods,
  diagnostics, and scene node wiring did not exist yet.
- Focused GREEN: `reports/report_1291/` passed `2/2`.
- Related GREEN: `reports/report_1292/` passed `11/11` across Story108,
  Story107 runoff duct, Story106 overflow pump reward cache, Story099 overflow
  pump skirmish, Story091 exhaust escape skirmish, and Story102 floor/platform
  visual suites.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_exit_skirmish_smoke.log` exited
  `0`; keyword scan found no Story108 script, parse, invalid-call/access,
  missing-resource, or resource-load errors. Godot emitted only known shutdown
  ObjectDB/resource cleanup noise.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed disk scene reload,
  edited scene target node, right wall x `8300`, camera limit right `8320`,
  runtime helper live, `current_run_errors=[]`, runtime tree containing the
  target Coil Rat and its `AnimatedSprite2D`, SpriteFrames binding to
  `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`,
  current game log containing only helper registration, editor log since
  current-run cursor empty, far-right floor tile texture loaded, and a non-empty
  `960x539` game screenshot.

## Dependencies

- Depends on: Story107 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Runoff Duct Traverse
- Unlocks: deeper Old Factory route content after the runoff-exit skirmish

## Verification Summary

Story108 followed thin TDD: focused RED `reports/report_1289/` failed before
runtime support existed, focused GREEN `reports/report_1291/` passed `2/2`, and
related GREEN `reports/report_1292/` passed `11/11`. Headless smoke exited `0`.
Godot MCP runtime validation passed under Godot 4.7 and Godot AI MCP 2.9.1.
