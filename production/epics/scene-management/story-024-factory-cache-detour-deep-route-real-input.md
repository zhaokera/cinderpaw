# Story 024: Factory Cache Detour and Deep Route Real-Input Loop

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration / Presentation
> **Type**: Gameplay / Traversal / Combat / Input
> **Estimate**: S
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/scene-management.md`,
`design/gdd/player-abilities.md`, `design/gdd/exploration-ability-gating.md`

**ADR Governing Implementation**: ADR-0004: Collision architecture,
ADR-0007: Scene management architecture

Story023 made the first Factory encounter readable, but the staged entrance
content still depended on direct test/MCP method calls. The optional cache,
deep guard, route endpoint and Spark Rat had no complete production-input path.
Story024 turns those existing pieces into a playable ACT route while preserving
the GDD's Sewer-owned Double-Jump gate as the mandatory Factory requirement.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] After the entrance guard is clear, the existing upper cache remains an
  optional detour before the deep-route commitment line. A real `interact`
  action awards exactly `+10 Gears` once.
- [x] The ground route may skip the cache without blocking progression.
- [x] Crossing world `x=1184` automatically activates the frame-animated deep
  guard at `(1280, 482)` with target, physics and combat collision enabled.
- [x] After that guard is defeated, a real `interact` action at the endpoint at
  `(1440, 400)` opens the route and disables the physical bulkhead at
  `(1520, 350)`.
- [x] Crossing world `x=1600` after the route opens automatically activates the
  frame-animated Spark Rat staged at `(1700, 482)`.
- [x] Keyboard, controller and MCP action injection share one rising-edge
  interaction path; holding `interact` cannot repeatedly fire the route action.
- [x] One intentional RED, focused GREEN, bounded related regression and one
  clean Godot MCP runtime acceptance provide evidence without a full suite.

## Implementation Notes

- `OldFactoryEntranceScene` polls the abstract `interact` action and owns a
  small rising-edge latch. The same handler routes cache, endpoint and existing
  service-lift interactions in progression order.
- Deep guard and Spark Rat activation are automatic spatial commitment checks,
  so normal movement drives the encounter instead of a test-only API.
- The new route bulkhead uses ADR-0004 collision layer `16` and the existing
  image-generated Factory deep-bulkhead texture. It is visible and blocking
  until the endpoint is activated, then both presentation and collision clear.
- Existing player, Rat and Spark Rat `AnimatedSprite2D + SpriteFrames` assets
  remain authoritative. No new visual asset was required.

## Out of Scope

- New enemies, rewards, animation frames, rooms, dialogue/tutorial UI, Factory
  route rebalance beyond this entrance loop, or changes to the Sewer-owned
  Double-Jump Factory gate.

## Test Evidence

- Initial intentional RED: `reports/report_2007/results.xml` failed the two new
  cases on the missing production interaction route.
- Initial focused GREEN: `reports/report_2008/results.xml` passed `2/2`.
- Related contract isolation: `reports/report_2009/results.xml` exposed only the
  old manual-activation assumptions; corrected fixtures passed `8/8` in
  `reports/report_2010/results.xml` and the related set passed `16/16` in
  `reports/report_2011/results.xml`.
- Runtime-driven input RED: `reports/report_2012/report_1/results.xml` proved that the
  old event-only handler did not consume the abstract `interact` action.
- Final focused GREEN: `reports/report_2015/report_1/results.xml` passed `2/2` after the
  rising-edge action fix.
- Final related GREEN: `reports/report_2016/report_1/results.xml` passed six suites and
  `16/16` cases with zero errors, failures, flaky cases, skips or orphans. No
  full suite ran.
- Godot MCP 3.0.2 run `r342477752-112` launched the Factory scene in Godot 4.7,
  claimed the optional cache through a real `interact` action, crossed both
  activation lines with real `move_right`, opened the physical gate through a
  real endpoint interaction, verified Player and Spark Rat frame animation,
  captured a non-empty `1278x718` screenshot and ended with no project errors.
- Detailed evidence:
  `production/qa/evidence/factory-cache-detour-deep-route-real-input-2026-07-19.md`.
