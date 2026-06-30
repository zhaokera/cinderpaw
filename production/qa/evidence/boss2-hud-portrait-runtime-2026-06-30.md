# Boss2 HUD Portrait Runtime Evidence

Date: 2026-06-30
Story: `production/epics/player-abilities/story-031-boss2-hud-portrait-runtime.md`

## Scope

Story031 adds a compact image-generated Boss2 Echo Guardian portrait to the
existing Boss HUD while Boss2 is the active focus. It does not redesign the Boss
HUD, add Rat King portrait art, animate the portrait, or change Boss2 combat.

## Asset Pipeline

- Runtime asset:
  `assets/ui/boss_portraits/boss2_echo_guardian_portrait.png`
- Godot import sidecar:
  `assets/ui/boss_portraits/boss2_echo_guardian_portrait.png.import`
- Image generation source:
  `assets/generated/source/boss2_echo_guardian_portrait_imagegen_20260630.png`
- Prompt/metadata:
  `assets/generated/source/boss2_echo_guardian_portrait_imagegen_20260630.json`
- Import command:
  `/opt/homebrew/bin/godot --headless --path . --import`
- Runtime PNG validation:
  128x128 transparent PNG, alpha extrema `(0, 255)`, non-empty alpha bounding
  box `(10, 5, 123, 123)`.

## Automated Tests

- RED focused:
  `reports/report_855/` failed `2/2` before
  `HUDManager.get_boss_portrait_diagnostics()` existed.
- RED refinement:
  `reports/report_858/` failed because the portrait rendered at 128x128,
  exceeding the compact HUD size limit.
- Final GREEN focused:
  `reports/report_862/` passed `2/2`.
- Related HUD/Boss2 regression:
  `reports/report_861/` passed `30/30` across Boss2 portrait, Boss2 HUD focus,
  Boss2 HUD hit feedback/arena visual, and `hud_manager_test.gd`.

Final related command:

```bash
/opt/homebrew/bin/godot --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/boss2_hud_portrait_runtime_test.gd \
  -a res://tests/unit/gameplay/boss2_hud_focus_runtime_test.gd \
  -a res://tests/unit/gameplay/boss2_hud_hit_feedback_arena_visual_runtime_test.gd \
  -a res://tests/unit/presentation/hud_manager_test.gd \
  --ignoreHeadlessMode -rd res://reports -c
```

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . \
  --scene res://scenes/main.tscn \
  --fixed-fps 60 --quit-after 3 \
  --log-file reports/boss2_hud_portrait_runtime_main_scene_smoke.log
```

Result:

- Process exit: `0`
- Log file:
  `reports/boss2_hud_portrait_runtime_main_scene_smoke.log`
- Keyword scan:
  no `SCRIPT ERROR`, `Parse Error`, `Invalid call`, `Invalid get index`,
  `Resource file not found`, `Failed loading resource`, or logged `ERROR:`
  entries.
- Godot stdout still prints its known shutdown-time ObjectDB/resource cleanup
  messages; they are not present in the gameplay log file.

## Godot MCP Runtime Evidence

Session: `cinderpaw@2dd4`
Godot: `4.6.3-stable (official)`
Scene: `res://scenes/main.tscn`

MCP flow:

1. Activated session `cinderpaw@2dd4`.
2. Reopened `res://scenes/player.tscn`, then `res://scenes/main.tscn` to force a
   disk reload.
3. Cleared editor/game logs.
4. Ran current scene with `autosave=false`.
5. Confirmed `game_capture_ready=true`.

Before Boss2 defeat:

- `/root/Main/HUD/HudRoot/BossHudPanel/@HBoxContainer@8/BossPortrait` found as
  `TextureRect`.
- Portrait `visible=true`.
- Portrait `custom_minimum_size=(48, 48)`.
- Portrait rendered `size=(48, 48)`.
- Portrait texture:
  `res://assets/ui/boss_portraits/boss2_echo_guardian_portrait.png`.
- Boss label remained `Echo Guardian  Phase I  36/36`.
- Game screenshot capture reported `1280x720`.

After setting `boss_02_echo_guardian_defeated=true` through MCP game eval:

- Portrait node remained found, but `visible=false` and `texture=null`.
- Boss label handed back to `垃圾桶鼠王  Phase I  300/300`.
- Game logs contained only MCP helper and DataManager info messages.
- Editor logs contained `0` entries.

Screenshot evidence:

- `reports/visual/cinderpaw-mcp-boss2-hud-portrait-runtime-20260630.png`
- File type: PNG, 1280x720, RGB.
- Pixel stats: alpha `(255, 255)`, mean RGBA approximately
  `[62.73, 51.56, 47.91, 255.0]`, full-image bounding box `(0, 0, 1280, 720)`.

## Result

PASS. Story031 acceptance criteria are satisfied with focused TDD coverage,
related HUD/Boss2 regression, headless smoke, imported generated art, and Godot
MCP runtime proof of the visible compact portrait and defeated-state cleanup.
