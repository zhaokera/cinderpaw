# QA Evidence: HUD Story 004 Settings + Accessibility Controls

> **Story**: `production/epics/hud-ui/story-004-settings-accessibility-controls.md`
> **Date**: 2026-06-24
> **Result**: PASS

## GdUnit Evidence

- RED confirmed first: missing `menu_settings_requested`, `SettingsButton`,
  settings APIs, and `show_damage_number=false` handling produced expected
  failures.
- `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/hud_manager_test.gd --ignoreHeadlessMode`
  - PASS: 11/11.
- `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode`
  - PASS: 11/11.
- `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd --ignoreHeadlessMode`
  - PASS: 2/2.
- Focused regression after warning fix:
  - `hud_manager_test.gd`, `main_scene_hud_settings_runtime_test.gd`,
    `combat_presentation_test.gd`
  - PASS: 24/24.
- UI/animation regression:
  - `hud_manager_test.gd`, `main_scene_hud_settings_runtime_test.gd`,
    `combat_presentation_test.gd`, `player_character_animation_test.gd`,
    `simple_enemy_character_animation_test.gd`
  - PASS: 30/30.

## Godot Smoke

- `godot --headless --path . --quit --log-file reports/hud_story004_project_boot.log`
  - Exit code 0.
- `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/hud_story004_main_scene_smoke.log`
  - Exit code 0.
- `rg -n "ERROR|WARNING|SCRIPT ERROR|Parse Error|Invalid access" reports/hud_story004_*.log`
  - No matches.

## MCP Runtime Evidence

- MCP endpoint: `http://127.0.0.1:8000/mcp`
- Server: Godot AI `3.4.2`
- Godot session: `cinderpaw@c1b2`
- Godot version: `4.6.3-stable (official)`
- Scene: `res://scenes/main.tscn`

Runtime probe result:

```json
{
  "settings_mode": "settings",
  "settings_focus": "Back",
  "settings_groups": ["Audio", "Display", "Controls", "Gameplay"],
  "focus_after_back": "Settings",
  "overlap_150": false,
  "hp_label_rg": "20 / 100",
  "hp_color_rg": "f6e05e",
  "start_hp": 100,
  "hp_after_enemy_hit": 88,
  "damage_numbers_after_toggle_off": 0,
  "sparks_after_toggle_off": 6,
  "battle_summary_mode": "battle_summary",
  "battle_summary_title": "Hunter's Lesson"
}
```

MCP logs:

- Game log: only `[godot_ai game_helper] registered mcp capture`.
- Editor log: empty after warning fix.

## Screenshot Evidence

- `reports/visual/cinderpaw-mcp-hud-settings-menu-20260624.png`
- `reports/visual/cinderpaw-mcp-hud-scale-150-colorblind-red-green-20260624.png`
- `reports/visual/cinderpaw-mcp-damage-number-toggle-off-20260624.png`
- `reports/visual/cinderpaw-mcp-battle-summary-toggle-panel-20260624.png`

## Notes

- No new visual assets were required for this UI story.
- Story 006 remains the right follow-up for full HUD scale/colorblind validation
  and settings persistence handoff.
