# QA Evidence: Old Factory Overflow Pump Runoff Exit Reward Cache -- 2026-07-10

## Scope

Story109 adds the reward-and-handoff beat after Story108 clears the overflow
pump runoff exit skirmish. The slice reuses existing imported visuals for a
claimable cache and a runoff exit gate.

## Automated Evidence

- RED focused: `reports/report_1293/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`. Expected failure: Story109 diagnostics and claim/open
    APIs did not exist before implementation.
- GREEN focused: `reports/report_1294/`
  - Same command.
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1295/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `8/8` passed.
- Pre-push focused rerun: `reports/report_1296/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `2/2` passed.

## Headless Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --quit-after 3 > reports/old_factory_overflow_pump_runoff_exit_reward_cache_smoke.log 2>&1`
- Result: exit `0`.
- Keyword scan found no Story109 `SCRIPT ERROR`, `Parse Error`, `Invalid call`,
  `Invalid access`, missing-resource, or resource-load errors.
- Godot still reports known shutdown ObjectDB/resource cleanup noise in the log;
  no Story109 script or resource path appears in that shutdown cleanup noise.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Session: `cinderpaw@1014`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffExitRewardCache`.
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffExitGate`.
  - Cache visual texture:
    `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
  - Gate visual texture:
    `res://assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`.
- Running scene check:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Runtime tree contained both Story109 target nodes.
  - Cache runtime node: script `res://src/feature/factory_combat_cache.gd`,
    `cache_id` and `reward_source` set to Story109 id, `reward_gears=20`,
    `claim_radius_px=96`, prompt `+20 Gears`, initial `visible=false`.
  - Gate runtime node: script `res://src/feature/factory_deep_route_endpoint.gd`,
    endpoint id set to Story109 gate id, activation radius `96`, prompt
    `Open Runoff Exit Gate`, initial `visible=false`.
  - Current game log contains only `[godot_ai game_helper] registered mcp capture`.
  - `logs_read(source="editor", since_cursor=9)` returned no current-run editor
    errors.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    response.

## MCP Notes

- `project_run` still returned retained historical Old Factory parse rows under
  `recent_errors_may_predate_run=true`; the current launch had
  `current_run_errors=[]`, helper live, clean current game log, and an empty
  editor logger read from the current-run cursor.
- The available MCP runtime inspection surface did not expose arbitrary
  GDScript eval through `game_manage`. Story109 claim/open/persistence behavior
  is covered by focused GdUnit; MCP covers scene reload, runtime tree, texture
  binding, current-run logs, and screenshot.

## Asset Pipeline

- No new visual asset was generated for Story109.
- The cache reuses the existing imported image-generated lower-deck cache PNG.
- The gate reuses the existing imported image-generated deep-bulkhead PNG.
- The gate unlock VFX reuses the existing imported factory route unlock spark.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Cache locked until Story108 cleared | `report_1294` | PASS |
| Cache visible/claimable after Story108 clear | `report_1294`; MCP scene check | PASS |
| Cache pays once and persists reward feedback | `report_1294` | PASS |
| Gate unlocks after cache claim | `report_1294` | PASS |
| Gate opens once and disables collision | `report_1294` | PASS |
| Restore preserves Story106/107/108 chain | `report_1294`; `report_1295` | PASS |
| Runtime scene loads with target nodes and clean logs | MCP scene/runtime tree, logs, screenshot | PASS |

## Verdict

PASS. Story109 converts the Story108 runoff exit clear into a visible reward
cache and textured gate handoff without adding placeholder blocks or unnecessary
new systems.
