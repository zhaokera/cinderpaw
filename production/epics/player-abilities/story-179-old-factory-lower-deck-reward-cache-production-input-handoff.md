# Story 179: Old Factory Lower Deck Reward Cache Production-Input Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Factory Progression
> **Type**: Integration + Gameplay Runtime + Production Input + Reward
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-20

## Context

Story177 made the Lower Deck skirmish reachable through production movement,
but the defeated encounter's visible reward cache still depended on the direct
`try_claim_factory_lower_deck_reward_cache()` API. The cache gates the existing
Parry-laser route, so players could clear the encounter but could not continue
through normal input.

The Lower Deck cache at `(790, 410)` and Return Patrol cache at `(874, 410)` are
only `84px` apart while both use a `96px` claim radius. A fixed interaction
priority could therefore claim the wrong reward even when Cinderpaw stood on the
Lower Deck cache.

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/level-design.md`,
`design/gdd/game-flow.md`.

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0007 Scene Management;
ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] A rising-edge production `interact` processed by the Factory `_process()`
  claims the available Lower Deck reward without a direct claim API call.
- [x] When multiple late-route reward caches overlap, interaction considers only
  available in-range caches and claims the one nearest to Cinderpaw.
- [x] Standing on the Lower Deck cache claims `10` gears from
  `old_factory_lower_deck_cache` and shows the exact feedback
  `Lower Deck Cache Claimed +10 Gears`.
- [x] The nearby Return Patrol cache remains unclaimed in the overlap case.
- [x] Claim state persists through
  `factory_lower_deck_reward_cache_claimed=true`.
- [x] The existing Lower Deck Parry gate becomes available, visible and
  collision-blocking so its authored unlock interaction can proceed.
- [x] The same input does not request the service-lift exit.
- [x] One intentional RED, focused GREEN, bounded related regression, Factory
  headless smoke and Godot 4.7 + MCP 3.0.2 runtime acceptance provide evidence.

## Out Of Scope

- No changes to reward amount, encounter combat, Parry mechanics, gate art,
  service-lift behavior or scene transitions.
- No new save fields, scene nodes, animations or visual assets.
- No global interaction-system refactor. Arbitration is bounded to existing
  Factory progression caches.

## Implementation Notes

- `handle_factory_interact_input()` keeps the initial cache and deep-route
  endpoint ordering, then delegates late-route reward handling to one nearest
  candidate selection before considering the service lift.
- Candidate filtering requires both `is_claim_available()` and
  `is_provider_in_reward_range()` before measuring global distance.
- The bounded candidate set contains the Lower Deck, Return Patrol and
  checkpoint Overdrive caches. Only the selected cache's existing claim method
  is called, preserving each cache's reward and persistence owner.
- The regression uses real `Input.action_press()` / `action_release()` and the
  production `_process()` rising-edge path.

## Test Evidence

- Intentional RED `reports/report_2051/results.xml`: the new real-input case
  recorded `9` expected failures because fixed priority claimed the nearby
  Return Patrol cache, left the Lower Deck cache unclaimed and kept the Parry
  gate hidden.
- Focused GREEN `reports/report_2052/results.xml`: the Lower Deck suite passed
  `4/4`, with zero failures, errors, flaky cases, skips or orphans.
- Related GREEN `reports/report_2053/results.xml`: four Factory input/route
  suites passed `8/8`, with zero failures, errors, flaky cases, skips or orphans.
- Godot 4.7 Factory headless smoke ran `180` frames and exited `0`. It emitted
  only shutdown cleanup diagnostics for four ObjectDB instances and two retained
  resources; no parse, script, invalid-call or missing-resource error appeared.
- Godot MCP accepted clean runs `r135737-1` and `r435019-2` in session
  `cinderpaw@caa9`. Real `interact` claimed the Lower Deck cache, preserved the
  Return Patrol cache, exposed the Parry gate and left the lift idle. Game logs
  were info-only and editor logs were empty.
- The non-empty `1278x718` screenshot is stored at
  `reports/visual/cinderpaw-mcp-old-factory-lower-deck-reward-input-20260720.png`.
- Full traceability is recorded in
  `production/qa/evidence/old-factory-lower-deck-reward-cache-production-input-handoff-2026-07-20.md`.

## Completion Notes

- Completed 2026-07-20 as a bounded production-input repair using existing
  gameplay, reward, gate and visual contracts.
- The complete-game goal remains active. The next functional slice should add
  shared Sluice Matriarch death/retry pacing; pressure-valve presentation remains
  a separate image-generation Story.
