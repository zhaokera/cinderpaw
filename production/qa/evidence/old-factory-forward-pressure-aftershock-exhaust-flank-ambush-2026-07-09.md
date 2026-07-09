# QA Evidence: Old Factory Forward Pressure Aftershock Exhaust Flank Ambush

Date: 2026-07-09
Story: `production/epics/player-abilities/story-089-old-factory-lower-deck-forward-pressure-aftershock-exhaust-flank-ambush.md`
Engine: Godot 4.7
Godot AI MCP: 2.9.1

## Scope

Story089 adds a compact ACT flank ambush after Story088. Once
`factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed=true`,
crossing x `2768.0` activates
`FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushSparkRat` as entity
`2132` and enables
`FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushVent` as a contact
hazard. The slice advances route feedback from
`Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears` to
`Break Aftershock Exhaust Flank`, then to
`Forward Pressure Exhaust Flank Cleared`.

## Asset Pipeline

No new visual or audio assets were generated for this Story. Story089 reuses
existing image-generated assets already imported into Godot:

- Runtime Factory Spark Rat SpriteFrames:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Runtime Factory Spark Rat character scene:
  `res://scenes/characters/factory_spark_rat.tscn`
- Runtime Factory Spark Rat gameplay scene:
  `res://src/gameplay/factory_spark_rat.tscn`
- Attack tell frames:
  `res://assets/characters/factory_spark_rat/attack_tell/factory_spark_rat_attack_tell_000.png`
  through `_002.png`
- Steam vent runtime texture:
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`

Reuse is recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and the Story089 file.

## Automated Evidence

- Initial RED: `reports/report_1198/`
  - Expected failure before Story089 diagnostics/activation APIs, scene nodes,
    and state fields existed.
- Pre-MCP GREEN: `reports/report_1200/`
  - Story089 focused suite passed `3/3` before the longer MCP runtime probe.
- MCP stale-reference RED: `reports/report_1202/`
  - Added regression coverage for calling Story089 diagnostics after the
    Spark Rat death tween had time to queue-free the enemy.
  - Failed with `Invalid type in function '_get_enemy_entity_id'` because
    diagnostics passed a previously freed enemy reference to a `Node`-typed
    helper.
- Final focused GREEN: `reports/report_1205/`
  - Story089 focused suite passed `3/3`, including the freed-node-safe
    diagnostics path.
- Final related GREEN: `reports/report_1204/`
  - Covered Story089 plus Story088, Story087, Story086, Story085, Story084,
    Story083, Story074 relay, service-lift scene-manager exit, no-loss respawn,
    Story068 no-replay, Story071 reward-cache audio no-replay, and steam vent
    hazard contracts.
  - Passed `33/33`.

## Headless Smoke

`reports/old_factory_forward_pressure_aftershock_exhaust_flank_ambush_smoke.log`
exited `0`. Keyword scan found no project script, parse, invalid-call,
invalid-access, missing-resource, resource-load, or shadowed-variable errors.

The Godot process still printed the existing cleanup-time ObjectDB/resource
messages at exit; no Story089 project file reported a parser/runtime error.

## MCP Runtime Evidence

Godot MCP session `cinderpaw@3094` reported Godot `4.7-stable (official)`,
`plugin_version=2.9.1`, `server_version=2.9.1`, helper live, and readiness
`ready` before launch.

MCP launched `res://scenes/factory_route_transition_shell.tscn` with
`project_run(mode="custom", autosave=false)` and confirmed:

- `FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushSparkRat` exists
  as `CharacterBody2D`.
- `FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushVent` exists as
  `Area2D`.
- Live Story088 cache claim returns `true` from
  `try_claim_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache`.
- Story089 becomes available only after that claim.
- Player at x `2772.0` activates the flank ambush.
- Active route label: `Break Aftershock Exhaust Flank`.
- Spark Rat entity id: `2132`; family id: `factory_spark_rat`.
- Child `Sprite` is `AnimatedSprite2D`.
- SpriteFrames path:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- Animation frame counts:
  `idle=3`, `run=3`, `attack_tell=3`, `attack=3`, `hurt=3`, `death=3`.
- Opening-grace total frames: `14`.
- Steam vent hazard id:
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush`.
- Steam vent damage/cooldown: `8` damage, `1.0s`.
- Steam vent texture:
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
- Runtime steam contact changed Cinderpaw HP from `100` to `92`.
- Defeating entity `2132` with `apply_damage` returns `true`.
- Settled cleared diagnostics after additional frames return
  `cleared=true`, `spark_visible=false`, `hazard_contact_active=false`, and
  route label `Forward Pressure Exhaust Flank Cleared` without the earlier
  stale freed-node runtime error.
- Story074 relay savepoint remains
  `old_factory_lower_deck_forward_pressure_exit_relay` /
  `lower_deck_forward_pressure_exit_relay`.
- `FactoryServiceLift` remains optional with prompt `Call lift`.
- Story068 clear feedback `spawn_count=0`.
- Story071 reward-cache audio request count remains `0`.

Final logs:

- Game log: only `[godot_ai game_helper] registered mcp capture`.
- Editor log: empty.

Screenshot:

- MCP `editor_screenshot(source="game")` returned a non-empty `960x539`
  framebuffer showing the active lower-deck flank state.

## Notes

The MCP probe initially exposed the stale freed-node diagnostics bug after the
Spark Rat death tween. The fix keeps diagnostics and enemy lookup robust by
checking `is_instance_valid()` before using scene-local enemy references and by
making the enemy id/family helpers tolerate stale `Variant` inputs.
