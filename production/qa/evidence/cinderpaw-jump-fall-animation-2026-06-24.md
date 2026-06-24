# Cinderpaw Jump and Fall Animation Evidence — 2026-06-24

## Scope

Combat Presentation Story 006: add Cinderpaw `jump` and `fall` frame
animations, wire them into `PlayerController` airborne movement state, and
preserve higher-priority combat, dodge, damage, death, and revive animations.

## Asset Pipeline

- Source: built-in image generation, saved under
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_0df305f576510a95016a3b909135688191a488505385bacc60.png`.
- Prompt summary: 2x3 stylized Cinderpaw sprite sheet on flat `#00ff00`
  chroma-key background, top row for jump and bottom row for fall, consistent
  cat-warrior identity, scale, and anchor.
- Workspace source sheet:
  `assets/characters/cinderpaw/source/cinderpaw_jump_fall_sheet_imagegen_20260624.png`.
- Alpha source sheet:
  `assets/characters/cinderpaw/source/cinderpaw_jump_fall_sheet_alpha_20260624.png`.
- Runtime frames:
  - `assets/characters/cinderpaw/jump/cinderpaw_jump_000.png` through `_002.png`
  - `assets/characters/cinderpaw/fall/cinderpaw_fall_000.png` through `_002.png`
- Processing: chroma-key background removed with
  `$CODEX_HOME/skills/.system/imagegen/scripts/remove_chroma_key.py`, then each
  cell was alpha-cropped, resized with consistent scale, and centered into a
  96x96 RGBA canvas with transparent corners and shared baseline.
- Import: `godot --headless --path . --import --quit-after 1` exited `0`.

## TDD Evidence

- RED:
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_air_animation_test.gd --ignoreHeadlessMode`
  - Result: exit `100`; failed because `jump` and `fall` SpriteFrames
    animations were absent.
- GREEN:
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_air_animation_test.gd --ignoreHeadlessMode`
  - Result: `8/8` passing, exit `0`.

## Regression Evidence

- Focused gameplay regression:
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_air_animation_test.gd -a res://tests/unit/gameplay/player_character_animation_test.gd -a res://tests/unit/gameplay/player_dodge_animation_test.gd -a res://tests/unit/gameplay/player_hurt_death_revive_animation_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/player_respawn_visual_feedback_test.gd -a res://tests/unit/gameplay/game_flow_controller_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd --ignoreHeadlessMode`
  - Result: `32/32` passing, exit `0`.
- Headless main-scene smoke:
  - Command:
    `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/cinderpaw_jump_fall_main_scene_smoke.log`
  - Result: exit `0`; log scan found no `ERROR`, `WARNING`,
    `SCRIPT ERROR`, `Parse Error`, `Invalid access`, `Invalid call`,
    `Failed`, or `Cannot`.

## MCP Runtime Evidence

- MCP server: Godot AI `3.4.2` over `http://127.0.0.1:8000/mcp`.
- Active session: `cinderpaw@c1b2`.
- Godot editor state: `4.6.3-stable (official)`, `res://scenes/main.tscn`,
  `is_playing=true`, `game_capture_ready=true`.
- Runtime metadata probe:
  - Player sprite class: `AnimatedSprite2D`.
  - Player script: `res://src/gameplay/player_controller.gd`.
  - SpriteFrames animations include `attack`, `death`, `dodge`, `fall`,
    `hurt`, `idle`, `jump`, `revive`, and `run`.
  - `jump_count=3`, `fall_count=3`.
  - `jump_size_0=96x96`, `fall_size_0=96x96`.
  - `_get_locomotion_animation(true, Vector2(0, -120))` returns `jump`,
    covering the Godot floor-contact cache edge found during MCP probing.
  - Upward runtime physics frame result: `after_jump=jump`.
  - Downward runtime physics frame result: `after_fall=fall`.
- MCP log check: final game log contained only the MCP helper registration
  line; final editor log returned `0` lines after clearing probe syntax noise.
- Runtime screenshot:
  `reports/visual/cinderpaw-mcp-jump-fall-runtime-20260624.png`.

## Remaining Gaps

- Landing dust, double-jump polish, and broader movement ability visuals remain
  separate stories.
