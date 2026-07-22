# Story 232: Old Factory Service Sluice Tailrace Relay Runoff Pincer Production Combat Reward Cache Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Combat / Reward Handoff
> **Type**: Integration + Production Movement + Production Combat + Live Death + Reward Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/input.md`,
`design/gdd/collision-detection.md`, `design/gdd/health-death.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`,
`TR-respawn-004`

**ADR Governing Implementation**: ADR-0004 collision detection; ADR-0005
combat state machine; ADR-0007 scene management.

Story231 leaves Story121 available but inactive after the Tailrace Relay
runoff. Story232 closes the pincer through production movement and the shared
physical hit path, preserves both live death presentations, and reveals
Story122's reward cache without consuming it through stale interaction input.

## Acceptance Criteria

- [x] Fresh `move_right` plus positive displacement across activation x
  `14640` activates Story121; direct placement without movement does not.
- [x] Spark Rat entity `2144` and Coil Rat entity `2145` become visible,
  targeted and processing at `24` HP with all six required gameplay animations
  containing at least three frames.
- [x] Two real `Input.attack` light strikes route through the shared physical
  hit path for each enemy, applying exact damage `12 + 12`, hitbox
  `cat_claw_light`, attacker `1`, weapon `cat_claw`, and correct facing/target.
- [x] Spark Rat can finish its death animation and free before Coil Rat is
  defeated without passing a stale Object reference into a typed sync helper.
- [x] The partial clear keeps Coil Rat active and Story122 hidden; the final
  clear shows Coil Rat's live `death`, disables targeting/physics/hurtbox and
  advances feedback to `Tailrace Runoff Pincer Cleared`.
- [x] Readability order is cache z `22`, enemies z `24`, Cinderpaw z `26`.
- [x] Holding `interact` before the final clear does not claim Story122. The
  cache becomes visible, available, in range and claimable with `+20 Gears`,
  while claimed remains false and reward/feedback payloads remain empty.
- [x] Focused/related GdUnit, one 180-frame smoke and Godot MCP runtime
  verification pass under Godot 4.7 / Godot AI MCP 3.0.4 with clean accepted
  run logs and non-empty screenshots.

## Out of Scope

Fresh Story122 claim routing; Story123 exit-hatch activation; new enemy AI,
balance, audio, particles, shaders, save schema or visual assets; full-suite
testing.

## Implementation Notes

- The production scene raises both pincer enemies from z `20` to `24`, between
  the cache and Cinderpaw.
- The shared pincer enemy-state synchronizer now accepts `Variant` and resolves
  it through `_get_valid_node2d` before accessing the node. This matches the
  existing safe diagnostics path and handles completed death-animation frees.
- The integration regression explicitly frees the first defeated enemy before
  the second lethal hit, reproducing the timing exposed by the MCP runtime.

## Asset Pipeline

Existing imported image-generated Factory, Cinderpaw, Spark Rat, Coil Rat and
reward-cache assets cover the slice. Both enemies already use
`AnimatedSprite2D + SpriteFrames` with three-frame `idle`, `run`,
`attack_tell`, `attack`, `hurt` and `death`. No image generation, import or
manifest change was required.

## Test Evidence

- Canonical visual RED: `reports/report_2390/results.xml`, one case with two
  expected z-order failures.
- Initial focused GREEN: `reports/report_2391/results.xml`, `1/1`.
- MCP runtime regression RED: `reports/report_2393/results.xml`, one runtime
  error reproducing the freed first-enemy reference before the second death.
- Fixed focused GREEN: `reports/report_2394/results.xml`, `1/1` with zero
  errors or failures.
- Final bounded related GREEN: `reports/report_2395/results.xml`, five suites
  and `7/7`; zero errors, failures, flaky, skipped or orphaned tests.
- Updated 180-frame smoke exited `0` and printed
  `story121_production_smoke=passed frames=180`, including death frames
  `0/1/2` for both enemies.
- Godot MCP 3.0.4 accepted run `r194847761-35` used real movement and four real
  attacks, waited for Spark Rat to free before Coil Rat's lethal hit, preserved
  held-input protection and ended with helper-only game logs plus an empty
  editor delta after cursor `2`.

## Dependencies

- Depends on: Story231 production runoff traversal and Story121/122 authored
  encounter/reward contracts
- Unlocks: Story122 fresh production reward input and Story123 exit-hatch
  handoff

## Verification Summary

Accepted under Godot 4.7 / Godot AI MCP 3.0.4. Story121 is now a production
movement/combat beat with robust sequential live deaths and an unconsumed
Story122 reward handoff. Full-suite testing was intentionally omitted.
