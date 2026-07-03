# QA Evidence: Old Factory Forward Pressure Counter-Ambush

Date: 2026-07-03
Engine: Godot 4.7
MCP: Godot AI 2.8.3
Story: `production/epics/player-abilities/story-070-old-factory-lower-deck-forward-pressure-counter-ambush.md`

## Scope

Story070 adds a one-shot forward pressure counter-ambush after Story069's
pressure traverse is crossed. The slice mounts a reused animated Factory Spark
Rat as entity `2119`, enables a reused generated steam vent hazard while the
ambush is active, and persists scene-local activation/defeat state without
SaveSystem schema changes.

## Asset Pipeline

No new visual or audio assets were generated for this story.

- Character reuse:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  via `FactoryLowerDeckForwardCounterSparkRat`.
- Hazard reuse:
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
  via `FactoryLowerDeckForwardCounterPressureVent`.
- Background reuse:
  `res://assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`.

The reused assets were originally created through image generation and are
recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`.

## Automated Verification

- RED focused: `reports/report_1107/` failed as expected before Story070
  activation APIs and diagnostics existed.
- Focused GREEN: `reports/report_1108/` passed Story070 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related regression: `reports/report_1109/` passed Story070, Story069,
  Story068, Story067, Story009, and service-lift SceneManager exit suites
  `14/14` with no errors, failures, skips, flaky cases, or orphans.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_counter_ambush_smoke.log` exited `0`.
  Keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors. The log retains only the known
  Godot cleanup-time `resources still in use` exit message.

## MCP Runtime Verification

Godot AI MCP `2.8.3` on Godot `4.7-stable` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed helper live.

- Runtime scene tree contains `FactoryLowerDeckForwardCounterSparkRat` and
  `FactoryLowerDeckForwardCounterPressureVent`.
- Activation after Story069 crossed returned `true`, showed entity `2119`,
  assigned Cinderpaw as target, enabled processing/physics, and set route
  feedback to `Survive Forward Pressure Ambush`.
- `FactoryLowerDeckForwardCounterSparkRat/Sprite` is `AnimatedSprite2D` using
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
  Frame counts are `idle=3`, `run=3`, `attack_tell=3`, `attack=3`, `hurt=3`,
  and `death=3`.
- `FactoryLowerDeckForwardCounterPressureVent` is visible/contact-active during
  the ambush, uses hazard id
  `old_factory_lower_deck_forward_pressure_counter_ambush`, damage `8`, cooldown
  `1.0`, and texture
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
- Applying `999` damage to entity `2119` returned `true`, disabled enemy/hazard
  active state, hid the enemy, changed route feedback to
  `Forward Pressure Ambush Cleared`, and persisted both Story070 local flags.
- Restored completed state kept Story070 inactive/defeated, Story069 crossed but
  inactive, Story067 entity inactive/defeated, Story068 clear burst
  `spawn_count=0`, and `FactoryServiceLift` prompt `Call lift`.
- Game log contained only the MCP helper registration line; editor log was
  empty.
- MCP game screenshot metadata was non-empty (`960x539`) and visibly showed the
  active Story070 route text, Cinderpaw, steam hazard, and Spark Rat encounter.
