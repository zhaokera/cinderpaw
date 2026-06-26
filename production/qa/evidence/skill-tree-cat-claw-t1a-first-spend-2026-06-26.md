# QA Evidence: Skill Tree Cat Claw T1-A First Spend

Date: 2026-06-26

Story:
`production/epics/player-abilities/story-018-skill-tree-cat-claw-t1a-first-spend.md`

## Scope

This slice adds the first playable skill-tree spend path. Rat King reward SP can
now open a minimal Skill Tree menu and buy Cat Claw T1-A (`疾步连爪`, displayed
as `Quickstep Claws`). The unlocked modifier changes Cat Claw light attack 2 by
adding an 8px forward lunge and hitbox metadata.

No new visual assets were generated. The story reuses existing image-generated
Cinderpaw `AnimatedSprite2D + SpriteFrames`, generated environment art, and
existing HUD presentation.

## Automated Tests

- RED: `reports/report_719/`
  - Command: `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/skill_tree_spending_ui_runtime_test.gd --ignoreHeadlessMode`
  - Result: expected failure on missing MainScene/HUD skill tree APIs and
    unlock request signals.
- GREEN focused before final refactor: `reports/report_720/`
  - Same focused command.
  - Result: exit `0`, Story018 `2/2`.
- Related regression before final refactor: `reports/report_723/`
  - Suites: Story018, HUD manager, MainScene player attack core chain, Rat King
    reward runtime, save handoff, Cat Claw counter, and damage special
    modifiers.
  - Result: exit `0`, `42/42`.
- Final focused after refactor: `reports/report_724/`
  - Same focused command.
  - Result: exit `0`, Story018 `2/2`.
  - Notes: Existing Godot process-exit ObjectDB/resource cleanup warnings
    appeared after the GdUnit result; test result itself passed.
- Final related regression: `reports/report_725/`
  - Same related suites as above.
  - Result: exit `0`, `42/42`.
  - Notes: Existing Godot process-exit ObjectDB/resource cleanup warnings
    appeared after the GdUnit result; test result itself passed.

## Headless Smoke

- Main scene:
  - Command: `/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/skill_tree_cat_claw_t1a_main_scene_smoke.log`
  - Result: exit `0`.
- Log keyword scan:
  - `rg -n "SCRIPT ERROR|Parse Error|Invalid call|Invalid access|Resource file not found|Failed loading resource|missing resource|Cannot open|ERROR:" reports/skill_tree_cat_claw_t1a_main_scene_smoke.log`
  - Result: no matches.
  - Notes: the console still printed the project's known cleanup-time
    ObjectDB/resource warning after process exit; the smoke log itself contained
    no script, parse, invalid-call, or resource-load errors.

## Godot MCP Runtime

Session: `cinderpaw@c1b2`, Godot `4.6.3-stable`, custom run scene
`res://scenes/main.tscn`.

MCP evidence:

- Runtime tree confirmed `/Main/SkillTreeManager` exists and is in group
  `skill_tree_manager`.
- Runtime tree confirmed `/Main/Player/Sprite` is `AnimatedSprite2D` with
  SpriteFrames path
  `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`.
- SpriteFrames runtime probe found `idle` has `3` frames and `attack` has `3`
  frames.
- Runtime probe defeated Rat King from `0` initial skill points to `5` reward
  skill points.
- `show_skill_tree_menu()` displayed:
  - menu mode `skill_tree`
  - title `Skill Tree`
  - `SP 5`
  - `Cat Claw T1 - Quickstep Claws`
  - `Learn Quickstep Claws`, enabled.
- `try_unlock_skill("cat_claw_t1a")` returned `true`, reduced skill points to
  `4`, and recorded `unlocked_skills=["cat_claw_t1a"]`.
- `get_skill_tree_modifiers("light_attack_2")` returned one modifier:
  `{stat_key="dash_distance", operation="ADD", value=8.0, condition.weapon="cat_claw"}`.
- Runtime Cat Claw attack probe confirmed:
  - first attack returned `true`
  - second attack returned `true`
  - player delta x was `8.0`
  - `get_last_skill_lunge_px()` returned `8.0`
  - `cat_claw_light` hitbox position x was `24.0`
  - attack metadata included `combo_index=1`, `skill_lunge_px=8.0`, and
    `hitbox_offset_x=8.0`.
- MCP game logs contained only DataManager domain load lines and game helper
  registration.
- MCP editor logs were empty.
- Runtime screenshot saved to
  `reports/visual/cinderpaw-mcp-skill-tree-cat-claw-t1a-20260626.png` at
  `1280x720`; screenshot is nonblank and shows the Skill Tree menu, Cinderpaw,
  HUD, and generated environment/gate feedback art.

## Acceptance Mapping

| Acceptance item | Evidence | Status |
| --- | --- | --- |
| `skill_tree` data and Cat Claw T1-A modifier load through DataManager | `report_724`, MCP runtime probe | PASS |
| Scene-local SkillTreeManager, no new Autoload | Code review, MCP runtime tree | PASS |
| HUD opens minimal skill tree and shows SP/node details | `report_724`, MCP runtime probe, screenshot | PASS |
| Rat King SP can buy Cat Claw T1-A exactly once | `report_724`, `report_725`, MCP runtime probe | PASS |
| Runtime progress/save state persists unlocked skill | `report_724`, `report_725` | PASS |
| Cat Claw light attack 2 lunges forward 8px and carries metadata | `report_724`, MCP runtime probe | PASS |
| Character animation and runtime logs/screenshot are valid | MCP runtime probe/logs/screenshot | PASS |
