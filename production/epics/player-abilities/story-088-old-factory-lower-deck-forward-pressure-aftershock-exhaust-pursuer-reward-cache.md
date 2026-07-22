# Story 088: Old Factory Lower Deck Forward Pressure Aftershock Exhaust Pursuer Reward Cache

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Gameplay Runtime + UI/Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-21

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story087 adds a final aftershock exhaust pursuer after the traversal beat.
Story088 gives that combat pressure a small immediate payoff: once the pursuer
is cleared, Cinderpaw can claim a once-only `+20 Gears` cache before the route
continues. The slice closes the push, fight, claim loop without adding a new
enemy family, reward economy rule, savepoint, service-lift route, or room scene.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` contains
  `FactoryLowerDeckForwardPressureAftershockExhaustPursuerRewardCache` using
  the existing lower-deck cache script and image-generated lower-deck cache
  texture.
- [x] The cache is unavailable while
  `factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_cleared=false`;
  it remains hidden, non-claimable, and manual claim returns `false`.
- [x] Once Story087 is cleared, the cache becomes visible and claimable with
  cache id/source
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache`,
  prompt `+20 Gears`, and the existing lower-deck cache texture path.
- [x] Claiming the cache once grants `20` gears, records
  `Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears`, persists
  `factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed=true`,
  disables further claims, and updates route feedback to the same claim text.
- [x] Production `Input.interact` includes this cache in nearest-cache
  arbitration, claims it once in range, and does not chain directly into
  Story089 activation.
- [x] A live Story087 defeat path synchronizes the cache state: activating the
  pursuer, defeating entity `2131`, and waiting one frame makes the cache
  visible, available, claimable, and then claimable exactly once.
- [x] Restoring claimed state keeps the cache claimed/non-claimable, keeps
  Story087 cleared, keeps Story086 crossed, keeps Story085 cleared, keeps
  Story084 claimed, preserves the Story074 exit relay savepoint contract, does
  not replay Story068 clear burst or Story071 reward-cache audio, and preserves
  `FactoryServiceLift` prompt `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4, including scene load, cache node,
  texture path, claim semantics, clean logs, and a non-empty screenshot showing
  the cache.

## Out of Scope

New generated character art, new character animation, new enemy family, new AI
behavior tree, new hazard, new reward economy, new savepoint, SaveSystem schema
changes, service-lift route changes, minimap/fast travel UI, authored audio,
particles/shaders, Boss2, and broader lower-deck layout work.

## Implementation Notes

- Reuse the existing lower-deck cache visual:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
- Keep Story088 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Use cache id/source
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache`.
- Keep the Story074 relay as the active non-boss respawn anchor; Story088 does
  not write a new savepoint contract.
- Do not lock `FactoryServiceLift`; this is a payoff cache, not a lift gate.
- Do not extend the Story071 reward-cache audio policy in this slice.

## Asset Pipeline

No new visual assets are required for this Story. It reuses the imported,
image-generated lower-deck reward cache texture:

- Lower-deck cache runtime texture:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`

Reuse is recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, this story, and QA evidence. The AGENTS
2D frame animation rule is not triggered because Story088 adds an environment
reward prop, not a new player-visible character.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_test.gd`
  - RED: `reports/report_1195/`
  - GREEN: `reports/report_1196/` (`3/3`)
- Related regression:
  Story088 focused + Story087, Story086, Story085, Story084, Story083,
  Story074 exit relay, service-lift, no-loss respawn, Story068 no-replay, and
  Story071 reward-cache audio no-replay suites.
  - GREEN: `reports/report_1197/` (`26/26`)
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, cache
  locked/available/claimed/restored diagnostics, live Story087 defeat-to-cache
  unlock, texture path, once-only claim, route label, unchanged relay savepoint
  contract, service lift prompt, clean logs, and a non-empty screenshot with the
  cache visible.
  - Headless smoke:
    `reports/old_factory_forward_pressure_aftershock_exhaust_pursuer_reward_cache_smoke.log`
  - QA evidence:
    `production/qa/evidence/old-factory-forward-pressure-aftershock-exhaust-pursuer-reward-cache-2026-07-09.md`

## Dependencies

- Depends on: Story087 Old Factory Lower Deck Forward Pressure Aftershock Exhaust Pursuer
- Unlocks: Deeper Old Factory route content after the aftershock exhaust pursuer payoff

## Verification Summary

- RED focused: `reports/report_1195/` failed before Story088 diagnostics and
  claim APIs existed.
- Focused GREEN: `reports/report_1196/` passed Story088 `3/3`, including the
  live pursuer defeat-to-cache-unlock path.
- Related GREEN: `reports/report_1197/` passed Story088, Story087, Story086,
  Story085, Story084, Story083, Story074 exit relay, service-lift, no-loss
  respawn, Story068 no-replay, and Story071 audio no-replay suites `26/26`.
- Headless smoke:
  `reports/old_factory_forward_pressure_aftershock_exhaust_pursuer_reward_cache_smoke.log`
  exited `0` and had no project script, parse, invalid-call, invalid-access,
  missing-resource, resource-load, or shadowed-variable errors by keyword scan.
- Godot MCP 2.9.1 / Godot 4.7 runtime confirmed the live Story087 defeat path:
  pursuer activation `true`, damage to entity `2131` `true`, cache visible /
  available / claimable after the defeat, runtime texture path, `+20 Gears`
  prompt, first claim `true`, duplicate claim `false`, `20` gear payload, route
  label `Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears`, Story074
  exit-relay savepoint, service lift `Call lift`, Story068/071 no-replay
  sentinels, clean game/editor logs, and a non-empty `960x539` game screenshot
  with the cache visible.
- Story207 production closure added this cache to the regular interaction
  router. Canonical/final related `reports/report_2251/results.xml` passed eight
  suites and `14/14`. Godot 4.7 / MCP 3.0.4 accepted run `r135689461-59` used
  real `interact` at `(2664, 410)`, returned exactly `20` gears and the expected
  source/feedback, rejected duplicate input, and left Story089 available but
  inactive. Non-empty `1278x718` death/cache and claimed screenshots are linked
  from
  `production/qa/evidence/old-factory-aftershock-exhaust-pursuer-production-combat-reward-handoff-2026-07-21.md`.
