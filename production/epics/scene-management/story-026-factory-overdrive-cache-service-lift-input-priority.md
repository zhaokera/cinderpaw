# Story 026: Factory Overdrive Cache and Service-Lift Input Priority

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Gameplay Integration
> **Type**: Integration / Input / SceneManager
> **Estimate**: S
> **Manifest Version**: 2026-07-19
> **Last Updated**: 2026-07-19

## Context

**GDD**: `design/gdd/scene-management.md`,
`design/gdd/player-abilities.md`

**ADR Governing Implementation**: ADR-0004: Collision architecture,
ADR-0007: Scene management architecture

The existing Factory overdrive reward cache and service lift have overlapping
96-pixel interaction radii. Once the Overdrive Duo is cleared, both actions can
be eligible at the same time, but the production input dispatcher skipped the
overdrive cache and called the lift first. This discarded the optional
`+25 Gears` payoff behind an irreversible scene transition even though the
cache's direct claim API and persistence contract were already complete.

Story026 closes only that production-input seam. It preserves the cache as an
optional reward outside the overlap and does not reopen the authored Forward
Patrol, Rear Ambush, Overdrive Duo or Lower Deck content.

**Engine**: Godot 4.7 | **Risk**: LOW

## Acceptance Criteria

- [x] Given a cleared Overdrive Duo, an unclaimed reward cache and an idle
  service lift, the first real rising-edge `interact` while both actions are
  eligible claims the cache exactly once for `+25 Gears`.
- [x] That first action does not activate the lift or create a SceneManager
  request.
- [x] Holding the same `interact` input across additional frames cannot chain
  into the service lift.
- [x] Releasing and pressing `interact` again while the lift remains eligible
  creates one `main/scrap_roost` request and records the local exit state.
- [x] The reward remains optional globally: a lift-only position can still
  exit without claiming it, and no reward flag becomes a new lift prerequisite.
- [x] Existing return-cache priority, Overdrive Duo progression, reward
  persistence and service-lift handoff contracts remain green.
- [x] One intentional RED, focused GREEN, bounded related regression and one
  clean Godot MCP runtime acceptance provide evidence without a full suite.

## Implementation Notes

- `handle_factory_interact_input()` now tries the overdrive reward cache after
  the existing return cache and before the service lift. Each target's existing
  availability and distance checks still decide whether it can consume input.
- The existing rising-edge latch supplies the required release between reward
  claim and lift activation; no timer, cooldown or general interaction registry
  was added.
- The service lift still does not require the reward's claimed flag. This keeps
  the Story051 optional-reward contract intact outside the overlap.
- Existing image-generated Factory props and frame-animated characters remain
  authoritative. No scene, animation or visual asset changed.

## Out of Scope

- Forward Patrol, Rear Ambush or Overdrive Duo combat, AI, animation, damage,
  pacing or balance changes.
- Moving either interaction target, changing the 96-pixel radii, or making the
  reward a global progression gate.
- Service-lift animation, Main arrival content, Lower Deck progression, a new
  room, new enemy, art, audio or SaveSystem schema change.
- A generic interaction registry or broad prompt-arbitration refactor.

## Test Evidence

- Intentional RED: `reports/report_2025/results.xml` ran the new production
  input case and failed four expected assertions because the first input
  requested the lift and left the reward unclaimed.
- Focused GREEN: `reports/report_2026/results.xml` passed `1/1` with zero
  errors, failures, flaky cases, skips or orphan nodes.
- Related GREEN: `reports/report_2027/results.xml` passed five suites and
  `9/9` cases covering the new priority test, overdrive reward cache,
  service-lift SceneManager exit, Story025 return loop and Story024 entry route.
- Overdrive progression regression: `reports/report_2028/results.xml` passed
  the existing Overdrive Duo suite `4/4`. No full suite ran.
- Godot MCP 3.0.2 run `r352318194-116` launched the Factory scene in Godot 4.7,
  seeded both overlapping interactions as eligible, claimed `+25 Gears` from
  one real held `interact` without an exit request, then accepted
  `main/scrap_roost` only after release and a second real input. It captured a
  non-empty `1278x718` game screenshot; game and editor logs contained no
  project errors.
- Detailed evidence:
  `production/qa/evidence/factory-overdrive-cache-service-lift-input-priority-2026-07-19.md`.
