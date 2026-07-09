# QA Evidence: Old Factory Forward Pressure Aftershock Exhaust Breaker Corridor

Date: 2026-07-09
Engine: Godot 4.7
Godot AI MCP: 2.9.1

## Scope

Story090 extends the lower-deck corridor to x `3200.0` and adds the
Story089-gated aftershock exhaust breaker corridor: Coil Rat entity `2133`,
steam vent hazard `old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker`,
and one-shot breaker cut state.

## Automated Tests

- Initial focused RED:
  `reports/report_1206/`
  - Expected failures: route geometry still ended at x `2400.0`; Story090
    diagnostics/APIs/local state did not exist.
- Focused GREEN:
  `reports/report_1208/`
  - `2/2` Story090 tests passed.
- Related regression RED:
  `reports/report_1209/`
  - `34/35` passed; Story089 settled diagnostics still reported stale
    Spark Rat entity id `2132` after clear.
- Final related GREEN:
  `reports/report_1210/`
  - `35/35` passed across Story090, Story089-084, Story083, Story074,
    service-lift, no-loss respawn, Story068 no-replay, Story071 audio
    no-replay, forward conduit clear feedback, forward pressure reward-cache
    audio, and steam-vent hazard coverage.

## Headless Smoke

Command:

```bash
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_forward_pressure_aftershock_exhaust_breaker_corridor_smoke.log
```

Result:

- Exit code: `0`.
- Log scan:
  `rg -n "SCRIPT ERROR|Parse Error|Invalid call|Invalid access|Resource file not found|Failed loading resource|ERROR:|WARNING:" reports/old_factory_forward_pressure_aftershock_exhaust_breaker_corridor_smoke.log`
  returned no matches.
- The terminal still printed existing Godot cleanup-time ObjectDB/resource
  messages at process exit; the smoke log did not contain project script,
  parse, invalid-call/access, or missing-resource failures.

## Godot MCP Runtime Evidence

- `session_manage(list)` reported session `cinderpaw@1014`, Godot
  `4.7-stable`, plugin version `2.9.1`, server version `2.9.1`, readiness
  `ready`.
- `scene_open(force_reload=true)` opened
  `res://scenes/factory_route_transition_shell.tscn`.
- Editor scene checks found:
  - `FactoryLowerDeckForwardPressureAftershockExhaustBreakerCoilRat`
  - `FactoryLowerDeckForwardPressureAftershockExhaustBreakerVent`
  - `FactoryLowerDeckForwardPressureAftershockExhaustBreaker`
  - `FactoryLowerDeckForwardPressureAftershockExhaustBreakerCoilRat/Sprite`
    as `AnimatedSprite2D` using
    `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`.
- `project_run(mode=custom, scene=..., autosave=false)` returned
  `helper_live=true`, `status=live`, and `recent_errors=[]`.
- Runtime `game_eval` with Story089 cleared state returned:
  - activation `true`
  - entity id `2133`
  - family id `factory_coil_rat`
  - target assigned `true`
  - frame counts `idle/run/attack_tell/attack/hurt/death = 3`
  - hazard visible/contact active `true`
  - hazard id
    `old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker`
  - hazard damage `8`, cooldown `1.0`
  - hazard texture
    `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
  - route label `Secure Aftershock Exhaust Breaker`
- Runtime cut evidence returned:
  - `apply_damage(2133, 999)=true`
  - secured `true`
  - Coil Rat hidden after secured `true`
  - vent hidden after secured `true`
  - breaker visible after secured `true`
  - first cut `true`
  - duplicate cut `false`
  - final cut `true`
  - final route label `Aftershock Exhaust Pressure Cut`
  - unlock feedback played `true`, spawn count `1`
  - local flags `activated/coil_rat_defeated/secured/cut = true`
- `game_manage(get_node_info)` confirmed the running Coil Rat node exists,
  is visible, and uses `res://src/gameplay/factory_coil_rat.gd`.
- `game_manage(get_scene_tree)` confirmed the runtime tree contains the new
  breaker and breaker vent nodes.
- `editor_screenshot(source=game, max_resolution=960)` returned non-empty
  `960x539` PNG metadata and visually showed the active Coil Rat and steam
  vent in the right-side corridor.

## Notes

The MCP tool schema available in this session did not expose `logs_read`.
Runtime log evidence is therefore based on `project_run.recent_errors=[]`, a
fresh MCP log clear before launch, and the headless smoke log scan above.

The direct MCP call into the steam hazard body-entered hook did not reduce HP;
that call path was not accepted as hazard-damage evidence. Steam damage remains
covered by focused and related GdUnit assertions.
