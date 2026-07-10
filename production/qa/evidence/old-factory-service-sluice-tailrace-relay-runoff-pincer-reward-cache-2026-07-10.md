# QA Evidence: Old Factory Service Sluice Tailrace Relay Runoff Pincer Reward Cache

Date: 2026-07-10
Story: `production/epics/player-abilities/story-122-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff-pincer-reward-cache.md`
Engine: Godot 4.7
Godot AI MCP: 2.9.1

## Scope

Verified the Story122 post-pincer payoff cache in
`res://scenes/factory_route_transition_shell.tscn`.

The slice adds no new enemy, hazard, route gate, savepoint, frame animation, or
visual asset. It completes the existing reward-cache node after Story121 and
reuses the imported lower-deck cache texture.

## Automated Tests

- Focused RED: `reports/report_1370/`
  - Failed before Story122 diagnostics and claim methods were available.
- Focused GREEN: `reports/report_1371/`
  - Passed Story122 `2/2`.
- Related GREEN: `reports/report_1372/`
  - Passed Story122, Story121 pincer, Story120 runoff, and Story115 service
    sluice reward cache suites `8/8`.

## Headless Smoke

Command:

```bash
'/Applications/Godot 2.app/Contents/MacOS/Godot' --headless --path . -s res://tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke.gd
```

Evidence:

- Log: `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke.log`
- Marker:
  `service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke=passed`
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
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerRewardCache`.
- Node properties:
  - script: `res://src/feature/factory_combat_cache.gd`
  - position: `Vector2(15460, 410)`
  - z index: `22`
  - cache id/source:
    `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache`
  - reward gears: `20`
  - claim radius: `96`
  - locked prompt: `Clear tailrace runoff pincer`
  - available prompt: `+20 Gears`
  - claimed prompt: `Claimed`

Runtime checks:

- Launched current scene with `autosave=false`; helper live.
- Set a pincer-cleared state through typed `game_eval`.
- Before claim:
  - present: `true`
  - visible: `true`
  - available: `true`
  - claim available: `true`
  - route label: `Tailrace Runoff Pincer Cleared`
  - position: `Vector2(15460, 410)`
- Claim:
  - first claim: `true`
  - duplicate claim: `false`
- After claim:
  - claimed: `true`
  - claim available: `false`
  - route label: `Tailrace Runoff Pincer Cache Claimed +20 Gears`
  - local state claimed flag: `true`
  - feedback payload text:
    `Tailrace Runoff Pincer Cache Claimed +20 Gears`

Logs and screenshot:

- Current-run game log contained only the Godot AI helper registration line.
- Editor log was empty.
- Game screenshot response was non-empty: `960x539`.

## Result

PASS. Story122 acceptance criteria are covered by focused tests, adjacent
regression tests, headless smoke, and MCP runtime verification.
