# QA Evidence: Boss2 HUD Hit Feedback + Arena Visual Runtime

Date: 2026-06-30

Story:
`production/epics/player-abilities/story-028-boss2-hud-hit-feedback-arena-visual-runtime.md`

## Scope

This slice improves the player-visible Boss2 encounter in
`res://scenes/main.tscn` by adding an authored Boss2 arena frame and short HUD
hit flash feedback when Boss2 takes damage. It preserves the existing Boss2
HUD focus, combat behavior, arena bounds/reset, and Double Jump reward path.

## Generated Asset Pipeline

Source prompt summary:

- Pixel-art side-view metroidvania Boss2 Echo Guardian arena frame, generated
  on a flat green chroma key for alpha removal. The prompt requested broken
  scrap-metal arch pieces, low side pylons, floating debris, steel blue-gray
  base, restrained rust orange, violet echo glow, small cat-eye gold safety
  accents, and no text/UI/characters/full background/placeholder rectangle.

Source and runtime files:

- Source PNG:
  `assets/generated/source/boss2_echo_guardian_arena_frame_imagegen_20260630.png`
- Alpha source:
  `assets/generated/source/boss2_echo_guardian_arena_frame_alpha_20260630.png`
- Source metadata:
  `assets/generated/source/boss2_echo_guardian_arena_frame_imagegen_20260630.json`
- Runtime PNG:
  `assets/environment/boss2_arena/boss2_echo_guardian_arena_frame.png`
- Godot import:
  `assets/environment/boss2_arena/boss2_echo_guardian_arena_frame.png.import`

Asset checks:

- Runtime PNG is 640x256 RGBA.
- Corner alpha is transparent; nontransparent content bbox is inside the frame.
- Runtime screenshot is nonblank and shows the arena frame behind Boss2.
- Runtime file was imported with
  `/opt/homebrew/bin/godot --headless --path . --import --quit`.
- `scenes/main.tscn` references the new arena frame texture on
  `Boss2ArenaFrame` with `z_index=31`, behind Boss2 `z_index=33`.

## Automated Tests

- RED focused: `reports/report_831/`
  - Command: `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/boss2_hud_hit_feedback_arena_visual_runtime_test.gd --ignoreHeadlessMode`
  - Result: exit `100`, expected failure because `Boss2ArenaFrame` was missing.
- GREEN focused: `reports/report_832/`
  - Same focused command.
  - Result: exit `0`, Story028 `2/2` passing.
- Final focused after MCP warning cleanup: `reports/report_838/`
  - Same focused command.
  - Result: exit `0`, Story028 `2/2` passing.
- Related regressions:
  - Boss2 HUD focus: `reports/report_833/`, exit `0`, `4/4` passing.
  - Boss2 arena bounds/reset: `reports/report_834/`, exit `0`, `5/5` passing.
  - Boss2 autonomous pressure: `reports/report_835/`, exit `0`, `6/6` passing.
  - Boss2 telegraph strike: `reports/report_836/`, exit `0`, `4/4` passing.
  - Boss2 Double Jump payoff: `reports/report_837/`, exit `0`, `3/3` passing.

Existing Godot process-exit ObjectDB/resource cleanup messages appeared after
some GdUnit results; the suites listed above had `0` errors and `0` failures.

## Headless Smoke

- Main scene:
  - Command: `/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --quit-after 240 > reports/boss2_hud_hit_feedback_arena_visual_runtime_main_scene_smoke.log 2>&1`
  - Result: exit `0`.
- Log keyword scan:
  - `rg -n "SCRIPT ERROR|Parse Error|Invalid call|Resource file not found|Failed loading resource|SHADOWED_VARIABLE|ERROR:" reports/boss2_hud_hit_feedback_arena_visual_runtime_main_scene_smoke.log`
  - Result: no script, parse, invalid-call, missing-resource, resource-load, or
    shadowed-variable matches. The only `ERROR:` match is Godot's cleanup-time
    `2 resources still in use at exit` line after the scene already exited `0`.

## Godot MCP Runtime

MCP evidence:

- Activated session `cinderpaw@c1b2`, opened `res://scenes/main.tscn`, and ran
  the custom scene with `autosave=false`.
- Runtime probe confirmed `Boss2ArenaFrame` exists, is `Sprite2D`, is visible,
  has `z_index=31`, and uses
  `res://assets/environment/boss2_arena/boss2_echo_guardian_arena_frame.png`.
- Runtime probe confirmed the arena frame texture size is `640x256`.
- Runtime probe confirmed `/Main/Boss2EchoGuardian/Sprite` is
  `AnimatedSprite2D`, has `SpriteFrames`, and `idle`, `run`, and `attack` each
  have `3` frames.
- Runtime probe applied `apply_damage(2200, 9, ...)` and confirmed:
  - `damage_ok=true`
  - HUD label remains `Echo Guardian  Phase I  27/36`
  - hit flash changes from `false` to `true`
  - flash color is `ffffff`
  - remaining time starts at `0.22`, advances to `0.11`, then reaches `0.0`
  - final flash visibility is `false`
- Runtime screenshot was written to
  `reports/visual/cinderpaw-mcp-boss2-hud-hit-feedback-arena-visual-20260630.png`.
- Screenshot local pixel check confirmed `1280x720` RGBA, nonblank, and
  `162755` unique RGB colors.
- MCP editor logs were empty after clearing the temporary eval warning.
- MCP game logs contained only game helper/DataManager info lines.

## Acceptance Mapping

| Acceptance item | Evidence | Status |
| --- | --- | --- |
| Boss2 arena frame exists and uses dedicated texture | RED `report_831`, GREEN `report_832`, final focused `report_838`, MCP probe | PASS |
| Runtime PNG/import/source metadata documented | Godot import, asset manifest, metadata JSON, this evidence doc | PASS |
| Arena frame stays visual-only and preserves Boss2 behavior | `report_834`, `report_837`, MCP scene probe | PASS |
| Boss2 damage triggers HUD hit flash without losing focus | `report_832`, `report_838`, `report_833`, MCP probe | PASS |
| HUD flash diagnostics are deterministic | `report_832`, `report_838`, MCP probe | PASS |
| Main scene runs under MCP with clean logs and nonblank screenshot | Headless smoke, MCP logs, MCP screenshot | PASS |
