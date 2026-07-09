# Story 092: Old Factory Lower Deck Forward Pressure Aftershock Exhaust Exit Hatch Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-09

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story091 secures the aftershock exhaust escape skirmish near the far right of
the Old Factory lower deck. Story092 converts that combat payoff into a visible
route handoff: after the escape skirmish is cleared, a player-facing exhaust
exit hatch appears near the route boundary, can be opened once, plays existing
image-generated unlock feedback, disables its blocker, and persists the opened
route state without replaying earlier combat, cache, lift, or savepoint events.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockExhaustExitHatch` exists in
  `factory_route_transition_shell.tscn`, starts hidden/inactive, uses
  `FactoryDeepRouteEndpoint`, and reuses the imported deep bulkhead hatch
  texture plus the existing image-generated unlock spark VFX.
- [x] The hatch is unavailable until
  `factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared=true`;
  locked manual activation returns `false`, keeps the hatch hidden, and keeps
  collision blocking disabled.
- [x] Once Story091 is cleared, the hatch becomes visible near x `3160.0`,
  exposes prompt `Open Exhaust Hatch`, enables interaction/collision blocking,
  and updates route feedback to `Open Aftershock Exhaust Hatch`.
- [x] Opening the hatch succeeds once for an in-range provider, persists
  `factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened=true`,
  disables collision blocking, plays one unlock-feedback burst, updates prompt
  `Exhaust Hatch Open`, and sets route feedback to
  `Aftershock Exhaust Exit Opened`.
- [x] Duplicate activation returns `false` and does not replay unlock feedback.
- [x] Restoring opened state keeps Story091/Story090/Story089 complete, keeps
  the Story074 exit relay savepoint contract stable, does not replay Story068
  clear burst or Story071 reward-cache audio, and preserves `FactoryServiceLift`
  prompt `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene load, hatch node,
  diagnostics, interaction state, clean logs, and a non-empty screenshot showing
  the opened hatch.

## Out of Scope

New generated character art, new enemy family, new combat behavior, new reward
cache, new savepoint, SaveSystem schema changes, service-lift route changes,
minimap/fast travel UI, authored audio, shaders, Boss2, and broader lower-deck
biome replacement.

## Implementation Notes

- Use endpoint id
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch`.
- Keep Story092 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Reuse `FactoryDeepRouteEndpoint` for prompt text, activation radius,
  one-shot activation, and unlock VFX diagnostics.
- Keep the Story074 relay as the active non-boss respawn anchor; Story092 does
  not write a new savepoint contract.

## Asset Pipeline

No new visual assets are planned for this Story. It reuses imported,
image-generated assets already in the Godot pipeline:

- Hatch visual:
  `assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
- Unlock VFX:
  `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`

Reuse is recorded in this story and will be reflected in QA evidence after MCP
validation.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_test.gd`
  - Initial RED: `reports/report_1218/` (`2` tests, missing Story092 API)
  - Focused GREEN: `reports/report_1219/` (`2/2`)
- Related regression:
  - Initial related RED: `reports/report_1220/` (`17` tests, `3` Story091
    expectation failures after the route chain advanced to Story092)
  - Final related GREEN: `reports/report_1221/` (`17/17`)
- Runtime evidence:
  Headless factory smoke
  `reports/old_factory_forward_pressure_aftershock_exhaust_exit_hatch_smoke.log`
  exited `0`; keyword scan found no project script/parse/invalid-call/access/
  missing-resource/resource-load/shadowed-variable errors.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed scene reload from disk,
  runtime helper live, `FactoryLowerDeckForwardPressureAftershockExhaustExitHatch`
  present at x `3160.0`, endpoint id and prompt configuration, locked
  diagnostics, Story091-cleared ready diagnostics, one successful open,
  duplicate activation `false`, persisted/restored opened state, unlock VFX
  spawn count `1`, clean final game/editor logs, and a non-empty `960x539` game
  screenshot showing the opened hatch.

## Dependencies

- Depends on: Story091 Old Factory Lower Deck Forward Pressure Aftershock Exhaust Escape Skirmish
- Unlocks: deeper Old Factory route content after the aftershock exhaust exit

## Verification Summary

Initial RED `reports/report_1218/` failed before Story092 API and diagnostics
existed. Focused GREEN `reports/report_1219/` passed `2/2`. The first related
run `reports/report_1220/` exposed outdated Story091 route-label expectations;
the Story091 test now expects the clear state to unlock Story092's hatch instead
of ending the route chain. Final related GREEN `reports/report_1221/` passed
`17/17`. Headless smoke and Godot MCP runtime evidence passed under Godot 4.7 /
Godot AI MCP 2.9.1.
