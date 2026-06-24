# QA Evidence: Rat King Boss Frame Animation — 2026-06-25

## Scope

Verifies Combat Presentation Story014: the Rat King boss has a first visual
frame-animation slice using the project `AnimatedSprite2D + SpriteFrames`
contract. This evidence covers character scene, frame assets, import pipeline,
and automated character-contract tests. Runtime boss gameplay remains follow-up
work.

## Asset Pipeline

- Source: built-in image generation, saved under
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_029ef4727d859337016a3c582315408191bc07fba7932ecbf2.png`.
- Workspace source sheet:
  `assets/characters/rat_king/source/rat_king_sprite_sheet_imagegen_20260625.png`.
- Alpha-matted source:
  `assets/characters/rat_king/source/rat_king_sprite_sheet_alpha_20260625.png`.
- Runtime frames:
  `assets/characters/rat_king/{idle,attack_tell,attack,hurt,death,phase_1_intro,phase_2_rebuild,phase_3_overload}/rat_king_<animation>_000.png`
  through `_002.png`.
- Validation: `python3` frame audit passed. All 8 runtime animations have 3
  frames, every frame is 192x192 RGBA, and every animation contains transparent
  pixels.
- Import: `godot --headless --path . --import` exited `0` and generated
  26 Rat King `.png.import` sidecars after the `phase_1_intro` addition.

## Image Generation Prompt Summary

Built-in image generation created a 7-row by 3-column pixel-art Rat King boss
sheet on a flat green chroma-key background. The prompt specified a giant
mechanical garbage-bin rat with scrap metal armor, red eyes, attack tell,
attack, hurt, death, phase 2 rebuild, and phase 3 overload poses; it prohibited
text, watermark, floor plane, shadows, and green in the subject.

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_character_animation_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_463/`.

Summary: expected failure because `scenes/characters/rat_king.tscn`,
`src/characters/rat_king.gd`, and
`assets/characters/rat_king/rat_king_sprite_frames.tres` did not exist.

### Import Correction

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_character_animation_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_464/`.

Summary: the scene and SpriteFrames existed, but new PNGs had not yet entered
the Godot import pipeline. The fix was to run `godot --headless --path .
--import`, which generated the `.png.import` sidecars required by the
Texture2D loader.

### GREEN

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_character_animation_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_466/`.

Summary: `2/2` passing, `0` errors, `0` failures.

### Focused Visual Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_character_animation_test.gd -a res://tests/unit/gameplay/player_character_animation_test.gd -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_467/`.

Summary: `12/12` passing, `0` errors, `0` failures.

### Headless Scene Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/characters/rat_king.tscn --fixed-fps 60 --quit-after 2 --log-file reports/rat_king_character_scene_smoke.log
```

Result: exit `0`.

Log scan:

```bash
rg -n "ERROR|SCRIPT ERROR|WARNING|Invalid call|Parse Error|FAILED" reports/rat_king_character_scene_smoke.log || true
```

Result: no matches.

## Godot MCP Evidence

Session:

- Godot version: `4.6.3-stable (official)`
- Scene: `res://scenes/characters/rat_king.tscn`
- Editor state: ready before run, playing during current-scene probe, ready
  after stop.

Editor-scene probe:

```json
{
  "root": "/RatKing",
  "type": "AnimatedSprite2D",
  "sprite_frames": "res://assets/characters/rat_king/rat_king_sprite_frames.tres",
  "animation": "idle",
  "script": "res://src/characters/rat_king.gd"
}
```

Runtime probe:

```json
{
  "scene_name": "RatKing",
  "class": "AnimatedSprite2D",
  "is_animated_sprite": true,
  "visible": true,
  "animation": "idle",
  "frames_path": "res://assets/characters/rat_king/rat_king_sprite_frames.tres",
  "animations": {
    "attack": 3,
    "attack_tell": 3,
    "death": 3,
    "hurt": 3,
    "idle": 3,
    "phase_1_intro": 3,
    "phase_2_rebuild": 3,
    "phase_3_overload": 3
  },
  "frame_sizes": {
    "all": "192x192"
  }
}
```

Logs:

- `logs_read(source="game", count=120)` returned only the MCP helper
  registration line.
- `logs_read(source="editor", count=120)` returned `0` lines.

Screenshot:

- MCP `editor_screenshot(source="game", max_resolution=640)` returned a
  nonblank 640x360 image, original framebuffer 1280x720. The first capture
  showed the root sprite clipped at the scene origin; the runtime-only probe
  moved the root to the viewport center without saving the scene, then captured
  a centered Rat King image.

## Verdict

PASS. Rat King now has an imported, visible frame-animation character asset
slice instead of existing only as data. Runtime BossConfig/AI integration remains
the next gameplay step.
