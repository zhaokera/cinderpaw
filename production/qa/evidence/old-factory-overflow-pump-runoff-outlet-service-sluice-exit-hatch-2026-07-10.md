# QA Evidence: Old Factory Overflow Pump Runoff Outlet Service Sluice Exit Hatch -- 2026-07-10

## Scope

Story116 adds a once-only service-sluice exit hatch after the Story115 reward
cache. The hatch gates deeper Old Factory route content, clears collision after
opening, plays unlock feedback, and persists restore state.

## Automated Evidence

- RED focused: `reports/report_1339/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_test.gd --ignoreHeadlessMode -rd res://reports/report_1339`
  - Result: exit `100`. Expected failure: Story116 diagnostics/API did not
    exist before implementation.
- GREEN focused: `reports/report_1340/report_2/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_test.gd --ignoreHeadlessMode -rd res://reports/report_1340`
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1342/report_1/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports/report_1342`
  - Result: exit `0`, `10/10` passed.

## Headless Smoke

- Direct runtime smoke:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --script tests/smoke/old_factory_service_sluice_exit_hatch_smoke.gd > reports/old_factory_overflow_pump_runoff_outlet_service_sluice_exit_hatch_smoke.log 2>&1`
  exited `0`.
- The smoke log contains `service_sluice_exit_hatch_smoke=passed`.
- The log contains Godot shutdown cleanup noise:
  `ObjectDB instances were leaked at exit` and
  `resources still in use at exit`. No Story116 script, parse, invalid-call,
  invalid-access, missing-resource, or resource-load failure was emitted before
  shutdown.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Force-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceExitHatch`.
  - Node type: `Node2D`.
  - Script: `res://src/feature/factory_deep_route_endpoint.gd`.
  - Position: `Vector2(11680, 392)`.
  - Initial state: `visible=false`.
  - Endpoint id:
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch`.
  - Prompts: `Claim service sluice cache`, `Open Service Exit`,
    `Service Exit Open`.
  - Texture:
    `res://assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`.
  - Unlock VFX texture:
    `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`.
- Running scene check:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Runtime eval after Story115 cache claim reported `before_available=true`,
    `before_visible=true`, and `before_collision_blocking=true`.
  - Runtime open returned `opened_ok=true`.
  - Opened diagnostics reported `after_opened=true`, `after_available=false`,
    `after_collision_blocking=false`, route label
    `Service Sluice Exit Opened`, unlock VFX spawn count `1`, and local opened
    state `true`.
- Logs:
  - Current game run id `r262168792-57` had only the MCP helper registration
    info line and no errors.
  - `logs_read(source="editor", since_cursor=9)` returned no rows after final
    Story116 runtime validation.
  - `project_run` returned retained historical editor parse rows with
    `recent_errors_may_predate_run=true`; compatibility wrappers were added for
    the old helper names, and cursor-scoped editor log reads confirmed no new
    Story116 editor errors.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    response.

## Asset Pipeline

No new visual or audio assets were generated. Story116 reuses existing
image-generated/imported environment assets:

- Hatch texture:
  `assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`.
- Unlock VFX:
  `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`.
- Service sluice landing:
  `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`.
- Route floor:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Hidden until service sluice cache claimed | `report_1340`; MCP runtime eval | PASS |
| Hatch node/script/texture/id/prompts exist | MCP static check; `report_1340` | PASS |
| First open succeeds and duplicate open fails | `report_1340`; MCP runtime eval | PASS |
| Collision blocks before open and clears after open | `report_1340`; MCP runtime eval | PASS |
| Unlock VFX plays once | `report_1340`; MCP runtime eval | PASS |
| Route label updates to opened handoff | `report_1340`; MCP runtime eval | PASS |
| Restore backfills Story106-115 chain | `report_1340`; `report_1342` | PASS |
| Runtime scene loads, logs clean, screenshot non-empty | Headless smoke; MCP run + screenshot | PASS |

## Verdict

PASS. Story116 adds a visible and interactive service sluice exit hatch using
existing image-generated hatch/VFX assets, not placeholder geometry, and passes
focused, related, headless, and MCP runtime validation.
