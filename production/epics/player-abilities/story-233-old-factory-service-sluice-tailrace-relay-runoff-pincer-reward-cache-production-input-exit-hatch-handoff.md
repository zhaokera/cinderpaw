# Story 233: Old Factory Service Sluice Tailrace Relay Runoff Pincer Reward Cache Production Input Exit Hatch Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Reward / Route Handoff
> **Type**: Integration + Production Input + Reward + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/input.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-input-001`, `TR-scene-004`, `TR-explore-005`

**ADR Governing Implementation**: ADR-0004 collision detection; ADR-0007
scene management.

Story232 leaves Story122 visible, available and unclaimed after the Tailrace
Runoff Pincer. Story233 routes one fresh production `interact` edge into that
cache, grants its exact reward once and exposes Story123 as a closed route
handoff without allowing the same held edge to open it.

## Acceptance Criteria

- [x] `interact` held before Story122 becomes available remains stale; releasing
  and placing Cinderpaw in range without input also leaves the cache unclaimed.
- [x] A fresh `Input.interact` edge travels through Factory `_process()`,
  `handle_factory_interact_input()` and the nearest-cache router to claim
  Story122 exactly once.
- [x] The claim records the full cache id/source, grants exactly `20` gears and
  shows `Tailrace Runoff Pincer Cache Claimed +20 Gears` as both feedback and
  immediate route label.
- [x] Story123 becomes visible, available, monitoring, monitorable and
  collision-blocking at `Vector2(16080, 392)` with `Open Tailrace Exit`, while
  opened remains false and unlock VFX spawn count remains zero.
- [x] Holding the cache-claim edge in Story123 range for at least four process
  frames does not open the hatch. Story124 remains hidden, unavailable,
  inactive and non-contacting.
- [x] Local state persists Story122 claimed and Story123 unopened.
- [x] Focused/related GdUnit, one 180-frame smoke and Godot MCP runtime
  verification pass under Godot 4.7 / Godot AI MCP 3.0.4 with clean accepted
  run logs and non-empty screenshots.

## Out of Scope

Story123 production hatch-open input, Story124 traversal, new enemies,
hazards, rewards, savepoints, balance, audio, particles, shaders, save schema,
generated art or full-suite testing.

## Implementation Notes

- The only production routing change adds the Story122 cache to the existing
  nearest Factory progression-cache candidate list.
- The shared rising-edge latch still owns stale/held-input protection. The
  cache router returns immediately after a successful claim, so the same edge
  cannot cascade into Story123.
- Immediate claim feedback deliberately remains visible. A restored/refreshed
  route objective resolves to `Open Tailrace Runoff Exit` without overwriting
  the reward event during this interaction.

## Asset Pipeline

Existing imported image-generated Factory, Cinderpaw, reward-cache and hatch
assets cover this slice. No image generation, import or asset-manifest change
was required.

## Test Evidence

- Canonical RED: `reports/report_2396/results.xml`, one case and exactly one
  expected fresh production-input routing failure.
- Focused GREEN: `reports/report_2397/results.xml`, `1/1` with zero failures or
  errors.
- Final bounded related GREEN: `reports/report_2398/results.xml`, five suites
  and `7/7`; zero errors, failures, flaky, skipped or orphaned tests.
- Updated smoke exited `0` after 180 frames and printed
  `story233_production_smoke=passed frames=180`.
- Godot MCP 3.0.4 accepted run `r196920539-37` used stale and fresh real
  `interact` states, preserved the held-edge hatch guard and Story124 lock, and
  ended with helper-only game logs plus an empty editor delta after cursor `2`.

## Dependencies

- Depends on: Story232 production combat handoff and Story122/123 authored
  reward/hatch contracts
- Unlocks: Story234 fresh production Story123 hatch-open input and Story124
  spillway waiting handoff

## Verification Summary

Accepted under Godot 4.7 / Godot AI MCP 3.0.4. Story122 now closes through a
real production input edge and hands a visible, blocking, unopened Story123 to
the next bounded slice. Full-suite testing was intentionally omitted.
