# QA Evidence: Old Factory Overflow Pump Reward Cache -- 2026-07-10

## Scope

Story106 adds a post-skirmish Old Factory reward-and-exit loop after Story099.
After the overflow pump Coil Rat is cleared, a cache becomes visible, pays
`20` gears once, then unlocks a runoff hatch that opens once and removes
blocking collision.

## Automated Evidence

- RED focused: `reports/report_1282/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`. Expected failure: Story106 methods and diagnostics did
    not exist before implementation.
- GREEN focused: `reports/report_1284/`
  - Same command.
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1285/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_test.gd -a res://tests/unit/gameplay/factory_route_runtime_roundtrip_test.gd -a res://tests/unit/gameplay/old_factory_service_lift_handoff_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `15/15` passed.

## Headless Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_overflow_pump_reward_cache_smoke.log`
- Result: exit `0`.
- Keyword scan found no `SCRIPT ERROR`, `Parse Error`, `Invalid call`,
  `Invalid access`, missing-resource, or resource-load errors in the log.
- Godot still reports the known shutdown ObjectDB/resource cleanup noise on
  stdout.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRewardCache`.
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpExitHatch`.
- Running scene check:
  - Runtime tree contained both cache and hatch nodes.
  - Player sprite node is `AnimatedSprite2D`.
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Current game log contains only `[godot_ai game_helper] registered mcp capture`.
- Runtime eval:
  - Cache before claim: visible, available, prompt `+20 Gears`, texture
    `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
  - Claim call returned `true`.
  - Cache after claim: `claimed=true`, `claim_available=false`, reward payload
    `gears=20`, feedback `Overflow Pump Cache Claimed +20 Gears`.
  - Hatch before open: visible, available, prompt `Open Runoff Hatch`,
    `collision_blocking=true`, texture
    `res://assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`.
  - Open call returned `true`.
  - Hatch after open: `opened=true`, `available=false`,
    `collision_blocking=false`.
  - Route label: `Overflow Pump Runoff Hatch Open`.
  - Local state persisted both Story106 flags.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    showing the overflow pump pocket and `Runoff Hatch Open` prompt.

## MCP Notes

- The editor log still returns retained historical Old Factory parse rows whose
  line numbers no longer match the current script on disk. Story106 acceptance
  uses `project_run.current_run_errors=[]`, focused/related GdUnit passes,
  headless smoke, clean current game log, successful runtime eval, and the MCP
  screenshot response.
- An early eval probe used GDScript type inference that paused the debugger;
  the game was stopped, MCP/Debugger logs were cleared, the scene was relaunched,
  and the final eval used explicit `bool()` calls. The final run stayed live.

## Asset Pipeline

- No new visual asset was generated for Story106.
- The cache reuses the existing imported image-generated lower-deck cache PNG.
- The runoff hatch reuses the existing imported image-generated deep bulkhead
  PNG.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Cache locked until overflow pump clear | `report_1284`; MCP eval | PASS |
| Cache visible/claimable after pump clear | `report_1284`; MCP eval | PASS |
| Cache pays once and persists reward feedback | `report_1284`; MCP eval | PASS |
| Hatch unlocks after cache claim | `report_1284`; MCP eval | PASS |
| Hatch opens once and removes collision | `report_1284`; MCP eval | PASS |
| Restored state preserves condenser chain and lift | `report_1284`; `report_1285` | PASS |
| Runtime scene loads with target nodes visible | MCP scene/runtime tree; screenshot | PASS |
