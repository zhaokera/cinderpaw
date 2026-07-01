# Story 048: Old Factory Checkpoint Rear Ambush

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat Pacing
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-01

## Context

Stories043-047 established the Old Factory return checkpoint, checkpoint
respawn, checkpoint-forward Spark Rat gate, and checkpoint steam vent gauntlet.
This story extends that route-open state with one more player-visible ACT
pressure beat: a rear Spark Rat ambush after the vent gauntlet, before Cinderpaw
can call the service lift.

This intentionally advances the Story046/047 route-open semantics. Defeating
the checkpoint-forward patrol still opens the next beat and activates the vent,
but the final service-lift route is now complete only after the rear ambush is
cleared.

Story049 supersedes the final lift-unlock handoff after this story. The rear
ambush now hands off to the checkpoint overdrive duo; the final service-lift
route is complete only after both overdrive Spark Rats are defeated.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryCheckpointRearSparkRat`, reusing the existing Factory Spark Rat
  `AnimatedSprite2D + SpriteFrames` gameplay wrapper.
- [x] The rear ambush remains hidden, non-physics, non-processing, and
  non-colliding until the checkpoint-forward patrol is defeated and the player
  crosses the post-vent activation boundary.
- [x] Activating the rear ambush makes it visible, enables physics/process and
  collision layer/mask, binds Cinderpaw as its attack target, and exposes
  deterministic diagnostics with entity id `2105`.
- [x] While the rear ambush is active or uncleared after the forward patrol,
  `FactoryServiceLift` is locked with prompt `Clear rear ambush` and rejects
  exit requests with reason `rear_ambush_active`.
- [x] Defeating the rear ambush hides and disables the enemy, persists
  `factory_checkpoint_rear_ambush_defeated`, updates the route label to
  `Vent Gauntlet Cleared`, and restores service lift prompt `Call lift`.
- [x] The rear ambush uses existing Factory Spark Rat frame animations:
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`, each with at
  least three frames.
- [x] Focused and related Godot 4.7 headless tests pass, and Godot MCP 4.7
  confirms runtime node presence, animation frame contract, state transition,
  clean current game logs, no new editor errors after stale cursor, and a
  non-empty game screenshot.

## Out of Scope

New enemy families, new visual asset generation, new rooms, minimap markers,
economy rewards, service-lift animation, new save schema, complex AI rewrites,
or broader Old Factory route redesign.

## Implementation Notes

- Reuse `res://src/gameplay/factory_spark_rat.tscn` and its child
  `res://scenes/characters/factory_spark_rat.tscn`.
- Keep state scene-local through `get_local_state()` / `set_local_state()`.
- Treat the rear ambush as a successor gate to Story046/047. Story046/047 tests
  were updated so the full service-lift route is considered open only after the
  rear ambush has been defeated.
- Do not add new image generation assets for this slice; the existing Spark Rat
  generated frame set already satisfies the character animation rules.

## Asset Pipeline

No new visual assets were generated. This story reuses:

- `res://src/gameplay/factory_spark_rat.tscn`
- `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- `res://assets/characters/factory_spark_rat/<animation>/factory_spark_rat_<animation>_000.png`

The reused Factory Spark Rat frame set is transparent `96x96` RGBA PNG with
continuous frame names and three frames each for `idle`, `run`, `attack_tell`,
`attack`, `hurt`, and `death`.

## Test Evidence

- Focused RED:
  - `reports/report_1006/` failed before implementation because
    `get_factory_checkpoint_rear_ambush_diagnostics()` and the rear ambush node
    did not exist.
- Focused GREEN:
  - `reports/report_1007/` passed Story048 focused tests `3/3` with `0` errors,
    failures, flaky tests, skipped tests, or orphans on Godot
    `4.7.stable.official.5b4e0cb0f`.
- Related regression:
  - `reports/report_1009/` passed `20/20` across Story048, Story047, Story046,
    return checkpoint, service-lift SceneManager exit, and Factory route
    roundtrip suites.
- Headless and MCP evidence:
  - `reports/old_factory_checkpoint_rear_ambush_smoke.log` exited `0`.
    Keyword scan found no `SCRIPT ERROR`, `Parse Error`, `FATAL`,
    `invalid call`, `invalid access`, `missing resource`, or `resource load`
    entries. The log contains Godot cleanup-time ObjectDB/resource warnings.
  - Godot MCP runtime evidence:
    `production/qa/evidence/old-factory-checkpoint-rear-ambush-2026-06-30.md`.

**Status**: [x] Complete.
