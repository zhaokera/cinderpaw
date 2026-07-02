# Story 060: Old Factory Lower Deck Deep Bulkhead Combat Gate

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Combat Gate
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-02

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Story059 clears the lower-deck steam sluice ambush and leaves Cinderpaw near the
deeper route. This story adds the next player-visible ACT beat: a heavy deep
bulkhead door guarded by a Spark Rat. The service lift remains optional while
the deeper route asks the player to defeat the guard and open the bulkhead.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckDeepBulkheadSparkRat` and
  `FactoryLowerDeckDeepBulkhead`, both default hidden or disabled until the
  steam sluice is cleared.
- [x] The deep bulkhead gate is unavailable until
  `factory_lower_deck_steam_sluice_defeated=true` and Cinderpaw crosses the
  deep bulkhead activation boundary.
- [x] Activating the gate shows the guard, assigns Cinderpaw as target, starts
  Spark Rat pacing, enables the bulkhead visual/collision state, updates route
  feedback to `Clear Deep Bulkhead Guard`, and keeps `FactoryServiceLift`
  prompt `Call lift`.
- [x] The guard uses unique entity id `2114`, and visible animations `idle`,
  `run`, `attack_tell`, `attack`, `hurt`, and `death` have at least three
  frames each through `AnimatedSprite2D + SpriteFrames`.
- [x] Defeating entity `2114` hides/disables the guard, updates route feedback
  to `Open Deep Bulkhead`, makes the bulkhead activatable with prompt
  `Open bulkhead`, and does not replay the Story054-059 lower-deck chain.
- [x] Opening the bulkhead persists
  `factory_lower_deck_deep_bulkhead_opened=true`, disables the local collision
  blocker, hides the interaction prompt, and updates route feedback to
  `Deep Bulkhead Opened`.
- [x] `get_local_state()` / `set_local_state()` persist
  `factory_lower_deck_deep_bulkhead_guard_activated`,
  `factory_lower_deck_deep_bulkhead_guard_defeated`, and
  `factory_lower_deck_deep_bulkhead_opened`.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass under Godot 4.7 with no current project script or
  resource errors.

## Out of Scope

New enemy family, new Cinderpaw animation, new enemy behavior family, new
reward cache, authored door-opening animation, new audio, minimap markers,
fast travel UI, SaveSystem schema changes, global quest/objective manager
changes, and service-lift route changes.

## Implementation Notes

- Reuse `res://src/gameplay/factory_spark_rat.tscn` and
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  for the animated guard.
- Add only a scene-local bulkhead prop and collision blocker in
  `res://scenes/factory_route_transition_shell.tscn`.
- Keep the slice scene-local. Persist only through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Keep the service lift independent from the deep bulkhead state; this gate is
  for deeper route progression, not the lift exit.

## Asset Pipeline

New visual asset generated through image generation:

- Source:
  `assets/generated/source/old_factory_lower_deck_deep_bulkhead_imagegen_20260702.png`
- Alpha-matted source:
  `assets/generated/source/old_factory_lower_deck_deep_bulkhead_alpha_20260702.png`
- Runtime prop:
  `assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
- Metadata:
  `assets/generated/source/old_factory_lower_deck_deep_bulkhead_imagegen_20260702.json`

The source was generated on a bright green chroma key, alpha-matted to
transparent, resized to a 256x256 runtime PNG, imported through Godot, and
recorded in `design/assets/asset-manifest.md` plus
`design/assets/entity-inventory.md`.

## Test Evidence

- Focused RED/GREEN:
  - `reports/report_1058/` failed as expected before Story060 diagnostics and
    activation/open APIs existed.
  - `reports/report_1060/` passed focused Story060 tests `2/2` with `0`
    orphans after Godot imported the generated PNG assets.
- Related regression:
  - `reports/report_1062/` passed deep bulkhead, steam sluice, pressure valve,
    and service-lift SceneManager exit tests `8/8` with `0` orphans.
- Headless smoke:
  - `reports/old_factory_lower_deck_deep_bulkhead_smoke.log` exited `0`;
    keyword scan found no script, parse, invalid-call/access, missing-resource,
    or resource-load errors. The log retains the known Godot cleanup-time
    ObjectDB/resource messages.
- MCP runtime:
  - Godot MCP launched
    `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`,
    confirmed runtime nodes `FactoryLowerDeckDeepBulkheadSparkRat` and
    `FactoryLowerDeckDeepBulkhead`, entity `2114`,
    `AnimatedSprite2D + SpriteFrames` at
    `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`,
    `idle/run/attack_tell/attack/hurt/death` frame counts all `3`, active
    route objective `Clear Deep Bulkhead Guard`, service lift prompt
    `Call lift`, defeat feedback `Open Deep Bulkhead`, opening feedback
    `Deep Bulkhead Opened`, persisted activated/defeated/opened flags, clean
    game/editor logs, and non-empty screenshot metadata `960x539`.
  - Full evidence:
    `production/qa/evidence/old-factory-lower-deck-deep-bulkhead-combat-gate-2026-07-02.md`.

**Status**: [x] Complete.
