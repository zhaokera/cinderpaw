# QA Evidence: Old Factory Spark Rat Patrol Encounter

> Story: `production/epics/player-abilities/story-013-old-factory-spark-rat-patrol-encounter.md`
> Date: 2026-06-26
> Result: PASS

## Scope

Story013 adds a distinct Old Factory enemy family, `FactorySparkRat`, using
image-generated frame animation assets. The enemy starts visible but inactive,
activates after the deep-route endpoint opens, can be damaged through the
existing scene combat adapter, and persists defeated state through
`OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.

## Asset Generation

Prompt:

```text
Use case: stylized-concept
Asset type: 2D side-scrolling action game character sprite sheet for Godot AnimatedSprite2D
Primary request: create a factory_spark_rat enemy sprite sheet with 15 frames arranged in a precise 5 rows x 3 columns grid.
Subject: a small hostile cyber-factory rat, soot-gray fur, orange ember eyes, copper wire whiskers, tiny sparking battery harness, readable silhouette, not cute, compact side-view character for a horizontal ACT game.
Animations by row, top to bottom: idle, run, attack, hurt, death. Each row has exactly 3 frames showing clear pose progression. All frames face right and use the same character scale, ground contact point, center anchor, and canvas size.
Style/medium: hand-painted pixel-adjacent 2D game sprite art, crisp edges, high contrast silhouette, production game asset, no text.
Composition/framing: one complete character centered in each grid cell, generous padding, consistent baseline across all cells, no cropping, no overlapping between frames.
Background: perfectly flat solid #00ff00 chroma-key background for background removal. The background must be one uniform color with no shadows, gradients, texture, reflections, floor plane, or lighting variation.
Constraints: exactly 5 rows and 3 columns, transparent-ready chroma-key source, no #00ff00 anywhere in the rat or sparks, no cast shadow, no contact shadow, no watermark, no labels, no UI, no frame numbers. Keep the sheet orthographic and side-on.
```

Generated source:
`assets/characters/factory_spark_rat/source/factory_spark_rat_sprite_sheet_imagegen_20260626.png`

Alpha source:
`assets/characters/factory_spark_rat/source/factory_spark_rat_sprite_sheet_alpha_20260626.png`

Preview sheet:
`assets/characters/factory_spark_rat/source/factory_spark_rat_frames_preview_20260626.png`

Runtime frames:

- `assets/characters/factory_spark_rat/idle/factory_spark_rat_idle_000.png` through `_002.png`
- `assets/characters/factory_spark_rat/run/factory_spark_rat_run_000.png` through `_002.png`
- `assets/characters/factory_spark_rat/attack/factory_spark_rat_attack_000.png` through `_002.png`
- `assets/characters/factory_spark_rat/hurt/factory_spark_rat_hurt_000.png` through `_002.png`
- `assets/characters/factory_spark_rat/death/factory_spark_rat_death_000.png` through `_002.png`

Godot import:

- `godot --headless --path . --import --quit`
- Result: exit `0`; Godot registered `FactorySparkRatCharacter`,
  `FactorySparkRat`, and imported the 15 runtime PNG frames plus source/preview
  audit PNGs.

## Automated Tests

RED:

- `reports/report_672/`
- Command: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_spark_rat_patrol_encounter_test.gd --ignoreHeadlessMode`
- Expected failure: missing `factory_spark_rat` character scene, character
  script, SpriteFrames resource, and Old Factory runtime node/API.

GREEN focused:

- `reports/report_681/`
- Result: `4/4` passed for frame-animation assets, initial inactive mount,
  endpoint-gated activation, damage/defeat, and local-state restore.

Related Old Factory regression:

- `reports/report_675/`: Old Factory deep-route unlock feedback, `5/5`
- `reports/report_676/`: Old Factory deep guard activation pacing, `4/4`
- `reports/report_677/`: Old Factory deep route micro-slice, `4/4`
- `reports/report_678/`: Old Factory entrance combat slice, `4/4`
- `reports/report_679/`: Old Factory room-clear cache, `3/3`
- `reports/report_680/`: Old Factory steam vent hazard, `4/4`

## Smoke

- `reports/old_factory_spark_rat_patrol_factory_scene_smoke.log`: exit `0`
- `reports/old_factory_spark_rat_patrol_main_scene_smoke.log`: exit `0`
- Keyword scan found no parse errors, invalid calls, missing resources, or
  resource-load failures. Both logs retain only the known cleanup-time
  ObjectDB/resource warnings already present in earlier story smoke logs.

## MCP Runtime

MCP session:

- Godot version: `4.6.3-stable`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Run mode: custom scene, `autosave=false`

Runtime probe:

- `FactorySparkRat` exists under `/FactoryRouteTransitionShellScene`.
- `FactorySparkRat/Sprite` is `AnimatedSprite2D`.
- SpriteFrames path:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Animation frame counts: `idle=3`, `run=3`, `attack=3`, `hurt=3`,
  `death=3`.
- Before activation: visible `true`, active `false`, target `false`,
  physics/process `false`, collision layer/mask `0/0`.
- After deep-route endpoint activation and spark-rat activation: active `true`,
  target `true`, physics/process `true`, collision layer/mask `2/17`.
- Damage path: entity id `2102`, HP `24 -> 12 -> defeated`, both damage calls
  returned `true`.
- After defeat: defeated `true`, active `false`, target `false`,
  physics/process `false`, collision layer/mask `0/0`, visible `false`.
- Game logs: no runtime errors; only MCP helper registration line.
- Editor logs: no errors.

Screenshot:

`reports/visual/cinderpaw-mcp-old-factory-spark-rat-patrol-encounter-20260626.png`

The screenshot shows the Old Factory scene with an activated visible Spark Rat
near the deep-route endpoint, using generated character art rather than a
ColorRect, Polygon2D, or single-frame placeholder.
