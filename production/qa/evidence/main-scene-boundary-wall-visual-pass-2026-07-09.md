# QA Evidence: Main Scene Boundary Wall Visual Pass -- 2026-07-09

## Scope

Story103 replaces MainScene boundary wall presentation nodes with a generated
transparent vertical wall sprite. This is a visual-only scene/resource pass: it
does not change wall collision dimensions, player spawn, ground/platform
collision, Dash/Double Jump gates, Boss2, HUD, SaveSystem, or route state.

## Automated Evidence

- RED focused: `reports/report_1268/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_boundary_wall_visual_pass_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`, `0/1` passed. Expected failure because
    `LeftWall/BoundaryWallVisual` and `RightWall/BoundaryWallVisual` did not
    exist and the old `WallVisual` ColorRects were still present.
- GREEN focused: `reports/report_1269/`
  - Same command.
  - Result: exit `0`, `1/1` passed.
- Related regression: `reports/report_1270/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_boundary_wall_visual_pass_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd -a res://tests/unit/gameplay/main_scene_dash_gate_authored_visual_test.gd -a res://tests/unit/gameplay/exploration_dash_gate_runtime_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `9/9`; Story103 boundary walls, main-scene visual
    contract, authored Dash gate, and Dash gate runtime coverage passed.

## Import Evidence

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --import --quit`
- Result: exit `0`.
- Imported runtime texture:
  `assets/environment/main_scene_boundary_wall/main_scene_boundary_wall_96x720.png`

## Headless Runtime Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/main_scene_boundary_wall_visual_pass_smoke.log`
- Result: exit `0`.
- Log scan:
  `rg -n "SCRIPT ERROR|Parse Error|Invalid call|Invalid access|Cannot open file|Failed loading resource|Resource file not found|main_scene_boundary_wall" reports/main_scene_boundary_wall_visual_pass_smoke.log`
- Result: no project script/parse/invalid-call/access/missing-resource/resource
  load errors found.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/main.tscn`.
- Runtime checks:
  - `project_run.current_run_errors=[]`.
  - `LeftWall/BoundaryWallVisual` and `RightWall/BoundaryWallVisual` exist at
    runtime and are visible in tree.
  - Both wall sprites use:
    `res://assets/environment/main_scene_boundary_wall/main_scene_boundary_wall_96x720.png`
  - Texture size is `96x720` for both sprites.
  - Left wall `flip_h=false`; right wall `flip_h=true`.
  - Both sprites use `z_index=8` and `z_as_relative=false`.
  - `LeftWall/WallVisual` and `RightWall/WallVisual` ColorRect nodes are absent.
  - Current game log contains only helper/DataManager info lines.
- Screenshot:
  `reports/visual/cinderpaw-mcp-main-scene-boundary-wall-visual-pass-20260709.png`
  is non-empty, `1278x718`, and shows the authored vertical boundary wall in
  the running main scene.

## MCP Notes

- An initial MCP `game_eval` probe used an unsupported inline function form and
  produced an eval compile/break state. The project was stopped, logs were
  cleared, and `res://scenes/main.tscn` was relaunched successfully before
  recording final MCP evidence.
- The editor log still displayed retained Old Factory parse rows that predate
  this Story and name helper functions absent from the current file. Final
  Story103 acceptance uses `project_run.current_run_errors=[]`, clean current
  game log, focused/related GdUnit passes, headless smoke, and the successful
  runtime MCP node/screenshot probe.

## Asset Pipeline

- New image-generation source:
  `assets/generated/source/main_scene_boundary_wall_imagegen_20260709.png`
- Alpha-matted source:
  `assets/generated/source/main_scene_boundary_wall_alpha_20260709.png`
- Metadata:
  `assets/generated/source/main_scene_boundary_wall_imagegen_20260709.json`
- Runtime asset:
  `assets/environment/main_scene_boundary_wall/main_scene_boundary_wall_96x720.png`
- Import status: imported through Godot 4.7 with `.png.import` sidecars.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Left/right wall visuals are generated Sprite2D nodes | `reports/report_1269/`; MCP probe | PASS |
| Runtime PNG path, size, flip, and z-order contract | `reports/report_1269/`; MCP probe | PASS |
| Old ColorRect wall visuals removed | `reports/report_1269/`; MCP probe | PASS |
| MainScene visual and Dash gate regressions remain green | `reports/report_1270/` | PASS |
| Headless and MCP runtime logs are clean for current run | Headless smoke; MCP runtime | PASS |
| Screenshot shows the authored boundary wall | MCP screenshot | PASS |
