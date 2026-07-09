# QA Evidence: Old Factory Overflow Pump Runoff Outlet Service Sluice Traverse -- 2026-07-10

## Scope

Story113 adds the first playable pocket beyond the runoff outlet service hatch:
an image-generated service sluice landing, a timed steam hazard, route bounds
extension, objective feedback, and save-state backfill.

## Automated Evidence

- RED focused: `reports/report_1323/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_traverse_test.gd --ignoreHeadlessMode -rd res://reports/report_1323`
  - Result: exit `100`. Expected failure: runtime asset and Story113 APIs did
    not exist before implementation.
- Parse/import cleanup runs: `reports/report_1325/`, `reports/report_1326/`,
  `reports/report_1327/`
  - Result: exit `100` while fixing transient GDScript indentation and route
    objective priority issues.
- GREEN focused: `reports/report_1328/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_traverse_test.gd --ignoreHeadlessMode -rd res://reports/report_1328`
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1329/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports/report_1329`
  - Result: exit `0`, `10/10` passed.

## Headless Smoke

- Direct scene smoke:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . res://scenes/factory_route_transition_shell.tscn --quit-after 3 > reports/old_factory_overflow_pump_runoff_outlet_service_sluice_smoke.log 2>&1`
  exited `0`.
- Scripted runtime smoke:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://tests/smoke/old_factory_service_sluice_smoke.gd > reports/old_factory_overflow_pump_runoff_outlet_service_sluice_script_smoke.log 2>&1`
  exited `0` and printed `service_sluice_smoke=passed`.
- Both logs contain Godot process-exit cleanup noise:
  `ObjectDB instances were leaked at exit` and
  `resources still in use at exit`. The scripted smoke pass marker was emitted
  before shutdown and no Story113 script, parse, invalid-call/access,
  missing-resource, or resource-load errors were emitted by the runtime
  assertions.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceDuct`.
  - Duct node type: `Sprite2D`.
  - Duct texture:
    `res://assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`.
  - Duct position: `Vector2(10480, 388)`, initially `visible=false`.
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceSteamVent`.
  - Steam vent node type: `Area2D`.
  - Steam vent script: `res://src/feature/factory_steam_vent_hazard.gd`.
  - Steam vent position: `Vector2(10540, 466)`, initially `visible=false`,
    `collision_layer=0`, `collision_mask=0`, and `monitoring=false`.
  - Hazard id:
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice`.
  - Hazard damage/cooldown: `8` / `1.0`.
  - Camera limit right: `10960`.
- Running scene check:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Runtime `game_eval` restored service-hatch-opened state and confirmed
    `ready_present=true`, `ready_visible=true`, and route label
    `Runoff Outlet Service Hatch Open`.
  - Runtime activation returned `true`, advanced to phase `active`, and
    reported `hazard_contact_active=true`.
  - Runtime completion returned `true`, persisted `done_crossed=true`, and
    route label `Runoff Outlet Service Sluice Crossed`.
  - Runtime diagnostics reported the generated duct texture path and expected
    service sluice hazard id.
- Logs:
  - Current game run id `r257164410-51` had only the MCP helper registration
    info line and no errors.
  - Editor log source retained older historical parse rows from implementation
    cleanup. A follow-up `logs_read(source="editor", since_cursor=9)` returned
    no new rows after the final Story113 runtime validation.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `1278x718` PNG
    response showing the service hatch, image-generated service sluice landing,
    and steam vent. The landing is authored visual art, not a placeholder
    rectangle.

## Asset Pipeline

- New image generation source:
  `assets/generated/source/old_factory_runoff_service_hatch_landing_imagegen_20260710.png`.
- Chroma-key alpha source:
  `assets/generated/source/old_factory_runoff_service_hatch_landing_alpha_20260710.png`.
- Metadata:
  `assets/generated/source/old_factory_runoff_service_hatch_landing_imagegen_20260710.json`.
- Runtime Godot asset:
  `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`.
- Manifest updated:
  `design/assets/asset-manifest.md`.
- Story113 adds no new player-visible character, so it does not add or modify
  `AnimatedSprite2D + SpriteFrames` character animation resources.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Locked until service hatch open | `report_1328` | PASS |
| Generated duct appears and uses runtime texture | `report_1328`; MCP static/runtime checks | PASS |
| Steam vent hazard id/damage/cooldown/contact window | `report_1328`; MCP runtime eval | PASS |
| Route bounds extend to right wall 10940 / camera 10960 | `report_1328`; MCP static check | PASS |
| Objective labels hand off hatch open -> cross -> crossed | `report_1328`; MCP runtime eval | PASS |
| Restore backfills Story106-112 route chain | `report_1328`; `report_1329` | PASS |
| Runtime scene loads and screenshot is non-empty | MCP run + screenshot | PASS |

## Verdict

PASS. Story113 adds a playable service sluice traverse with image-generated
environment art, not a placeholder block, and passes focused, related,
headless, and MCP runtime validation.
