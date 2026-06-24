# Dodge Afterimage + Cinderpaw Dodge Animation Evidence — 2026-06-24

## Scope

Combat Presentation Story 004: add Cinderpaw `dodge` frame animation, expose a
testable player dodge request API, route dodge-start presentation metadata from
MainScene to CombatPresentation, and spawn three textured player afterimages for
dodge readability.

## Asset Pipeline

- Source: built-in image generation, saved under
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/`.
- Workspace source strip:
  `assets/characters/cinderpaw/source/cinderpaw_dodge_strip_imagegen_20260624.png`.
- Runtime frames:
  `assets/characters/cinderpaw/dodge/cinderpaw_dodge_000.png` through `_002.png`.
- Validation: all runtime frames are 96x96 RGBA PNGs with transparent
  background and consistent canvas size.
- Import: `godot --headless --path . --import --quit-after 1` exited `0`.

## TDD Evidence

- RED:
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_dodge_animation_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode`
  - Result: `11` test cases, `0` errors, `8` expected failures, exit `100`
    (`reports/report_346/`).
- GREEN:
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_dodge_animation_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode`
  - Result: `14/14` passing, exit `0` (`reports/report_347/`).

## Regression Evidence

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_dodge_animation_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/player_character_animation_test.gd -a res://tests/unit/combat/story_003_dodge_iframes_hurtbox_adapter_test.gd --ignoreHeadlessMode`
- Result: `23/23` passing, exit `0` (`reports/report_348/`).

## MCP Runtime Evidence

- MCP session: `cinderpaw@c1b2`, Godot `4.6.3-stable (official)`, Godot AI
  server `3.4.2`, plugin `2.7.6`.
- Scene: `res://scenes/main.tscn`, `game_capture_ready = true`.
- Runtime probe:
  - `$Player/Sprite` class: `AnimatedSprite2D`
  - animation after `player.request_dodge()`: `dodge`
  - `dodge` SpriteFrames animation exists
  - `dodge` frame count: `3`
  - dodge frame texture size: 96x96
  - `player.request_dodge()` returned `true`
  - `CombatPresentation.get_active_afterimage_count()` returned `3`
  - `CombatPresentation.get_last_afterimage_alphas()` returned
    `[0.5, 0.3, 0.1]`
  - first afterimage position matched `$Player/Sprite.global_position`
- Logs:
  - game log contained only the Godot AI helper registration line
  - editor log returned `0` lines after clearing
- Screenshot:
  `reports/visual/cinderpaw-mcp-dodge-afterimage-runtime-20260624.png`

## Remaining Gaps

- Perfect-dodge gold afterimage variant remains pending.
- Full character animation set still needs jump, fall, hurt, death, and revive
  frames.
