# QA Evidence: Old Factory Overflow Pump Runoff Outlet Reward Cache -- 2026-07-10

## Scope

Story112 adds a reward cache and service hatch after Story111 clears the runoff
outlet Spark Rat. The slice validates one-time reward claiming, service hatch
unlock/open behavior, route extension bounds, save-state backfill, and runtime
scene visibility.

## Automated Evidence

- RED focused: `reports/report_1311/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `100`. Expected failure: Story112 diagnostics and interaction
    APIs did not exist before implementation.
- GREEN focused: `reports/report_1319/`
  - Same command.
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1320/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_test.gd --ignoreHeadlessMode -rd res://reports -c`
  - Result: exit `0`, `8/8` passed.
- Final post-format focused rerun: `reports/report_1321/`
  - Same focused command.
  - Result: exit `0`, `2/2` passed.
- Final post-format related rerun: `reports/report_1322/`
  - Same related regression command.
  - Result: exit `0`, `8/8` passed.

## Headless Smoke

- Command:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --quit-after 3 > reports/old_factory_overflow_pump_runoff_outlet_reward_cache_smoke.log 2>&1`
- Result: exit `0`.
- Final log contains engine startup, DataManager domain loads, and MCP helper
  registration. No Story112 script, parse, invalid-call/access,
  missing-resource, or resource-load errors were emitted.
- The log also contains Godot process-exit cleanup noise:
  `ObjectDB instances were leaked at exit` and
  `resources still in use at exit`. This did not block the scene load,
  automated tests, or MCP runtime run.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletRewardCache`.
  - Cache node type: `Node2D`.
  - Cache script: `res://src/feature/factory_combat_cache.gd`.
  - Cache position: `Vector2(9520, 410)`, initially `visible=false`.
  - Cache id/reward source:
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache`.
  - Cache reward: `20` gears.
  - Disk-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceHatch`.
  - Hatch node type: `Node2D`.
  - Hatch script: `res://src/feature/factory_deep_route_endpoint.gd`.
  - Hatch position: `Vector2(9880, 392)`, initially `visible=false`.
  - Hatch endpoint id:
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch`.
  - Right wall x `10220`, camera limit right `10240`.
- Running scene check:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Runtime eval confirmed Story112 diagnostics, cache claim API, and service
    hatch open API exist.
  - Runtime restored Story111 clear state made the cache visible and available
    with prompt `+20 Gears` and route label `Runoff Outlet Spark Rat Cleared`.
  - Runtime cache claim returned `true`, recorded reward
    `20` gears, and emitted feedback `Runoff Outlet Cache Claimed +20 Gears`.
  - Runtime hatch diagnostics after cache claim reported
    `available=true`, `visible=true`, `collision_blocking=true`, and prompt
    `Open Runoff Outlet Service Hatch`.
  - Runtime hatch open returned `true`, then reported `opened=true`,
    `available=false`, `collision_blocking=false`, and route label
    `Runoff Outlet Service Hatch Open`.
  - Runtime `get_local_state()` recorded both
    `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed=true`
    and
    `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened=true`.
- Logs:
  - Current game run id `r254783717-49` had only the MCP helper registration
    info line and no errors.
  - Editor log source still retained older historical parse rows. A follow-up
    `logs_read(source="editor", since_cursor=9)` returned no new rows after the
    Story112 runtime validation.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    response showing the claimed cache and opened service hatch.

## MCP Notes

- MCP `project_run` continued to include retained historical parse rows under
  `recent_errors_may_predate_run=true`; they were not current-run failures.
  Current launch had `current_run_errors=[]`, helper live, successful runtime
  eval calls against the Story112 APIs, and a successful game screenshot.
- One transient MCP `game_eval` attempt passed a `Vector2` where the API
  expected a `Node`. The game was stopped, MCP logs were cleared, the scene was
  relaunched, and the corrected runtime eval validation passed without a new
  editor log row after cursor `9`.

## Asset Pipeline

- No new visual asset was generated for Story112.
- The slice reuses existing imported image-generated environment assets for the
  cache, service hatch, unlock spark, and route floor.
- Story112 adds no new player-visible character, so it does not add or modify
  `AnimatedSprite2D + SpriteFrames` character animation resources.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Locked until Story111 clear | `report_1321` | PASS |
| Cache appears and pays 20 gears once | `report_1321`; MCP runtime eval | PASS |
| Service hatch appears after cache claim | `report_1321`; MCP runtime eval | PASS |
| Hatch opens once and disables collision | `report_1321`; MCP runtime eval | PASS |
| Route bounds extend to x 10220 / camera 10240 | `report_1321`; MCP static scene check | PASS |
| Restore backfills Story106-111 chain | `report_1321`; `report_1322` | PASS |
| Runtime scene loads and screenshot is non-empty | MCP run + screenshot | PASS |

## Verdict

PASS. Story112 adds a playable reward-and-handoff beat after the overflow pump
runoff outlet skirmish without adding placeholder blocks, single-frame
characters, or unnecessary new art churn.
