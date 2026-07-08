# Story 084: Old Factory Lower Deck Forward Pressure Aftershock Reward Cache

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Gameplay Runtime + UI/Visual
> **Estimate**: S
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

Story083 ends the current Coil Rat pressure chain with a compact aftershock
fight. Story084 closes that beat with an immediate player-visible reward cache:
after the Coil Aftershock is cleared, Cinderpaw can claim a once-only `+20
Gears` payoff before the route continues. This reinforces the ACT loop of push,
fight, survive, claim, and keep moving without introducing a new enemy family,
new reward economy, savepoint, service-lift route, or room scene.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureAftershockRewardCache` using the existing
  lower-deck cache script and image-generated lower-deck cache texture.
- [x] The cache is unavailable while
  `factory_lower_deck_forward_pressure_coil_aftershock_cleared=false`; it
  remains hidden, non-claimable, and manual claim returns `false`.
- [x] Once Story083 is cleared, the cache becomes visible and claimable with
  cache id/source
  `old_factory_lower_deck_forward_pressure_aftershock_reward_cache`, prompt
  `+20 Gears`, and the existing lower-deck cache texture path.
- [x] Claiming the cache once grants `20` gears, records
  `Forward Pressure Aftershock Cache Claimed +20 Gears`, persists
  `factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed=true`,
  disables further claims, and updates route feedback to the same claim text.
- [x] Restoring claimed state keeps the cache claimed/non-claimable, keeps
  Story083 cleared, keeps Story082/081 completed, preserves the Story074 exit
  relay savepoint contract, does not replay Story068 clear burst or Story071
  reward-cache audio, and preserves `FactoryServiceLift` prompt `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene load, cache node,
  texture path, claim semantics, clean logs, and a non-empty screenshot showing
  the available or claimed cache.

## Out of Scope

New generated character art, new character animation, new enemy family, new AI
behavior tree, new hazard, new reward economy, new savepoint, SaveSystem schema
changes, service-lift route changes, minimap/fast travel UI, authored audio,
particles/shaders, Boss2, and broader lower-deck layout work.

## Implementation Notes

- Reuse the existing lower-deck cache visual:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
- Keep Story084 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Use cache id/source
  `old_factory_lower_deck_forward_pressure_aftershock_reward_cache`.
- Keep the Story074 relay as the active non-boss respawn anchor; Story084 does
  not write a new savepoint contract.
- Do not lock `FactoryServiceLift`; this is a payoff cache, not a lift gate.

## Asset Pipeline

No new visual assets are required for this Story. It reuses the imported,
image-generated lower-deck reward cache texture:

- Lower-deck cache runtime texture:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`

Reuse must be recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, this story, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_reward_cache_test.gd`
- Related regression:
  Story084 focused + Story083, Story082, Story081, Story080, Story079,
  Story078, Story077, Story076, Story075, Story074, service-lift, and no-loss
  respawn suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, cache
  locked/available/claimed/restored diagnostics, texture path, once-only claim,
  route label, unchanged relay savepoint contract, service lift prompt, clean
  logs, and a non-empty screenshot with the cache visible.

## Dependencies

- Depends on: Story083 Old Factory Lower Deck Forward Pressure Coil Aftershock
- Unlocks: Deeper Old Factory route content after the aftershock payoff

## Verification Summary

- RED focused: `reports/report_1172/` failed before Story084 diagnostics and
  claim APIs existed.
- Live-path RED: `reports/report_1178/` failed after adding coverage for the
  real Story083 Coil Aftershock defeat path; the cache stayed locked because
  the defeat handler did not sync the Story084 cache state.
- Focused GREEN: `reports/report_1179/` passed Story084 `3/3`, including the
  live defeat-to-cache-unlock path.
- Initial related GREEN: `reports/report_1176/` passed Story084, Story083,
  Story071 audio no-replay, service-lift exit, and no-loss respawn suites
  `10/10`.
- Expanded related GREEN: `reports/report_1180/` passed Story084, Story083
  through Story074, Story071 audio no-replay, service-lift exit, and no-loss
  respawn suites `29/29`.
- Headless smoke: `reports/old_factory_forward_pressure_aftershock_reward_cache_smoke.log`
  exited `0` and had no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors by keyword scan.
- Godot MCP 2.9.1 / Godot 4.7 runtime confirmed the live Story083 defeat path:
  aftershock activation `true`, entity `2128` damage `true`, cache visible /
  available / claimable, texture path, `+20 Gears` prompt, first claim `true`,
  duplicate claim `false`, route label
  `Forward Pressure Aftershock Cache Claimed +20 Gears`, Story074 exit-relay
  savepoint, service lift `Call lift`, clean game/editor logs, and a non-empty
  `960x539` game screenshot with the cache visible.
