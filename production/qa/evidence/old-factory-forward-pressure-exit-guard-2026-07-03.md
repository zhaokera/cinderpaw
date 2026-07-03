# QA Evidence: Old Factory Forward Pressure Exit Guard

Date: 2026-07-03
Engine: Godot 4.7
MCP: Godot AI 2.8.3
Story: `production/epics/player-abilities/story-073-old-factory-lower-deck-forward-pressure-exit-guard.md`

## Scope

Story073 adds a one-shot forward-pressure exit guard after the Story071 reward
cache is claimed. The slice mounts a reused animated Factory Spark Rat as entity
`2120`, enables a reused generated steam vent hazard while the guard encounter is
active, and persists scene-local activation/defeat state without SaveSystem
schema changes.

## Asset Pipeline

No new visual or audio assets were generated for this story.

- Character reuse:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  via `FactoryLowerDeckForwardPressureExitGuardSparkRat`.
- Hazard reuse:
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
  via `FactoryLowerDeckForwardPressureExitGuardVent`.
- Background reuse:
  `res://assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`.

The reused assets were originally created through image generation and are
recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`.

## Automated Verification

- RED focused: `reports/report_1116/` failed as expected before Story073
  activation APIs and diagnostics existed.
- Focused GREEN: `reports/report_1117/report_5/` passed Story073 `2/2` with no
  errors, failures, skips, flaky cases, or orphans.
- Related regression: `reports/report_1118/report_1/` passed Story073,
  Story072, Story071, Story070, Story069, shortcut pursuer, and service-lift
  suites `14/14` with no errors, failures, skips, flaky cases, or orphans.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_exit_guard_smoke.log` exited `0`.
  Keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors.

The terminal still printed the known Godot cleanup-time ObjectDB/resource
messages at process exit; the smoke log did not contain project script/resource
errors.

## MCP Runtime Verification

Godot AI MCP `2.8.3` on Godot `4.7-stable` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed helper live.

- Runtime diagnostics confirmed `FactoryLowerDeckForwardPressureExitGuardSparkRat`
  and `FactoryLowerDeckForwardPressureExitGuardVent` are present.
- Activation after Story071 cache claim showed entity `2120`, assigned Cinderpaw
  as target, enabled processing/physics, and set route feedback to
  `Clear Forward Pressure Exit Guard`.
- `FactoryLowerDeckForwardPressureExitGuardSparkRat/Sprite` is
  `AnimatedSprite2D` using
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
  Frame counts are `idle=3`, `run=3`, `attack_tell=3`, `attack=3`, `hurt=3`,
  and `death=3`.
- `FactoryLowerDeckForwardPressureExitGuardVent` is visible/contact-active
  during the encounter, uses hazard id
  `old_factory_lower_deck_forward_pressure_exit_guard`, damage `8`, cooldown
  `1.0`, and texture
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
- Applying `999` damage to entity `2120` returned `true`, disabled enemy/hazard
  active state, hid the enemy, changed route feedback to
  `Forward Pressure Exit Secured`, and persisted both Story073 local flags.
- Restored completed state kept Story073 inactive/defeated, Story071 cache
  claimed with `claim_audio_request_count=0`, Story070 inactive/defeated,
  Story069 crossed but inactive, Story068 clear burst `spawn_count=0`, and
  `FactoryServiceLift` prompt `Call lift`.
- Game log contained only the MCP helper registration line; editor log was
  empty.
- MCP game screenshot metadata was non-empty (`960x539`) and visibly showed the
  active Story073 route text, Cinderpaw, steam hazard, and Spark Rat encounter.

## Result

PASS. Story073 adds a player-visible exit guard encounter after the forward
pressure reward cache, keeps the Spark Rat frame-animation contract, preserves
scene-local persistence, and passes focused, related, headless, and MCP runtime
verification.
