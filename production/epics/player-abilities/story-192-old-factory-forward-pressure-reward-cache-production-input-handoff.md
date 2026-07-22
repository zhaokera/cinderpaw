# Story 192: Old Factory Forward Pressure Reward Cache Production Input Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Input
> **Type**: Integration + Gameplay Runtime + Production Input + Reward
> **Estimate**: XS
> **Manifest Version**: 2026-07-21
> **Last Updated**: 2026-07-21

## Context

Story071 authored the forward-pressure reward cache and Story072 added its
once-only spatial audio. The cache could still be claimed only through its
direct API because the Factory production interaction arbitration did not
include it. Story192 connects that existing reward contract to the real
`interact` rising edge after Story191 clears the counter-ambush.

**GDD**: `design/gdd/input.md`, `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/audio-system.md`,
`design/gdd/scene-management.md`

**Governing ADRs**: ADR-0002 Event Bus; ADR-0004 Collision Detection;
ADR-0007 Scene Management.

## Acceptance Criteria

- [x] From a valid Story191-complete state, a real `interact` rising edge inside
  the Story071 cache radius reaches it through production nearest-reward
  arbitration; tests do not call the claim API directly.
- [x] The first edge claims exactly once with cache/source
  `old_factory_lower_deck_forward_pressure_reward_cache`, payload `gears=20`
  and feedback `Forward Pressure Cache Claimed +20 Gears`.
- [x] The fresh claim requests exactly one `reward_cache_claimed ->
  sfx_door_unlock` event at `(1340,310)`, priority `90`; held input and restored
  state do not replay it.
- [x] Claiming while Cinderpaw is already at Story073's inclusive `x=1352`
  boundary only makes the exit guard available. The guard remains inactive,
  hidden and non-hazardous during the Story192 frame.
- [x] Keeping the same press held for at least three frames, including after
  moving into the real service-lift radius, does not claim again, activate the
  lift or request a scene change. Releasing and pressing again re-arms normal
  interaction and may call the lift once.
- [x] Scene-local state roundtrips the claimed cache into a fresh Factory
  instance without replaying reward/audio or activating Story073/lift.
- [x] Focused/related GdUnit, a 180-frame Factory smoke and Godot MCP 3.0.4
  real-input acceptance pass under Godot 4.7 with a non-empty screenshot and
  clean runtime/editor logs.

## Out Of Scope

Story073 production movement activation, synthetic invalid progression states
with multiple sequential caches simultaneously claimable, global wallet or
economy integration, reward-value tuning, SaveSystem schema changes, scene
geometry changes and new visual/audio assets.

## Implementation Notes

- `_try_claim_nearest_factory_progression_reward_cache()` now includes the
  existing Story071 cache and claim method. Existing distance selection and
  stable candidate-order tie breaking remain unchanged.
- The existing `_process()` rising-edge latch remains the only production input
  gate. No parallel interaction or reward system was added.
- The adjacent service-lift regression exposed a pre-existing diagnostics bug:
  it read a nonexistent root `RouteLabel`. Diagnostics now read the actual
  `RouteHud/RouteLabel` written by `_update_route_label()`.
- Factory reward contracts still expose a `gears=20` payload; this story does
  not claim that `_currency_amount` or a global wallet is incremented.

## Asset Use

No image-generation request was needed. The slice reuses the imported,
image-generated Story071 cache at
`assets/environment/old_factory_lower_deck_skirmish_cache/`, Cinderpaw's
`AnimatedSprite2D`, the existing forward hatch, service lift and Factory
environment. Their source and import records already exist in the asset
manifest; no placeholder or single-frame character was added.

## Verification Evidence

- Canonical RED `reports/report_2140/results.xml` failed its single test at the
  intended production claim assertion before the cache candidate was added.
- Initial focused GREEN `reports/report_2141/results.xml` passed `1/1`.
- Related run `reports/report_2142/results.xml` passed the Story192 chain and
  exposed only the pre-existing service-lift diagnostic path bug. Isolated RED
  `report_2143` reproduced it; `report_2144` passed `2/2` after the path fix.
- Final related GREEN `reports/report_2145/results.xml` passed seven suites at
  `13/13`. Strengthened final focused GREEN `reports/report_2146/results.xml`
  passed the `x=1352`, restore and held-at-lift contract at `1/1`.
- Godot 4.7 loaded the Factory scene for `180` fixed frames and exited `0`;
  `reports/old_factory_forward_pressure_reward_cache_production_input_handoff_smoke.log`
  records startup plus the established cleanup-only ObjectDB/resource baseline.
- Godot AI MCP 3.0.4 accepted run `r97358912-8`. Real `interact` claimed the
  cache once at `x=1352`; diagnostics reported exact reward/audio, Story073
  available but inactive, and lift idle. Holding while moving to the lift kept
  claim count `1` and made no exit request. Game log was helper-only, editor log
  was empty, and stop restored `ready`.
- Accepted non-empty RGB `1278x718` screenshot:
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-reward-cache-production-input-handoff-20260721.png`.
- Full evidence:
  `production/qa/evidence/old-factory-forward-pressure-reward-cache-production-input-handoff-2026-07-21.md`.

**Status**: [x] Complete.
