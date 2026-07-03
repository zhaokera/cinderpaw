# Story 073: Old Factory Lower Deck Forward Pressure Exit Guard

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat Route
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-03

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0004 Collision architecture; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Story071/072 make the forward-pressure reward cache a visible, audible payoff
after the counter-ambush. This story turns that payoff into a route commitment:
after the cache is claimed, crossing the next boundary starts a short exit guard
fight with an animated Factory Spark Rat and a reused steam vent hazard. The
slice stays scene-local and keeps the service lift optional.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureExitGuardSparkRat` and
  `FactoryLowerDeckForwardPressureExitGuardVent`, both hidden, non-processing,
  non-physics, and non-contacting before
  `factory_lower_deck_forward_pressure_reward_cache_claimed=true`.
- [x] Crossing the Story073 activation boundary after the Story071 reward cache
  is claimed activates entity `2120`, assigns Cinderpaw as target, starts Spark
  Rat pacing, enables the exit pressure vent, and updates route feedback to
  `Clear Forward Pressure Exit Guard`.
- [x] The visible enemy uses `AnimatedSprite2D + SpriteFrames` and has
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` animations with
  at least `3` frames each.
- [x] The exit guard pressure vent reuses the existing image-generated steam vent
  texture with hazard id `old_factory_lower_deck_forward_pressure_exit_guard`,
  damage `8`, and cooldown `1.0`.
- [x] Defeating entity `2120` hides/disables the enemy and hazard, persists
  `factory_lower_deck_forward_pressure_exit_guard_activated=true` and
  `factory_lower_deck_forward_pressure_exit_guard_defeated=true`, and advances
  feedback to `Forward Pressure Exit Secured`.
- [x] Restored completed state does not replay Story068 clear burst, does not
  restart Story069/070 content, keeps the Story071 cache claimed without audio
  replay, and keeps `FactoryServiceLift` optional with prompt `Call lift`.
- [x] No new visual or audio assets are generated; reused image-generated assets
  are recorded in asset documentation and QA evidence.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New enemy family art, new lower-deck room scene, new reward caches, minimap
markers, fast travel, SaveSystem schema expansion, global quest state,
service-lift route changes, boss content, new particles/shaders, authored
hazard audio, and new generated visual assets.

## Implementation Notes

- `OldFactoryEntranceScene` owns Story073 activation, diagnostics,
  scene-local persistence, route feedback, enemy state, and hazard contact
  state.
- The encounter reuses `FactorySparkRat` so the visible enemy remains a real
  multi-frame character, not a square or static placeholder.
- The exit pressure vent is active only while the guard encounter is active and
  uses existing `FactorySteamVentHazard` wiring.

## Asset Pipeline

No new asset generation is required. Reuse:

- `res://src/gameplay/factory_spark_rat.tscn`
- `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- `assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`

Record the new usage in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_exit_guard_test.gd`
- Related regression:
  Story073 focused + Story072, Story071, Story070, Story069, shortcut pursuer,
  and service-lift suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, node
  presence, animation frame counts, hazard state, route label, local-state
  persistence, service lift prompt, clean logs, and a non-empty screenshot with
  the animated enemy visible.

## Verification Summary

- RED focused: `reports/report_1116/` failed as expected before Story073
  activation APIs and diagnostics existed.
- Focused GREEN: `reports/report_1117/report_5/` passed Story073 `2/2`.
- Related GREEN: `reports/report_1118/report_1/` passed Story073, Story072,
  Story071, Story070, Story069, shortcut pursuer, and service-lift suites
  `14/14`.
- Headless Factory smoke:
  `reports/old_factory_forward_pressure_exit_guard_smoke.log` exited `0` with
  no project script/parse/invalid-call/access/missing-resource/resource-load
  errors by keyword scan; only the known Godot cleanup-time resource message
  remained in terminal output.
- Godot AI MCP `2.8.3` runtime evidence confirmed helper live, active entity
  `2120`, Spark Rat frame counts `idle/run/attack_tell/attack/hurt/death=3`,
  active pressure hazard id/damage/cooldown, route labels
  `Clear Forward Pressure Exit Guard` and `Forward Pressure Exit Secured`,
  persisted Story073 flags, no prerequisite replay, service lift `Call lift`,
  clean game/editor logs, and non-empty screenshot metadata `960x539`.
- Full evidence:
  `production/qa/evidence/old-factory-forward-pressure-exit-guard-2026-07-03.md`.

**Status**: [x] Complete.
