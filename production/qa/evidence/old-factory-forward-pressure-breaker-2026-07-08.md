# QA Evidence: Old Factory Forward Pressure Breaker

Date: 2026-07-08
Engine: Godot 4.7
MCP: Godot AI 2.9.1
Story: `production/epics/player-abilities/story-079-old-factory-lower-deck-forward-pressure-breaker.md`

## Scope

Story079 adds a post-overrun breaker stand in the Old Factory lower deck. The
slice gates one animated Factory Spark Rat, one pressure vent, and a generated
breaker console behind Story078 completion. Defeating entity `2123` secures the
stand; interacting with the console cuts the forward pressure line once,
persists scene-local state, and preserves the Story074 exit relay savepoint and
optional service lift.

## Asset Pipeline

New image-generated runtime prop:

- Runtime asset:
  `res://assets/environment/old_factory_forward_pressure_breaker/env_old_factory_forward_pressure_breaker_console_256.png`
- Preserved image-generation source:
  `assets/generated/source/old_factory_forward_pressure_breaker_console_imagegen_20260708.png`
- Preserved alpha-matted source:
  `assets/generated/source/old_factory_forward_pressure_breaker_console_alpha_20260708.png`
- Prompt and processing record:
  `assets/generated/source/old_factory_forward_pressure_breaker_console_imagegen_20260708.md`

The prompt requested a compact side-view scrap-metal pressure breaker console
with a cyan analog gauge, warning stripes, red cut cable details, readable
platformer silhouette, no text/watermark, and a flat chroma-key background. The
source was processed through local chroma removal, despill, alpha matting, and
`256x256` RGBA resize, then imported through the Godot asset pipeline.

Reused visual assets:

- Enemy frame animation:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Enemy source sheets:
  `assets/characters/factory_spark_rat/source/factory_spark_rat_sprite_sheet_imagegen_20260626.png`,
  `assets/characters/factory_spark_rat/source/factory_spark_rat_sprite_sheet_alpha_20260626.png`,
  `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_sheet_imagegen_20260626.png`,
  and
  `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_sheet_alpha_20260626.png`
- Hazard prop:
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Room backdrop:
  `res://assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`
- Unlock VFX:
  `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`

## Automated Verification

- RED focused: `reports/report_1144/` failed as expected after adding Story079
  tests, because the breaker diagnostics and activation APIs did not exist.
- Focused GREEN: `reports/report_1147/` passed Story079 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related regression: `reports/report_1148/` passed Story079, Story078,
  Story077, Story076, Story075, Story074, Story073, service-lift, and no-loss
  respawn suites `18/18` with no errors, failures, skips, flaky cases, or
  orphans.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_breaker_smoke.log` exited `0`.
  Keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors.

The headless terminal output still includes the known Godot cleanup-time
`ObjectDB` / `resources still in use at exit` messages; no current project
script/resource failure was reproduced.

## MCP Runtime Verification

Godot AI MCP `2.9.1` on Godot `4.7-stable` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed helper live with no startup `recent_errors`.

- Editor scene inspection found
  `FactoryLowerDeckForwardPressureBreakerSparkRat`,
  `FactoryLowerDeckForwardPressureBreakerVent`, and
  `FactoryLowerDeckForwardPressureBreaker`; the breaker endpoint has id
  `old_factory_lower_deck_forward_pressure_breaker`, radius `112`, prompts
  `Secure breaker` / `Cut Pressure` / `Pressure Cut`, and the generated texture.
- Locked state before Story078 completion: breaker present but unavailable,
  inactive, enemy hidden, hazard inactive, console hidden, and manual activation
  returned `false`.
- Ready/active state after Story078 completion: activation at x `1668.0`
  returned `true`; entity `2123` became visible with target, process/physics on,
  hazard id `old_factory_lower_deck_forward_pressure_breaker` active with
  damage `8` and cooldown `1.0`, and route label
  `Secure Forward Pressure Breaker`.
- SpriteFrames probe confirmed `attack`, `attack_tell`, `death`, `hurt`,
  `idle`, and `run`, each with 3 frames.
- Defeat state: `apply_damage(2123, 999, ...)` returned `true`; enemy and
  hazard disabled; console became visible with prompt `Cut Pressure` and the
  generated breaker texture path.
- Cut state: console activation returned `true`, duplicate activation returned
  `false`, route label became `Forward Pressure Breaker Cut`, local flags
  `factory_lower_deck_forward_pressure_breaker_activated`,
  `factory_lower_deck_forward_pressure_breaker_secured`, and
  `factory_lower_deck_forward_pressure_breaker_cut` persisted as `true`, and
  unlock VFX spawned once.
- Fresh restored completed state kept the breaker visible/cut without replaying
  unlock VFX (`unlock_feedback_spawn_count=0`), kept Story078 overrun inactive
  and defeated, and preserved `FactoryServiceLift` prompt `Call lift`.
- Game log for the formal MCP run contained only the helper registration line;
  editor log was empty.

MCP `editor_screenshot(source="game")` returned non-empty `960x539` game
framebuffers for both active breaker-stand and secured-console states.

## Result

PASS. Story079 adds a visible, playable ACT route beat after Story078, uses
compliant Factory Spark Rat frame animation, imports a new generated transparent
breaker prop through the Godot asset pipeline, persists the one-shot breaker
cut state, avoids replay on restore, and passes focused, related, headless, MCP
runtime, log, and screenshot checks.
