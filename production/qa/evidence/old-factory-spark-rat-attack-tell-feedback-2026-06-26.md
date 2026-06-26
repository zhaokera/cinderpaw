# QA Evidence: Old Factory Spark Rat Attack Tell Feedback

> Story: `production/epics/player-abilities/story-014-old-factory-spark-rat-attack-tell-feedback.md`
> Date: 2026-06-26
> Result: PASS

## Scope

Story014 adds a readable attack startup animation to the existing Old Factory
`FactorySparkRat` enemy. The enemy keeps the Story013 patrol encounter, entity
id, activation gate, damage metadata, and bite damage contract. Only the attack
startup visual changes: `request_attack()` now plays generated `attack_tell`
frames during startup, then switches back to the existing `attack` frames when
active bite frames begin.

Out of scope remains unchanged: no Boss2, hidden boss, new rooms, savepoints,
minimap, skill-tree UI, patrol spline tooling, NavigationAgent2D,
dodge-counter windows, new enemy family, loot/economy change, shader/camera
polish, SFX requirement, or full Spark Rat AI redesign.

## Asset Generation

Prompt:

```text
Use case: stylized-concept
Asset type: 2D side-scrolling action game character animation strip for Godot AnimatedSprite2D
Primary request: create exactly 3 frames for factory_spark_rat attack_tell / windup animation in a single horizontal row.
Subject: the existing factory_spark_rat enemy, a small hostile cyber-factory rat with soot-gray fur, orange ember eyes, copper wire whiskers, tiny sparking battery harness. It faces right, crouches lower, overcharges, and shows a clear red triangular danger tell before biting.
Animation beats left to right: 000 crouch and coil, 001 sparks building around harness and whiskers, 002 red danger triangle / arcing pre-bite snap pose.
Style/medium: hand-painted pixel-adjacent 2D game sprite art, crisp silhouette, readable at 96x96, production game asset, no text.
Composition/framing: 3 equal cells in one row, one complete character centered in each cell, generous padding, same baseline, same anchor, no cropping, no overlapping frames.
Background: perfectly flat solid #00ff00 chroma-key background for background removal. Background must be uniform with no shadows, gradients, floor plane, reflections, texture, or lighting variation.
Constraints: exactly 3 frames, right-facing side view, same scale as the existing Factory Spark Rat, transparent-ready chroma-key source, no #00ff00 in the rat or sparks, no cast shadow, no contact shadow, no watermark, no labels, no UI, no frame numbers.
```

Generated source:

- `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_sheet_imagegen_20260626.png`

Alpha source:

- `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_sheet_alpha_20260626.png`

Preview:

- `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_preview_20260626.png`

Runtime frames:

- `assets/characters/factory_spark_rat/attack_tell/factory_spark_rat_attack_tell_000.png`
- `assets/characters/factory_spark_rat/attack_tell/factory_spark_rat_attack_tell_001.png`
- `assets/characters/factory_spark_rat/attack_tell/factory_spark_rat_attack_tell_002.png`

Godot import:

- `godot --headless --path . --import --quit`
- Result: exit `0`; Godot imported the 3 runtime `attack_tell` PNGs plus
  source/alpha/preview PNG import metadata.

## Automated Tests

RED:

- `reports/report_684/`
- Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_spark_rat_attack_tell_feedback_test.gd --ignoreHeadlessMode`
- Expected failure: missing `attack_tell` animation in
  `factory_spark_rat_sprite_frames.tres`.

GREEN focused:

- `reports/report_686/`
- Result: `4/4` passed for generated transparent `attack_tell` frames,
  non-looping SpriteFrames setup, startup-to-active animation handoff, metadata
  contract preservation, and no visible placeholder nodes.

Final focused/related submission regression:

- Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_spark_rat_attack_tell_feedback_test.gd -a res://tests/unit/gameplay/old_factory_spark_rat_patrol_encounter_test.gd -a res://tests/unit/gameplay/old_factory_deep_route_unlock_feedback_test.gd -a res://tests/unit/gameplay/old_factory_deep_guard_activation_pacing_test.gd -a res://tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd --ignoreHeadlessMode`
- Result: `reports/report_689/` passed `28/28`.

## Headless Smoke Evidence

Commands:

- `godot --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --quit-after 20 > reports/old_factory_spark_rat_attack_tell_factory_scene_smoke.log 2>&1`
- `godot --headless --path . --scene res://scenes/main.tscn --quit-after 20 > reports/old_factory_spark_rat_attack_tell_main_scene_smoke.log 2>&1`

Result:

- Both commands exited `0`.
- Keyword scan found no script parse, invalid call, missing resource, or
  resource-load errors in either log.
- The logs retain only Godot cleanup-time resource messages at process exit:
  `2 resources still in use at exit` for the Factory scene and
  `1 resources still in use at exit` for the main scene. This is the same
  cleanup category seen in earlier Old Factory headless smoke logs; MCP runtime
  logs below are clean.

## Godot MCP Runtime Evidence

MCP connection:

- Godot: `4.6.3-stable`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Run mode: custom scene, `autosave=false`

Runtime probe:

- `FactorySparkRat` exists in the running game.
- `FactorySparkRat/Sprite` is `AnimatedSprite2D`.
- SpriteFrames path:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Animation frame counts: `attack_tell=3`, `attack=3`.
- `attack_tell` loops: `false`.
- `request_attack()` returned `true`.
- Startup animation immediately after request: `attack_tell`.
- Active-frame animation after `advance_attack_frames(7)`: `attack`.
- Attack metadata still reports source `factory_spark_rat`, weapon id
  `factory_spark_rat_bite`, and base damage `9`.
- Game/editor logs had no runtime errors after the probe.

Screenshot:

`reports/visual/cinderpaw-mcp-old-factory-spark-rat-attack-tell-feedback-20260626.png`

The screenshot captures the Old Factory runtime with the generated Spark Rat
attack-tell art loaded through `AnimatedSprite2D + SpriteFrames`, rather than a
ColorRect, Polygon2D, or single-frame placeholder.
