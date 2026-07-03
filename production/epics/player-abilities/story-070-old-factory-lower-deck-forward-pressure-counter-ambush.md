# Story 070: Old Factory Lower Deck Forward Pressure Counter-Ambush

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

Story069 gets Cinderpaw across the forward pressure leak. This story adds the
next short ACT beat: after the traverse is crossed, a counter-ambush activates
with an animated Factory Spark Rat and an active pressure vent. The slice stays
scene-local, reuses existing generated assets, and keeps the service lift
optional.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardCounterSparkRat` and
  `FactoryLowerDeckForwardCounterPressureVent`, both hidden, non-processing,
  non-physics, and non-contacting before
  `factory_lower_deck_forward_pressure_traverse_crossed=true`.
- [x] Crossing the Story070 activation boundary after Story069 crossed activates
  entity `2119`, assigns Cinderpaw as target, starts Spark Rat pacing, enables
  the counter pressure vent, and updates route feedback to
  `Survive Forward Pressure Ambush`.
- [x] The visible enemy uses `AnimatedSprite2D + SpriteFrames` and has
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` animations with
  at least `3` frames each.
- [x] The counter pressure vent reuses the existing image-generated steam vent
  texture with hazard id
  `old_factory_lower_deck_forward_pressure_counter_ambush`, damage `8`, and
  cooldown `1.0`.
- [x] Defeating entity `2119` hides/disables the enemy and hazard, persists
  `factory_lower_deck_forward_pressure_counter_ambush_activated=true` and
  `factory_lower_deck_forward_pressure_counter_ambush_defeated=true`, and
  advances feedback to `Forward Pressure Ambush Cleared`.
- [x] Restored completed state does not replay Story068 clear burst, does not
  restart entity `2118`, keeps Story069 pressure traversal inactive, and keeps
  `FactoryServiceLift` optional with prompt `Call lift`.
- [x] No new visual or audio assets are generated; reused image-generated assets
  are recorded in asset documentation and QA evidence.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New enemy family art, new lower-deck room scene, reward caches, minimap markers,
fast travel, SaveSystem schema expansion, global quest state, service-lift route
changes, boss content, new particles/shaders, authored hazard audio, and new
generated visual assets.

## Implementation Notes

- `OldFactoryEntranceScene` owns Story070 activation, diagnostics, scene-local
  persistence, route feedback, enemy state, and hazard contact state.
- The encounter reuses `FactorySparkRat` so the visible enemy remains a real
  multi-frame character, not a square or static placeholder.
- The counter pressure vent is active only while the ambush is active and uses
  existing `FactorySteamVentHazard` wiring.

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
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_counter_ambush_test.gd`
- Related regression:
  Story070 focused + Story069, Story068, Story067, Story009, and service-lift
  suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, node
  presence, animation frame counts, hazard state, route label, local-state
  persistence, service lift prompt, clean logs, and a non-empty screenshot with
  the animated enemy visible.

## Verification Summary

- RED focused: `reports/report_1107/` failed as expected before the Story070
  activation APIs and diagnostics existed.
- Focused GREEN: `reports/report_1108/` passed Story070 `2/2`.
- Related GREEN: `reports/report_1109/` passed Story070, Story069, Story068,
  Story067, Story009, and service-lift SceneManager exit suites `14/14`.
- Headless Factory smoke:
  `reports/old_factory_forward_pressure_counter_ambush_smoke.log` exited `0`
  with no project script/parse/invalid-call/access/missing-resource/resource-load
  errors by keyword scan; only the known Godot cleanup-time resource message
  remained.
- Godot AI MCP `2.8.3` runtime evidence confirmed helper live, active entity
  `2119`, Spark Rat frame counts `idle/run/attack_tell/attack/hurt/death=3`,
  active pressure hazard id/damage/cooldown, route labels
  `Survive Forward Pressure Ambush` and `Forward Pressure Ambush Cleared`,
  persisted Story070 flags, no prerequisite replay, service lift `Call lift`,
  clean game/editor logs, and non-empty screenshot metadata `960x539`.
- Full evidence:
  `production/qa/evidence/old-factory-forward-pressure-counter-ambush-2026-07-03.md`.

**Status**: [x] Complete.
