# Boss2 Room Seal Runtime Evidence

Date: 2026-06-30
Story: `production/epics/player-abilities/story-030-boss2-room-seal-runtime.md`

## Scope

Story030 adds visible Boss2 room-seal doors to `scenes/main.tscn`. The seals
block the Boss2 room while the Echo Guardian is active and undefeated, then
open when `boss_02_echo_guardian_defeated` is set or restored. The story keeps
the implementation scene-local and does not add a generic door system.

## Asset Pipeline

- Runtime asset:
  `assets/environment/boss2_arena/boss2_echo_guardian_room_seal.png`
- Godot import sidecar:
  `assets/environment/boss2_arena/boss2_echo_guardian_room_seal.png.import`
- Image generation source:
  `assets/generated/source/boss2_echo_guardian_room_seal_imagegen_20260630.png`
- Prompt/metadata:
  `assets/generated/source/boss2_echo_guardian_room_seal_imagegen_20260630.json`
- Import command:
  `/opt/homebrew/bin/godot --headless --path . --import`
- Runtime PNG validation:
  256x384 transparent PNG, transparent corners, alpha extrema `(0, 255)`.

## Automated Tests

- RED focused:
  `reports/report_848/` failed as expected before implementation because
  `MainScene.refresh_boss2_room_seals()` and
  `MainScene.get_boss2_room_seal_diagnostics()` were missing.
- GREEN focused:
  `reports/report_849/` passed `3/3`.
- Autonomous pressure related regression:
  `reports/report_850/` passed `6/6`.
- Related Boss2 regression before final seal placement refinement:
  `reports/report_851/` passed `19/19`.
- Final focused after moving seals to room edges:
  `reports/report_852/` passed `3/3`.
- Final focused after the no-behavior GDScript cleanup:
  `reports/report_854/` passed `3/3`.
- Final related Boss2 regression:
  `reports/report_853/` passed `19/19`.

Command used for the final related run:

```bash
/opt/homebrew/bin/godot --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/gameplay/boss2_room_seal_runtime_test.gd \
  -a res://tests/unit/gameplay/boss2_arena_camera_lock_runtime_test.gd \
  -a res://tests/unit/gameplay/boss2_hud_focus_runtime_test.gd \
  -a res://tests/unit/gameplay/boss2_arena_bounds_reset_runtime_test.gd \
  -a res://tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd \
  --ignoreHeadlessMode -rd res://reports -c
```

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . \
  --scene res://scenes/main.tscn \
  --fixed-fps 60 --quit-after 3 \
  --log-file reports/boss2_room_seal_runtime_main_scene_smoke.log
```

Result:

- Process exit: `0`
- Log file:
  `reports/boss2_room_seal_runtime_main_scene_smoke.log`
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
3. Ran current scene with `autosave=false`.
4. Confirmed `game_capture_ready=true`.
5. Cleared editor/game logs, restarted the current scene, and captured final
   evidence.

Before Boss2 defeat:

- `/root/Main/Boss2LeftRoomSeal` found as `StaticBody2D`.
- Left seal position: `(250, 420)`.
- Left seal `visible=true`, `collision_layer=16`.
- `/root/Main/Boss2RightRoomSeal` found as `StaticBody2D`.
- Right seal position: `(790, 420)`.
- Right seal `visible=true`, `collision_layer=16`.
- Game screenshot capture reported `1280x720`.

After setting `boss_02_echo_guardian_defeated=true` through MCP game eval:

- Left seal `visible=false`, `collision_layer=0`.
- Right seal `visible=false`, `collision_layer=0`.
- `/root/Main/Boss2DoubleJumpRewardSource` remained found and `visible=true`.
- Game logs contained only MCP helper and DataManager info messages.
- Editor logs contained `0` entries after final clean verification.

Screenshot evidence:

- `reports/visual/cinderpaw-mcp-boss2-room-seal-runtime-20260630.png`
- File type: PNG, 1280x720, RGB.
- Pixel stats: alpha `(255, 255)`, mean RGBA approximately
  `[63.35, 51.89, 48.08, 255.0]`, full-image bounding box `(0, 0, 1280, 720)`.

## Result

PASS. Story030 acceptance criteria are satisfied with focused tests, related
Boss2 regression coverage, headless smoke, asset import evidence, and MCP
runtime proof that the visible seals block the active room and open on defeat.
