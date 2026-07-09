# QA Evidence: Old Factory Forward Pressure Aftershock Condenser Valve Ambush

Date: 2026-07-09
Engine: Godot 4.7-stable
MCP: Godot AI 2.9.1

## Scope

Player Abilities Story094 extends the route after Story093's aftershock cooling
duct. The condenser valve landing becomes visible after the duct is crossed,
uses a newly generated transparent environment prop, activates a Spark Rat plus
Coil Rat ambush, and persists the secured landing through scene-local Old
Factory state.

## Assets

New image generation was used for the condenser valve landing prop:

- Source:
  `assets/generated/source/old_factory_aftershock_condenser_valve_imagegen_20260709.png`
- Metadata:
  `assets/generated/source/old_factory_aftershock_condenser_valve_imagegen_20260709.json`
- Runtime:
  `res://assets/environment/old_factory_aftershock_condenser_valve/env_old_factory_aftershock_condenser_valve_768.png`

Prompt summary: transparent 2D side-scrolling Old Factory aftershock condenser
valve/fan landing anchor with cracked pressure pipes, dented brass valve wheel,
riveted steel duct housing, soot, amber warning lights, blue-grey metal, and a
flat green chroma-key background for local alpha removal.

Story094 reuses generated frame-animation resources:

- Spark Rat:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Coil Rat:
  `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`

## Automated Evidence

- Initial focused RED: `reports/report_1229/`
  - Failure captured missing Story094 diagnostics/API before implementation.
- Focused GREEN: `reports/report_1230/`
  - `2/2` tests passed.
- Minimal related GREEN: `reports/report_1231/`
  - `6/6` Story094 + Story093 + Story092 tests passed.
- Headless smoke:
  `reports/old_factory_aftershock_condenser_valve_ambush_smoke.log` exited
  `0`.
  - Keyword scan found no project script/parse/invalid-call/access/
    missing-resource/resource-load errors.
  - Godot emitted existing shutdown cleanup noise about leaked
    ObjectDB/resource instances after `--quit-after`; no Story094 script or
    resource paths were present in that noise.

## MCP Evidence

Godot MCP session `cinderpaw@1014` reloaded
`res://scenes/factory_route_transition_shell.tscn` from disk and launched the
current scene. Runtime helper status was live.

MCP verified:

- Editor scene tree contains
  `FactoryLowerDeckForwardPressureAftershockCondenserValve`,
  `FactoryLowerDeckForwardPressureAftershockCondenserLandingSparkRat`, and
  `FactoryLowerDeckForwardPressureAftershockCondenserLandingCoilRat`.
- Runtime activation diagnostics:
  `activated=true`, `active=true`, both enemies visible, both enemies have
  attack targets, and route label `Secure Aftershock Condenser Landing`.
- Runtime clear/restore diagnostics:
  `spark_defeat=true`, `coil_defeat=true`, `cleared=true`,
  `active_after_clear=false`, route label
  `Aftershock Condenser Landing Secured`, restored cleared state `true`,
  cooling duct crossed `true`, cooling duct active `false`, and cooling-duct
  hazard contact `false`.
- Final editor log was empty.
- Final game log contained only Godot AI helper registration plus the two
  Story094 MCP probe lines.
- A non-empty `960x539` game screenshot showed the generated condenser valve
  landing prop with Cinderpaw and the active Spark/Coil Rat enemies.

## Verdict

PASS. Story094 meets its focused acceptance criteria, adds generated visual
environment art, reuses frame-animated enemies instead of static placeholders,
and preserves the adjacent Story092/Story093 route chain.
