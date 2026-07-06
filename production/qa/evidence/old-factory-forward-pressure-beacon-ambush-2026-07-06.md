# QA Evidence: Old Factory Forward Pressure Beacon Ambush

Date: 2026-07-06
Engine: Godot 4.7
MCP: Godot AI 2.9.1
Story: `production/epics/player-abilities/story-077-old-factory-lower-deck-forward-pressure-beacon-ambush.md`

## Scope

Story077 adds a route-beacon follow-up ambush after Story076. The slice gates a
new animated Factory Spark Rat and pressure vent behind the lit route beacon,
persists clear state, and preserves the Story074 exit relay savepoint,
Story068/071/073 no-replay contracts, and optional service lift.

## Asset Pipeline

No new visual or audio assets were generated for this story.

- Enemy frame animation reuse:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  through `FactoryLowerDeckForwardPressureBeaconAmbushSparkRat/Sprite`.
- Frame-generation sources:
  `assets/characters/factory_spark_rat/source/factory_spark_rat_sprite_sheet_imagegen_20260626.png`,
  `assets/characters/factory_spark_rat/source/factory_spark_rat_sprite_sheet_alpha_20260626.png`,
  `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_sheet_imagegen_20260626.png`,
  and
  `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_sheet_alpha_20260626.png`.
- Hazard prop reuse:
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
  through `FactoryLowerDeckForwardPressureBeaconAmbushVent/Visual`.
- Room context reuse:
  `res://assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`.
- Visual evidence: MCP `editor_screenshot(source="game")` returned a non-empty
  `960x539` game framebuffer showing the active route label, steam hazards,
  and the target encounter area.

All reused visual assets were originally created through image generation and
are recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`.

## Automated Verification

- RED focused: `reports/report_1132/` failed as expected after adding Story077
  tests, because the beacon ambush diagnostics and activation API did not
  exist.
- Focused GREEN: `reports/report_1137/` passed Story077 `2/2` with no errors,
  failures, skips, flaky cases, or orphans.
- Related regression: `reports/report_1138/` passed Story077, Story076,
  Story075, Story074, Story073, Story070, service-lift, and no-loss respawn
  suites `16/16` with no errors, failures, skips, flaky cases, or orphans.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_beacon_ambush_smoke.log` exited `0`.
  Keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors.

The focused CLI run surfaced the known Godot cleanup-time `ObjectDB` /
`resources still in use at exit` messages; no current project script/resource
failure was reproduced.

## MCP Runtime Verification

Godot AI MCP `2.9.1` on Godot `4.7-stable` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed helper live with no startup `recent_errors`.

- Runtime scene tree confirmed
  `FactoryLowerDeckForwardPressureBeaconAmbushSparkRat` and
  `FactoryLowerDeckForwardPressureBeaconAmbushVent`.
- Sprite probe confirmed `FactoryLowerDeckForwardPressureBeaconAmbushSparkRat`
  is a `CharacterBody2D`, child `Sprite` is `AnimatedSprite2D`, and SpriteFrames
  path is
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- SpriteFrames probe confirmed animation names
  `attack`, `attack_tell`, `death`, `hurt`, `idle`, and `run`, each with 3
  frames.
- Locked state before route beacon lighting: ambush present but unavailable,
  inactive, enemy hidden, hazard inactive, and activation returned `false`.
- Ready/active state after marker lit: ready state available/inactive;
  activation at x `1560.0` returned `true`; active state showed entity `2121`,
  visible targeted enemy, enabled process/physics, visible active hazard id
  `old_factory_lower_deck_forward_pressure_beacon_ambush`, steam vent texture
  path, and route label `Clear Forward Pressure Beacon Ambush`.
- Defeat state: `apply_damage(2121, 999, ...)` returned `true`, enemy and hazard
  disabled, local activation/defeat flags persisted, route label changed to
  `Forward Pressure Beacon Ambush Cleared`, and route completion was `true`.
- Restored completed state kept the route marker lit, preserved savepoint
  contract
  `old_factory_lower_deck_forward_pressure_exit_relay / area_03_factory /
  lower_deck_forward_pressure_exit_relay`, kept Story073 inactive/defeated,
  kept Story071 cache claimed with `claim_audio_request_count=0`, kept Story068
  clear burst `spawn_count=0`, and preserved `FactoryServiceLift` prompt
  `Call lift`.
- Game log for the formal MCP run contained only the helper registration line.
  An earlier eval probe caused an eval-script parser break and was discarded;
  the formal verification was restarted on a fresh run before evidence was
  recorded.

MCP screenshot evidence returned a non-empty `960x539` game framebuffer with
the active route label and target encounter area visible in the tool response.

## Result

PASS. Story077 adds a small player-visible ACT combat slice beyond the route
handoff marker, uses compliant frame animation assets, keeps completed route
state persistent, avoids replaying prior lower-deck content on restore, and
passes focused, related, headless, MCP runtime, and visual-evidence checks.
