# Story 055: Old Factory Lower Deck Shortcut Seal Combat Gate

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Optional Combat
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-02

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/combat-presentation.md`

**Requirements**: `TR-ability-005`, `TR-scene-003`, `TR-scene-005`

**ADR Governing Implementation**: ADR-0004 Collision Detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story054 ends the lower-deck parry route with `Lower Deck Exit Cleared`. This
story adds a small player-visible continuation loop: after the exit ambush is
cleared, Cinderpaw can trigger a shortcut seal guard, defeat it, then open the
lower-deck shortcut seal. The slice creates a forward promise without blocking
the already-unlocked service lift.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckShortcutSparkRat` and `FactoryLowerDeckShortcutSeal`.
- [x] The shortcut slice remains unavailable until
  `factory_lower_deck_exit_ambush_defeated=true`.
- [x] Crossing the shortcut activation boundary after Story054 completion
  activates entity `2110`, targets Cinderpaw, enables processing/physics, and
  updates the route objective to `Clear Shortcut Guard`.
- [x] The shortcut guard uses the existing Factory Spark Rat
  `AnimatedSprite2D + SpriteFrames` resource with at least 3 frames for
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`.
- [x] While the optional shortcut guard is active, `FactoryServiceLift` remains
  available with prompt `Call lift`.
- [x] Defeating entity `2110` hides/disables the guard, persists
  `factory_lower_deck_shortcut_guard_defeated`, and changes the objective to
  `Open Lower Deck Shortcut`.
- [x] Opening `FactoryLowerDeckShortcutSeal` persists
  `factory_lower_deck_shortcut_unlocked=true`, disables shortcut collision, and
  changes the objective to `Lower Deck Shortcut Opened`.
- [x] Restoring scene-local state keeps the shortcut open, keeps the guard
  defeated, and does not replay the Story054 exit ambush.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass under Godot 4.7 with no current project script or
  resource errors.

## Out of Scope

New enemy artwork, new shortcut seal art generation, new audio, new particles,
minimap markers, SaveSystem schema changes, global quest/objective manager
changes, and service-lift route changes.

## Implementation Notes

- The shortcut guard reuses
  `res://src/gameplay/factory_spark_rat.tscn` and entity id `2110`.
- The shortcut seal reuses the existing `FactoryDeepRouteEndpoint` component,
  Old Factory endpoint texture, and unlock VFX texture.
- The shortcut activation boundary is right of the checkpoint steam vent zone
  so route-objective text is not immediately overwritten by hazard feedback.
- The shortcut is optional content. It may become the current objective while
  active, cleared, or opened, but it does not become a service-lift blocker.

## Asset Pipeline

No new visual assets were generated for this story. The slice reuses:

- Factory Spark Rat SpriteFrames:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- Shortcut seal visual:
  `res://assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png`.
- Unlock VFX:
  `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`.

## Test Evidence

- Focused RED:
  - `reports/report_1039/` failed because the shortcut diagnostics and
    activation APIs did not exist yet.
- Focused GREEN:
  - `reports/report_1043/` passed Story055 `2/2` with `0` errors, failures,
    flaky tests, skipped tests, or orphans on Godot
    `4.7.stable.official.5b4e0cb0f`.
- Related regression, headless smoke, and MCP runtime evidence:
  - `reports/report_1044/` passed `14/14` across Story055, Story054, Story053,
    checkpoint overdrive duo, overdrive reward cache, service-lift SceneManager
    exit, and Factory route roundtrip.
  - `reports/old_factory_lower_deck_shortcut_seal_smoke.log` exited `0`;
    keyword scan found no project script, parse, invalid-call, invalid-access,
    missing-resource, or resource-load errors in the log file. Godot still
    printed known cleanup-time ObjectDB/resource-at-exit noise to terminal.
  - Godot MCP 4.7 runtime evidence:
    `production/qa/evidence/old-factory-lower-deck-shortcut-seal-combat-gate-2026-07-02.md`.

**Status**: [x] Complete.
