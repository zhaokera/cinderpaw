# QA Evidence: Old Factory Overflow Pump Runoff Outlet Service Sluice Tailrace -- 2026-07-10

## Scope

Story117 adds a short service-sluice tailrace traversal after the Story116 exit
hatch. The pocket extends playable space, exposes a reused authored duct and
timed steam vent, persists crossed state, and keeps the Story106-116 chain from
replaying after restore.

## Automated Evidence

- RED focused: `reports/report_1344/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_traverse_test.gd --ignoreHeadlessMode`
  - Result: exit `100`. Expected failure: Story117 tailrace diagnostics,
    activation API, and completion API did not exist before implementation.
- GREEN focused: `reports/report_1345/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_traverse_test.gd --ignoreHeadlessMode`
  - Result: exit `0`, `2/2` passed.
- Related regression: `reports/report_1346/`
  - Command:
    `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_traverse_test.gd -a res://tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_test.gd --ignoreHeadlessMode`
  - Result: exit `0`, `12/12` passed.

## Headless Smoke

- Direct runtime smoke:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --script tests/smoke/old_factory_service_sluice_tailrace_smoke.gd > reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_smoke.log 2>&1`
  exited `0`.
- The smoke log contains `service_sluice_tailrace_smoke=passed`.
- The log contains known Godot shutdown cleanup noise:
  `ObjectDB instances were leaked at exit` and
  `resources still in use at exit`. No Story117 script, parse, invalid-call,
  invalid-access, missing-resource, or resource-load failure was emitted before
  shutdown.

## Godot MCP Runtime Evidence

- Godot MCP version: `2.9.1`.
- Editor/runtime: Godot `4.7-stable`.
- Scene: `res://scenes/factory_route_transition_shell.tscn`.
- Static MCP scene check:
  - Force-reloaded scene contained
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceDuct`
    and
    `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceVent`.
  - Tailrace duct type: `Sprite2D`; texture:
    `res://assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`.
  - Tailrace vent type: `Area2D`; script:
    `res://src/feature/factory_steam_vent_hazard.gd`; hazard id:
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace`;
    damage `8`, cooldown `1.0`.
  - Right wall x `12700` and `Player/Camera2D.limit_right=12720`.
- Running scene check:
  - `project_run.current_run_errors=[]`.
  - Game helper live and session active.
  - Typed runtime eval reported locked unavailable/hidden, ready
    available/visible after Story116 hatch opened, activation `true`, active
    phase `active`, active contact `true`, right wall x `12700`, camera right
    `12720`, background width `12720`, ground right edge x `12800`, floor tile
    count `53`, completion `true`, crossed `true`, contact disabled after
    crossed, route label `Service Sluice Tailrace Crossed`, and local crossed
    state `true`.
- Logs:
  - Current game run id `r263857094-59` had only the MCP helper registration
    info line and no errors.
  - `logs_read(source="editor", since_cursor=9)` returned no rows after final
    Story117 runtime validation.
  - `project_run` returned retained historical editor parse rows with
    `recent_errors_may_predate_run=true`; focused/related tests, smoke,
    current-run game log, typed runtime eval, and cursor-scoped editor log were
    clean.
- Screenshot:
  - MCP `editor_screenshot(source="game")` returned a non-empty `960x539` PNG
    response while the tailrace was active.

## Asset Pipeline

No new visual or audio assets were generated. Story117 reuses existing
image-generated/imported environment assets:

- Service sluice/tailrace duct:
  `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`.
- Steam vent:
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
- Route floor:
  `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`.

The AGENTS frame-animation rule is not triggered because Story117 adds an
environment traversal hazard, not a new player-visible character.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Hidden until Story116 hatch opened | `report_1345`; MCP runtime eval | PASS |
| Tailrace duct/vent nodes and reused textures exist | `report_1345`; MCP static check | PASS |
| Activation x and route label work | `report_1345`; headless smoke; MCP runtime eval | PASS |
| Active-only steam contact | `report_1345`; headless smoke; MCP runtime eval | PASS |
| Completion persists crossed state | `report_1345`; headless smoke; MCP runtime eval | PASS |
| Scene bounds cover new route pocket | `report_1345`; MCP static/runtime checks | PASS |
| Restore backfills Story106-116 chain | `report_1345`; `report_1346` | PASS |
| Runtime scene loads, logs clean, screenshot non-empty | headless smoke; MCP run + screenshot | PASS |

## Verdict

PASS. Story117 adds a visible and playable service-sluice tailrace traversal
using existing image-generated/imported environment assets, extends the playable
route beyond the Story116 hatch, and passes focused, related, headless, and MCP
runtime validation.
