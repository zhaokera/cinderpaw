# Story 111: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Skirmish

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

Story110 leaves the player at the crossed overflow pump runoff outlet. Story111
adds the next forward pressure beat: a reused animated Factory Spark Rat wakes
up beyond the outlet, forcing a short skirmish before the deeper route can be
treated as secure.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletSparkRat`
  exists in `factory_route_transition_shell.tscn`, starts hidden, and is placed
  at x `9340` inside the right wall x `9580` / camera limit `9600` route bounds.
- [x] The skirmish stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed=true`;
  locked diagnostics report unavailable/hidden and activation returns `false`.
- [x] Crossing activation x `9280` starts the skirmish, reveals the Spark Rat,
  assigns the player target, enables process/physics, and advances route
  feedback to `Clear Runoff Outlet Spark Rat`.
- [x] The enemy uses the existing `FactorySparkRat` scene/script family with
  entity id `2141`.
- [x] The visible enemy uses `AnimatedSprite2D + SpriteFrames`; `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` each have at least `3` frames.
- [x] The opening grace pacing for this encounter is `12` frames and exposes
  deterministic diagnostics for test and MCP probes.
- [x] Defeating entity `2141` hides/disables the Spark Rat, persists activated,
  defeated, and cleared state, and advances route feedback to
  `Runoff Outlet Spark Rat Cleared`.
- [x] Restoring the cleared state backfills the Story106/107/108/109/110 runoff
  chain so prior cache, gate, duct, exit skirmish, reward cache, and outlet
  traverse states do not replay.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1.

## Out of Scope

New generated character art, new reward cache, new savepoint, minimap, fast
travel, authored audio, particles/shaders, Boss2, SaveSystem schema changes,
and broader lower-deck art replacement.

## Implementation Notes

- The slice intentionally reuses the existing Factory Spark Rat instead of
  generating a new enemy asset, because the project already has compliant
  transparent PNG frame animation for this enemy family.
- `set_local_state` restores Story111 activated/defeated/cleared flags and
  backfills the Story106-110 runoff route chain when Story111 is restored.
- Route objective priority places Story111 active and cleared states before
  Story110 crossed and Story109 gate-opened handoff states.
- During implementation, a local route-label regression was traced to
  `set_local_state` objective refresh being incorrectly nested under an older
  outlet-clamp branch. The fix restored the objective refresh to the common
  restore path.

## Asset Pipeline

No new visual asset was generated for Story111.

Reused imported character animation asset:

- Spark Rat SpriteFrames:
  `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Source frame folders:
  `assets/characters/factory_spark_rat/idle/`,
  `assets/characters/factory_spark_rat/run/`,
  `assets/characters/factory_spark_rat/attack_tell/`,
  `assets/characters/factory_spark_rat/attack/`,
  `assets/characters/factory_spark_rat/hurt/`,
  `assets/characters/factory_spark_rat/death/`

All reused frames are already imported through the Godot asset pipeline and are
bound through `AnimatedSprite2D + SpriteFrames`.

## Test Evidence

- Focused RED: `reports/report_1300/` failed because Story111 diagnostics and
  activation APIs did not exist yet.
- Focused GREEN: `reports/report_1309/` passed `2/2`.
- Related GREEN: `reports/report_1310/` passed `8/8` across Story111, Story110,
  Story109, and Story108.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_skirmish_smoke.log` exited
  `0`.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed disk scene reload,
  edited scene target node, `AnimatedSprite2D` SpriteFrames binding, right wall
  x `9580`, camera limit right `9600`, runtime helper live,
  `current_run_errors=[]`, runtime Story111 activation diagnostics, six target
  animations at `3` frames each, and a non-empty `960x539` game screenshot with
  the Spark Rat visible in the target pocket.

## Dependencies

- Depends on: Story110 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Runoff Outlet Traverse
- Unlocks: deeper Old Factory route combat/content after the runoff outlet
  skirmish

## Verification Summary

Story111 followed thin TDD: focused RED `reports/report_1300/` failed before
runtime support existed, focused GREEN `reports/report_1309/` passed `2/2`, and
related GREEN `reports/report_1310/` passed `8/8`. Headless smoke exited `0`.
Godot MCP runtime validation passed under Godot 4.7 and Godot AI MCP 2.9.1.
