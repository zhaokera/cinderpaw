# QA Evidence: Old Factory Service Sluice Tailrace Relay Runoff

Date: 2026-07-10
Engine: Godot 4.7
MCP: Godot AI 2.9.1

## Scope

Story120 adds a short post-Tailrace-Relay runoff traversal pocket to
`res://scenes/factory_route_transition_shell.tscn`. It is gated by the
Story119 tailrace relay, uses a deterministic steam vent contact window, and
persists activated/crossed local state without changing the Story119 savepoint
payload.

## Asset Evidence

No new assets were generated. Story120 reuses existing imported visual assets:

- `assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`
- `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

The AGENTS frame-animation rule is not triggered because this story adds an
environment traversal hazard, not a new visible character.

## Automated Verification

- Focused RED: `reports/report_1362/` failed before Story120 diagnostics,
  activation/completion APIs, scene node, state, and bounds existed.
- Focused GREEN: `reports/report_1364/` passed Story120 `2/2`.
- Related GREEN: `reports/report_1365/` passed Story120 plus Story119,
  Story118, Story117, and Story116 adjacent service-sluice/tailrace suites
  `10/10`.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_smoke.log`
  exited `0` and printed `service_sluice_tailrace_relay_runoff_smoke=passed`.
  It reported only known Godot cleanup-time ObjectDB/resource messages after
  shutdown.

## MCP Runtime Verification

Godot AI MCP `2.9.1` connected to session `cinderpaw@e40d` under Godot
`4.7-stable`.

- Opened `res://scenes/factory_route_transition_shell.tscn` from disk and ran
  the current scene; `project_run` returned `current_run_errors=[]`,
  `helper_live=true`, and `session_active=true`.
- `node_find` found both Story120 edited-scene nodes:
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffDuct`
  and
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffVent`.
- `node_get_properties` confirmed the duct uses
  `res://assets/environment/old_factory_runoff_service_hatch_landing/env_old_factory_runoff_service_hatch_landing_768.png`
  at x `14040`, and the vent uses
  `res://src/feature/factory_steam_vent_hazard.gd` with hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff`,
  damage `8`, cooldown `1.0`, and locked-state `visible=false`,
  `monitoring=false`, `collision_layer=0`, `collision_mask=0`.
- Runtime `game_manage(get_node_info)` found the Story120 vent in the running
  game under group `factory_hazard` with the same script, hazard id, damage,
  cooldown, position, locked visibility, and disabled monitoring/collision
  state.
- `editor_screenshot(source="game")` returned a non-empty game framebuffer
  (`640x359`, original `1278x718`) showing Cinderpaw and the factory route.
- Current-run game log contained only the Godot AI helper registration line;
  editor log returned no current errors.

Activation behavior, active-only contact collision, route bounds, restore
backfill, and savepoint preservation are covered by focused and related GdUnit
plus the headless smoke above.

## Notes

QA sidecar recommended a post-relay Spark Rat + Coil Rat skirmish for stronger
ACT density. The integrating decision for Story120 is a shorter traversal beat
because Story118 already introduced a Tailrace Coil Rat ambush immediately
before the Story119 relay. The next Old Factory slice can use the sidecar's
dual-enemy recommendation as a post-runoff skirmish.
