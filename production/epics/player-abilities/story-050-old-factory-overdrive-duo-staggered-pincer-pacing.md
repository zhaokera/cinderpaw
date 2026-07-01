# Story 050: Old Factory Overdrive Duo Staggered Pincer Pacing

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat Pacing
> **Type**: Logic + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-01

## Context

Story049 added a final paired Spark Rat gate before the Old Factory service
lift, but both rats used the same opening grace timing. That made the pair
functionally correct but flatter than an ACT pincer beat: both threats woke up
in lockstep.

This story keeps the same enemies, assets, route gate, and service-lift
semantics, but changes the overdrive duo to use staggered timing. The left Spark
Rat starts pressure after a shorter grace window, while the right Spark Rat
delays to create a readable second threat.

## Acceptance Criteria

- [x] Activating the overdrive duo starts the left Spark Rat with `12` opening
  grace frames and the right Spark Rat with `30` opening grace frames.
- [x] Runtime diagnostics expose the configured per-rat grace totals and
  remaining frames instead of reporting a single misleading shared value.
- [x] `advance_factory_checkpoint_overdrive_duo_pacing_frames()` advances both
  active, undefeated overdrive rats deterministically for tests and MCP probes.
- [x] After advancing past the left grace window with Cinderpaw in left melee
  range, the left rat enters `attack_tell` with animation `attack_tell`, while
  the right rat remains in `opening_grace` with no active attack.
- [x] Scene-local state preserves independent left/right overdrive grace frames
  so runtime scene restore does not collapse the stagger back into synchronized
  timing.
- [x] Story049 behavior remains intact: rear ambush gates activation, service
  lift stays locked while either rat is uncleared, single kill does not unlock,
  double kill unlocks service-lift departure to `main / scrap_roost`, and both
  rats keep their `AnimatedSprite2D + SpriteFrames` contract.
- [x] Focused and related Godot 4.7 tests pass, and Godot MCP 4.7 confirms the
  staggered runtime state, animation frame contract, non-empty screenshot, and
  clean current logs.

## Out of Scope

New enemies, new visual assets, new animation states, new SFX, new rooms, new
service-lift behavior, reward/cache changes, minimap, save schema changes, or a
broader Old Factory encounter redesign.

## Implementation Notes

- Keep this as a pacing change inside the existing Factory route scene and
  `FactorySparkRat` behavior.
- Preserve `FactorySparkRat.begin_pacing(opening_grace_frames)` as the shared
  hook, but make diagnostics report the configured total for the current pacing
  instance.
- Keep the left-first/right-delayed split explicit for this story:
  `12` frames left, `30` frames right.
- Continue storing the old aggregate
  `factory_checkpoint_overdrive_duo_opening_grace_frames` for compatibility,
  but use new left/right state fields for current restore behavior.

## Asset Pipeline

No new visual assets were generated. This story only changes runtime pacing and
diagnostics. It reuses the existing image-generated Factory Spark Rat frame set:

- `res://src/gameplay/factory_spark_rat.tscn`
- `res://scenes/characters/factory_spark_rat.tscn`
- `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- `res://assets/characters/factory_spark_rat/{idle,run,attack_tell,attack,hurt,death}/`

Both overdrive rats remain `AnimatedSprite2D + SpriteFrames` instances, and each
required animation has three frames.

## Test Evidence

- Focused RED:
  - `reports/report_1018/` failed on the new acceptance test because
    `advance_factory_checkpoint_overdrive_duo_pacing_frames()` did not exist.
- Focused GREEN:
  - `reports/report_1019/` passed Story049/050 overdrive duo focused tests
    `4/4` with `0` errors, failures, flaky tests, skipped tests, or orphans.
- Related regression:
  - `reports/report_1021/` passed `14/14` across overdrive duo, Spark Rat
    pacing polish, rear ambush handoff, and service-lift SceneManager exit
    suites with `0` errors, failures, flaky tests, skipped tests, or orphans.
- MCP evidence:
  - Godot MCP 4.7 launched
    `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`.
  - Runtime diagnostics confirmed activation pacing left `12` / right `30`,
    aggregate total `30`, left entering `attack_tell` after the short window,
    right remaining `opening_grace`, independent local-state grace values,
    existing Spark Rat SpriteFrames path, and all required animation frame
    counts at `3`.
  - MCP screenshot returned PNG metadata `640x359`.
  - Reading `godot://logs/recent` after clearing logs returned only MCP/plugin
    `info` rows, with no current `error` or `warning` rows.

**Status**: [x] Complete.
