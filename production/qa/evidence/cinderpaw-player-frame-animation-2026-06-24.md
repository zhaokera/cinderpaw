# Cinderpaw Player Frame Animation Evidence — 2026-06-24

## Scope

Combat Presentation Story 003: replace the static player `Sprite2D` visual with
`AnimatedSprite2D + SpriteFrames`, generated Cinderpaw idle/run/attack frames,
and runtime animation switching from `PlayerController`.

## Asset Pipeline

- Source: built-in image generation, saved under
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/`.
- Workspace source sheet:
  `assets/characters/cinderpaw/source/cinderpaw_sprite_sheet_chroma.png`.
- Runtime frames:
  - `assets/characters/cinderpaw/idle/cinderpaw_idle_000.png` through `_002.png`
  - `assets/characters/cinderpaw/run/cinderpaw_run_000.png` through `_002.png`
  - `assets/characters/cinderpaw/attack/cinderpaw_attack_000.png` through `_002.png`
- Validation: all runtime frames are 96x96 PNG with transparent corners and
  consistent canvas size.
- Import: `godot --headless --path . --import --quit-after 1` exited `0`.

## TDD Evidence

- RED:
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_character_animation_test.gd --ignoreHeadlessMode`
  - Result: failed because `$Sprite` was not `AnimatedSprite2D`
    (`reports/report_345/`).
- GREEN:
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_character_animation_test.gd --ignoreHeadlessMode`
  - Result: `3/3` passing, exit `0` (`reports/report_346/`).

## Regression Evidence

- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_respawn_visual_feedback_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd --ignoreHeadlessMode`
- Result: `5/5` passing, exit `0` (`reports/report_347/`).
- Final focused regression command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_character_animation_test.gd -a res://tests/unit/gameplay/player_respawn_visual_feedback_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode`
- Final focused regression result: `17/17` passing, exit `0`
  (`reports/report_344/`).
- Headless smoke command:
  `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/cinderpaw_player_frame_animation_main_scene_smoke.log`
- Headless smoke result: exit `0`; log scan found no `ERROR`, `WARNING`,
  `SCRIPT ERROR`, `Parse Error`, or `Invalid access` lines.

## MCP Runtime Evidence

- MCP session: `cinderpaw@c1b2`, Godot `4.6.3-stable (official)`, Godot AI
  plugin `2.7.6`, server `3.4.2`.
- Scene: `res://scenes/main.tscn`, `game_capture_ready = true`.
- Runtime probe:
  - `$Player/Sprite` class: `AnimatedSprite2D`
  - script class: `CinderpawCharacter`
  - animations: `attack`, `idle`, `run`
  - frame counts: `attack=3`, `idle=3`, `run=3`
  - frame sizes: 96x96 for all three animations
  - `player.request_attack()` returned `true`
  - animation after attack: `attack`
- Logs:
  - game log contained only the Godot AI helper registration line
  - editor log returned `0` lines after clearing
- Screenshot:
  `reports/visual/cinderpaw-mcp-player-frame-animation-runtime-20260624.png`

## Remaining Gaps

- Full character animation set still needs jump, fall, dodge, hurt, death, and
  revive frames.
- Dodge afterimages remain a separate Combat Presentation story.
