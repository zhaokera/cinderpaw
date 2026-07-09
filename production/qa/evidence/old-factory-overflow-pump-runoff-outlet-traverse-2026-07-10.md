# QA Evidence: Old Factory Overflow Pump Runoff Outlet Traverse -- 2026-07-10

## Scope

Story110 adds a short movement-pressure pocket after Story109 opens the overflow
pump runoff exit gate. The slice extends the route bounds, reuses an existing
generated duct visual, and adds a reused steam vent timing hazard.

## Automated Evidence

- RED focused: `reports/report_1297/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_traverse_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`. Expected failure: Story110 diagnostics and traversal
    APIs did not exist before implementation.
- GREEN focused: `reports/report_1298/`
  - Same command.
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1299/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_traverse_test.gd -a res://tests/unit/gameplay/old_factory_route_floor_platform_visual_pass_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `9/9` passed.

## Headless Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --quit-after 3 > reports/old_factory_overflow_pump_runoff_outlet_traverse_smoke.log 2>&1`
- Result: exit `0`.
- Keyword scan found no Story110 `SCRIPT ERROR`, `Parse Error`, `Invalid call`,
  `Invalid access`, missing-resource, or resource-load errors.
- Godot still reports known shutdown ObjectDB/resource cleanup noise in the log;
  no Story110 script or resource path appears in that shutdown cleanup noise.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletDuct`.
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletSteamVent`.
  - Duct visual texture:
    `res://assets/environment/old_factory_aftershock_cooling_duct/env_old_factory_aftershock_cooling_duct_768.png`.
  - Steam vent script and properties:
    `res://src/feature/factory_steam_vent_hazard.gd`,
    hazard id
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet`,
    damage `8`, cooldown `1.0`.
- Running scene check:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Runtime tree contained both Story110 target nodes.
  - Runtime duct node: `Sprite2D`, target texture bound, initial
    `visible=false`.
  - Runtime steam vent node: group `factory_hazard`, target script bound,
    hazard id and damage set, initial `visible=false`, monitoring/masks off.
  - Current game log contains only `[godot_ai game_helper] registered mcp capture`.
  - `logs_read(source="editor", since_cursor=9)` returned no current-run editor
    errors.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    response.

## MCP Notes

- `project_run` returned retained historical Old Factory parse rows under
  `recent_errors_may_predate_run=true`; the current launch had
  `current_run_errors=[]`, helper live, clean current game log, and an empty
  editor logger read from the current-run cursor.

## Asset Pipeline

- No new visual asset was generated for Story110.
- The outlet duct reuses the existing imported image-generated aftershock
  cooling duct PNG.
- The hazard reuses the existing imported steam vent PNG and script.
- The extended floor uses the existing imported old-factory floor tile PNG.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Locked until Story109 gate opened | `report_1298` | PASS |
| Outlet duct and vent visible after gate opens | `report_1298`; MCP scene check | PASS |
| Activation x starts traverse and label | `report_1298` | PASS |
| Steam vent active window enables contact | `report_1298` | PASS |
| Completion persists crossed state | `report_1298` | PASS |
| Restore backfills Story106-109 chain | `report_1298`; `report_1299` | PASS |
| Route bounds/floor visuals extended | `report_1299`; MCP scene check | PASS |
| Runtime scene loads with target nodes and clean logs | MCP scene/runtime tree, logs, screenshot | PASS |

## Verdict

PASS. Story110 extends the runoff route into a visible timed traversal pocket
without adding placeholder blocks, new art churn, or a broad test sweep.
