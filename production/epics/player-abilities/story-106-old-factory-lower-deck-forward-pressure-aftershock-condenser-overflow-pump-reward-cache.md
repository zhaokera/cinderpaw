# Story 106: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Reward Cache

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Reward + Route Handoff
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0005 Combat
state machine; ADR-0007 Scene management; ADR-0018 Player abilities; ADR-0021
Save system.

Story099 clears the aftershock condenser overflow pump skirmish. Story106 adds
a short reward-and-exit loop after that fight: a visible runoff cache pays the
player once, then unlocks a runoff hatch that removes its collision and hands
the route to the next Old Factory pocket.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRewardCache`
  exists in `factory_route_transition_shell.tscn`, starts hidden, and reuses the
  existing image-generated lower-deck cache texture.
- [x] The reward cache stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_cleared=true`;
  locked diagnostics report unavailable/hidden and claiming returns `false`.
- [x] Once the overflow pump is cleared, the cache becomes visible, exposes
  cache id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache`,
  prompt `+20 Gears`, texture path
  `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`,
  and a finite claim radius.
- [x] Claiming the cache once persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed=true`,
  records a `20` gear reward payload, records feedback
  `Overflow Pump Cache Claimed +20 Gears`, and rejects a second claim.
- [x] Production interaction routes this cache through nearest-distance
  arbitration and a fresh `interact` rising edge. Held pre-clear input and
  no-input movement into reward range do not claim it.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpExitHatch`
  exists in the same scene, starts hidden/blocked, and reuses the existing
  image-generated deep bulkhead hatch texture.
- [x] The runoff hatch becomes visible/available only after the cache is
  claimed, exposes prompt `Open Runoff Hatch`, and opens once through provider
  proximity.
- [x] Production nearest-provider routing requires a fresh `interact` rising
  edge: held approach and no-input displacement cannot open the hatch.
- [x] Opening the hatch persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened=true`,
  disables its blocking collision, keeps the visual visible, rejects a second
  open, and advances route feedback to `Overflow Pump Runoff Hatch Open`.
- [x] The opened visual retracts to `(48,-136)`, rotates `6deg`, hides its
  prompt, renders above the runoff duct and below Cinderpaw, and plays one
  non-repeating unlock burst.
- [x] Restoring completed state preserves the Story095-099 condenser chain,
  prevents reward/hatch replay, keeps the hatch unblocked, and leaves
  `FactoryServiceLift` prompt at `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4, including scene reload, runtime helper,
  production input, stale/no-input rejection, cache/hatch diagnostics,
  current-run logs, and non-empty runtime screenshots.

## Out of Scope

New image generation, new enemy family, new character animation art, new AI
behavior, minimap, fast travel, authored audio, particles/shaders, Boss2,
SaveSystem schema changes, and broader lower-deck art replacement.

## Implementation Notes

- The cache and hatch are intentionally small post-combat affordances rather
  than a new encounter. They sit at the overflow pump pocket and use existing
  `FactoryRewardCache` / route endpoint behavior.
- `set_local_state` restores the new cache and hatch flags and also backfills
  the overflow pump cleared state when a completed reward/hatch state is loaded.
- The route objective keeps Story099 behavior intact: pump clear alone still
  reports `Overflow Pump Cleared`; claiming the cache advances to the runoff
  hatch objective; opening the hatch reports `Overflow Pump Runoff Hatch Open`.
- Story219 adds the cache to the shared production progression-cache router;
  the direct Story106 claim API and once-only payload remain unchanged.

## Asset Pipeline

No new visual asset was generated for Story106.

Reused image-generated/imported runtime assets:

- Cache:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`
- Hatch:
  `assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`

Both assets were already imported through the Godot asset pipeline. Story106
only wires them into the new runtime cache and hatch nodes.

## Test Evidence

- Focused RED: `reports/report_1282/` failed because Story106 APIs,
  diagnostics, and scene nodes did not exist yet.
- Focused GREEN: `reports/report_1284/` passed `2/2`.
- Related GREEN: `reports/report_1285/` passed `15/15` across Story106,
  Story099 overflow pump skirmish, Story095-098 condenser chain,
  factory-route roundtrip, and service-lift handoff suites.
- Headless smoke:
  `reports/old_factory_overflow_pump_reward_cache_smoke.log` exited `0`;
  keyword scan found no project script/parse/invalid-call/access,
  missing-resource, or resource-load errors. Godot emitted only existing
  shutdown resource cleanup noise.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed disk scene reload,
  cache/hatch nodes in edited scene and running scene tree, runtime helper
  live, `current_run_errors=[]`, current game log containing only helper
  registration, cache claim payload/feedback, hatch open state, collision
  removal, local-state persistence, `AnimatedSprite2D` player sprite, and a
  non-empty `960x539` game screenshot showing `Runoff Hatch Open`.
- Story219 production interaction:
  `reports/report_2331/results.xml` recorded the missing-router RED;
  `reports/report_2334/results.xml` passed the final bounded `7/7`. MCP 3.0.4
  run `r158132331-16` proved stale/no-input non-consumption, then fresh
  `interact` claimed one `20`-gear payload and exposed the available,
  collision-blocking, unopened runoff hatch.
- Story220 production hatch input/readability:
  `reports/report_2335/results.xml` recorded the integrated RED and
  `reports/report_2339/results.xml` passed the final bounded `13/13`. Godot
  4.7 / MCP 3.0.4 session `cinderpaw@198e` proved held-approach rejection,
  fresh interaction, once-only unlock VFX, blocker removal and the readable
  retracted hatch state before Story107 activation.

## Dependencies

- Depends on: Story099 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Skirmish
- Unlocks: deeper Old Factory route content after the overflow pump runoff hatch

## Verification Summary

Story106 followed thin TDD: focused RED `reports/report_1282/` failed before
runtime support existed, focused GREEN `reports/report_1284/` passed `2/2`, and
related GREEN `reports/report_1285/` passed `15/15`. Headless smoke exited `0`.
Godot MCP runtime validation passed under Godot 4.7 and Godot AI MCP 2.9.1.

Story219 adds current Godot 4.7 / MCP 3.0.4 proof for the production input path
without changing Story106's reward, persistence or hatch-open contracts.

Story220 completes the production hatch-open path and readable open silhouette;
focused `1/1`, related `13/13`, smoke and MCP runtime/log/visual acceptance pass.
