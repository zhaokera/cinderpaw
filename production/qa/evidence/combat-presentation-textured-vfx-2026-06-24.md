# QA Evidence: Combat Presentation Textured VFX — 2026-06-24

## Scope

Verifies that hit sparks and enemy kill debris no longer render as square
`ColorRect` prototype blocks. Runtime CombatPresentation VFX now uses
image-generated transparent PNG textures through `Sprite2D` nodes.

## Automated Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode
```

Result: exit `100`.

Observed failure: `test_hit_feedback_uses_textured_sprite_vfx_not_color_rect_blocks`
found `0` textured `Sprite2D` VFX and `6` `ColorRect` spark blocks.

### GREEN

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode
```

Result: exit `0`.

Summary: `6/6` passing, `0` errors, `0` failures.

### Headless Main Scene Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/combat_presentation_textured_vfx_main_scene_smoke.log
rg -n "ERROR|Error|error|WARNING|Warning|warning|Parse Error|SCRIPT ERROR" reports/combat_presentation_textured_vfx_main_scene_smoke.log
```

Result: Godot exited `0`; log scan returned no matches.

## Godot MCP Runtime Evidence

- MCP server: Godot AI 3.4.2 over `http://127.0.0.1:8000/mcp`.
- Runtime session: `cinderpaw@c4d7`, Godot `4.6.3-stable (official)`,
  `res://scenes/main.tscn`.
- Runtime `game_eval` probe after triggering hit + kill feedback:

```json
{
  "scene": "Main",
  "sparks": 12,
  "debris": 18,
  "sprite_count": 30,
  "textured_sprite_count": 30,
  "color_rect_count": 0,
  "texture_paths": [
    "res://assets/generated/combat_hit_spark.png",
    "res://assets/generated/combat_enemy_debris.png"
  ]
}
```

- Game logs: `logs_read(source="game", count=80)` returned only the MCP helper
  registration line; no runtime error or warning entries were reported by the
  game log buffer.
- Screenshot: `reports/visual/cinderpaw-mcp-textured-combat-vfx-20260624.png`.

## Verdict

PASS. Combat hit and kill feedback now uses generated textured VFX sprites in
runtime Godot, and the MCP screenshot confirms a nonblank 2D game scene with
visible non-square hit/debris effects.
