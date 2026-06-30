# Story 047: Old Factory Checkpoint Steam Vent Gauntlet

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Hazard Pacing
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

Stories043-046 established the Old Factory return checkpoint, checkpoint
respawn, Factory-owned death integration, and checkpoint-forward Spark Rat gate.
This story adds a checkpoint-adjacent steam vent hazard gauntlet after the
forward patrol is cleared, turning the opened route into a visible ACT hazard
beat instead of only a state transition.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryCheckpointSteamVentHazard` as a scene-authored `Area2D` using the
  existing steam vent image-generated texture.
- [x] The checkpoint steam vent is hidden, non-monitoring, non-colliding, and
  collision-shape disabled until the checkpoint-forward patrol is defeated.
- [x] Defeating the checkpoint-forward patrol activates the vent with
  environment collision layer/mask, visible art, `damage=8`, and
  `contact_cooldown_sec=1.0`.
- [x] The vent uses hazard id `old_factory_checkpoint_steam_vent`, applies
  contact damage to Cinderpaw, and respects the existing per-target cooldown.
- [x] Return-checkpoint respawns receive a short hazard grace/cooldown window so
  the activated vent does not immediately overwrite checkpoint respawn state.
- [x] SceneManager return-checkpoint handoff keeps Cinderpaw snapped to the
  repair savepoint during the brief respawn window, then restores player physics.
- [x] Opening the route and activating the checkpoint steam vent does not relock
  the service lift after the checkpoint-forward patrol is defeated.
- [x] Focused and related Godot 4.7 headless tests pass, and Godot MCP 4.7
  confirms runtime node presence, activation properties, player
  `AnimatedSprite2D + SpriteFrames`, and a non-empty game screenshot.

## Out of Scope

New rooms, new enemy families, new art generation, minimap markers, broader
level redesign, new save schema, new audio cues, or service-lift animation.

## Implementation Notes

- The story reuses `FactorySteamVentHazard` and
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
  instead of generating new art.
- `OldFactoryEntranceScene` now treats steam hazards as a small collection, so
  the original entrance vent and checkpoint vent share overlap, cooldown,
  diagnostics, and contact damage logic.
- The checkpoint vent is synced from
  `factory_checkpoint_forward_patrol_defeated`, keeping the hazard tied to a
  concrete gameplay state.
- Return-checkpoint SceneManager handoff briefly pins player physics and snaps
  position to the checkpoint to avoid first-frame gravity/collision drift during
  respawn.
- Godot 4.7 GdUnit teardown attempted to parse `main.tscn`; optional generated
  combat VFX textures and Rat King component scripts now load at runtime rather
  than parse-time preload so focused story runs do not end with stale
  preload/parse errors after the test suite has completed.

## Asset Pipeline

No new visual assets were generated. This story reuses the existing
image-generated steam vent hazard asset:

- `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`

The player-visible characters in the route remain authored
`AnimatedSprite2D + SpriteFrames` assets.

## Test Evidence

- Focused RED:
  - `reports/report_985/` failed on missing
    `FactoryCheckpointSteamVentHazard` before implementation.
- Focused GREEN:
  - `reports/report_991/` passed Story047 focused tests `3/3` with `0` errors,
    failures, flaky tests, skipped tests, or orphans on Godot
    `4.7.stable.official.5b4e0cb0f`.
- Related regression:
  - `reports/report_1002/` passed `21/21` across Story047, checkpoint-forward
    patrol, original steam vent hazard, service-lift SceneManager exit, return
    checkpoint respawn, and Factory runtime roundtrip suites.
- Headless and MCP evidence:
  - `reports/old_factory_checkpoint_steam_vent_gauntlet_smoke.log` exited `0`.
    Keyword scan found no `ERROR`, `SCRIPT ERROR`, `Parse Error`, `FATAL`, or
    `WARNING` entries in the log file.
  - Validation cleanup regression `reports/report_1005/` passed `40/40` across
    Story047 focused tests, `combat_presentation_test.gd`, and
    `rat_king_boss_runtime_contract_test.gd`; stdout retained only the known
    cleanup-time ObjectDB/resource messages.
  - Godot MCP runtime evidence:
    `production/qa/evidence/old-factory-checkpoint-steam-vent-gauntlet-2026-06-30.md`.

**Status**: [x] Complete.
