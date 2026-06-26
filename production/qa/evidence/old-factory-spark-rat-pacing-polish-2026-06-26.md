# QA Evidence: Old Factory Spark Rat Pacing Polish

Date: 2026-06-26

Story: `production/epics/player-abilities/story-017-old-factory-spark-rat-pacing-polish.md`

## Scope

This slice polishes the existing Factory Spark Rat encounter pacing. The Spark
Rat now waits for a scene-local pressure line after the deep route endpoint
opens, starts with an opening grace window, patrols outside alert radius, and
keeps the existing `attack_tell -> attack` bite contract with a 12-frame
startup.

No new visual assets were generated. The story reuses the existing
image-generated Factory Spark Rat `AnimatedSprite2D + SpriteFrames` assets from
Stories013-014.

## Automated Tests

- RED: `reports/report_712/`
  - Command: `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_spark_rat_pacing_polish_test.gd --ignoreHeadlessMode`
  - Result: exit `100`; expected failures on missing pacing API,
    activation diagnostics, and pressure-line gate.
- GREEN focused: `reports/report_714/`
  - Same focused command.
  - Result: exit `0`, Story017 `5/5`.
- Spark Rat / dodge-counter related regression: `reports/report_715/`
  - Suites: Story017, Story013, Story014, Story015, dodge i-frame,
    Cat Claw counter, player dodge animation, and dodge afterimage.
  - Result: exit `0`, `32/32`.
  - Notes: Existing Godot process-exit ObjectDB/resource cleanup warnings
    appeared after the GdUnit result; test result itself passed.
- Old Factory route related regression: `reports/report_716/`
  - Suites: Factory route shell, entrance combat, room clear cache, steam vent,
    deep route micro-slice, deep route unlock feedback, deep guard activation
    pacing, and Story017.
  - Result: exit `0`, `32/32`.
- `git diff --check`: exit `0`.
- Final pre-commit focused: `reports/report_717/`, exit `0`, Story017 `5/5`.

## Headless Smoke

- Factory scene:
  - Command: `/opt/homebrew/bin/godot --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --fixed-fps 60 --quit-after 180 --log-file reports/old_factory_spark_rat_pacing_polish_factory_scene_smoke.log`
  - Result: exit `0`.
- Main scene:
  - Command: `/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/old_factory_spark_rat_pacing_polish_main_scene_smoke.log`
  - Result: exit `0`.
- Log keyword scan:
  - `rg -n "SCRIPT ERROR|ERROR:|Invalid call|Parse Error|Resource file not found|Failed loading resource|missing resource|Cannot open" reports/old_factory_spark_rat_pacing_polish_factory_scene_smoke.log reports/old_factory_spark_rat_pacing_polish_main_scene_smoke.log`
  - Result: no matches.

## Godot MCP Runtime

Session: `cinderpaw@c1b2`, Godot `4.6.3-stable`, scene
`res://scenes/factory_route_transition_shell.tscn`.

MCP evidence:

- Scene tree confirmed `FactorySparkRat/Sprite` is `AnimatedSprite2D`.
- Runtime probe confirmed:
  - `SpriteFrames` path:
    `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
  - `idle`, `run`, `attack`, `attack_tell`, `hurt`, and `death` each have
    `3` frames.
  - `attack_tell.loop=false`.
  - Initial Spark Rat state is visible but inactive.
  - Deep guard activation and endpoint activation return `true`.
  - Endpoint-open state does not auto-activate Spark Rat.
  - Player before Spark Rat pressure line cannot activate it; collision remains
    `0`.
  - Player after pressure line activates it once; collision becomes `2/17`,
    target is bound, and pacing state starts as `opening_grace` with `18`
    frames.
  - After grace, auto attack enters `attack_tell`; tell-phase bite resolution
    returns `resolved=false` and applies no damage.
  - Startup is `12` frames.
  - Active bite resolves once as `factory_spark_rat_bite`, applies exactly `9`
    damage, and changes player HP from `100` to `91`.
- MCP game logs contained only the game helper registration line.
- MCP editor logs were empty.
- Runtime screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-spark-rat-pacing-polish-20260626.png`
  saved from the running game viewport at `1280x720`.

## Acceptance Mapping

| Acceptance item | Evidence | Status |
| --- | --- | --- |
| Pressure-line gate keeps Spark Rat inactive after endpoint open | `report_714`, MCP runtime probe | PASS |
| Activation is one-shot and exposes pacing diagnostics | `report_714`, MCP runtime probe | PASS |
| Opening grace prevents immediate automatic bite | `report_714`, MCP runtime probe | PASS |
| Patrol outside alert radius uses existing run animation | `report_714` | PASS |
| Alert/attack preserves `attack_tell -> attack` with 12-frame startup | `report_714`, `report_715`, MCP runtime probe | PASS |
| Story015 dodge-counter contract remains intact | `report_715` | PASS |
| Local state restore preserves pacing state without stale bite diagnostics | `report_714` | PASS |
| Scene/runtime logs and screenshot are clean/nonblank | Headless smoke, MCP logs, screenshot | PASS |
