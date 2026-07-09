# QA Evidence: Old Factory Forward Pressure Aftershock Cooling Duct Traverse

Date: 2026-07-09
Engine: Godot 4.7-stable
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story093 extends the route after Story092's aftershock exhaust
exit hatch. The cooling duct becomes visible after the hatch opens, adds a
generated environment prop, reuses the steam vent hazard visual, runs a timed
grace/warning/active/safe damage window, and persists crossed state through the
scene-local Old Factory state.

## Assets

New image generation was used for the duct environment prop:

- Source:
  `assets/generated/source/old_factory_aftershock_cooling_duct_imagegen_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_cooling_duct_imagegen_20260709.json`
- Runtime:
  `res://assets/environment/old_factory_aftershock_cooling_duct/env_old_factory_aftershock_cooling_duct_768.png`

Prompt summary: a long horizontal 2D Old Factory aftershock cooling exhaust
duct frame with rusted bolted steel, black internal slats, hazard striping,
cyan vent lights, small gauges, and a flat green chroma-key background for
local alpha removal.

Story093 also reuses the imported image-generated steam vent:

- `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`

## Automated Evidence

- Initial focused RED: `reports/report_1223/`
  - `2` tests ran.
  - Failures captured missing Story093 diagnostics/API before implementation.
- Import RED: `reports/report_1224/`
  - `2` tests ran.
  - Failure captured the new generated PNG before Godot import metadata existed.
- Focused GREEN: `reports/report_1225/`
  - `2/2` tests passed.
- Minimal related GREEN: `reports/report_1226/`
  - `4/4` Story093 + Story092 hatch tests passed.
- Post-warning-fix related GREEN: `reports/report_1227/`
  - `4/4` Story093 + Story092 hatch tests passed after `StringName` diagnostic
    values were normalized to `String`.
- Final auto-complete GREEN: `reports/report_1228/`
  - `4/4` Story093 + Story092 hatch tests passed after `_process` was wired to
    complete the traverse when the player crosses x `3740.0`.
- Headless smoke:
  `reports/old_factory_aftershock_cooling_duct_traverse_smoke.log` exited `0`.
  - Keyword scan found no project script/parse/invalid-call/access/
    missing-resource/resource-load/shadowed-variable errors.
  - Godot emitted existing shutdown cleanup noise about leaked ObjectDB/resource
    instances after `--quit-after`; no Story093 script or resource paths were
    present in that noise.

## MCP Evidence

Godot MCP session `cinderpaw@1014` reloaded
`res://scenes/factory_route_transition_shell.tscn` from disk and launched the
current scene. Runtime helper status was live.

MCP verified:

- Runtime scene tree contains
  `FactoryLowerDeckForwardPressureAftershockCoolingDuct` and
  `FactoryLowerDeckForwardPressureAftershockCoolingDuctVent`.
- Duct texture path:
  `res://assets/environment/old_factory_aftershock_cooling_duct/env_old_factory_aftershock_cooling_duct_768.png`.
- Hazard id:
  `old_factory_lower_deck_forward_pressure_aftershock_cooling_duct`.
- Hazard damage `8`, cooldown `1.0`, active texture
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
- Route extension diagnostics: ground width `3840.0`, right wall x `3820.0`,
  camera limit right `3840.0`, activation x `3240.0`, exit x `3740.0`.
- Locked diagnostics before hatch open: available `false`, visible `false`,
  active `false`, crossed `false`, contact damage `false`.
- Ready diagnostics after hatch open: available `true`, visible `true`, hazard
  visible `true`, contact damage `false`, route label
  `Aftershock Exhaust Exit Opened`.
- `_process` activation with player beyond x `3240.0` set active state, route
  label became `Cross Aftershock Cooling Duct`, and after `0.68s` the phase was
  `active` with contact damage enabled.
- `_process` completion beyond x `3740.0` persisted crossed state, set phase
  `crossed`, disabled contact damage, and route label became
  `Aftershock Cooling Duct Crossed`.
- Final editor log was empty.
- Final game log contained only the Godot AI helper registration line.
- A non-empty `960x539` game screenshot showed the generated duct and steam
  vent visible in the Old Factory route.

## Verdict

PASS. Story093 meets its focused acceptance criteria, adds generated visual
environment art instead of another placeholder block, and preserves the adjacent
Story092 route chain.
