# QA Evidence: Old Factory Service Sluice Tailrace Relay Runoff Pincer

Date: 2026-07-10
Engine: Godot 4.7
MCP: Godot AI 2.9.1

## Scope

Story121 adds a Story120-gated post-runoff Spark Rat + Coil Rat pincer to
`res://scenes/factory_route_transition_shell.tscn`. The slice improves ACT
density after the Tailrace Relay runoff while preserving the existing Tailrace
Relay savepoint and prior service-sluice/tailrace chain.

## Asset Evidence

No new assets were generated. Story121 reuses existing image-generated/imported
frame-animation assets:

- `assets/characters/factory_spark_rat/<animation>/`
- `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- `assets/characters/factory_coil_rat/<animation>/`
- `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

MCP/runtime diagnostics and focused tests confirmed both reused characters are
`AnimatedSprite2D + SpriteFrames` instances with at least three frames for
`idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`.

## Automated Verification

- Focused RED: `reports/report_1366/` failed before Story121 diagnostics,
  activation API, scene nodes, route state, and bounds existed.
- Intermediate RED: `reports/report_1367/` failed until the new pincer enemy
  nodes were included in the entity lookup used by `apply_damage(2144/2145)`.
- Focused GREEN: `reports/report_1368/` passed Story121 `2/2`.
- Related GREEN: `reports/report_1369/` passed Story121 plus Story120,
  Story118, and Story114 adjacent service-sluice/tailrace suites `8/8`.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_smoke.log`
  exited `0` and printed
  `service_sluice_tailrace_relay_runoff_pincer_smoke=passed`. It reported only
  known Godot cleanup-time ObjectDB/resource messages after shutdown.

## MCP Runtime Verification

Godot AI MCP `2.9.1` connected to session `cinderpaw@e40d` under Godot
`4.7-stable`.

- Reloaded `res://scenes/factory_route_transition_shell.tscn` from disk.
- `node_find(name="TailraceRelayRunoffPincer")` found both edited-scene
  CharacterBody2D nodes:
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerSparkRat`
  and
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerCoilRat`.
- `node_get_properties` confirmed the Spark Rat uses
  `res://src/gameplay/factory_spark_rat.gd`, position `Vector2(14760, 482)`,
  z index `20`, and SpriteFrames
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- `node_get_properties` confirmed the Coil Rat uses
  `res://src/gameplay/factory_coil_rat.gd`, position `Vector2(15280, 482)`,
  z index `20`, and SpriteFrames
  `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`.
- `project_run(mode="current")` returned `current_run_errors=[]`,
  `helper_live=true`, and `session_active=true`.
- Runtime `game_manage(get_scene_tree)` found both pincer enemies and their
  `Sprite` `AnimatedSprite2D` children in the running scene.
- Typed `editor_manage(game_eval)` injected the Story106-120 completed state,
  moved Cinderpaw to x `14680`, activated the pincer, and returned diagnostics
  with `activation_call_result=true`, `active=true`, `spark_visible=true`,
  `coil_visible=true`, `spark_has_target=true`, `coil_has_target=true`,
  Spark entity `2144`, Coil entity `2145`, route label
  `Break Tailrace Runoff Pincer`, Spark opening grace `10`, Coil opening grace
  `24`, floor tile count `63`, right wall x `15580`, camera/background right
  `15600`, and ground right edge x `15700`.
- `editor_screenshot(source="game")` returned a non-empty active-pincer game
  framebuffer (`640x359`, original `1278x718`) showing Cinderpaw between the
  Spark Rat and Coil Rat.
- Current-run game log contained only the Godot AI helper registration line;
  editor log returned no current errors.

## Notes

An initial untyped MCP `game_eval` probe used a Variant inference form that
caused a temporary eval-only debugger break. The running project was stopped,
the scene was reloaded, and the final typed eval, screenshot, current editor
log, and current game log passed cleanly. No project file or runtime script
error remained.
