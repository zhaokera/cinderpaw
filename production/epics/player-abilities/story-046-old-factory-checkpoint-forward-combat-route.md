# Story 046: Old Factory Checkpoint-Forward Combat Route

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat Pacing
> **Type**: Integration + Gameplay Runtime + Combat Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-scene-001`, `TR-scene-003`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system.

Stories040-045 established the Old Factory return loop, return patrol,
return-checkpoint respawn, and Factory-owned death integration. This story adds
the next checkpoint-forward combat beat: after Cinderpaw returns to and secures
the Factory checkpoint, a reused Spark Rat patrol blocks the service lift until
defeated.

## Acceptance Criteria

- [x] A new scene-local `FactoryCheckpointForwardSparkRat` exists in
  `factory_route_transition_shell.tscn` with deterministic entity id `2104`.
- [x] The checkpoint-forward patrol stays hidden and inactive until
  `FactoryReturnCheckpoint` is activated.
- [x] The patrol activates only after checkpoint activation and an in-range
  player/provider crossing the forward activation point.
- [x] Activated patrol binds Cinderpaw as target, enables processing/physics,
  remains visible, and reports `idle`, `run`, `attack_tell`, `attack`, `hurt`,
  and `death` animation frame counts of at least `3`.
- [x] While active, the patrol locks `FactoryServiceLift`, rejects exit with
  `forward_patrol_active`, and updates the prompt to `Clear forward patrol`.
- [x] Defeating entity `2104` persists
  `factory_checkpoint_forward_patrol_defeated`, hides the patrol, opens the
  route objective `checkpoint_forward_route_opened`, and restores the service
  lift prompt to `Call lift`.
- [x] Restoring uncleared local state brings the patrol back as an active
  checkpoint challenge; restoring cleared state keeps it defeated and hidden.
- [x] Focused and related Godot 4.7 headless tests pass, and Godot MCP 4.7
  confirms scene load, runtime nodes, animation frame counts, route lock/open,
  clean logs, and a non-empty game screenshot.

## Out of Scope

- New rooms, minimap markers, new enemy families, new visual/audio assets,
  service-lift animation, new save schema, or a broader Old Factory route
  redesign.

## Implementation Notes

- The story reuses the existing `FactorySparkRat` PackedScene and
  `factory_spark_rat_sprite_frames.tres` so the player-visible enemy remains an
  `AnimatedSprite2D + SpriteFrames` character rather than a block placeholder.
- `OldFactoryEntranceScene.apply_damage()` now synchronizes scene-level defeated
  state immediately when a scene-owned enemy reaches `0` HP. The existing enemy
  defeated signals remain connected; the synchronous check prevents runtime
  probes and real gameplay from depending on a deferred frame to unlock the
  route.
- Route objective priority now gives checkpoint-forward patrols precedence over
  the earlier return-patrol-cleared objective, keeping the HUD label aligned with
  the newest blocking combat beat.

## Asset Pipeline

No new visual assets were generated. This story reuses existing Spark Rat
character frame animation assets:

- `res://scenes/characters/factory_spark_rat.tscn`
- `res://src/characters/factory_spark_rat.gd`
- `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- `res://assets/characters/factory_spark_rat/idle/`
- `res://assets/characters/factory_spark_rat/run/`
- `res://assets/characters/factory_spark_rat/attack_tell/`
- `res://assets/characters/factory_spark_rat/attack/`
- `res://assets/characters/factory_spark_rat/hurt/`
- `res://assets/characters/factory_spark_rat/death/`

## Test Evidence

- Focused RED:
  - `reports/report_976/` failed on missing
    `get_factory_checkpoint_forward_patrol_diagnostics()` before implementation.
- Focused GREEN:
  - `reports/report_981/` passed Story046 focused tests `4/4` with `0` errors,
    failures, flaky tests, skipped tests, or orphans on Godot
    `4.7.stable.official.5b4e0cb0f`.
- Related regression:
  - `reports/report_984/` passed `24/24` across Story046, Old Factory return
    checkpoint, return patrol, service-lift SceneManager exit, Factory runtime
    roundtrip, player respawn visual feedback, and savepoint selection suites.
  - The stdout copy retained the known Godot cleanup-time ObjectDB/resource
    warnings at process exit.
- Headless and MCP evidence:
  - `reports/old_factory_checkpoint_forward_combat_factory_scene_smoke.log`
    exited `0`. Keyword scan found no script, parse, invalid-call,
    invalid-access, missing-resource, or resource-load errors; only the known
    cleanup-time resource warning remained at process exit.
  - Godot MCP runtime evidence:
    `production/qa/evidence/old-factory-checkpoint-forward-combat-route-2026-06-30.md`.

**Status**: [x] Complete.
