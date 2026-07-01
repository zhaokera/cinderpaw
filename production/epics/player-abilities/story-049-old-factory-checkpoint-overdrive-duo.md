# Story 049: Old Factory Checkpoint Overdrive Duo

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat Pacing
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-01

## Context

Stories043-048 established the Old Factory return checkpoint, checkpoint
respawn, checkpoint-forward patrol, checkpoint steam vent, and rear ambush.
This story adds a final service-lift gate: a paired Spark Rat overdrive duo
that activates after the rear ambush is defeated and Cinderpaw pushes back
toward the service lift.

This intentionally advances Story048's route-completion semantics. Defeating
the rear ambush now hands off to the overdrive duo instead of immediately
unlocking final service-lift departure.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryCheckpointOverdriveSparkRatLeft` and
  `FactoryCheckpointOverdriveSparkRatRight`, both reusing the existing Factory
  Spark Rat `AnimatedSprite2D + SpriteFrames` gameplay wrapper.
- [x] The overdrive duo remains hidden, non-physics, non-processing, and
  non-colliding until the checkpoint rear ambush is defeated and the player
  crosses the final overdrive activation boundary.
- [x] Activating the duo makes both enemies visible, enables physics/process and
  collision layer/mask, binds Cinderpaw as their attack target, and exposes
  deterministic diagnostics with entity ids `2106` and `2107`.
- [x] While either overdrive Spark Rat remains uncleared, `FactoryServiceLift`
  is locked with prompt `Clear overdrive duo` and rejects exit requests with
  reason `overdrive_duo_active`.
- [x] Defeating only one Spark Rat persists that side's defeated state, hides
  and disables it, and keeps the service lift locked until the other Spark Rat
  is also defeated.
- [x] Defeating both Spark Rats persists the duo clear state, updates the route
  objective to `checkpoint_overdrive_duo_cleared`, restores service lift prompt
  `Call lift`, and allows the service lift to request `main / scrap_roost`.
- [x] Both overdrive enemies use existing Factory Spark Rat frame animations:
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`, each with three
  frames.
- [x] Focused and related Godot 4.7 headless tests pass, and Godot MCP 4.7
  confirms runtime node presence, animation frame contract, single-kill
  lockout, double-kill lift unlock, clean current MCP logs, and a non-empty
  game screenshot.

## Out of Scope

New enemy families, new visual asset generation, new rooms, minimap markers,
economy rewards, service-lift animation, new save schema, broader AI rewrites,
or a wider Old Factory route redesign.

## Implementation Notes

- Reuse `res://src/gameplay/factory_spark_rat.tscn` and its child
  `res://scenes/characters/factory_spark_rat.tscn`.
- Keep state scene-local through `get_local_state()` / `set_local_state()`:
  `factory_checkpoint_overdrive_duo_activated`,
  `factory_checkpoint_overdrive_left_defeated`,
  `factory_checkpoint_overdrive_right_defeated`, and
  `factory_checkpoint_overdrive_duo_cleared`.
- Treat the overdrive duo as a successor gate to Story048. Story048/047
  regression expectations were updated so the full service-lift route is
  complete only after both overdrive Spark Rats are defeated.
- Do not add new image generation assets for this slice; the existing Factory
  Spark Rat generated frame set already satisfies the character animation rules.

## Asset Pipeline

No new visual assets were generated. This story reuses:

- `res://src/gameplay/factory_spark_rat.tscn`
- `res://scenes/characters/factory_spark_rat.tscn`
- `res://src/characters/factory_spark_rat.gd`
- `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- `res://assets/characters/factory_spark_rat/<animation>/factory_spark_rat_<animation>_000.png`

The reused Factory Spark Rat frame set is transparent `96x96` RGBA PNG with
continuous frame names and three frames each for `idle`, `run`, `attack_tell`,
`attack`, `hurt`, and `death`.

## Test Evidence

- Focused RED:
  - `reports/report_1011/` failed before implementation because
    `get_factory_checkpoint_overdrive_duo_diagnostics()` did not exist.
- Focused GREEN:
  - `reports/report_1012/` passed Story049 focused tests `3/3` with `0`
    errors, failures, flaky tests, skipped tests, or orphans on Godot
    `4.7.stable.official.5b4e0cb0f`.
- Related regression:
  - `reports/report_1015/` passed `15/15` across Story049, Story048,
    Story047, Story046, and service-lift SceneManager exit suites.
  - `reports/report_1016/` passed `23/23` after adding return checkpoint and
    Factory route runtime roundtrip coverage.
  - Final pre-commit rerun `reports/report_1017/` passed the same targeted
    Story049 + adjacent Old Factory chain `23/23` with `0` errors, failures,
    flaky tests, skipped tests, or orphans.
- Headless and MCP evidence:
  - `reports/old_factory_checkpoint_overdrive_duo_smoke.log` exited `0`.
    Keyword scan found no `SCRIPT ERROR`, `Parse Error`, `FATAL`,
    `invalid call`, `invalid access`, `missing resource`, or `resource load`
    entries. The log retains only Godot cleanup-time resource warnings.
  - Godot MCP runtime evidence:
    `production/qa/evidence/old-factory-checkpoint-overdrive-duo-2026-07-01.md`.

**Status**: [x] Complete.
