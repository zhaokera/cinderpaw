# Story 058: Old Factory Lower Deck Pressure Valve Combat Gate

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Combat Gate
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-02

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system.

Story057 clears the shortcut pursuer after the lower-deck shortcut reward. This
story adds the next player-visible Old Factory route beat: a pressure valve
guarded by an animated Factory Spark Rat. The player must clear the guard and
open the valve to mark the deeper lower-deck route as opened. The service lift
remains optional and available once the route is otherwise clear.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckPressureValveSparkRat` and `FactoryLowerDeckPressureValve`.
- [x] The pressure valve guard remains hidden, non-processing, non-physics, and
  unavailable until `factory_lower_deck_shortcut_pursuer_defeated=true` and
  Cinderpaw crosses the pressure valve activation boundary.
- [x] Activating the pressure valve guard shows the enemy, assigns Cinderpaw as
  target, starts Spark Rat pacing, updates route feedback to
  `Clear Pressure Valve Guard`, and keeps `FactoryServiceLift` prompt
  `Call lift`.
- [x] The guard uses unique entity id `2112`, and its visible animations
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` have at least
  three frames each.
- [x] Defeating entity `2112` hides/disables the guard, updates route feedback
  to `Open Pressure Valve`, and makes `FactoryLowerDeckPressureValve`
  activatable with prompt `Open valve`.
- [x] Opening the pressure valve persists
  `factory_lower_deck_pressure_valve_opened=true`, updates route feedback to
  `Pressure Valve Opened`, and does not replay Story054 exit ambush, Story055
  shortcut guard, Story056 shortcut payoff cache, or Story057 shortcut pursuer.
- [x] `get_local_state()` / `set_local_state()` persist
  `factory_lower_deck_pressure_guard_activated`,
  `factory_lower_deck_pressure_guard_defeated`, and
  `factory_lower_deck_pressure_valve_opened`.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass under Godot 4.7 with no current project script or
  resource errors.

## Out of Scope

New enemy artwork, new Cinderpaw animation, new enemy behavior family, new
audio, new particles, minimap markers, fast travel UI, SaveSystem schema
changes, global quest/objective manager changes, and service-lift route changes.

## Implementation Notes

- Reuse `res://src/gameplay/factory_spark_rat.tscn` and
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- Reuse the existing Factory endpoint switch script and visual treatment for
  `FactoryLowerDeckPressureValve`.
- Keep the slice scene-local. Persist only through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- The pressure valve advances the local route objective only; it does not create
  a new global route, fast-travel destination, or SaveSystem migration.

## Asset Pipeline

No new visual assets are planned for this story. The guard reuses the existing
Factory Spark Rat frame-animation asset; the valve reuses the existing Old
Factory endpoint texture and unlock VFX already imported through Godot.

## Test Evidence

- Focused RED:
  - `reports/report_1051/` failed as expected before pressure-valve diagnostics
    and activation APIs existed.
  - `reports/report_1052/` failed on an implementation parse error during the
    RED/GREEN loop and drove the local fix.
- Focused GREEN:
  - `reports/report_1053/` passed Story058 focused tests `2/2`.
- Related regression, headless smoke, and MCP runtime evidence:
  - `reports/report_1054/` passed related Old Factory lower-deck and service
    lift regressions `11/11`.
  - `reports/old_factory_lower_deck_pressure_valve_smoke.log` exited `0`;
    keyword scan found no project script, parse, invalid-call/access, missing
    resource, or resource-load errors. The log retains the known Godot
    cleanup-time ObjectDB/resource messages at process exit.
  - Godot MCP session `cinderpaw@4400`, plugin/server `2.8.1`, Godot
    `4.7-stable (official)`, launched
    `res://scenes/factory_route_transition_shell.tscn`, confirmed runtime
    `FactoryLowerDeckPressureValveSparkRat` and `FactoryLowerDeckPressureValve`,
    hidden-before-activation guard state, active visible/targeted/physics-enabled
    guard state, entity `2112`, `idle/run/attack_tell/attack/hurt/death` frame
    counts all `3`, `Open Pressure Valve` after defeat, persisted
    `factory_lower_deck_pressure_valve_opened=true`, service lift prompt
    `Call lift`, clean game/editor logs, and non-empty screenshot metadata
    `960x539`.
  - Full evidence:
    `production/qa/evidence/old-factory-lower-deck-pressure-valve-combat-gate-2026-07-02.md`.

**Status**: [x] Complete.
