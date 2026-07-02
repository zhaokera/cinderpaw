# QA Evidence: Old Factory Lower Deck Pressure Valve Combat Gate

Date: 2026-07-02
Story: Player Abilities Story 058
Engine: Godot 4.7.stable.official.5b4e0cb0f

## Scope

Validated the Old Factory lower-deck pressure valve combat gate. The slice adds
`FactoryLowerDeckPressureValveSparkRat` and `FactoryLowerDeckPressureValve`,
reusing existing imported Factory Spark Rat frame-animation and Old Factory
endpoint assets.

## Automated Evidence

- Focused RED: `reports/report_1051/` failed before pressure-valve diagnostics
  and activation APIs existed.
- Implementation RED: `reports/report_1052/` failed on a parse error during the
  RED/GREEN loop and drove the local script fix.
- Focused GREEN: `reports/report_1053/` passed `2/2`.
- Related regression: `reports/report_1054/` passed `11/11` across Story058,
  shortcut pursuer, shortcut reward cache, shortcut seal, lower-deck exit
  ambush, and service-lift SceneManager exit coverage.
- Headless smoke:
  `reports/old_factory_lower_deck_pressure_valve_smoke.log` exited `0` under
  Godot 4.7. Keyword scan found no project script, parse, invalid-call/access,
  missing-resource, or resource-load errors. The log retains known Godot
  cleanup-time ObjectDB/resource messages at process exit.

## MCP Runtime Evidence

- Session: `cinderpaw@4400`
- Godot: `4.7-stable (official)`
- MCP plugin/server: `2.8.1`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Runtime scene tree contained `FactoryLowerDeckPressureValveSparkRat` and
  `FactoryLowerDeckPressureValve`.
- Before activation: guard present, hidden, non-processing, non-physics,
  untargeted; pressure valve visible but not available.
- Activation: `try_activate_factory_lower_deck_pressure_guard()` returned true,
  guard visible, target assigned, physics/process enabled, entity id `2112`,
  route label `Clear Pressure Valve Guard`.
- Animation contract: `idle`, `run`, `attack_tell`, `attack`, `hurt`, and
  `death` all reported `3` frames from
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- Defeat: `apply_damage(2112, 999, ...)` returned true, guard hidden/disabled,
  pressure valve prompt changed to `Open valve`, route label `Open Pressure Valve`.
- Open valve: `try_open_factory_lower_deck_pressure_valve()` returned true,
  `factory_lower_deck_pressure_valve_opened=true` persisted in local state, and
  route label changed to `Pressure Valve Opened`.
- Service lift remained optional with prompt `Call lift`.
- MCP game logs contained only helper registration; editor logs were empty.
- MCP screenshot captured non-empty game framebuffer metadata `960x539`, showing
  the pressure-valve-open route state.

## Asset Notes

No new visual assets were generated for this story. It reuses the already
imported image-generated Factory Spark Rat frame animation and Old Factory
endpoint/unlock VFX assets.
