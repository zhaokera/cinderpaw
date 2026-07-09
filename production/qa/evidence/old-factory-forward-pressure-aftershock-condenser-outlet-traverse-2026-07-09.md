# QA Evidence: Old Factory Forward Pressure Aftershock Condenser Outlet Traverse

Date: 2026-07-09
Engine: Godot 4.7-stable
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story096 extends the route beyond the Story095 condenser
savepoint into a generated aftershock condenser outlet traverse. The outlet is
hidden until the savepoint is activated, then exposes a short playable duct
bridge and a timed steam hazard window before persisting the crossed state.

## Assets

New image generation was used for the aftershock condenser outlet:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_imagegen_20260709.png`
- Alpha source:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_alpha_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_outlet_imagegen_20260709.json`
- Runtime:
  `res://assets/environment/old_factory_aftershock_condenser_outlet/env_old_factory_aftershock_condenser_outlet_768.png`

Prompt summary: long horizontal Old Factory aftershock condenser outlet duct
bridge for a cat action game, with riveted blue-grey steel, cracked pressure
pipes, bolted plates, rust-orange hazard strips, cyan condenser lamps, analog
gauges, and a side-view walkway lip on a flat green chroma-key background for
local alpha removal.

The active hazard reuses the existing imported image-generated steam vent prop
at `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.

## Automated Evidence

- Initial focused RED: `reports/report_1235/`
  - Failure captured missing Story096 asset/API/diagnostics before
    implementation.
- Focused GREEN: `reports/report_1237/`
  - `2/2` tests passed.
- Related GREEN: `reports/report_1238/`
  - `16/16` Story096 + adjacent aftershock chain + respawn tests passed.
- Final focused GREEN after MCP parse-log hardening: `reports/report_1239/`
  - `2/2` tests passed.
- Headless smoke:
  `reports/old_factory_aftershock_condenser_outlet_traverse_smoke.log` exited
  `0`.
  - Keyword scan found no project script/parse/invalid-call/access/
    missing-resource/resource-load errors.
  - Godot emitted existing shutdown cleanup noise about leaked
    ObjectDB/resource instances after `--quit-after`; no Story096 script or
    resource paths were present in that noise.

## MCP Evidence

Godot MCP session `cinderpaw@1014` reloaded
`res://scenes/factory_route_transition_shell.tscn` from disk and launched the
current scene. Runtime helper status was live.

MCP verified:

- Editor and runtime scene trees contain
  `FactoryLowerDeckForwardPressureAftershockCondenserOutlet` and
  `FactoryLowerDeckForwardPressureAftershockCondenserOutletVent`.
- Editor properties match the outlet contract: generated texture
  `res://assets/environment/old_factory_aftershock_condenser_outlet/env_old_factory_aftershock_condenser_outlet_768.png`,
  position x `4740.0`, route width `5120.0`, right wall x `5100.0`, camera
  limit right `5120`, vent hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet`,
  damage `8`, and cooldown `1.0`.
- Runtime probe after Story095 savepoint activation reported ready visibility,
  available `true`, activation `true`, active phase `active`, active contact
  `true`, hazard hit `true`, HP `100 -> 92`, completion `true`, crossed
  `true`, objective id `forward_pressure_aftershock_condenser_outlet_crossed`,
  and route label `Aftershock Condenser Outlet Crossed`.
- `project_run.current_run_errors=[]`; retained editor parse rows from an
  earlier pre-fix helper-name reload were marked as predating the run, and
  `logs_read(source="editor", since_cursor=9)` returned no new editor errors
  after the final reimport/relaunch.
- Final game log contained Godot AI helper registration plus the Story096 MCP
  probe line.
- A non-empty `960x539` game screenshot showed the generated outlet duct,
  reused steam vent, and player in the playable route.

## Verdict

PASS. Story096 adds a generated visible outlet traverse, gates it behind the
Story095 condenser savepoint, applies active-phase steam damage, persists the
crossed state, and keeps the aftershock route moving as playable ACT space.
