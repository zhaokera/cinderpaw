# QA Evidence: Damage Number Tier Polish — 2026-06-24

## Scope

Verifies Combat Presentation Story 008. The slice completes the GDD six-tier
damage-number visual language using existing Godot `Label` styling, without
changing Core damage, weapon tuning, enemy HP, or HUD menu persistence.

## Story

- Story:
  `production/epics/combat-presentation/story-008-damage-number-tier-polish.md`
- Requirements: `TR-combatfx-005`, `TR-combatfx-007`
- Runtime implementation:
  `src/presentation/combat_presentation.gd`
- Tests:
  `tests/unit/presentation/combat_presentation_test.gd`
- Asset note: no new image asset was needed. This story uses Label font size,
  color, outline, tween, and lifetime styling. Earlier experimental boss-phase
  image-generation outputs were discarded and are not referenced by project
  files.

## Automated Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode
```

Result: exit `100`, expected failures in
`test_damage_number_tiers_match_gdd_size_color_and_outline`,
`reports/report_355/`.

Observed failure:

- Damage `31` still used the yellow tier instead of gold.
- Damage `61` still used the yellow tier instead of cat-eye gold.
- Damage `151` used `36px` with no white outline instead of the GDD highest
  tier.

### GREEN

Focused command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `17/17` passing, `reports/report_356/`.

Related regression command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `26/26` passing, `reports/report_357/`.

### Headless Main Scene Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/damage_number_story008_main_scene_smoke.log
rg -n "ERROR|Error|error|WARNING|Warning|warning|Parse Error|SCRIPT ERROR|Invalid call|Failed" reports/damage_number_story008_main_scene_smoke.log
```

Result: Godot exited `0`; log scan returned no matches.

## Godot MCP Runtime Evidence

- Godot: `4.6.3-stable (official)`
- Scene: `res://scenes/main.tscn`
- Logs:
  - Game log contained only the MCP helper registration line.
  - Editor log returned zero error/warning lines.

Runtime probe:

```json
{
  "scene": "Main",
  "active_damage_numbers": 1,
  "last_text": "151",
  "last_color": "ecc94b",
  "last_font_size": 48,
  "last_outline_size": 2,
  "last_float_distance": 30,
  "last_lifetime": 1.5,
  "labels": [
    {
      "text": "151",
      "font_size": 48,
      "font_color": "ecc94b",
      "outline_size": 2,
      "outline_color": "ffffff"
    }
  ],
  "player_sprite_class": "AnimatedSprite2D",
  "enemy_sprite_class": "AnimatedSprite2D",
  "player_animation_count": 9,
  "enemy_animation_count": 6,
  "screenshot_save_error": 0
}
```

Screenshot:

- `reports/visual/cinderpaw-mcp-damage-number-tier-polish-20260624.png`

## Acceptance Criteria Mapping

| Acceptance Criterion | Evidence | Status |
|----------------------|----------|--------|
| Six GDD damage tiers map to `12/16/20/28/36/48` font sizes. | `test_damage_number_tiers_match_gdd_size_color_and_outline`. | PASS |
| Tier colors and highest-tier white outline are readable. | Focused test + MCP `font_color=ecc94b`, `outline_size=2`, `outline_color=ffffff`. | PASS |
| Damage numbers float 30px and expire after 1.5s. | `test_damage_number_records_gdd_float_distance_and_lifetime`. | PASS |
| `show_damage_number=false` only suppresses the Label. | Existing toggle regression in presentation and MainScene HUD settings suites. | PASS |
| Boundary values are safe. | `test_damage_number_boundary_values_clamp_to_valid_tiers`. | PASS |
| Ten rapid hits clean up without stale active entries. | `test_rapid_damage_numbers_cleanup_without_stale_active_entries`. | PASS |
| MCP validates runtime logs, screenshot, and Story007 visual contract. | MCP probe, clean logs, screenshot path above. | PASS |

## Verdict

PASS. Story 008 completes the GDD damage-number visual tier language and keeps
the implementation Presentation-only.
