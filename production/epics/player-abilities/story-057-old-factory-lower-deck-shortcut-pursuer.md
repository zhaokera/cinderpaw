# Story 057: Old Factory Lower Deck Shortcut Pursuer

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
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system.

Story056 closes the shortcut payoff loop with a once-only `+15 Gears` cache.
This story adds one small player-visible ACT pressure beat after that reward:
claiming the shortcut payoff makes a reused animated Factory Spark Rat pursuer
available as optional combat pressure. It keeps the service lift optional and
does not add a new route blocker.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckShortcutPursuerSparkRat`, reusing the existing Factory Spark
  Rat `AnimatedSprite2D + SpriteFrames` resource.
- [x] The shortcut pursuer remains hidden, non-processing, non-physics, and
  untargeted until `factory_lower_deck_shortcut_reward_cache_claimed=true` and
  Cinderpaw crosses the pursuer activation boundary.
- [x] Activating the pursuer shows the enemy, assigns Cinderpaw as target,
  starts Spark Rat pacing, updates route feedback to `Clear Shortcut Pursuer`,
  and preserves `FactoryServiceLift` prompt `Call lift`.
- [x] The pursuer uses unique entity id `2111`, and its visible animations
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` have at least
  three frames each.
- [x] Defeating entity `2111` hides/disables the pursuer, updates route feedback
  to `Shortcut Pursuer Cleared`, and does not replay Story054 exit ambush,
  Story055 shortcut guard, or Story056 shortcut payoff cache.
- [x] `get_local_state()` / `set_local_state()` persist
  `factory_lower_deck_shortcut_pursuer_activated` and
  `factory_lower_deck_shortcut_pursuer_defeated`.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass under Godot 4.7 with no current project script or
  resource errors.

## Out of Scope

New enemy artwork, new character states, new audio, new particles, new reward
cache, minimap markers, SaveSystem schema changes, service-lift route changes,
global quest/objective manager changes, and fast-travel UI.

## Implementation Notes

- Reuse `res://src/gameplay/factory_spark_rat.tscn` and
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- This is optional combat pressure. It must not block the service lift or undo
  the shortcut/cache states from Stories054-056.
- Keep the slice scene-local. Persist only through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.

## Asset Pipeline

No new visual assets are planned for this story. The pursuer reuses the existing
Factory Spark Rat frame-animation asset already imported through Godot.

## Test Evidence

- Focused RED:
  - `reports/report_1048/` failed as expected before the public pursuer
    diagnostics and activation APIs existed.
- Focused GREEN:
  - `reports/report_1049/` passed Story057 focused tests `2/2`.
- Related regression, headless smoke, and MCP runtime evidence:
  - `reports/report_1050/` passed related Old Factory route regressions
    `12/12`.
  - `reports/old_factory_lower_deck_shortcut_pursuer_smoke.log` exited `0`;
    keyword scan found no project script, parse, invalid-call/access, missing
    resource, or fatal errors.
  - Godot MCP session `cinderpaw@4400`, Godot `4.7-stable (official)`,
    launched `res://scenes/factory_route_transition_shell.tscn`, confirmed the
    runtime `FactoryLowerDeckShortcutPursuerSparkRat`, activation from hidden
    to visible/targeted/physics-enabled, `idle/run/attack_tell/attack/hurt/death`
    frame counts all `3`, service lift prompt `Call lift`, defeat state
    `Shortcut Pursuer Cleared`, clean game/editor logs, and non-empty screenshot
    metadata `960x539`.
  - Full evidence:
    `production/qa/evidence/old-factory-lower-deck-shortcut-pursuer-2026-07-02.md`.

**Status**: [x] Complete.
