# QA Evidence: Old Factory Checkpoint Rear Ambush

> **Story**: Player Abilities Story 048
> **Engine**: Godot `4.7.stable.official.5b4e0cb0f`
> **Date**: 2026-06-30

## Scope

Story048 adds a rear Spark Rat ambush after the Old Factory checkpoint steam
vent gauntlet. It turns the post-forward-patrol route into a visible combat beat
before the service lift can be called.

No new visual assets were generated. The story reuses the existing
image-generated Factory Spark Rat frame animation set.

## Automated Verification

- Focused RED: `reports/report_1006/`
  - Failed because the rear ambush diagnostics API and scene node did not exist.
- Focused GREEN: `reports/report_1007/`
  - Passed `3/3`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
- Related regression: `reports/report_1009/`
  - Passed `20/20`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
  - Covered Story048 rear ambush, Story047 checkpoint steam vent, Story046
    checkpoint-forward handoff, return checkpoint, service-lift SceneManager
    exit, and Factory route roundtrip.
- Headless target-scene smoke:
  - `reports/old_factory_checkpoint_rear_ambush_smoke.log` exited `0`.
  - Keyword scan found no `SCRIPT ERROR`, `Parse Error`, `FATAL`,
    `invalid call`, `invalid access`, `missing resource`, or `resource load`.
  - The log contains Godot cleanup-time ObjectDB/resource warnings:
    `4 ObjectDB instances were leaked` and `2 resources still in use at exit`.

## Asset / Animation Evidence

- Runtime node:
  - `/FactoryRouteTransitionShellScene/FactoryCheckpointRearSparkRat`
  - Type: `CharacterBody2D`
  - Entity id: `2105`
  - Default state: `visible=false`, `collision_layer=0`, `collision_mask=0`
- Presentation chain:
  - `/FactoryRouteTransitionShellScene/FactoryCheckpointRearSparkRat/Sprite`
  - Type: `AnimatedSprite2D`
  - SpriteFrames:
    `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Frame counts confirmed by MCP diagnostics:
  - `idle=3`
  - `run=3`
  - `attack_tell=3`
  - `attack=3`
  - `hurt=3`
  - `death=3`

## Godot MCP Runtime Evidence

MCP session used Godot `4.7-stable (official)`.

Runtime tree and default-state probe:

- Runtime tree contained `FactoryCheckpointRearSparkRat` under
  `/FactoryRouteTransitionShellScene`.
- Default diagnostics:
  - `present=true`
  - `available=false`
  - `active=false`
  - `visible=false`
  - `collision_layer=0`
  - `collision_mask=0`
  - `entity_id=2105`
  - `sprite_frames_path` points to the Factory Spark Rat SpriteFrames resource.
- Runtime player node `/FactoryRouteTransitionShellScene/Player/Sprite` was
  `AnimatedSprite2D` using
  `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`.

Activation probe:

- MCP called `set_local_state()` with the prerequisite Old Factory route state,
  including `factory_checkpoint_forward_patrol_defeated=true`.
- MCP moved Cinderpaw past `activation_x=1108` and called
  `try_activate_factory_checkpoint_rear_ambush(player)`.
- Activation result:
  - `activated=true`
  - `visible=true`
  - `active=true`
  - `collision_layer=2`
  - `collision_mask=17`
  - `has_target=true`
  - `physics_enabled=true`
  - `process_enabled=true`
  - route objective `clear_checkpoint_rear_ambush`
  - route label `Clear Rear Ambush`
  - service lift prompt `Clear rear ambush`
  - service lift available `false`

Defeat probe:

- MCP called `apply_damage(2105, 999, {"source": "mcp_checkpoint_rear_ambush"})`.
- Defeat result:
  - `damaged=true`
  - `defeated=true`
  - `active=false`
  - `visible=false`
  - `collision_layer=0`
  - `collision_mask=0`
  - route objective `checkpoint_rear_ambush_cleared`
  - route label `Vent Gauntlet Cleared`
  - service lift prompt `Call lift`
  - service lift available `true`

Logs and screenshot:

- MCP game log after clearing temporary eval failures contained only the helper
  registration line.
- MCP editor log had stale parse rows from the file's half-edited state before
  the successful run; reading from cursor `7` after those rows returned no new
  editor errors.
- MCP game screenshot returned PNG metadata `640x359`, original framebuffer
  `1278x718`, confirming non-empty runtime capture.

## Verdict

PASS. The rear ambush is scene-authored, reuses compliant Factory Spark Rat
frame animation assets, blocks the service lift after the checkpoint vent
gauntlet, persists defeat state, restores route completion after defeat, and
passes focused, related, headless, and MCP 4.7 runtime verification.
