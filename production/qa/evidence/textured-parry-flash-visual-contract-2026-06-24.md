# QA Evidence: Textured Parry Flash + Main Scene Visual Contract — 2026-06-24

## Scope

Verifies Combat Presentation Story 007. The slice replaces the PERFECT parry
full-screen flash `ColorRect` with an image-generated textured overlay and adds
a main-scene visual contract for player-visible character presentation.

## Story

- Story:
  `production/epics/combat-presentation/story-007-textured-parry-flash-visual-contract.md`
- Requirements: `TR-combatfx-006`, `TR-combatfx-010`
- Runtime asset:
  `res://assets/generated/combat_parry_flash_overlay.png`
- Image generation source:
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_098c6ebe78dace7c016a3bc4fee8a88191817f709080dc93d9.png`

## Image Generation Prompt Summary

Full-screen 16:9 pixel-art PERFECT parry flash overlay for a Godot combat
`TextureRect`: 80%-white flash, cat-eye gold radial energy, blade-like rays,
signal-red flecks, crisp game-ready VFX texture, no characters, no text, no UI,
and no pure flat rectangle.

## Automated Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd --ignoreHeadlessMode
```

Result: exit `100`, `10` executed tests, `2` failures,
`reports/report_350/`.

Observed failure:

- `test_perfect_parry_flash_uses_textured_overlay_not_color_rect` found one
  nested `ColorRect` and zero `TextureRect` overlays after PERFECT parry.

### GREEN

Focused command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `14/14` passing, `reports/report_353/`.

Related visual regression command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd -a res://tests/unit/gameplay/player_character_animation_test.gd -a res://tests/unit/gameplay/player_dodge_animation_test.gd -a res://tests/unit/gameplay/player_hurt_death_revive_animation_test.gd -a res://tests/unit/gameplay/player_air_animation_test.gd -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `39/39` passing, `reports/report_354/`.

### Asset Import

Command:

```bash
godot --headless --path . --import --quit-after 1
```

Result: exit `0`. Godot imported
`assets/generated/combat_parry_flash_overlay.png`.

### Headless Main Scene Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/combat_presentation_story007_main_scene_smoke.log
rg -n "ERROR|Error|error|WARNING|Warning|warning|Parse Error|SCRIPT ERROR|Invalid call|Failed" reports/combat_presentation_story007_main_scene_smoke.log
```

Result: Godot exited `0`; log scan returned no matches.

## Godot MCP Runtime Evidence

- MCP session: `cinderpaw@c1b2`
- Godot: `4.6.3-stable (official)`
- Scene: `res://scenes/main.tscn`
- Logs:
  - Game log contained only the MCP helper registration line.
  - Editor log returned zero error/warning lines.

Runtime PERFECT parry probe after restarting the game:

```json
{
  "scene": "Main",
  "player_sprite_class": "AnimatedSprite2D",
  "enemy_sprite_class": "AnimatedSprite2D",
  "player_animation_count": 9,
  "enemy_animation_count": 6,
  "player_has_required": true,
  "enemy_has_required": true,
  "flashes": 1,
  "last_flash_alpha": 0.8,
  "parry_sparks": 22,
  "hitstop": 8,
  "shake": 8,
  "color_rect_count": 0,
  "texture_rect_count": 1,
  "texture_rect_paths": [
    "res://assets/generated/combat_parry_flash_overlay.png"
  ],
  "screenshot_save_error": 0
}
```

Screenshots:

- Textured parry flash:
  `reports/visual/cinderpaw-mcp-textured-parry-flash-20260624.png`
- Clean main-scene visual contract:
  `reports/visual/cinderpaw-mcp-main-scene-visual-contract-20260624.png`

## Acceptance Criteria Mapping

| Acceptance Criterion | Evidence | Status |
|----------------------|----------|--------|
| PERFECT parry still applies 8 hitstop frames, 8px shake, 80%-alpha full-screen flash, and 20-25 radial sparks. | Focused test suite + MCP probe `hitstop=8`, `shake=8`, `last_flash_alpha=0.8`, `parry_sparks=22`. | PASS |
| PERFECT parry flash uses a textured overlay node with generated/imported texture, not visible `ColorRect`. | `test_perfect_parry_flash_uses_textured_overlay_not_color_rect`; MCP `TextureRect=1`, `ColorRect=0`, texture path `combat_parry_flash_overlay.png`. | PASS |
| `main.tscn` visual contract confirms Player and Enemy runtime visuals are `AnimatedSprite2D` with `SpriteFrames`. | `main_scene_visual_contract_test.gd`; MCP Player/Enemy class and animation counts. | PASS |
| `main.tscn` startup has no visible gameplay `ColorRect` blocks. | `test_main_scene_startup_has_no_visible_gameplay_color_rect_blocks`. | PASS |
| VFX texture provenance is recorded. | `design/assets/asset-manifest.md` + source image path above. | PASS |
| Godot MCP validates runtime logs, nodes, and screenshot. | MCP probe, clean logs, screenshots above. | PASS |

## Verdict

PASS. Story 007 removes the remaining PERFECT parry `ColorRect` flash from
CombatPresentation, uses an image-generated full-screen texture overlay, and
adds a regression contract that prevents main-scene character visuals from
returning to square/static placeholders.
