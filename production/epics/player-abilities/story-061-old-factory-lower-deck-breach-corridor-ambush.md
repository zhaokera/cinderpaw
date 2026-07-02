# Story 061: Old Factory Lower Deck Breach Corridor Ambush

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

Story060 opens the lower-deck deep bulkhead. This story makes the newly opened
route immediately playable by adding a short breach corridor ambush: a front
Spark Rat guard, a rear pincer ambusher, an active steam hazard, and a new
image-generated post-bulkhead backdrop so the area does not read as the same
placeholder room.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `PostBulkheadBackground`, `FactoryLowerDeckBreachFrontSparkRat`,
  `FactoryLowerDeckBreachRearSparkRat`, and
  `FactoryLowerDeckBreachSteamHazard`; all breach combat nodes default hidden
  or disabled before the deep bulkhead opens.
- [x] The breach corridor is unavailable until
  `factory_lower_deck_deep_bulkhead_opened=true`.
- [x] Crossing the breach activation boundary reveals front guard entity
  `2115`, assigns Cinderpaw as target, starts Spark Rat pacing, enables the
  breach steam hazard, and updates route feedback to
  `Clear Breach Corridor Ambush`.
- [x] Pushing to the breach midpoint reveals rear ambusher entity `2116`,
  assigns Cinderpaw as target, starts pacing, and updates route feedback to
  `Survive Breach Pincer`.
- [x] Both visible enemies use `AnimatedSprite2D + SpriteFrames` with
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` at least three
  frames each.
- [x] Defeating entities `2115` and `2116` hides/disables both enemies,
  disables the steam hazard, persists breach flags, and updates route feedback
  to `Breach Corridor Secured`.
- [x] `FactoryServiceLift` remains optional during the breach ambush with
  prompt `Call lift`.
- [x] `get_local_state()` / `set_local_state()` persist breach activation,
  front defeat, rear activation, rear defeat, and secured state without
  replaying the Story054-060 lower-deck prerequisite chain.
- [x] Focused and related GdUnit regressions, headless smoke, Godot import, and
  Godot MCP runtime evidence pass under Godot 4.7 with no current project
  script or resource errors.

## Out of Scope

New enemy family, new Cinderpaw animation, new combat AI family, reward cache,
SaveSystem schema changes, minimap markers, fast travel UI, global
quest/objective manager changes, authored steam SFX, service-lift route
changes, and boss content.

## Implementation Notes

- Reuse `res://src/gameplay/factory_spark_rat.tscn` and
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  for both animated enemies.
- Keep the slice scene-local. Persist only through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Keep the service lift independent from breach corridor state; this ambush is
  deeper-route content, not a lift lockout.
- Use the new generated post-bulkhead backdrop only after the deep bulkhead is
  open, so the player gets a visible change of space.

## Asset Pipeline

New visual asset generated through image generation:

- Source:
  `assets/generated/source/old_factory_lower_deck_post_bulkhead_backdrop_imagegen_20260702.png`
- Runtime background:
  `assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`
- Metadata:
  `assets/generated/source/old_factory_lower_deck_post_bulkhead_backdrop_imagegen_20260702.json`

The source was generated as an opaque 16:9 pixel-art lower-deck chamber beyond
the bulkhead, resized to a 1280x720 runtime PNG, imported through Godot, and
recorded in `design/assets/asset-manifest.md` plus
`design/assets/entity-inventory.md`.

## Test Evidence

- Focused RED/GREEN:
  - `reports/report_1064/` failed as expected before the Story061 diagnostics
    and activation APIs existed.
  - `reports/report_1065/` passed focused Story061 tests `2/2` with `0`
    orphans after implementation and import.
- Related regression:
  - `reports/report_1066/` passed pressure valve, steam sluice, deep bulkhead,
    breach corridor, and service-lift SceneManager exit suites `10/10` with
    `0` orphans.
- Headless smoke:
  - `reports/old_factory_lower_deck_bulkhead_breach_ambush_smoke.log` exited
    `0`; keyword scan found no script, parse, invalid-call/access,
    missing-resource, or resource-load errors. The log retains only the known
    Godot cleanup-time resource message.
- MCP runtime:
  - Godot MCP launched
    `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`,
    confirmed `PostBulkheadBackground`,
    `FactoryLowerDeckBreachSteamHazard`, entities `2115` and `2116`,
    `AnimatedSprite2D + SpriteFrames` frame counts
    `idle/run/attack_tell/attack/hurt/death=3` on both enemies, activation
    feedback `Clear Breach Corridor Ambush`, pincer feedback
    `Survive Breach Pincer`, service lift prompt `Call lift`, defeat feedback
    `Breach Corridor Secured`, persisted breach flags, clean game/editor logs,
    and non-empty screenshot
    `reports/visual/cinderpaw-mcp-old-factory-lower-deck-breach-corridor-ambush-20260702.png`.
  - Full evidence:
    `production/qa/evidence/old-factory-lower-deck-breach-corridor-ambush-2026-07-02.md`.

**Status**: [x] Complete.
