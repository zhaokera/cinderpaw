# Cinderpaw Hurt, Death, and Revive Animation Evidence — 2026-06-24

## Scope

Combat Presentation Story 005: add Cinderpaw `hurt`, `death`, and `revive`
frame animations, wire them into `PlayerController` damage/death/respawn state
changes, and preserve the existing death-respawn HP and invincibility feedback.

## Asset Pipeline

- Source: built-in image generation, saved under
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_01e57c6bf6c3a1f0016a3b88000fb88191898ee41249c77f4a.png`.
- Prompt summary: 3x3 pixel-art Cinderpaw sprite sheet on flat `#00ff00`
  chroma-key background, rows for hurt, death, and revive, consistent side-view
  cat-warrior identity and anchor.
- Workspace source sheet:
  `assets/characters/cinderpaw/source/cinderpaw_hurt_death_revive_sheet_imagegen_20260624.png`.
- Alpha source sheet:
  `assets/characters/cinderpaw/source/cinderpaw_hurt_death_revive_sheet_alpha_20260624.png`.
- Runtime frames:
  - `assets/characters/cinderpaw/hurt/cinderpaw_hurt_000.png` through `_002.png`
  - `assets/characters/cinderpaw/death/cinderpaw_death_000.png` through `_002.png`
  - `assets/characters/cinderpaw/revive/cinderpaw_revive_000.png` through `_002.png`
- Processing: chroma-key background removed with
  `$CODEX_HOME/skills/.system/imagegen/scripts/remove_chroma_key.py`, then each
  cell was cropped, nearest-neighbor scaled, and centered into a 96x96 RGBA
  canvas with transparent corners and consistent baseline.
- Import: `godot --headless --path . --import --quit-after 1` exited `0`.

## TDD Evidence

- RED:
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_hurt_death_revive_animation_test.gd --ignoreHeadlessMode`
  - Result: exit `100`; failed because `hurt`, `death`, and `revive`
    SpriteFrames animations were absent (`reports/report_350/`).
- GREEN:
  - Command:
    `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_hurt_death_revive_animation_test.gd --ignoreHeadlessMode`
  - Result: `5/5` passing, exit `0` (`reports/report_352/`).

## Regression Evidence

- Focused regression command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/player_hurt_death_revive_animation_test.gd -a res://tests/unit/gameplay/player_character_animation_test.gd -a res://tests/unit/gameplay/player_dodge_animation_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd -a res://tests/unit/gameplay/player_respawn_visual_feedback_test.gd -a res://tests/unit/gameplay/game_flow_controller_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd --ignoreHeadlessMode`
- Result: `22/22` passing, exit `0` (`reports/report_353/`).
- Headless smoke command:
  `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/cinderpaw_hurt_death_revive_main_scene_smoke.log`
- Headless smoke result: exit `0`; log scan found no `ERROR`, `WARNING`,
  `SCRIPT ERROR`, `Parse Error`, `Invalid access`, `Failed`, or `Cannot` lines.

## MCP Runtime Evidence

- MCP session: `cinderpaw@c1b2`, Godot `4.6.3-stable (official)`, Godot AI
  plugin `2.7.6`, server `3.4.2`.
- Scene: `res://scenes/main.tscn`, `game_capture_ready = true`.
- Runtime probe:
  - `$Player/Sprite` class: `AnimatedSprite2D`
  - script class: `CinderpawCharacter`
  - animations: `attack`, `death`, `dodge`, `hurt`, `idle`, `revive`, `run`
  - frame counts: `hurt=3`, `death=3`, `revive=3`
  - frame sizes: `hurt=96x96`, `death=96x96`, `revive=96x96`
  - non-lethal `player.apply_damage(12, ...)` set animation to `hurt`
  - lethal `player.apply_damage(player.get_current_hp(), ...)` set animation
    to `death`
  - `player.respawn_at(Vector2(96, 112), 0.5)` set animation to `revive`
  - revive HP returned `50`
  - respawn visual remained active with sprite alpha approximately `0.42`
- Logs:
  - final game log contained only the Godot AI helper registration line
  - final editor log returned `0` lines after clearing MCP plugin debug logs
- Screenshot:
  `reports/visual/cinderpaw-mcp-hurt-death-revive-runtime-20260624.png`

## Remaining Gaps

- Cinderpaw still needs jump and fall animation coverage.
- Death dissolve particles and revive ring VFX remain separate visual stories.
