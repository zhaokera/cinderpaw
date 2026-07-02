# Story 054: Old Factory Lower Deck Parry-Laser Ambush Gate

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Optional Combat
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-01

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/combat-presentation.md`

**Requirements**: `TR-ability-005`, `TR-scene-003`, `TR-scene-005`

**ADR Governing Implementation**: ADR-0004 Collision Detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story053 adds an optional lower-deck skirmish and reward cache after the Old
Factory checkpoint overdrive route. This story adds a player-visible parry
payoff immediately after claiming that lower-deck cache: a Parry Laser gate
blocks the lower-deck exit until Cinderpaw activates `parry`, then opens and
triggers a reused animated Factory Spark Rat exit ambush.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckParryLaserGate` and `FactoryLowerDeckExitSparkRat`.
- [x] The lower-deck parry gate stays unavailable until the lower-deck cache is
  claimed, then becomes visible, `unlockable`, and collision-blocking.
- [x] Activating Cinderpaw's `parry` in range unlocks the gate, disables its
  collision, persists `factory_lower_deck_parry_gate_unlocked`, and triggers the
  lower-deck exit ambush.
- [x] The exit ambush uses entity id `2109`, targets the player, and exposes
  deterministic diagnostics through
  `get_factory_lower_deck_exit_ambush_diagnostics()`.
- [x] The exit Spark Rat uses the existing Factory Spark Rat
  `AnimatedSprite2D + SpriteFrames` resource with at least 3 frames for
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`.
- [x] While the optional exit ambush is active, the already-unlocked service
  lift remains available with prompt `Call lift`.
- [x] Defeating entity `2109` hides/disables the enemy, persists
  `factory_lower_deck_exit_ambush_defeated`, and updates the route objective to
  `Lower Deck Exit Cleared`.
- [x] Scene-local state restores the unlocked gate and defeated ambush without
  reactivating the enemy or relocking the gate.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass under Godot 4.7 with no new project script or resource
  errors.

## Out of Scope

New enemy artwork, new character frame generation, new reward cache assets, new
audio, new particles, global quest/objective manager changes, minimap updates,
service-lift route changes, and SaveSystem schema changes.

## Implementation Notes

- The story reuses the existing `ExplorationGate` runtime for the lower-deck
  Parry Laser gate instead of introducing a new gate implementation.
- The gate is positioned left of the active checkpoint steam vent collision
  zone so parry activation does not immediately cause hazard damage or overwrite
  the route objective with hazard feedback.
- The lower-deck exit ambush is optional content. It can become the current
  route objective while active or just cleared, but it does not become a
  service-lift blocker.
- The visible enemy actor reuses
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.

## Asset Pipeline

No new visual assets were generated for this story. The slice reuses:

- Parry gate texture:
  `res://assets/environment/parry_laser_gate/parry_laser_gate_marker.png`.
- Factory Spark Rat SpriteFrames:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.

## Test Evidence

- Focused RED:
  - `reports/report_1034/` failed because the lower-deck parry gate and exit
    ambush diagnostics did not exist yet.
- Focused GREEN:
  - `reports/report_1037/` passed Story054 `1/1` with `0` errors, failures,
    flaky tests, skipped tests, or orphans on Godot
    `4.7.stable.official.5b4e0cb0f`.
- Related regression, headless smoke, and MCP runtime evidence:
  - `reports/report_1038/` passed `12/12` across Story054, Story053 lower-deck
    cache, checkpoint overdrive duo, overdrive reward cache, service-lift
    SceneManager exit, and Factory route roundtrip.
  - `reports/old_factory_lower_deck_exit_ambush_smoke.log` exited `0`;
    keyword scan found no project script, parse, invalid-call, invalid-access,
    missing-resource, or resource-load errors in the log file. Godot still
    printed known cleanup-time ObjectDB/resource-at-exit noise to terminal.
  - Godot MCP 4.7 runtime evidence:
    `production/qa/evidence/old-factory-lower-deck-parry-laser-ambush-gate-2026-07-01.md`.

**Status**: [x] Complete.
