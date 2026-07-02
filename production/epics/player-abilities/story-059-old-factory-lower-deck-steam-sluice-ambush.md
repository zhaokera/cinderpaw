# Story 059: Old Factory Lower Deck Steam Sluice Ambush

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

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007
Scene management; ADR-0018 Player abilities; ADR-0021 Save system.

Story058 opens the lower-deck pressure valve and leaves the local route feedback
at `Pressure Valve Opened`. This story adds the next player-visible ACT beat:
after the valve opens, a steam sluice awakens near the deeper route, enabling a
steam hazard and a Spark Rat ambush that the player must clear without changing
the optional service-lift route.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckSteamSluiceSparkRat` and
  `FactoryLowerDeckSteamSluiceHazard`, both default hidden/disabled.
- [x] The steam sluice ambush is unavailable until
  `factory_lower_deck_pressure_valve_opened=true` and Cinderpaw crosses the
  steam sluice activation boundary.
- [x] Activating the ambush shows the enemy, assigns Cinderpaw as target,
  starts Spark Rat pacing, enables the steam hazard, updates route feedback to
  `Clear Steam Sluice Ambush`, and keeps `FactoryServiceLift` prompt `Call lift`.
- [x] The ambush enemy uses unique entity id `2113`, and visible animations
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` have at least
  three frames each.
- [x] Defeating entity `2113` hides/disables the enemy, disables the steam
  hazard, updates route feedback to `Steam Sluice Cleared`, and does not replay
  Story054 exit ambush, Story055 shortcut guard, Story056 shortcut payoff cache,
  Story057 shortcut pursuer, or Story058 pressure valve.
- [x] `get_local_state()` / `set_local_state()` persist
  `factory_lower_deck_steam_sluice_activated` and
  `factory_lower_deck_steam_sluice_defeated`.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass under Godot 4.7 with no current project script or
  resource errors.

## Out of Scope

New enemy artwork, new Cinderpaw animation, new enemy behavior family, new
audio, new particles, minimap markers, fast travel UI, SaveSystem schema
changes, global quest/objective manager changes, service-lift route changes,
new reward caches, and new economy rewards.

## Implementation Notes

- Reuse `res://src/gameplay/factory_spark_rat.tscn` and
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- Reuse the existing steam vent hazard script and texture for
  `FactoryLowerDeckSteamSluiceHazard`.
- Keep the slice scene-local. Persist only through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- The steam sluice advances the local route objective only; it does not create
  a new global route, fast-travel destination, SaveSystem migration, or service
  lift requirement.

## Asset Pipeline

No new visual assets are planned for this story. The ambush enemy reuses the
existing Factory Spark Rat frame-animation asset, and the hazard reuses the
existing Old Factory steam vent PNG already imported through Godot. No image
generation is needed unless the story scope later introduces a new visible
landmark or enemy family.

## Test Evidence

- Focused RED/GREEN:
  - `reports/report_1055/` failed as expected before Story059 diagnostics and
    activation APIs existed.
  - `reports/report_1056/` passed focused Story059 tests `2/2` with `0`
    orphans.
- Related regression:
  - `reports/report_1057/` passed lower-deck pressure valve, shortcut pursuer,
    shortcut reward cache, shortcut seal, exit ambush, and service-lift
    SceneManager exit tests `11/11` with `0` orphans.
- MCP runtime:
  - `reports/old_factory_lower_deck_steam_sluice_smoke.log` exited `0`;
    keyword scan found no script, parse, invalid-call/access, missing-resource,
    resource-load, or `ERROR:` entries. The log retains the known Godot
    cleanup-time ObjectDB/resource messages at process exit.
  - Godot MCP session `cinderpaw@4400`, plugin/server `2.8.1`, Godot
    `4.7-stable (official)`, launched
    `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`,
    confirmed hidden-before-activation steam sluice state, activation after
    `factory_lower_deck_pressure_valve_opened=true`, entity `2113`,
    `AnimatedSprite2D + SpriteFrames` at
    `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`,
    `idle/run/attack_tell/attack/hurt/death` frame counts all `3`, active
    steam hazard id `old_factory_lower_deck_steam_sluice`, route feedback
    `Clear Steam Sluice Ambush`, service lift prompt `Call lift`, defeat
    feedback `Steam Sluice Cleared`, persisted
    `factory_lower_deck_steam_sluice_activated=true` and
    `factory_lower_deck_steam_sluice_defeated=true`, clean game/editor logs,
    and non-empty screenshot metadata `960x539`.
  - Full evidence:
    `production/qa/evidence/old-factory-lower-deck-steam-sluice-ambush-2026-07-02.md`.

**Status**: [x] Complete.
