# QA Evidence: Old Factory Route Floor Platform Visual Pass -- 2026-07-09

## Scope

Story102 replaces player-facing Old Factory route floor and platform placeholder
readability with image-generated metal floor/platform sprites in
`scenes/factory_route_transition_shell.tscn`. It does not change route geometry,
collision shape sizes, enemy behavior, cache rewards, save schema, or service
lift routing.

## Automated Evidence

- RED focused: `reports/report_1264/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_route_floor_platform_visual_pass_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`, `0/1` passed. Expected failure because
    `OldFactoryEntranceScene.get_factory_route_visual_diagnostics()` did not
    exist yet.
- GREEN focused: `reports/report_1265/`
  - Same command.
  - Result: exit `0`, `1/1` passed.
- Related regression: `reports/report_1267/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_route_floor_platform_visual_pass_test.gd -a res://tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd -a res://tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd -a res://tests/unit/gameplay/factory_route_runtime_roundtrip_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `12/12`; Story102, factory route runtime, entrance combat
    shell, room-clear cache, and route roundtrip coverage passed.

## Import Evidence

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --import --quit`
- Result: exit `0`.
- Imported runtime textures:
  - `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`
  - `assets/environment/old_factory_route_platform/env_old_factory_route_entry_platform_320x96.png`
  - `assets/environment/old_factory_route_platform/env_old_factory_route_cache_platform_320x96.png`

## Headless Runtime Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --fixed-fps 60 --quit-after 180 --log-file reports/old_factory_route_floor_platform_visual_pass_smoke.log`
- Result: exit `0`.
- Log scan:
  `rg -n "SCRIPT ERROR|Parse Error|Invalid call|Invalid access|Cannot open file|Failed loading resource|Resource file not found|old_factory_route_floor|old_factory_route_platform" reports/old_factory_route_floor_platform_visual_pass_smoke.log`
- Result: no project script/parse/invalid-call/access/missing-resource/resource
  load errors found.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Runtime checks:
  - `project_run.current_run_errors=[]`.
  - `FactoryRouteFloorVisual`, `FactoryRouteEntryPlatformVisual`, and
    `FactoryRouteCachePlatformVisual` exist at runtime.
  - Floor diagnostic:
    - texture:
      `res://assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`
    - texture size: `256x96`
    - tile count: `28`
    - world width: `7168`
    - world height: `96`
    - visible and in-tree: `true`
  - Entry platform diagnostic:
    - texture:
      `res://assets/environment/old_factory_route_platform/env_old_factory_route_entry_platform_320x96.png`
    - texture size/world size: `320x96`
    - visible and in-tree: `true`
  - Cache platform diagnostic:
    - texture:
      `res://assets/environment/old_factory_route_platform/env_old_factory_route_cache_platform_320x96.png`
    - texture size/world size: `320x96`
    - visible and in-tree: `true`
  - Ground collision remains `7040x40`.
  - `uses_placeholder_color_rect=false`.
  - Current game log contained only helper registration.
- Screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-route-floor-platform-visual-pass-20260709.png`
  is non-empty, `1278x718`, and shows Cinderpaw standing on generated metal
  route flooring with generated entry/cache platform visuals visible.

## MCP Notes

- The MCP editor hierarchy view briefly returned a stale in-memory scene tree
  showing `Ground` with only its collision child. No `scene_save` was executed
  from that stale editor state.
- Disk reads through MCP and local file inspection showed the new scene nodes,
  and MCP `project_run` runtime `game_eval` confirmed the actual running scene
  loaded the generated visual nodes and textures.
- The editor Debugger retained old Factory parse rows for helper names absent
  from the current `src/gameplay/old_factory_entrance_scene.gd`; local `rg`,
  headless parsing/tests, headless smoke, and current-run MCP checks passed.

## Asset Pipeline

- New image-generation source:
  `assets/generated/source/old_factory_route_floor_platform_sheet_imagegen_20260709.png`
- Alpha-matted source:
  `assets/generated/source/old_factory_route_floor_platform_sheet_alpha_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_route_floor_platform_sheet_imagegen_20260709.json`
- Runtime assets:
  - `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`
  - `assets/environment/old_factory_route_platform/env_old_factory_route_entry_platform_320x96.png`
  - `assets/environment/old_factory_route_platform/env_old_factory_route_cache_platform_320x96.png`
- Import status: imported through Godot 4.7 with `.png.import` sidecars.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Floor visuals cover full route collision width | `reports/report_1265/`; MCP probe | PASS |
| Entry/cache platforms use generated textures | `reports/report_1265/`; MCP probe | PASS |
| No player-facing placeholder ColorRect/Polygon2D visuals | `reports/report_1265/`; MCP probe | PASS |
| Route/cache/roundtrip behavior preserved | `reports/report_1267/` | PASS |
| Headless and MCP runtime logs are clean for current run | Headless smoke; MCP runtime | PASS |
| Screenshot proves non-empty generated floor/platform visuals | MCP screenshot | PASS |
