# QA Evidence: Old Factory Tailrace Exit Spillway Visual Pass -- 2026-07-10

## Scope

Story125 replaces the Story124 spillway duct's reused service-sluice landing
texture with a dedicated generated Old Factory tailrace exit spillway prop in
`scenes/factory_route_transition_shell.tscn`. It does not change route geometry,
collision, steam hazard timing, enemy behavior, reward economy, save schema, or
route state keys.

## Automated Evidence

- RED focused: `reports/report_1383/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_tailrace_exit_spillway_visual_pass_test.gd --ignoreHeadlessMode`
  - Result: exit `100`, `0/1` passed. Expected failure because
    `ExitSpillwayDuct` still used
    `res://assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`.
- GREEN focused: `reports/report_1384/`
  - Same command.
  - Result: exit `0`, `1/1` passed.

## Import Evidence

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --import --quit`
- Result: exit `0`.
- Import output included:
  - `env_old_factory_tailrace_exit_spillway_768.png`
  - `old_factory_tailrace_exit_spillway_alpha_20260710.png`
  - `old_factory_tailrace_exit_spillway_imagegen_20260710.png`

## Image Processing Evidence

- Generated source:
  `assets/generated/source/old_factory_tailrace_exit_spillway_imagegen_20260710.png`
  - Mode/size: `RGB`, `1942x809`.
- Alpha-matted source:
  `assets/generated/source/old_factory_tailrace_exit_spillway_alpha_20260710.png`
  - Mode/size: `RGBA`, `1942x809`.
  - Chroma-key helper reported key color `#05f903`, transparent pixels
    `988812/1571078`, and partially transparent pixels `21211/1571078`.
- Runtime texture:
  `assets/environment/old_factory_tailrace_exit_spillway/env_old_factory_tailrace_exit_spillway_768.png`
  - Mode/size: `RGBA`, `768x320`.
  - Alpha stats: transparent `146233`, partial `8752`, opaque `90775`.
  - Alpha bbox: `(12, 50, 756, 270)`.
- Metadata:
  `assets/generated/source/old_factory_tailrace_exit_spillway_imagegen_20260710.json`.

## Headless Runtime Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --script res://tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.gd > reports/old_factory_tailrace_exit_spillway_visual_pass_smoke.log 2>&1`
- Result: exit `0`.
- Smoke marker:
  `service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke=passed`.
- Log notes: only known Godot shutdown-time ObjectDB/resource cleanup messages
  appeared after the pass marker.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Editor checks:
  - `scene_open(force_reload=true)` reloaded the scene from disk.
  - `ExitSpillwayDuct` exists as `Sprite2D`.
  - `ExitSpillwayDuct.texture` is
    `res://assets/environment/old_factory_tailrace_exit_spillway/env_old_factory_tailrace_exit_spillway_768.png`.
  - Duct transform is `position=(16720,392)`, `scale=(0.78,0.78)`,
    `z_index=12`, `z_as_relative=false`.
  - `ExitSpillwayVent` keeps script
    `res://src/feature/factory_steam_vent_hazard.gd`, hazard id
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway`,
    `damage=8`, and `contact_cooldown_sec=1.0`.
  - Vent visual still uses
    `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
- Runtime checks:
  - `project_run(mode=current, autosave=false)` launched with helper live and
    `current_run_errors=[]`.
  - Typed MCP `game_eval` after seeding Story123 hatch-opened state returned:
    - `present=true`, `available=true`, `visible=true`,
      `duct_visible_in_tree=true`.
    - `duct_texture_path` equals the new Story125 runtime texture.
    - `duct_texture_size=(768,320)`.
    - `hazard_contact_active=false`, `hazard_damage=8`,
      `hazard_cooldown_sec=1.0`.
    - `right_wall_x=17280`, `camera_limit_right=17300`,
      `background_width=17300`, `ground_right_edge_x=17400`,
      `floor_tile_count=69`.
    - `route_label_text=Tailrace Runoff Exit Opened`.
  - Game log contained only the helper registration line.
  - Editor log was empty.
  - Game screenshot response was non-empty, `640x359`, and showed the updated
    tailrace exit spillway segment with route prompt visible.

## MCP Notes

- An initial runtime eval probe used untyped `var diagnostics` and briefly put
  the game in a debugger break after returning a result:
  `Cannot infer the type of "diagnostics" variable`.
- The run was stopped through `project_manage(op="stop")`, relaunched, and the
  probe was rerun with explicit `Dictionary`/`Sprite2D` types. The typed eval,
  game/editor logs, and screenshot checks then passed cleanly.

## Asset Pipeline

- New image-generation source:
  `assets/generated/source/old_factory_tailrace_exit_spillway_imagegen_20260710.png`
- Alpha-matted source:
  `assets/generated/source/old_factory_tailrace_exit_spillway_alpha_20260710.png`
- Metadata:
  `assets/generated/source/old_factory_tailrace_exit_spillway_imagegen_20260710.json`
- Runtime asset:
  `assets/environment/old_factory_tailrace_exit_spillway/env_old_factory_tailrace_exit_spillway_768.png`
- Import status: imported through Godot 4.7 with `.png.import` sidecars.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Dedicated spillway texture replaces reused landing | `reports/report_1384`; MCP node props/eval | PASS |
| Texture is transparent 768x320 and imported | Image stats; import log; manifest | PASS |
| Story124 hazard parameters and bounds preserved | `reports/report_1384`; MCP eval | PASS |
| Existing Story124 targeted smoke still passes | Smoke log | PASS |
| Runtime logs and screenshot are clean/current | MCP logs and screenshot | PASS |
