# QA Evidence: Old Factory Overflow Pump Runoff Duct Traverse -- 2026-07-10

## Scope

Story107 extends the Old Factory route after Story106 opens the overflow pump
runoff hatch. The slice adds a visible duct traversal and a reused steam vent
with deterministic `grace -> warning -> active -> safe` pressure timing.

## Automated Evidence

- RED focused: `reports/report_1286/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_traverse_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`. Expected failure: Story107 methods, diagnostics, and
    scene nodes did not exist before implementation.
- GREEN focused: `reports/report_1287/`
  - Same command.
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1288/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_traverse_test.gd -a res://tests/unit/gameplay/old_factory_route_floor_platform_visual_pass_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `9/9` passed.

## Headless Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --quit-after 2 > reports/old_factory_overflow_pump_runoff_duct_smoke.log 2>&1`
- Result: exit `0`.
- Keyword scan found no Story107 `SCRIPT ERROR`, `Parse Error`, `Invalid call`,
  `Invalid access`, missing-resource, or resource-load errors.
- Godot still reports known shutdown ObjectDB/resource cleanup noise in the log;
  no Story107 script or resource path appears in that shutdown cleanup noise.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Session: `cinderpaw@1014`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffDuct`.
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffSteamVent`.
  - `RightWall.position.x == 7660`.
  - `Player/Camera2D.limit_right == 7680`.
- Running scene check:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Current game log contains only `[godot_ai game_helper] registered mcp capture`.
  - `logs_read(source="editor", since_cursor=9)` returned no current-run editor
    errors.
- Runtime eval:
  - Hatch-open state made the duct visible and available.
  - Duct texture:
    `res://assets/environment/old_factory_aftershock_cooling_duct/env_old_factory_aftershock_cooling_duct_768.png`.
  - Activation at x `7160` returned `true`.
  - Active phase contact was enabled after deterministic time advance.
  - `apply_factory_steam_vent_contact` returned `true` and applied `8` damage
    (`100 -> 92`).
  - Hazard source id:
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct`.
  - Safe phase disabled contact.
  - Crossing x `7560` returned `true`, persisted activated/crossed state, and
    route label became `Overflow Pump Runoff Duct Crossed`.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    showing the reused cooling-duct visual and reused steam vent in the runoff
    pocket.

## MCP Notes

- `project_run` still returned retained historical Old Factory parse rows under
  `recent_errors_may_predate_run=true`; the current launch had
  `current_run_errors=[]`, helper live, clean current game log, and an empty
  editor logger read from the current-run cursor.
- An intermediate eval probe used a local variable named `ready`, which produced
  a GDScript eval-script shadow warning. The game was stopped, MCP logs and
  Debugger rows were cleared, the scene was relaunched, and the final eval used
  non-shadowing variable names.

## Asset Pipeline

- No new visual asset was generated for Story107.
- The duct reuses the existing imported image-generated cooling duct PNG.
- The hazard reuses the existing imported image-generated steam vent PNG.
- The route extension reuses the existing imported image-generated floor tile
  PNG.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Locked until overflow pump runoff hatch open | `report_1287`; MCP eval | PASS |
| Duct and steam vent nodes visible after hatch open | `report_1287`; MCP scene check | PASS |
| Route extends to x `7680` camera/right wall bounds | `report_1287`; MCP properties | PASS |
| Activation starts traversal and route label changes | `report_1287`; MCP eval | PASS |
| Active-only steam contact applies 8 damage | `report_1287`; MCP eval | PASS |
| Safe phase disables contact | `report_1287`; MCP eval | PASS |
| Crossed state persists and preserves Story106 hatch | `report_1287`; `report_1288` | PASS |
| Runtime scene loads with target nodes visible | MCP screenshot and logs | PASS |

## Verdict

PASS. Story107 converts the Story106 runoff hatch handoff into a visible,
playable ACT traversal pocket with timed steam damage, persistent crossed state,
and reused imported image-generated environment assets instead of placeholders.
