# Story 053: Old Factory Lower Deck Skirmish Cache

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

Stories049-052 complete the Old Factory checkpoint overdrive gate and its
reward feedback. This story adds an optional lower-deck side skirmish after the
overdrive duo is cleared. The side skirmish reuses the existing animated
Factory Spark Rat, briefly activates a local steam-pressure hazard, and unlocks
an independent image-generated gear cache without blocking the service lift.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckSparkRat`, `FactoryLowerDeckSteamVentHazard`, and
  `FactoryLowerDeckRewardCache`.
- [x] The lower-deck Spark Rat stays hidden, non-processing, and non-colliding
  until the checkpoint overdrive duo is cleared and Cinderpaw crosses the
  lower-deck activation boundary.
- [x] The lower-deck Spark Rat uses the existing Factory Spark Rat
  `AnimatedSprite2D + SpriteFrames` resource with at least 3 frames for
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`.
- [x] Activating the lower-deck skirmish changes the current route objective to
  `Clear Lower Deck Skirmish`, targets the player, and activates the lower-deck
  steam hazard.
- [x] While the optional lower-deck skirmish is active, the already-unlocked
  service lift remains available with prompt `Call lift`.
- [x] Defeating entity `2108` disables the lower-deck enemy and steam hazard,
  then makes the lower-deck cache visible and claimable.
- [x] The lower-deck cache grants deterministic `10` gears with source
  `old_factory_lower_deck_cache`, rejects duplicate claims, persists through
  `get_local_state()` / `set_local_state()`, and does not mutate the checkpoint
  overdrive reward cache state.
- [x] New visual cache asset is generated through image generation, imported
  through Godot, and recorded in the asset manifest and QA evidence.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass under Godot 4.7 with no new project script or resource
  errors.

## Out of Scope

New enemy artwork, new character frame generation, new SceneManager target,
global economy wiring, service-lift route changes, minimap updates, new audio,
new particles, shader animation, and new save-slot UI.

## Implementation Notes

- The story keeps shared gameplay code integrated in
  `src/gameplay/old_factory_entrance_scene.gd` because the side skirmish
  depends on existing Old Factory objective, hazard, service-lift, and cache
  contracts.
- The lower-deck encounter is optional content. It can temporarily surface as
  the current objective while active or just cleared, but it does not become a
  service-lift blocker.
- The visible enemy actor reuses
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
  The new image-generated asset is the reward cache prop only.

## Asset Pipeline

- New generated source:
  `assets/generated/source/old_factory_lower_deck_skirmish_cache_imagegen_20260701.png`.
- Alpha source:
  `assets/generated/source/old_factory_lower_deck_skirmish_cache_alpha_20260701.png`.
- Metadata:
  `assets/generated/source/old_factory_lower_deck_skirmish_cache_imagegen_20260701.json`.
- Runtime PNG:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
- Manifest row:
  `design/assets/asset-manifest.md`.

## Test Evidence

- Focused RED:
  - `reports/report_1029/` failed because the lower-deck skirmish API and scene
    wiring did not exist.
- Focused GREEN:
  - `reports/report_1031/` passed Story053 `2/2` with `0` errors, failures,
    flaky tests, skipped tests, or orphans on Godot
    `4.7.stable.official.5b4e0cb0f`.
- Related regression, headless smoke, and MCP runtime evidence:
  - `reports/report_1032/` passed `16/16` across Story053, overdrive reward
    cache, cache claim feedback, return patrol reward cache, overdrive duo,
    Factory route roundtrip, and service-lift SceneManager exit.
  - `reports/old_factory_lower_deck_skirmish_cache_factory_scene_smoke.log`
    exited `0`; keyword scan found no project script, parse, invalid-call,
    invalid-access, missing-resource, or resource-load errors in the log file.
    Godot still printed known cleanup-time ObjectDB/resource-at-exit noise to
    terminal.
  - Godot MCP 4.7 runtime evidence:
    `production/qa/evidence/old-factory-lower-deck-skirmish-cache-2026-07-01.md`.

**Status**: [x] Complete.
