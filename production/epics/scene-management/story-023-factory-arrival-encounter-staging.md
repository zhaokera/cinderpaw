# Story 023: Factory Arrival Encounter Staging

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration / Presentation
> **Type**: Gameplay / Pacing / Visual / Persistence
> **Estimate**: S
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/scene-management.md`,
`design/gdd/player-abilities.md`, `design/gdd/exploration-ability-gating.md`

**ADR Governing Implementation**: ADR-0004: Collision architecture,
ADR-0007: Scene management architecture

Story022 made Sewer the real first-entry owner for Factory. The destination was
playable, but its first viewport exposed the cache, deep guard, deep endpoint,
Spark Rat and service lift at once. Their yellow prompts competed with the
current objective, while the entrance Rat began chasing as soon as the scene
loaded. Story023 stages that existing content into one readable ACT encounter.

**Engine**: Godot 4.7 | **Risk**: MEDIUM

## Acceptance Criteria

- [x] `factory_gate_entry` places the player clear of the entrance portal with
  zero inherited velocity and preserves the existing Factory scene contract.
- [x] Fresh arrival shows one frame-animated entrance Rat. It has no target,
  physics process, blocking collision or damageable Hurtbox until the player
  crosses the authored pressure line at world `x=520`; activation occurs only
  once.
- [x] The entrance cache, deep guard, deep endpoint, Spark Rat and service lift
  reveal in their existing progression order instead of competing in the first
  viewport. No new enemy, prop or placeholder is introduced.
- [x] Steam contact still damages the player and records hazard metadata, but
  it no longer permanently replaces the authoritative route objective text.
- [x] Entry-guard activation persists in scene-local state; cleared legacy or
  current saves do not restore a live entrance guard.
- [x] One intentional RED, focused GREEN, bounded related regression and one
  clean Godot MCP runtime acceptance provide evidence without a full suite.

## Implementation Notes

- `OldFactoryEntranceScene` owns a small `factory_entry_guard_activated` state
  and deterministic diagnostics for tests and MCP probes.
- The existing Rat Minion remains visible in `idle` before commitment. Crossing
  the pressure line enables its existing target, physics, collision and chase
  behavior. Entry, deep and Spark Rat Hurtboxes track those activation states,
  so staged or restored enemies cannot absorb attacks while inactive; no
  alternate AI implementation was added.
- Existing generated Factory art, platform art, cache, terminal, service lift,
  steam animation and all character `SpriteFrames` are reused. No image
  generation was needed for this composition and reveal pass.
- Story023 intentionally supersedes Story010/013's historical requirement that
  locked deep-route content remain visible before it becomes relevant.

## Out of Scope

- Enemy stat changes, new animation frames, a new Factory room, new rewards,
  dialogue/tutorial UI, input-system quarantine, SceneManager architecture
  changes or Factory route rebalance beyond the first-screen reveal sequence.

## Test Evidence

- Intentional RED: `reports/report_1997/results.xml` failed the single
  acceptance on the missing staging APIs.
- Focused GREEN: `reports/report_1998/results.xml` passed `1/1` with zero
  errors, failures, flaky cases, skips or orphans.
- Related contract update: `reports/report_1999/results.xml` isolated exactly
  two superseded locked-visibility assertions; all other related cases passed.
- Initial related GREEN: `reports/report_2000/results.xml` passed eight suites and
  `19/19` cases with zero test errors, failures, flaky cases, skips or orphans.
  No full suite ran.
- Post-diagnostic focused verification: `reports/report_2001/results.xml`
  passed `1/1` after the final in-tree prompt visibility assertions.
- Review regression RED: `reports/report_2002/results.xml` reproduced seven
  inactive/legacy Hurtbox and freed-reference contract failures across `4`
  cases. Focused GREEN `reports/report_2003/results.xml` passed `4/4`.
- `reports/report_2004/results.xml` isolated one superseded pre-activation hit
  test; its corrected focused run passed `4/4` in `reports/report_2005/results.xml`.
- Final related GREEN: `reports/report_2006/results.xml` passed nine suites and
  `22/22` cases with zero errors, failures, flaky cases, skips or orphans. No
  full suite ran.
- Godot MCP 3.0.2 run `r335863042-105` launched the Factory scene in Godot 4.7,
  captured non-empty `1278x718` screenshots before and after the real
  `move_right` commitment, verified the Player and Rat `AnimatedSprite2D`
  nodes, staged visibility, `x=520` activation, target/physics/collision state,
  unchanged objective text after steam damage, one initialization log line and
  zero editor errors.
- Final clean MCP run `r337599831-107` reloaded the edited script, confirmed all
  three future-stage prompts were hidden in-tree, captured a non-empty Factory
  screenshot, and ended with one helper info line and zero editor errors.
- Post-review MCP run `r338967041-108` confirmed the entry, deep and Spark Rat
  Hurtboxes all started `gone`; real `move_right` crossed `x=520` and changed
  only the entrance Hurtbox to `normal` with target, physics and collision
  enabled. Steam reduced HP to `92` without replacing the route objective; the
  screenshot was non-empty and game/editor logs had no project errors.
- Detailed evidence:
  `production/qa/evidence/factory-arrival-encounter-staging-2026-07-19.md`.
