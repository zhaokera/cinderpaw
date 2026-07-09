# Story 114: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Skirmish

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Combat
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract
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

Story113 leaves Cinderpaw at the crossed runoff outlet service sluice. Story114
adds the first combat check after that traverse: a reused image-generated
Factory Spark Rat appears in the new pocket, activates from the player's forward
movement, and clears into persistent route progress without replaying the
Story106-113 runoff chain.

## Acceptance Criteria

- [x] The skirmish is locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed=true`.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceSparkRat`
  exists in `factory_route_transition_shell.tscn`, starts hidden/inactive, and
  uses the Factory Spark Rat `AnimatedSprite2D + SpriteFrames` contract.
- [x] Crossing activation x `10920` activates entity `2142`, assigns Cinderpaw
  as target, enables process/physics, starts opening grace `12`, and advances
  route feedback to `Clear Service Sluice Spark Rat`.
- [x] The Spark Rat's `SpriteFrames` resource is
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  and includes `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`
  with at least `3` frames each.
- [x] The route extends to Spark Rat position `Vector2(11120, 482)`, right wall
  x `11500`, camera limit right `11520`, background width `11520`, and solid
  ground coverage through at least x `11520`.
- [x] Defeating entity `2142` disables the enemy, persists activated/defeated
  and cleared local state, and advances route feedback to
  `Service Sluice Spark Rat Cleared`.
- [x] Restoring skirmish active/cleared state backfills the Story106-113 overflow
  pump runoff and service sluice chain so previous traversal, reward, hatch,
  and sluice states do not replay.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New enemy family, new image-generated character frames, new reward cache, new
savepoint, minimap, fast travel, authored audio, particles, shaders, new AI
behavior tree, and broader lower-deck biome art replacement.

## Implementation Notes

- Story114 reuses the Factory Spark Rat character scene and SpriteFrames instead
  of adding new character art.
- `get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_diagnostics()`
  exposes deterministic scene/runtime assertions for tests and MCP eval.
- The route shell now extends the background, right wall, camera limit, floor
  visuals, and ground collision so the active enemy and player remain supported
  at the far-right combat pocket.
- Route objective priority now distinguishes `Runoff Outlet Service Sluice
  Crossed`, `Clear Service Sluice Spark Rat`, and `Service Sluice Spark Rat
  Cleared`.

## Asset Pipeline

No new visual or audio assets were generated. Story114 reuses the existing
image-generated Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset:

- Character scene: `scenes/characters/factory_spark_rat.tscn`
- Gameplay wrapper: `src/gameplay/factory_spark_rat.tscn`
- Script: `src/gameplay/factory_spark_rat.gd`
- SpriteFrames:
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Runtime transparent PNG frames:
  `assets/characters/factory_spark_rat/<animation>/factory_spark_rat_<animation>_*.png`

## Test Evidence

- Focused RED: `reports/report_1330/` failed before Story114 diagnostics, API,
  scene node, and activation state existed.
- Focused GREEN before physics hardening: `reports/report_1331/` passed `2/2`.
- Related GREEN before physics hardening: `reports/report_1332/` passed `12/12`
  across the Story109-114 runoff chain.
- MCP runtime probing found the old ground collision ended before the new combat
  pocket, causing the active enemy to fall below the route. The ground collision
  was extended and the focused test now asserts `ground_right_edge_x >= 11520`.
- Parse cleanup RED: `reports/report_1333/` captured a transient duplicate local
  variable while adding the ground-coverage diagnostic.
- Final focused GREEN: `reports/report_1334/` passed `2/2`.
- Final related GREEN: `reports/report_1335/` passed `12/12`.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_skirmish_smoke.log`
  exited `0`. The log contains Godot shutdown cleanup noise
  (`ObjectDB instances were leaked at exit`, `resources still in use at exit`)
  after the scene run.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed disk scene reload,
  hidden Spark Rat node, right wall/camera/background bounds, runtime helper
  live, activation at x `10920`, entity `2142`, target/process/physics enabled,
  expected SpriteFrames path and 3-frame animation counts, opening grace `12`,
  route labels, solid ground edge x `11700`, defeat/cleared persistence,
  no current game log errors, no new editor log rows after cursor `9`, and a
  non-empty game screenshot showing Cinderpaw and the Spark Rat in the service
  sluice combat pocket.

## Dependencies

- Depends on: Story113 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Runoff Outlet Service Sluice Traverse
- Unlocks: deeper Old Factory route content beyond the service sluice skirmish

## Verification Summary

Story114 followed thin TDD: focused RED `reports/report_1330/` failed before
runtime support existed, final focused GREEN `reports/report_1334/` passed
`2/2`, and final related GREEN `reports/report_1335/` passed `12/12`. Godot MCP
runtime validation passed under Godot 4.7 and Godot AI MCP 2.9.1, including the
AGENTS-required `AnimatedSprite2D + SpriteFrames` character checks and a live
physics-ground fix discovered during runtime validation.
