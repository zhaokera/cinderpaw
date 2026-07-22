# Story 226: Old Factory Service Sluice Reward Cache Production Input Exit Hatch Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Reward Handoff
> **Type**: Integration + Production Input + Reward + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

Story225 stops with Story114 cleared, Story115 visible and claimable, and
Story116 still hidden. Story226 closes the next player-visible step: the
Factory production interaction router accepts one fresh `interact` edge,
claims the service-sluice cache, and reveals the closed exit hatch without
allowing the same or held input to open it.

**GDD**: `design/gdd/input.md`, `design/gdd/scene-management.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-input-001`, `TR-scene-004`, `TR-explore-005`

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0007 Scene Management.

## Acceptance Criteria

- [x] Story225's terminal state exposes Story115 at `Vector2(11360, 410)` as
  visible, available and claimable while Story116 remains hidden and locked.
- [x] An `interact` held before Story115 becomes available remains stale, and
  no-input placement inside its `96px` reward radius does not claim it.
- [x] After one release/rearm frame, a fresh production `Input.interact` edge
  claims Story115 through Factory `_process()` rather than a direct claim API.
- [x] The once-only payload records the exact cache id/source, `20` gears and
  `Service Sluice Cache Claimed +20 Gears` feedback and route label.
- [x] Story116 becomes present, visible, available, monitoring, monitorable and
  collision-blocking at `Vector2(11680, 392)` with `Open Service Exit`.
- [x] The claim edge and four later held frames in Hatch range leave Story116
  unopened with zero unlock-VFX spawns; Story117 remains unavailable, inactive
  and hidden.
- [x] Local state persists Story115 claimed and Story116 unopened.
- [x] Focused/related GdUnit, a marker-backed `180`-frame Factory smoke, and
  Godot 4.7 / Godot AI MCP 3.0.4 runtime/log/framebuffer acceptance pass.

## Out of Scope

Opening Story116, Story116 open-state motion/readability, activating Story117,
global wallet/economy integration, SaveSystem schema changes, combat changes,
new art/audio/VFX, image generation and full-suite testing.

## Implementation Notes

- Story115's existing cache and claim API now participate in
  `_try_claim_nearest_factory_progression_reward_cache()`.
- Factory's existing `_interact_input_was_pressed` rising-edge latch remains
  the sole stale/held/fresh authority.
- Story116 is intentionally not added to the progression-prop input router;
  its fresh opening input and visible retraction belong to the next slice.
- The reward contract is the existing scene-local payload/feedback ledger, not
  a new global currency mutation.

## Asset Use

No image generation was required. Existing imported Factory cache, service
exit hatch, unlock VFX, Cinderpaw and environment assets cover the slice. No
character or animation resource changed.

## Verification Evidence

- Canonical RED `reports/report_2364/results.xml` ran `1` test with zero errors
  and exactly one expected failure: fresh production input could not claim
  Story115 because the cache was absent from the shared router.
- Initial GREEN `reports/report_2365/results.xml` passed `1/1`; six-suite
  related `reports/report_2366/results.xml` passed `9/9`; strengthened final
  focused `reports/report_2367/results.xml` passed `1/1`.
- `reports/old_factory_service_sluice_reward_cache_production_input_exit_hatch_handoff_smoke.log`
  exited `0` with `story226_smoke=passed frames=180`.
- Godot MCP 3.0.4 session `cinderpaw@198e`, accepted run
  `r179796549-23`, drove real `interact`, exact reward and held-input Hatch
  protection. The game log was helper-only, editor delta after cursor `2` was
  empty, inputs were released, playback stopped ready, and non-empty RGB
  `1278x718` framebuffers showed both the claimable cache and the closed Hatch
  handoff.

## Dependencies

- Depends on: Story225 production combat/reward-cache handoff and Stories115-116
  baseline content.
- Unlocks: Story116 production exit-hatch input/readability and Story117
  tailrace handoff.

## Verification Summary

One thin RED isolated the missing router entry. One production candidate fixed
the playable input path while preserving stale/held protection, exact reward
data and the unopened Story116 boundary. Focused, related, smoke and MCP
runtime/log/visual evidence passed without new assets or a full suite.
