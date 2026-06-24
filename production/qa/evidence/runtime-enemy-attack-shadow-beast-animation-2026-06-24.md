# QA Evidence: Runtime Enemy Attack + Shadow Beast Frame Animation — 2026-06-24

## Scope

Verifies Feline Combat Story 009: the runtime enemy uses a frame-animated
Shadow Beast presentation and deals reciprocal combat pressure through the Core
collision/combat/damage/health chain.

## Asset Pipeline

- Source: built-in image generation, saved under
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_0df61aef1a5a9ba4016a3b76d438108191b07bcd2fe43ffb9b.png`.
- Workspace source sheet:
  `assets/characters/shadow_beast/source/shadow_beast_sprite_sheet_imagegen_20260624.png`.
- Runtime frames:
  `assets/characters/shadow_beast/{idle,patrol,attack_tell,attack,hurt,death}/shadow_beast_<animation>_000.png`
  through `_002.png`.
- Validation: all runtime frames are 96x96 RGBA PNGs with transparent
  background and consistent canvas size; post-processing validation reported
  `suspicious_green_pixels=0`.
- Import: `godot --headless --path . --import --quit-after 1` exited `0`.

## Automated Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: exit `100`. Expected failures covered missing Shadow Beast scene/script,
static enemy sprite, missing enemy attack API, missing player `apply_damage`,
and absent runtime hit feedback.

### GREEN

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_346/`.

Summary: `5/5` passing, `0` errors, `0` failures.

### Focused Regression

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/combat/story_007_hit_confirmation_focus_damage_metadata_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_347/`.

Summary: `12/12` passing, `0` errors, `0` failures.

## Godot MCP Runtime Evidence

Session:

- MCP server: `Godot AI 3.4.2`
- Godot session: `cinderpaw@c1b2`
- Godot version: `4.6.3-stable (official)`
- Scene: `res://scenes/main.tscn`

Runtime Shadow Beast probe after MCP restart:

```json
{
  "request_ok": true,
  "sprite_class": "AnimatedSprite2D",
  "sprite_animation": "attack",
  "attack_tell_frames": 3,
  "attack_frames": 3,
  "active_after_tell": true,
  "before_hp": 100,
  "after_hp": 88,
  "damage_numbers_before": 0,
  "damage_numbers_after": 1,
  "metadata": {
    "hitbox_id": "shadow_beast_bite",
    "weapon_id": "shadow_beast_bite",
    "target_id": 1,
    "final_damage": 12,
    "damage_category": "normal"
  }
}
```

Logs:

- `logs_read(source="game", count=80)` returned only the MCP helper
  registration line.
- `logs_read(source="editor", count=80)` returned `0` lines after clearing.

Screenshot:

- `reports/visual/cinderpaw-mcp-enemy-attack-animation-runtime-20260624.png`

## Verdict

PASS. Runtime enemy attacks now use the Core hit confirmation path and the
Shadow Beast no longer reads as a static placeholder.
