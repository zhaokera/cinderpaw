# Story 109: Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Exit Reward Cache

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Reward + Handoff
> **Type**: Integration + Gameplay Runtime + UI/Visual Feel
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

Story108 clears the overflow pump runoff exit Coil Rat. Story109 turns that
combat clear into a short reward-and-handoff beat: a visible cache appears, pays
once, then reveals a textured runoff exit gate that opens and persists as the
next route marker.

## Acceptance Criteria

- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffExitRewardCache`
  exists in `factory_route_transition_shell.tscn`, starts hidden, and reuses the
  existing imported image-generated lower-deck cache texture.
- [x] `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffExitGate`
  exists in the same scene, starts hidden/non-blocking, and reuses the existing
  imported image-generated deep-bulkhead texture plus unlock spark VFX.
- [x] The cache stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_cleared=true`;
  locked diagnostics report unavailable/hidden and claim/open calls return
  `false`.
- [x] Once Story108 is cleared, the cache becomes visible/claimable, route
  feedback remains `Overflow Pump Runoff Exit Cleared`, and the cache prompt is
  `+20 Gears`.
- [x] Claiming the cache succeeds once, records a `20` gear reward with source
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache`,
  persists the cache flag, and records feedback
  `Runoff Exit Cache Claimed +20 Gears`.
- [x] The cache participates in the production nearest-cache router. Held
  pre-clear input and no-input range placement do not claim it; release/rearm
  plus fresh `Input.interact` claims once.
- [x] Claiming the cache reveals the runoff exit gate with prompt
  `Open Runoff Exit Gate`; opening the gate succeeds once, disables blocking
  collision, and advances route feedback to
  `Overflow Pump Runoff Exit Gate Open`.
- [x] The gate participates in the production nearest progression interaction
  route. Held input from outside range stays stale; a later fresh in-range
  `interact` opens it once, hides the prompt and emits one unlock burst.
- [x] Production opening lifts the visual to `(48,-136)`, rotates it `6deg`
  and renders it at effective z `23`, above the outlet duct and below
  Cinderpaw, while the interaction/collision root remains fixed.
- [x] Restoring gate-opened state backfills Story106/107/108 runoff chain state,
  prevents reward/duct/skirmish replay, keeps runoff duct contact disabled, and
  keeps the gate collision open.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 3.0.4, including scene reload, runtime helper,
  cache/gate node visibility, texture binding, current-run logs, and non-empty
  runtime screenshot.

## Out of Scope

New visual asset generation, new enemies, new hazards, new savepoint, minimap,
fast travel, authored audio, particles/shaders, Boss2, SaveSystem schema
changes, and broader lower-deck art replacement.

## Implementation Notes

- The slice intentionally mirrors Story106 reward-cache + hatch semantics, but
  keeps the scope to the Story108 runoff-exit pocket.
- `set_local_state` restores the Story109 cache/gate flags and backfills the
  Story106/107/108 overflow pump chain when a cache-claimed or gate-opened state
  is loaded.
- Route objective priority places Story109 gate states before Story108 cleared
  so the label does not remain stuck on `Overflow Pump Runoff Exit Cleared`.

## Asset Pipeline

No new visual asset was generated for Story109.

Reused image-generated/imported runtime assets:

- Cache:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`
- Gate:
  `assets/environment/old_factory_lower_deck_deep_bulkhead/env_old_factory_lower_deck_deep_bulkhead_closed_256.png`
- Unlock VFX:
  `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`

All reused assets were already imported through the Godot asset pipeline.

## Test Evidence

- Focused RED: `reports/report_1293/` failed because Story109 diagnostics and
  claim/open APIs did not exist yet.
- Focused GREEN: `reports/report_1294/` passed `2/2`.
- Related GREEN: `reports/report_1295/` passed `8/8` across Story109, Story108
  runoff exit skirmish, Story107 runoff duct, and Story106 overflow pump reward
  cache suites.
- Pre-push focused rerun: `reports/report_1296/` passed `2/2`.
- Headless smoke:
  `reports/old_factory_overflow_pump_runoff_exit_reward_cache_smoke.log` exited
  `0`; keyword scan found no Story109 script, parse, invalid-call/access,
  missing-resource, or resource-load errors. Godot emitted only known shutdown
  ObjectDB/resource cleanup noise.
- Godot MCP:
  Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed disk scene reload,
  edited scene target nodes, cache/gate texture paths, runtime helper live,
  `current_run_errors=[]`, runtime tree containing both target nodes with
  correct scripts/IDs/prompts/radii, current game log containing only helper
  registration, editor log since current-run cursor empty, and a non-empty
  `960x539` game screenshot.
- Story221 production closure: canonical RED/GREEN
  `reports/report_2341/results.xml` / `reports/report_2342/results.xml` and
  bounded related `reports/report_2343/results.xml` (`7/7`) passed. MCP 3.0.4
  run `r163369359-6` proved stale/no-input non-consumption, fresh production
  `interact`, the exact `20`-gear payload/feedback, and a visible, blocking,
  unopened gate in a non-empty `1278x718` runtime capture.
- Story222 production gate closure: final focused
  `reports/report_2349/results.xml` passed `1/1`; bounded related
  `reports/report_2350/results.xml` passed `11/11`; the `180`-frame Factory
  smoke exited `0`. MCP 3.0.4 accepted run `r165369444-9` proved stale/fresh
  interaction, one open VFX, disabled collision/hidden prompt and the lifted
  `(48,-136)` / `6deg` / effective-z-`23` runtime silhouette.

## Dependencies

- Depends on: Story108 Old Factory Lower Deck Forward Pressure Aftershock
  Condenser Overflow Pump Runoff Exit Skirmish
- Unlocks: deeper Old Factory route content after the runoff-exit gate handoff

## Verification Summary

Story109 followed thin TDD: focused RED `reports/report_1293/` failed before
runtime support existed, focused GREEN `reports/report_1294/` passed `2/2`,
related GREEN `reports/report_1295/` passed `8/8`, and pre-push focused rerun
`reports/report_1296/` passed `2/2`. Headless smoke exited `0`. Godot MCP
runtime validation passed under Godot 4.7 and historical Godot AI MCP 2.9.1.
Story221 adds current MCP 3.0.4 production-input and visual evidence while
Story222 completes the gate's current MCP 3.0.4 production interaction and
shape-readable opening evidence.
