# Story 099: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Skirmish

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Enemy Encounter
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

Story098 crosses the aftershock condenser outlet drip vent. Story099 extends the
route into the next visible runoff pocket: a newly generated transparent
overflow pump prop anchors the space, and a reused image-generated Factory Coil
Rat frame-animated enemy creates a short ACT skirmish before the route continues.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPump` exists in
  `factory_route_transition_shell.tscn`, starts hidden, uses the new
  transparent `768x320` overflow pump PNG, and extends the playable route to x
  `7040.0`.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpCoilRat`
  exists in the same scene, starts hidden/inactive, reuses
  `factory_coil_rat_sprite_frames.tres`, and binds entity id `2139` with family
  id `factory_coil_rat`.
- [x] The skirmish stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_crossed=true`;
  locked activation returns `false`, the prop is hidden, and the Coil Rat has no
  target/process/physics.
- [x] Once Story098 is crossed, diagnostics expose availability, prop
  visibility, generated texture path, route width `7040`, right wall x `7020`,
  camera limit `7040`, activation x `6540`, and route label
  `Outlet Drip Vent Crossed`.
- [x] Activating at the overflow pump pocket advances route feedback to
  `Clear Overflow Pump Skirmish`, shows the Coil Rat, assigns the player target,
  enables process/physics/collision, and starts `10` opening-grace frames.
- [x] Production auto-activation requires Story099 to be available at frame
  start, held `move_right`, and fresh positive x movement at/after x `6540`;
  Story098's crossing frame and stationary/no-input displacement cannot start
  entity `2139`.
- [x] The reused Factory Coil Rat remains a proper frame-animated character:
  `AnimatedSprite2D + SpriteFrames` with at least 3 frames each for `idle`,
  `run`, `attack_tell`, `attack`, `hurt`, and `death`.
- [x] Defeating entity `2139` persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated=true`,
  `..._coil_rat_defeated=true`, and `..._cleared=true`; immediately disables
  the Coil Rat's physics, collision, target and damage while preserving its
  authored three-frame death presentation; keeps the generated prop visible;
  and advances feedback to `Overflow Pump Cleared`.
- [x] The Coil Rat renders at z `24`, in front of the overlapping pump at z
  `22` and behind the player at z `26`.
- [x] Restoring cleared local state keeps Story095, Story096, Story097, and
  Story098 intact without replaying them; the service lift prompt remains
  `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4, including scene reload, runtime helper,
  generated prop, frame-animated Coil Rat diagnostics, production activation
  isolation, z-order, clean current-run logs, and a non-empty screenshot.

## Out of Scope

New enemy family, new character animation art, new AI behavior, reward cache,
savepoint, minimap, fast travel, authored audio, particles/shaders, Boss2,
SaveSystem schema changes, and broader lower-deck art replacement.

## Implementation Notes

- Activation is gated by
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_crossed`.
- Route geometry extends the factory shell from x `6400.0` to x `7040.0`.
- The overflow pump sits at x `6680.0`; the Coil Rat starts at x `6668.0`.
- Production auto-activation snapshots availability and player x at frame
  start, then requires held `move_right` plus positive x movement. Direct API
  activation remains unchanged for fixtures and explicit callers.
- The Coil Rat uses z `24`; death keeps render/process alive for the shared
  RatMinion death animation while combat and physics are already disabled.
- `set_local_state` now accepts a few historical defeated/cleared aliases for
  this long Old Factory route chain so restored state does not get stuck on old
  objective names when older evidence fixtures are replayed.

## Asset Pipeline

New image-generated runtime prop:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_overflow_pump_imagegen_20260709.png`
- Alpha source:
  `assets/generated/source/old_factory_aftershock_condenser_overflow_pump_alpha_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_overflow_pump_imagegen_20260709.json`
- Runtime:
  `assets/environment/old_factory_aftershock_condenser_overflow_pump/env_old_factory_aftershock_condenser_overflow_pump_768.png`

The enemy reuses the imported image-generated Factory Coil Rat character at
`assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`.

## Test Evidence

- Focused RED: `reports/report_1250/` failed because the Story099 API and
  diagnostics did not exist yet.
- Focused GREEN: `reports/report_1252/` passed `2/2`.
- Related GREEN: `reports/report_1253/` passed `10/10` covering Story099 and
  the Story095-098 condenser chain.
- Headless smoke:
  `reports/old_factory_aftershock_condenser_overflow_pump_skirmish_smoke.log`
  exited `0`; keyword scan found no project script/parse/invalid-call/access,
  missing-resource/resource-load, flushing-query, or in/out-signal state-change
  errors. Godot emitted only existing shutdown resource cleanup noise.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed scene reload from disk,
  plugin/server version `2.9.1`, runtime helper live, prop and Coil Rat nodes
  present, generated prop texture path, camera/right-wall route extension,
  locked and ready diagnostics, activation range semantics, frame animation
  counts, opening-grace pacing, entity `2139` defeat persistence, clean current
  run game/editor logs after cursor `9`, and a non-empty `960x539` screenshot
  showing the generated overflow pump prop.
- Story218 production handoff:
  `reports/report_2327/report_1/results.xml` passed the canonical real-movement
  and overlap path `1/1`; `reports/report_2329/report_1/results.xml` passed the
  bounded Story217/098/099/218 regression `6/6`. Godot AI MCP `3.0.4` run
  `r156727664-15` proved no-input x `6536 -> 6544` stayed inactive, then fresh
  `move_right` plus positive x activated entity `2139` with target,
  process/physics, `10` grace frames and z `24` in front of the pump.
- Story219 production combat/reward handoff:
  canonical RED `reports/report_2331/results.xml` isolated the missing
  production cache route; final related `reports/report_2334/results.xml`
  passed `7/7`. MCP 3.0.4 run `r158132331-16` used real movement and a real
  `cat_claw_light` lethal hit, preserved visible/process `death`, and exposed
  Story106's unclaimed `+20 Gears` cache.

## Dependencies

- Depends on: Story098 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Outlet Drip Vent Traverse
- Unlocks: deeper Old Factory route content after the overflow pump skirmish

## Verification Summary

Story099 followed thin TDD: focused RED `reports/report_1250/` failed before
runtime support existed, focused GREEN `reports/report_1252/` passed `2/2`, and
related GREEN `reports/report_1253/` passed `10/10`. Story218 added REDs for
stale/no-input activation and z-order, then current MCP 3.0.4 production proof
with final focused `1/1` and bounded related `6/6`. Headless smoke exited `0`.
The original MCP 2.9.1 evidence remains historical; current acceptance uses
Godot 4.7 and Godot AI MCP 3.0.4.

Story219 additionally proves the production combat and live-death path through
to Story106 reward availability without changing Story099's values or assets.
