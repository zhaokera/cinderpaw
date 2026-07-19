# Story 025: Factory Service-Lift Return and Reentry Checkpoint Loop

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration / Presentation
> **Type**: Gameplay / Combat / Input / Persistence
> **Estimate**: S
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/scene-management.md`,
`design/gdd/player-abilities.md`, `design/gdd/save-system.md`

**ADR Governing Implementation**: ADR-0004: Collision architecture,
ADR-0007: Scene management architecture, ADR-0021: Save data schema

Story024 made the first Factory route playable through the Spark Rat
commitment line. The existing service lift, return patrol, reward cache,
Factory repair station and checkpoint-forward patrol still did not form a
continuous production-input loop. A real service-lift snapshot also persisted
`factory_return_patrol_activated=false`, which suppressed the intended patrol
when the player returned from Scrap Roost.

Story025 closes that reentry seam and ends at the next combat handoff. It does
not expand the later rear-ambush, overdrive or Lower Deck chains.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] After the first Spark Rat is defeated, the actionable objective becomes
  `Call Service Lift`; a real rising-edge `interact` requests
  `main/scrap_roost` once.
- [x] Restoring a real service-lift snapshot activates Return Patrol even when
  that snapshot explicitly contains `factory_return_patrol_activated=false`.
- [x] Return Patrol restores as entity `2103` with player target, physics,
  combat collision and all six authored Spark Rat animations at three frames
  each.
- [x] Defeating Return Patrol reveals the existing `+15 Gears` cache and the
  Factory repair station, then changes the objective to
  `Repair Factory Savepoint`.
- [x] A real `interact` action claims the return cache exactly once; it cannot
  accidentally request the service lift from the cache position.
- [x] The repair station retains its production contact contract:
  `Area2D.body_entered` activates `old_factory_return_checkpoint` without a
  second interaction semantic.
- [x] After checkpoint activation, the objective becomes
  `Savepoint Secured - Advance Right`; crossing world `x=900` automatically
  activates the frame-animated Forward Patrol with target and physics enabled.
- [x] One intentional RED, focused GREEN, bounded related regression and one
  clean Godot MCP runtime acceptance provide evidence without a full suite.

## Implementation Notes

- `OldFactoryEntranceScene.set_local_state()` treats an unresolved return
  contract as authoritative even when an older live snapshot serialized the
  pre-return `false` latch. A defeated patrol remains defeated.
- The existing abstract interaction handler now checks the return-patrol cache
  before the service lift. Existing per-object distance and availability
  guards remain responsible for whether an action succeeds.
- Objective selection now exposes the next playable action for the lift,
  repair station and post-checkpoint handoff instead of a passive clear label.
- The checkpoint remains contact-driven through `SavepointRuntime`; no parallel
  `interact` path was added.
- Existing image-generated Factory props and Spark Rat
  `AnimatedSprite2D + SpriteFrames` assets remain authoritative. No new visual
  asset was required.

## Out of Scope

- Forward Patrol defeat, rear ambush, overdrive duo, Lower Deck progression,
  service-lift animation, new rooms, new enemies, new art, audio or balance
  changes.
- A general interaction registry or broad Factory prompt-priority refactor.

## Test Evidence

- Initial intentional RED: `reports/report_2018/report_1/results.xml` failed
  both new real-input cases on the missing production wiring.
- Initial focused GREEN: `reports/report_2019/report_1/results.xml` passed
  `2/2` before the realistic serialized reentry fixture was added.
- Related contract run: `reports/report_2020/report_1/results.xml` exposed nine
  expected stale objective/diagnostic assumptions in the bounded related set.
- Real snapshot RED: `reports/report_2021/report_1/results.xml` reproduced the
  explicit-false return-patrol latch with nine focused assertions.
- Headless contact probe: `reports/report_2022/report_1/results.xml` passed the
  state fix and isolated headless physics scheduling from the contact contract.
- Final focused GREEN: `reports/report_2023/report_1/results.xml` passed `2/2`.
- Final related GREEN: `reports/report_2024/report_1/results.xml` passed nine
  suites and `27/27` cases with zero errors, failures, flaky cases, skips or
  orphan nodes. No full suite ran.
- Godot MCP 3.0.2 run `r349643989-115` launched the Factory scene in Godot 4.7,
  restored the realistic return state, defeated Return Patrol through a real
  `attack`, claimed `+15 Gears` through real `interact`, activated the repair
  station through physical contact, crossed `x=900` with real movement and
  captured a non-empty `1278x718` Forward Patrol screenshot. Game and editor
  logs ended with no project errors.
- Detailed evidence:
  `production/qa/evidence/factory-service-lift-return-loop-2026-07-19.md`.
