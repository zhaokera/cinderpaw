# QA Evidence: Old Factory Overflow Pump Runoff Outlet Service Sluice Reward Cache -- 2026-07-10

## Scope

Story115 adds the service-sluice skirmish payoff: a once-only `+20 Gears`
reward cache after Story114, with route feedback and persistence.

## Automated Evidence

- RED focused: `reports/report_1336/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports/report_1336`
  - Result: exit `100`. Expected failure: Story115 diagnostics/API did not
    exist before implementation.
- GREEN focused: `reports/report_1337/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports/report_1337`
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1338/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports/report_1338`
  - Result: exit `0`, `8/8` passed.

## Headless Smoke

- Direct scene smoke:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . res://scenes/factory_route_transition_shell.tscn --quit-after 3 > reports/old_factory_overflow_pump_runoff_outlet_service_sluice_reward_cache_smoke.log 2>&1`
  exited `0`.
- The log contains Godot shutdown cleanup noise:
  `ObjectDB instances were leaked at exit` and
  `resources still in use at exit`. No Story115 script, parse, invalid-call,
  invalid-access, missing-resource, or resource-load failure was emitted before
  shutdown.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Force-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceRewardCache`.
  - Node type: `Node2D`.
  - Script: `res://src/feature/factory_combat_cache.gd`.
  - Position: `Vector2(11360, 410)`.
  - Initial state: `visible=false`.
  - Cache id/reward source:
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache`.
  - Reward gears: `20`.
  - Texture:
    `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
  - Prompt text before runtime availability: `Clear service sluice Spark Rat`.
- Running scene check:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Locked diagnostics reported `visible=false`, `available=false`,
    `claim_available=false`, and `service_sluice_skirmish_cleared=false`.
  - Available diagnostics after Story114 clear reported `visible=true`,
    `available=true`, `claim_available=true`, prompt `+20 Gears`, route label
    `Service Sluice Spark Rat Cleared`, right wall x `11500`, camera/background
    `11520`, and ground right edge x `11700`.
  - Claim diagnostics returned first claim `true`, duplicate claim `false`,
    reward payload `gears=20`, local claimed state `true`, and route label
    `Service Sluice Cache Claimed +20 Gears`.
- Logs:
  - Current game run id `r260168761-55` had only the MCP helper registration
    info line and no errors.
  - `logs_read(source="editor", since_cursor=9)` returned no rows after final
    Story115 runtime validation.
  - `project_run` returned retained historical editor parse rows with
    `recent_errors_may_predate_run=true`; focused/related tests, headless
    smoke, current-run game log, and cursor-scoped editor log confirmed no new
    Story115 error.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    response showing Cinderpaw and the service sluice reward cache in the same
    pocket.

## Asset Pipeline

No new visual or audio assets were generated. Story115 reuses existing
image-generated/imported environment assets:

- Reward cache:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
- Service sluice landing:
  `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`.
- Route floor:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Locked until service sluice skirmish clear | `report_1337`; MCP runtime eval | PASS |
| Cache node/script/texture/id/reward exist | MCP static check; `report_1337` | PASS |
| First claim succeeds and duplicate claim fails | `report_1337`; MCP runtime eval | PASS |
| Reward payload and local state persist | `report_1337`; MCP runtime eval | PASS |
| Route label updates to claimed payoff | `report_1337`; MCP runtime eval | PASS |
| Restore backfills Story106-114 chain | `report_1337`; `report_1338` | PASS |
| Runtime scene loads, logs clean, screenshot non-empty | Headless smoke; MCP run + screenshot | PASS |

## Verdict

PASS. Story115 adds a visible service sluice reward payoff using existing
image-generated cache art, not placeholder geometry, and passes focused,
related, headless, and MCP runtime validation.
