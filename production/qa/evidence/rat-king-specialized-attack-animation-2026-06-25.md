# QA Evidence: Rat King Specialized Attack Animation — 2026-06-25

## Scope

Verifies Combat Presentation Story015: Rat King uses data-aligned specialized
attack frame animations for `charge`, `claw_swipe`, `summon_minion`, `slam`,
and `berserk_combo` in the playable MainScene runtime.

This evidence does not claim final boss gameplay completion. Physical charge
movement, live summon spawning, arena mutation, boss music/SFX, and final reward
presentation remain separate gameplay/presentation stories.

## Asset Pipeline

- Source: built-in image generation, saved under
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_0e15c563157bf3c6016a3c6d77a8bc81919b2199dd947a5989.png`.
- Workspace source sheet:
  `assets/characters/rat_king/source/rat_king_special_attacks_sheet_imagegen_20260625.png`.
- Alpha-matted source:
  `assets/characters/rat_king/source/rat_king_special_attacks_sheet_alpha_20260625.png`.
- Runtime frames:
  `assets/characters/rat_king/{charge,claw_swipe,summon_minion,slam,berserk_combo}/rat_king_<animation>_000.png`
  through `_002.png`.
- Validation: source sheet was alpha-matted and sliced into 15 transparent
  192x192 PNG frames. Spot checks confirmed frames are not blank and do not
  retain the chroma-key background.
- Import: `godot --headless --path . --import --quit-after 1` exited `0` and
  imported the new Rat King specialized attack PNGs.

## Image Generation Prompt Summary

Built-in image generation created a 5-row by 3-column pixel-art Rat King boss
special-attack sheet on a flat green chroma-key background. Rows specified
`charge`, `claw_swipe`, `summon_minion`, `slam`, and `berserk_combo`; columns
specified wind-up, impact, and recovery poses. The prompt required transparent
pipeline suitability, consistent lower-center anchor, no text, no watermark, no
floor plane, and no green inside the subject.

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_character_animation_test.gd -a res://tests/unit/gameplay/rat_king_specialized_attack_animation_test.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_480/`.

Summary: expected failure. The specialized Rat King animation names and frames
were missing from `rat_king_sprite_frames.tres`.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_character_animation_test.gd -a res://tests/unit/gameplay/rat_king_specialized_attack_animation_test.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_482/`.

Summary: `15/15` passing, `0` errors, `0` failures.

### Related Boss / AI / Gameplay Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/ai -a res://tests/unit/boss -a res://tests/unit/gameplay/rat_king_character_animation_test.gd -a res://tests/unit/gameplay/rat_king_specialized_attack_animation_test.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_484/`.

Summary: `82/82` passing, `0` errors, `0` failures.

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/rat_king_specialized_attack_animation_main_scene_smoke.log
rg -n "ERROR|SCRIPT ERROR|WARNING|Invalid call|Parse Error|FAILED|Failed loading resource|Cannot" reports/rat_king_specialized_attack_animation_main_scene_smoke.log
```

Result: Godot exited normally. `rg` returned `1` because there were no
error/warning keyword matches.

## Godot MCP Evidence

Session:

- Godot version: `4.6.3-stable (official)`
- Editor scene: `res://scenes/main.tscn`
- Editor readiness before runtime: ready
- Runtime state: playing, game capture ready

Runtime probe result:

```json
{
  "ok": true,
  "sprite_class": "AnimatedSprite2D",
  "sprite_frames_path": "res://assets/characters/rat_king/rat_king_sprite_frames.tres",
  "frame_counts": {
    "charge": 3,
    "claw_swipe": 3,
    "summon_minion": 3,
    "slam": 3,
    "berserk_combo": 3
  },
  "pattern_map": {
    "charge": "charge",
    "claw_swipe": "claw_swipe",
    "summon_minion": "summon_minion",
    "slam": "slam",
    "berserk_combo": "berserk_combo"
  },
  "charge": {
    "requested": true,
    "started_animation": "charge",
    "active_animation": "charge",
    "hitbox_active": true,
    "metadata_pattern": "charge"
  },
  "claw_swipe": {
    "requested": true,
    "started_animation": "claw_swipe",
    "active_animation": "claw_swipe",
    "hitbox_active": true,
    "metadata_pattern": "claw_swipe"
  },
  "slam": {
    "requested": true,
    "started_animation": "slam",
    "active_animation": "slam",
    "hitbox_active": true,
    "metadata_pattern": "slam"
  },
  "berserk_combo": {
    "requested": true,
    "started_animation": "berserk_combo",
    "active_animation": "berserk_combo",
    "hitbox_active": true,
    "metadata_pattern": "berserk_combo"
  },
  "summon_minion": {
    "played": true,
    "animation": "summon_minion"
  }
}
```

Logs:

- `logs_read(source="game", count=100)` returned only MCP helper registration
  and DataManager domain load lines for `boss_configs` / `enemy_stats`.
- `logs_read(source="editor", count=100)` returned `0` lines.

Screenshot:

- `editor_screenshot(source="game", max_resolution=960)` returned a nonblank
  `960x540` image.
- Screenshot visibly shows Rat King in the playable arena as an authored
  animated sprite, not a ColorRect, block, or single static placeholder.

## Verdict

PASS. Rat King specialized attack presentation is now connected to the playable
runtime. Data-driven attack ids choose visible specialized animations, hitbox
activation metadata remains intact, and the MainScene no longer presents the
boss attacks through one generic repeated pose.
