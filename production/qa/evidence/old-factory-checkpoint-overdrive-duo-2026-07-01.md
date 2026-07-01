# QA Evidence: Old Factory Checkpoint Overdrive Duo

> **Story**: Player Abilities Story 049
> **Engine**: Godot `4.7.stable.official.5b4e0cb0f`
> **Date**: 2026-07-01

## Scope

Story049 adds a paired Spark Rat overdrive encounter after the Old Factory
checkpoint rear ambush. It blocks the final service lift until both visible
animated enemies are defeated.

No new visual assets were generated. The story reuses the existing
image-generated Factory Spark Rat frame animation set.

## Automated Verification

- Focused RED: `reports/report_1011/`
  - Failed because the overdrive duo diagnostics API did not exist.
- Focused GREEN: `reports/report_1012/`
  - Passed `3/3`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
- Related regression: `reports/report_1015/`
  - Passed `15/15`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
  - Covered Story049, Story048, Story047, Story046, and service-lift
    SceneManager exit suites.
- Extended related regression: `reports/report_1016/`
  - Passed `23/23`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
  - Added return checkpoint and Factory route runtime roundtrip coverage.
- Final pre-commit regression: `reports/report_1017/`
  - Passed `23/23`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
  - Covered Story049 plus Story048, Story047, Story046, service-lift
    SceneManager exit, return checkpoint, and Factory route runtime roundtrip.
  - Stdout retained one Godot cleanup-time ObjectDB warning at process exit.
- Headless target-scene smoke:
  - `reports/old_factory_checkpoint_overdrive_duo_smoke.log` exited `0`.
  - Keyword scan found no `SCRIPT ERROR`, `Parse Error`, `FATAL`,
    `invalid call`, `invalid access`, `missing resource`, or `resource load`.
  - The log contains only Godot cleanup-time resource warnings such as
    `2 resources still in use at exit`.

## Asset / Animation Evidence

- Runtime nodes:
  - `/FactoryRouteTransitionShellScene/FactoryCheckpointOverdriveSparkRatLeft`
  - `/FactoryRouteTransitionShellScene/FactoryCheckpointOverdriveSparkRatRight`
  - Type: `CharacterBody2D`
  - Entity ids: `2106` and `2107`
  - Default state: `visible=false`, `collision_layer=0`, `collision_mask=0`
- Presentation chain:
  - Child node `Sprite`
  - Type: `AnimatedSprite2D`
  - SpriteFrames:
    `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Frame counts confirmed by MCP diagnostics for both enemies:
  - `idle=3`
  - `run=3`
  - `attack_tell=3`
  - `attack=3`
  - `hurt=3`
  - `death=3`

## Godot MCP Runtime Evidence

MCP session used Godot `4.7-stable (official)` with plugin/server `2.8.1`.

Runtime tree and default-state probe:

- Runtime tree contained both overdrive Spark Rat nodes under
  `/FactoryRouteTransitionShellScene`.
- Default diagnostics:
  - `present=true`
  - `available=false`
  - `active=false`
  - `cleared=false`
  - left and right nodes hidden, non-processing, non-physics, and
    non-colliding
  - `sprite_frames_path` points to the Factory Spark Rat SpriteFrames resource.

Activation probe:

- MCP called `set_local_state()` with the prerequisite Old Factory route state,
  including `factory_checkpoint_rear_ambush_defeated=true`.
- MCP moved Cinderpaw past `activation_x=1196` and called
  `try_activate_factory_checkpoint_overdrive_duo(player)`.
- Activation result:
  - `activated=true`
  - `active=true`
  - `available=true`
  - left and right `visible=true`
  - left and right `collision_layer=2`
  - left and right `collision_mask=17`
  - left and right `has_target=true`
  - route objective `clear_checkpoint_overdrive_duo`
  - route label `Clear Overdrive Duo`
  - service lift prompt `Clear overdrive duo`
  - service lift available `false`

Single-defeat lockout probe:

- MCP called `apply_damage(2106, 999, {"source": "mcp_overdrive_left"})`.
- Left defeat result:
  - left `defeated=true`
  - left `visible=false`
  - left `collision_layer=0`
  - right `defeated=false`
  - right `visible=true`
  - right `collision_layer=2`
  - service lift activation returned `false`
  - service lift rejected exit with `overdrive_duo_active`

Double-defeat unlock probe:

- MCP called `apply_damage(2107, 999, {"source": "mcp_overdrive_right"})`.
- Before lift activation:
  - duo `cleared=true`
  - route objective `checkpoint_overdrive_duo_cleared`
  - route label `Factory Lift Secured`
  - service lift prompt `Call lift`
  - service lift available `true`
- After lift activation:
  - service lift activation returned `true`
  - `exit_requested=true`
  - `last_exit_request.scene_id="main"`
  - `last_exit_request.spawn_point="scrap_roost"`
  - route label `Service Lift Departing`

Logs and screenshot:

- MCP game screenshot returned PNG metadata `640x360`, original framebuffer
  `1280x720`, confirming non-empty runtime capture.
- After clearing the MCP log buffer, a runtime eval returned
  `{"ok": true, "scene": "FactoryRouteTransitionShellScene"}`.
- Reading `godot://logs/recent` after the clear/stop sequence returned only
  MCP/plugin `info` rows for clear logs, eval, state, stop, and log read; no
  current `error` or `warning` rows were present.
- Earlier editor parse rows from half-edited files were stale pre-run state and
  were not present in the post-clear recent log resource.

## Verdict

PASS. The overdrive duo is scene-authored, reuses compliant Factory Spark Rat
frame animation assets, blocks the service lift until both enemies are defeated,
persists single-side and full-clear state, requests `main / scrap_roost` after
clear, and passes focused, related, headless, and MCP 4.7 runtime verification.
