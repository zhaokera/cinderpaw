# QA Evidence: Old Factory Forward Pressure Relief Ambush

Date: 2026-07-08
Engine: Godot 4.7
MCP: Godot AI 2.9.1
Story: `production/epics/player-abilities/story-080-old-factory-lower-deck-forward-pressure-relief-ambush.md`

## Scope

Story080 adds a post-breaker relief ambush in the Old Factory lower deck. The
slice gates one animated Factory Spark Rat and one pressure vent behind the
Story079 breaker cut. Crossing x `1804.0` activates entity `2124`, enables the
hazard `old_factory_lower_deck_forward_pressure_relief_ambush`, persists
scene-local activation/defeat state, and preserves the Story074 exit relay
savepoint plus optional service lift.

## Asset Pipeline

No new visual or audio asset was generated for Story080. The story reuses
already imported image-generated assets:

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

Reuse was recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`.

## Automated Verification

- RED focused: `reports/report_1150/` failed as expected after adding Story080
  tests, because the relief ambush diagnostics and activation APIs did not
  exist.
- Focused GREEN: `reports/report_1151/` passed Story080 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related regression: `reports/report_1152/` passed Story080, Story079,
  Story078, Story077, Story076, Story075, Story074, service-lift, and no-loss
  respawn suites `20/20` with no errors, failures, skips, flaky cases, or
  orphans.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_relief_ambush_smoke.log` exited `0`.
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
  `FactoryLowerDeckForwardPressureReliefSparkRat` and
  `FactoryLowerDeckForwardPressureReliefVent`.
- Locked state before Story079 breaker cut: relief ambush present but
  unavailable, inactive, enemy hidden, hazard inactive, and manual activation
  returned `false`.
- Ready/active state after breaker cut: activation before x `1804.0` returned
  `false`; activation after the boundary returned `true`; entity `2124` became
  visible with target, process/physics on, hazard id
  `old_factory_lower_deck_forward_pressure_relief_ambush` active with damage
  `8`, cooldown `1.0`, steam vent texture path, and route label
  `Survive Forward Pressure Relief Ambush`.
- SpriteFrames probe confirmed `attack`, `attack_tell`, `death`, `hurt`,
  `idle`, and `run`, each with 3 frames.
- Defeat state: `apply_damage(2124, 999, ...)` returned `true`; enemy and
  hazard disabled; route label became `Forward Pressure Relief Ambush Cleared`;
  local flags `factory_lower_deck_forward_pressure_relief_ambush_activated` and
  `factory_lower_deck_forward_pressure_relief_ambush_defeated` persisted as
  `true`; the route objective reported complete.
- Fresh restored completed state kept Story080 inactive/defeated, kept Story079
  breaker cut with prompt `Pressure Cut`, preserved Story074 relay savepoint
  `old_factory_lower_deck_forward_pressure_exit_relay` and spawn point
  `lower_deck_forward_pressure_exit_relay`, kept Story071 cache claimed with
  `claim_audio_request_count=0`, kept Story068 clear feedback
  `spawn_count=0`, and preserved `FactoryServiceLift` prompt `Call lift`.
- Game log for the formal MCP run contained only the helper registration line;
  editor log was empty after clearing discarded eval-probe warnings.

MCP `editor_screenshot(source="game")` returned a non-empty `960x539` game
framebuffer for the active relief ambush state.

## Result

PASS. Story080 adds a visible, playable post-breaker ACT beat, reuses compliant
Factory Spark Rat frame animation and the imported steam vent hazard prop,
persists relief ambush completion, avoids prerequisite replay on restore, and
passes focused, related, headless, MCP runtime, log, and screenshot checks.
