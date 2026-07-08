# QA Evidence: Old Factory Forward Pressure Overrun

Date: 2026-07-08
Engine: Godot 4.7
MCP: Godot AI 2.9.1
Story: `production/epics/player-abilities/story-078-old-factory-lower-deck-forward-pressure-overrun.md`

## Scope

Story078 adds a short forward-pressure overrun after Story077. The slice gates a
new animated Factory Spark Rat and pressure vent behind the cleared beacon
ambush, persists clear state, and preserves the Story074 exit relay savepoint,
Story068/071/073/077 no-replay contracts, and optional service lift.

## Asset Pipeline

No new visual or audio assets were generated for this story.

- Enemy frame animation reuse:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  through `FactoryLowerDeckForwardPressureOverrunSparkRat/Sprite`.
- Frame-generation sources:
  `assets/characters/factory_spark_rat/source/factory_spark_rat_sprite_sheet_imagegen_20260626.png`,
  `assets/characters/factory_spark_rat/source/factory_spark_rat_sprite_sheet_alpha_20260626.png`,
  `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_sheet_imagegen_20260626.png`,
  and
  `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_sheet_alpha_20260626.png`.
- Hazard prop reuse:
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
  through `FactoryLowerDeckForwardPressureOverrunVent/Visual`.
- Room context reuse:
  `res://assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`.
- Visual evidence: MCP `editor_screenshot(source="game")` returned a non-empty
  `960x539` game framebuffer while the overrun route label, enemy, and hazard
  were active.

All reused visual assets were originally created through image generation and
are recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`.

## Automated Verification

- RED focused: `reports/report_1139/` failed as expected after adding Story078
  tests, because the overrun diagnostics and activation API did not exist.
- Focused GREEN: `reports/report_1142/` passed Story078 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related regression: `reports/report_1143/` passed Story078, Story077,
  Story076, Story075, Story074, Story073, Story070, service-lift, and no-loss
  respawn suites `18/18` with no errors, failures, skips, flaky cases, or
  orphans.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_overrun_smoke.log` exited `0`.
  Keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors.

The headless smoke surfaced the known Godot cleanup-time `ObjectDB` /
`resources still in use at exit` messages in terminal output; no current project
script/resource failure was reproduced.

## MCP Runtime Verification

Godot AI MCP `2.9.1` on Godot `4.7-stable` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed helper live with no startup `recent_errors`.

- Locked state before beacon ambush clear: overrun present but unavailable,
  inactive, enemy hidden, hazard inactive, and activation returned `false`.
- Ready/active state after beacon ambush clear: ready state available/inactive;
  activation at x `1620.0` returned `true`; active state showed entity `2122`,
  visible targeted enemy, enabled process/physics, visible active hazard id
  `old_factory_lower_deck_forward_pressure_overrun`, steam vent texture path,
  and route label `Survive Forward Pressure Overrun`.
- SpriteFrames probe confirmed animation names `attack`, `attack_tell`,
  `death`, `hurt`, `idle`, and `run`, each with 3 frames.
- Defeat state: `apply_damage(2122, 999, ...)` returned `true`, enemy and hazard
  disabled, local activation/defeat flags persisted, route label changed to
  `Forward Pressure Overrun Cleared`, and route completion was `true`.
- Restored completed state kept the route marker lit, kept Story077 inactive
  and defeated, preserved savepoint contract
  `old_factory_lower_deck_forward_pressure_exit_relay / area_03_factory /
  lower_deck_forward_pressure_exit_relay`, kept Story073 inactive/defeated,
  kept Story071 cache claimed with `claim_audio_request_count=0`, kept Story068
  clear burst `spawn_count=0`, and preserved `FactoryServiceLift` prompt
  `Call lift`.
- Game log for the formal MCP run contained only the helper registration line;
  editor log was empty.

MCP screenshot evidence returned a non-empty `960x539` game framebuffer during
the active overrun state.

## Result

PASS. Story078 adds a small player-visible ACT combat beat after the beacon
ambush, uses compliant frame animation assets, keeps completed route state
persistent, avoids replaying prior lower-deck content on restore, and passes
focused, related, headless, MCP runtime, and visual-evidence checks.
