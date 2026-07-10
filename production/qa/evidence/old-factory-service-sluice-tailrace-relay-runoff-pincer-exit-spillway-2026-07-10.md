# QA Evidence: Old Factory Service Sluice Tailrace Relay Runoff Pincer Exit Spillway

Date: 2026-07-10
Story: `production/epics/player-abilities/story-124-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff-pincer-exit-spillway-traverse.md`
Engine: Godot 4.7
Godot AI MCP: 2.9.1

## Scope

Verified the Story124 pincer exit spillway traversal in
`res://scenes/factory_route_transition_shell.tscn`.

The slice adds no new enemy, reward cache, savepoint, frame animation, or visual
asset. It reuses the existing service-sluice landing texture, steam vent hazard
texture, and route floor tile asset.

## Automated Tests

- Focused RED: `reports/report_1379/`
  - Failed before Story124 diagnostics, activation, and completion methods were
    available.
- Focused GREEN: `reports/report_1380/`
  - Passed Story124 `2/2`.
- Related GREEN: `reports/report_1381/`
  - Passed Story124, Story123 exit hatch, Story122 reward cache, Story121
    pincer, Story120 runoff, and Story119 relay suites `12/12`.

## Headless Smoke

Command:

```bash
'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . --script res://tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.gd
```

Evidence:

- Log:
  `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.log`
- Marker:
  `service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke=passed`
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
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitSpillwayDuct`.
- Found
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitSpillwayVent`.
- Duct properties:
  - position: `Vector2(16720, 392)`
  - texture:
    `res://assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`
- Vent properties:
  - position: `Vector2(16720, 466)`
  - script: `res://src/feature/factory_steam_vent_hazard.gd`
  - hazard id:
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway`
  - damage: `8`
  - cooldown: `1.0`
- Bounds:
  - right wall x: `17280`
  - camera limit right: `17300`

Runtime checks:

- Launched current scene with `autosave=false`; helper live and
  `current_run_errors=[]`.
- Set a pincer exit hatch opened state through typed `game_eval`.
- Ready:
  - present: `true`
  - available: `true`
  - visible: `true`
  - phase: `idle`
  - route label: `Tailrace Runoff Exit Opened`
  - right wall x: `17280`
  - camera limit right: `17300`
  - ground right edge x: `17400`
  - floor tile count: `69`
- Active:
  - activation returned `true`
  - phase: `grace`
  - hazard contact: `false`
  - route label: `Cross Tailrace Exit Spillway`
- Contact:
  - phase: `active`
  - hazard contact: `true`
  - collision layer: `16`
  - collision mask: `12`
- Complete:
  - completion returned `true`
  - phase: `crossed`
  - crossed: `true`
  - hazard contact: `false`
  - route label: `Tailrace Exit Spillway Crossed`
  - local crossed state: `true`

Logs and screenshot:

- Current-run game log contained only the Godot AI helper registration line.
- Editor log was empty.
- Game screenshot response was non-empty: `640x359`.

## Result

PASS. Story124 acceptance criteria are covered by focused tests, adjacent
regression tests, headless smoke, and MCP runtime verification.
