# QA Evidence: Old Factory Service Sluice Tailrace Relay

Date: 2026-07-10
Story: `production/epics/player-abilities/story-119-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay.md`
Engine: Godot 4.7 stable
MCP: Godot AI 2.9.1

## Scope

Story119 adds a Story118-gated Tailrace Relay savepoint after the
service-sluice tailrace Coil Rat ambush. It verifies availability, one-shot
activation, last-discovered savepoint persistence, direct SceneManager spawn
mapping, death/respawn behavior, route feedback, and route bounds.

## Assets

No new image generation was required. The story reuses existing generated and
imported assets:

- `assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`
- `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`
- `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`

## Automated Evidence

- Focused RED:
  `reports/report_1350/` failed before Story119 diagnostics/API/scene/state
  existed.
- Spawn regression RED:
  `reports/report_1359/` failed after adding direct SceneManager-spawn coverage:
  the player stayed `400px` away from the relay and the route label remained
  `Tailrace Relay Secured`.
- Focused GREEN:
  `reports/report_1360/` passed `2/2` after adding the Story119 spawn mapping
  and respawn label branch.
- Related GREEN:
  `reports/report_1361/` passed `21/21` across:
  Story113 service-sluice traverse, Story114 skirmish, Story115 reward cache,
  Story116 exit hatch, Story117 tailrace traverse, Story118 ambush, Story119
  relay, Story004 savepoint selection, and player respawn visual feedback.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_smoke.log`
  exited `0` and printed `service_sluice_tailrace_relay_smoke=passed`.

## MCP Runtime Evidence

- Session `cinderpaw@1014` was connected and active with Godot `4.7-stable`,
  plugin version `2.9.1`, server version `2.9.1`, readiness `ready`.
- MCP `scene_open(force_reload=true)` reloaded
  `res://scenes/factory_route_transition_shell.tscn` from disk.
- MCP editor node checks found
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelaySavepoint`
  and `FactoryRouteFloorVisual58`.
- MCP property checks confirmed savepoint id, scene id, spawn point, prompt,
  script `res://src/feature/savepoint_runtime.gd`, relay texture, unlock VFX,
  default hidden state, and disabled interaction monitoring/monitorable.
- MCP `project_run(mode=current)` launched with helper live and
  `current_run_errors=[]`.
- MCP runtime tree showed `FactoryGameFlowController`, Player, Tailrace Relay,
  Tailrace Coil Rat, and 58 floor visual tiles.
- MCP typed `game_eval` set Story118 ambush cleared state, moved Player into
  relay range, activated the relay, and returned:
  `activated_call=true`, `present=true`, `visible=true`, `activated=true`,
  `available=false`, `activation_vfx_spawn_count=1`,
  `route_label_text="Tailrace Relay Secured"`, and last savepoint scene/spawn
  matching Story119.
- MCP game screenshot returned `960x539` PNG data and showed the Tailrace Relay
  visual plus `Repair Tailrace Relay` prompt.
- MCP final editor state remained `status=live`, `helper_live=true`,
  `game_capture_ready=true`, with no debugger break before stopping the game.

## Notes

`project_run` continued to surface retained historical editor parse rows marked
as `recent_errors_may_predate_run=true` and `recent_errors_scope=retained_recent`.
Current-run errors were empty, the running helper was live, typed runtime eval
passed, `--check-only --script res://src/gameplay/old_factory_entrance_scene.gd`
passed, and local `rg` confirmed the named helper functions exist. One untyped
MCP eval probe caused a temporary eval-only debugger break due Variant type
inference; the game was stopped and relaunched, then typed eval and screenshot
checks passed.
