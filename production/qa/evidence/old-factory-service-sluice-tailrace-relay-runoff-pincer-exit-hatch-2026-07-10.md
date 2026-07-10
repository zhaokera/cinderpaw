# QA Evidence: Old Factory Service Sluice Tailrace Relay Runoff Pincer Exit Hatch

Date: 2026-07-10
Story: `production/epics/player-abilities/story-123-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff-pincer-exit-hatch-handoff.md`
Engine: Godot 4.7
Godot AI MCP: 2.9.1

## Scope

Verified the Story123 pincer reward exit hatch handoff in
`res://scenes/factory_route_transition_shell.tscn`.

The slice adds no new enemy, hazard, reward cache, savepoint, frame animation,
or visual asset. It reuses the existing deep-route endpoint script, imported
deep-bulkhead hatch texture, unlock spark VFX, and route floor tile asset.

## Automated Tests

- Focused RED: `reports/report_1373/`
  - Failed before Story123 diagnostics and open methods were available.
- Focused GREEN: `reports/report_1377/`
  - Passed Story123 `2/2`.
- Related GREEN: `reports/report_1378/`
  - Passed Story123, Story122 reward cache, Story121 pincer, Story120 runoff,
    Story119 relay, and Story116 service-sluice hatch suites `12/12`.

Note: an earlier related run `reports/report_1375/` exposed the expected
Story122 route-objective handoff change. The Story122 restore assertion was
updated from the old cache-claimed terminal label to the new Story123
`Open Tailrace Runoff Exit` label, then `reports/report_1378/` passed.

## Headless Smoke

Command:

```bash
'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . -s res://tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke.gd
```

Evidence:

- Log:
  `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke.log`
- Marker:
  `service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke=passed`
- Exit code: `0`
- Notes: the log contains known Godot shutdown-time ObjectDB/resource cleanup
  messages after the pass marker. No project script parse errors, invalid
  calls, invalid access, failed resource loads, or missing resources were
  present.

## MCP Runtime Evidence

MCP session:

- Session: `cinderpaw@e40d`
- Godot: `4.7-stable (official)`
- Plugin/server: `2.9.1`
- Scene: `res://scenes/factory_route_transition_shell.tscn`

Editor-scene checks:

- Disk-reloaded target scene with `force_reload=true`.
- Found
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitHatch`.
- Node properties:
  - script: `res://src/feature/factory_deep_route_endpoint.gd`
  - position: `Vector2(16080, 392)`
  - z index: `27`
  - endpoint id:
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch`
  - activation radius: `96`
  - locked prompt: `Claim pincer cache`
  - available prompt: `Open Tailrace Exit`
  - activated prompt: `Tailrace Exit Open`
  - unlock VFX:
    `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
- Bounds:
  - right wall x: `16480`
  - camera limit right: `16500`

Runtime checks:

- Launched current scene with `autosave=false`; helper live.
- Set a pincer reward cache claimed state through typed `game_eval`.
- Before open:
  - present: `true`
  - visible: `true`
  - available: `true`
  - collision blocking: `true`
  - route label: `Open Tailrace Runoff Exit`
- Open:
  - first open: `true`
  - duplicate open: `false`
- After open:
  - opened: `true`
  - available: `false`
  - collision blocking: `false`
  - prompt: `Tailrace Exit Open`
  - route label: `Tailrace Runoff Exit Opened`
  - unlock VFX spawn count: `1`
  - local state opened flag: `true`

Logs and screenshot:

- Current-run game log contained only the Godot AI helper registration line.
- Editor log was empty.
- Game screenshot response was non-empty: `960x539`.

## Result

PASS. Story123 acceptance criteria are covered by focused tests, adjacent
regression tests, headless smoke, and MCP runtime verification.
