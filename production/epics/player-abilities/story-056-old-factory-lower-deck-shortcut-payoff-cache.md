# Story 056: Old Factory Lower Deck Shortcut Payoff Cache

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Optional Reward
> **Type**: Integration + Gameplay Runtime + UI/Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-02

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-scene-003`, `TR-scene-005`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system.

Story055 opens the lower-deck shortcut seal after Cinderpaw defeats the
shortcut guard. This story adds the smallest payoff after that open state: a
visible, once-only shortcut cache behind the seal. It closes the micro-loop
“clear guard -> open shortcut -> claim reward” without adding another enemy or
blocking the already available service lift.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckShortcutRewardCache` behind/near the opened shortcut seal.
- [x] The shortcut payoff cache remains hidden/unclaimable until
  `factory_lower_deck_shortcut_unlocked=true`.
- [x] When the shortcut is open, the cache is visible, claimable, uses cache id
  `old_factory_lower_deck_shortcut_cache`, and shows prompt `+15 Gears`.
- [x] While the shortcut payoff cache is available, `FactoryServiceLift`
  remains available with prompt `Call lift`.
- [x] Claiming the cache grants deterministic `15` gears with source
  `old_factory_lower_deck_shortcut_cache`, updates route feedback to
  `Shortcut Cache Claimed +15 Gears`, and rejects duplicate claims.
- [x] `get_local_state()` / `set_local_state()` persist
  `factory_lower_deck_shortcut_reward_cache_claimed` without replaying Story054
  exit ambush or Story055 shortcut guard.
- [x] Focused and related GdUnit regressions, headless smoke, and Godot MCP
  runtime evidence pass under Godot 4.7 with no current project script or
  resource errors.

## Out of Scope

New enemies, new character artwork, new cache artwork, new audio, new
particles, minimap markers, SaveSystem schema changes, global quest/objective
manager changes, service-lift route changes, and fast-travel UI.

## Implementation Notes

- Reuse `FactoryCombatCache` and the existing lower-deck cache texture:
  `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
- The cache is scene-local state only. It follows the existing return patrol,
  overdrive, and lower-deck reward cache patterns.
- The slice is optional content. It may show claim feedback on `RouteLabel`, but
  it does not become a service-lift blocker.

## Asset Pipeline

No new visual assets are planned for this story. The payoff cache reuses the
existing image-generated lower-deck cache texture already imported through
Godot.

## Test Evidence

- Focused RED:
  - `reports/report_1045/` failed as expected before implementation (`2/2`
    failing): shortcut reward cache diagnostics and claim API were missing.
- Focused GREEN:
  - `reports/report_1046/` passed `2/2` with `0` errors, failures, flaky tests,
    skipped tests, or orphans.
- Related regression, headless smoke, and MCP runtime evidence:
  - `reports/report_1047/` passed `10/10` across shortcut payoff cache,
    shortcut seal, lower-deck exit ambush, lower-deck skirmish cache, service
    lift exit, and Factory route roundtrip tests.
  - `reports/old_factory_lower_deck_shortcut_payoff_cache_smoke.log` exited
    `0` with no project script/resource errors by keyword scan.
  - Godot MCP `cinderpaw@4400` on Godot `4.7-stable (official)` confirmed
    cache visibility/claimability after shortcut unlock, `+15 Gears`, duplicate
    claim rejection, persisted state, service lift `Call lift`, clean
    game/editor logs, and non-empty screenshot metadata.
  - QA evidence:
    `production/qa/evidence/old-factory-lower-deck-shortcut-payoff-cache-2026-07-02.md`.

**Status**: [x] Complete.
