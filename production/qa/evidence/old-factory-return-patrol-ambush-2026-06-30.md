# QA Evidence: Old Factory Return Patrol Ambush

> **Story**: Player Abilities Story040
> **Date**: 2026-06-30
> **Engine**: Godot 4.7
> **Scope**: Old Factory return-visit patrol ambush, service-lift lockout, and
> post-clear handoff back to Scrap Roost.

## Automated Evidence

- Focused RED: `reports/report_928/` failed `1/3` at the new return-patrol
  objective completion assertion. The failing behavior was
  `objective_id == "return_patrol_cleared"` while `complete == false`.
- Focused GREEN: `reports/report_929/` passed Story040 `3/3` with `0` errors,
  failures, skipped tests, flaky tests, or orphan nodes on Godot
  `4.7.stable.official.5b4e0cb0f`.
- Related regression: `reports/report_930/` passed `14/14` across:
  - Story040 Old Factory return patrol ambush
  - Story034 Old Factory route objective handoff
  - Story035 Old Factory service lift handoff
  - Story036 Old Factory service lift SceneManager exit
  - Story037 Factory route runtime roundtrip
  - Story038 Factory route return prompt
  - Story039 Scrap Roost return hub runtime
- Headless Factory scene smoke:
  `reports/old_factory_return_patrol_ambush_factory_scene_smoke.log` exited
  `0`. Keyword scan found no `SCRIPT ERROR`, parse error, invalid call/access,
  missing resource, failed resource load, or `ERROR:` entry in the log.
  The command-line console still printed the project's known Godot
  cleanup-time ObjectDB/resource messages after process exit.

## MCP Runtime Evidence

- MCP session `cinderpaw@6787` connected to Godot `4.7-stable (official)`.
- Plugin/server versions both reported `2.8.1`.
- Runtime launched `res://scenes/factory_route_transition_shell.tscn` with
  `autosave=false`.
- Runtime scene tree confirmed `/FactoryRouteTransitionShellScene/
  FactoryReturnSparkRat` exists as `CharacterBody2D` with child `Sprite`
  `AnimatedSprite2D`.
- Return-contract probe restored `area_03_factory` local state with:
  - `factory_service_lift_exit_requested == true`
  - `factory_service_lift_exit_scene_id == "main"`
  - `factory_service_lift_exit_spawn_point == "scrap_roost"`
- Active patrol diagnostics:
  - `present=true`, `visible=true`, `active=true`, `defeated=false`
  - `entity_id=2103`
  - `has_target=true`
  - `physics_enabled=true`, `process_enabled=true`
  - `collision_layer=2`, `collision_mask=17`
  - SpriteFrames path:
    `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  - Animation frame counts:
    `idle=3`, `run=3`, `attack_tell=3`, `attack=3`, `hurt=3`, `death=3`
- While active, service lift activation returned `false` and diagnostics
  reported:
  - route objective `clear_return_patrol`
  - route label `Clear Return Patrol`
  - lift prompt `Clear patrol`
  - `return_patrol_active=true`
  - `exit_rejected_reason="return_patrol_active"`
  - `exit_requested=false`
- Defeat probe called `apply_damage(2103, 999, ...)` and returned `true`.
  After defeat:
  - patrol `active=false`, `visible=false`, `defeated=true`
  - objective `return_patrol_cleared`
  - objective text `Return Patrol Cleared`
  - objective `complete=true`
  - lift prompt `Call lift`
  - `return_patrol_active=false`
  - lift became `available=true` and `activation_ready=true`
- Post-clear lift activation returned `true` and requested:
  - target scene `main`
  - spawn point `scrap_roost`
  - route label `Service Lift Departing`
- MCP logs after clearing temporary eval errors:
  - game log contained only the Godot AI helper registration line
  - editor log was empty
- MCP screenshot metadata: game screenshot `640x359`, original framebuffer
  `1278x718`.
- Saved screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-return-patrol-ambush-20260630.png`
  is nonblank and shows the return patrol encounter in the Old Factory room.

## Spawn Semantics

`FactoryReturnSparkRat` is authored in
`res://scenes/factory_route_transition_shell.tscn` and starts hidden, disabled,
and non-colliding outside the return-contract path. Story040 uses "spawn" in the
gameplay sense: the patrol becomes visible, targeted, processing, colliding, and
service-lift-blocking only after the full service-lift return contract is
restored. This avoids runtime scene mutation and keeps the encounter inside the
scene-local state protocol required by ADR-0007.

## Asset Notes

- No new visual assets were generated for this story.
- The patrol reuses the existing image-generated Factory Spark Rat character
  frames and SpriteFrames resource.
- The service lift reuses the existing image-generated service-lift console and
  unlock VFX assets from Story035.
