# QA Evidence: Parry Flash + Cat Claw Trail — 2026-06-24

## Scope

Verifies CombatPresentation Story 002: PERFECT parry presentation feedback and
Cat Claw attack-start slash trails. This evidence covers presentation events,
generated VFX assets, MainScene attack-start routing, Godot asset import, and
MCP runtime validation. Core player parry input integration is out of scope.

## Story

- Story: `production/epics/combat-presentation/story-002-parry-flash-cat-claw-trail.md`
- Requirements: `TR-combatfx-003`, `TR-combatfx-004`
- Runtime assets:
  - `res://assets/generated/combat_parry_spark.png`
  - `res://assets/generated/combat_claw_trail.png`

## Automated Evidence

### RED

Commands:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: exit `100` before implementation.

Observed failures:

- `CombatPresentation` had no `on_parry_event()` or `on_weapon_attack_event()`.
- MainScene runtime attack contract did not expose `get_active_trail_count()`.

### GREEN

Commands:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd --ignoreHeadlessMode
```

Results:

- Presentation suite: `9/9` passing, exit `0`, latest local report
  `reports/report_348/`.
- MainScene attack chain suite: `2/2` passing, exit `0`, latest local report
  `reports/report_349/`.

### Headless Main Scene Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/combat_presentation_parry_trail_main_scene_smoke.log
rg -n "ERROR|Error|error|WARNING|Warning|warning|Parse Error|SCRIPT ERROR|Invalid call|Failed" reports/combat_presentation_parry_trail_main_scene_smoke.log
```

Result: Godot exited `0`; log scan returned no matches.

## Godot MCP Runtime Evidence

- MCP server: Godot AI 3.4.2 over `http://127.0.0.1:8000/mcp`.
- Runtime session: `cinderpaw@c1b2`, Godot `4.6.3-stable (official)`.
- Scene: `res://scenes/main.tscn`.
- MCP editor state: `is_playing=true`, `game_capture_ready=true`.

Runtime `game_eval` probe after triggering `Player.request_attack()` and a
PERFECT parry presentation event:

```json
{
  "scene": "Main",
  "attack_request": true,
  "trails": 3,
  "parry_sparks": 22,
  "flashes": 1,
  "last_flash_alpha": 0.8,
  "hitstop": 8,
  "shake": 8,
  "sprite_count": 25,
  "textured_sprite_count": 25,
  "color_rect_count": 0,
  "texture_paths": [
    "res://assets/generated/combat_claw_trail.png",
    "res://assets/generated/combat_parry_spark.png"
  ]
}
```

Log checks:

- `logs_read(source="game", count=80)` returned only the MCP helper
  registration line.
- `logs_read(source="editor", count=80, include_details=true)` returned `0`
  editor error/warning lines after plugin reload, resource reimport, and clean
  restart.

Screenshot:

- `reports/visual/cinderpaw-mcp-parry-claw-trail-runtime-20260624.png`

## Acceptance Criteria Mapping

| Acceptance Criterion | Evidence | Status |
|----------------------|----------|--------|
| PERFECT parry applies 8 hitstop frames, 8px shake, 80% white flash, and 20-25 radial sparks. | Presentation test + MCP `hitstop=8`, `shake=8`, `last_flash_alpha=0.8`, `parry_sparks=22`. | PASS |
| Cat Claw attack start spawns exactly 3 textured slash trails for 0.4s. | Presentation test + MainScene test + MCP `trails=3`, texture path `combat_claw_trail.png`. | PASS |
| Non-Cat-Claw attack-start events do not spawn Cat Claw trails. | `test_non_cat_claw_attack_does_not_spawn_claw_trails`. | PASS |
| MainScene player light attack routes attack-start metadata to CombatPresentation. | `test_player_light_attack_damages_enemy_through_core_chain_once`; MCP `attack_request=true`, `trails=3`. | PASS |
| New VFX assets use image generation and Godot import pipeline. | `assets/generated/combat_parry_spark*.png`, `assets/generated/combat_claw_trail*.png`, `.import` files, asset manifest entries. | PASS |
| Runtime validation through Godot MCP confirms VFX and captures nonblank 2D screenshot. | MCP `game_eval`, clean game/editor logs, screenshot path above. | PASS |

## Verdict

PASS. PERFECT parry and Cat Claw attack-start feedback now use generated
textured VFX sprites in runtime Godot, MainScene routes player attack-start
metadata into CombatPresentation, and MCP confirms clean runtime logs plus a
nonblank 2D screenshot.
