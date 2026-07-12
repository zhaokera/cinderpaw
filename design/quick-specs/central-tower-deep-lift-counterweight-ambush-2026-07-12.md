# Quick Design Spec: Central Tower Deep Lift Counterweight Ambush

> **Status**: Approved for bounded implementation
> **Story**: 143
> **Date**: 2026-07-12

## Problem

Story142 gives the Central Tower a fair recovery point and a generated movement
route, then stops at the Deep Lift beacon. The next slice needs an ACT payoff
that changes the player's motion and returns to readable enemy combat. Boss4,
its arena, reward, phases, music, and narrative remain undefined.

## Decision

Extend `area_05_central_tower` from three to four `1280x720` viewports. The
fourth viewport is one vertical moving-platform ambush:

1. `central_tower_cooling_shaft_traversed=true` unlocks the lower lift dock.
   The optional Story141 cache never gates progression.
2. Cinderpaw boards an `AnimatableBody2D` lift and uses `interact` while standing
   on it. A short startup closes the entry and upper shutters.
3. The platform rises to a mid-shaft lock stop and deploys one ordinary,
   frame-animated `central_tower_counterweight_sentry`.
4. Defeating entity `2703` releases the lock stop. The platform rises to the
   upper landing, opens the upper shutter, and exposes one bounded endpoint.
5. Reaching the endpoint persists `central_tower_deep_lift_ascended=true` and
   reports `Deep Lift Secured`; no scene switch or Boss encounter is implied.

The controller is slice-local. It uses Godot 4.7's physics-synchronized
`AnimatableBody2D` and the existing CharacterBody2D platform contract rather
than changing PlayerController or adding a shared moving-platform framework.

## Stable Contract

| Contract | Value |
|----------|-------|
| Scene id / path | `area_05_central_tower` / `res://scenes/areas/central_tower_threshold.tscn` |
| Expanded scene size | `5120x720` |
| Route prerequisite | `central_tower_cooling_shaft_traversed` |
| Controller | `CentralTowerDeepLiftController` |
| Encounter | `central_tower_deep_lift_counterweight_ambush` |
| Sentry entity / config | `2703` / `central_tower_counterweight_sentry` |
| Sentry clear | `central_tower_counterweight_sentry_defeated` |
| Endpoint | `central_tower_deep_lift_upper_endpoint` |
| Durable completion | `central_tower_deep_lift_ascended` |
| Sentry tuning | `44 HP`, `24/5/24` frames, `12` damage, `120px/s` ram |

## Authored Geometry

- Fourth background center: `(4480,360)`.
- Lower dock floor: x `3840..4170`, surface y `576`.
- Lift platform: center x `4380`, size `420x28`, lower/mid/top center y
  `590/450/290`; its top aligns to y `576/436/276`.
- Open shaft and lethal fall: x `4170..4590`; fall-zone center `(4380,680)`.
- Upper landing: x `4590..5120`, surface y `276`.
- Entry shutter x `4130`; upper shutter x `4630`; endpoint `(4980,252)`.
- Camera/right/top bounds become `5120`, x `5140`, and width `5120` centered
  at x `2560`. Story140-142 authored nodes and local geometry remain unchanged.

## Lift And Combat Timing

- Startup interlock: `0.60s`.
- Lower-to-lock-stop travel: `140px` at `100px/s`.
- Sentry deploy grace before AI activation: `0.75s`.
- Defeat presentation linger: `0.45s`.
- Lock-stop-to-upper travel: `160px` at `112px/s`.
- The generated warning sweep is presentation only, never taller than `128px`,
  and cannot cover the platform top or the player's core silhouette.
- Sentry attack values are sourced from `enemy_stats.json`; its ram uses the
  shared Health/Collision/Combat/StatusEffect path and duplicate-hit guard.

## Death, Retry, And Persistence

- Lift startup, platform phase, elapsed time, current docking, living-enemy HP,
  and shutters are attempt-local and are not serialized.
- Before Sentry defeat, lethal damage uses the existing Tower `1.5s` death
  delay and Cooling Roost `(2740,552)` revive at 50% HP with 120 i-frames. The
  platform returns to the lower dock, shutters open, and the Sentry returns to
  full HP at its authored deployment position.
- Sentry defeat is durable, including defeat during the player's death window.
  On retry or fresh restore, the platform still starts at the lower dock and can
  be ridden directly to the upper landing without replaying the enemy.
- Endpoint completion is durable. Fresh restore rehydrates Story140-143 state,
  resets feedback counters, preserves exact abilities, and keeps the lower lift
  callable so a Cooling Roost respawn can never be soft-locked below it.

## Visual Direction

- Fourth viewport: asymmetrical vertical counterweight bay, short safe lower
  dock, deep central shaft, narrow high-right landing, visible cables and depth.
- Dark steel-blue and black iron dominate. Cyan communicates lift machinery;
  restrained amber marks safe controls. Signal red appears only in interlock
  warning and Sentry attack frames.
- Counterweight Sentry: compact top-heavy trapezoid body, hanging ballast,
  short clawed legs, and one telescoping ram. It must not read as the square
  Threshold Guard, tall Mantis, a rat, or a Boss.
- Character runtime art uses `AnimatedSprite2D + SpriteFrames`; `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` each contain exactly three
  transparent `96x96` frames with bottom-center anchor `(48,88)`. This retains
  the established Tower-enemy readability exception to the Art Bible's older
  `64x64` ordinary-character budget.

## Out Of Scope

- Boss4 identity, data, arena, phases, reward, music, narrative, or ending.
- New scene id/handoff, new savepoint, ability, reward cache, NPC, dialogue,
  minimap, fast travel, secret room, or generalized moving-platform framework.
- Shared PlayerController, GameFlow, SaveSystem, SceneManager, Ability,
  Collision, Combat, or animation-resource refactors.
- Rebalancing or replaying Story139-142 gameplay during target verification.

## Verification Budget

- One three-case focused RED/GREEN suite with a real physics carry assertion.
- Story141 and Story142 adjacent regression only; no full suite.
- One target headless smoke starting from Story142 completion.
- One final Godot MCP run with real `interact`, platform carry, combat input,
  live Sentry animation, endpoint, non-empty screenshot, and current-run logs.
