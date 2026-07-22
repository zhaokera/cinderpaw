# Story 231: Old Factory Service Sluice Tailrace Relay Runoff Production Hazard Traverse Pincer Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Traversal / Route Handoff
> **Type**: Integration + Production Movement + Physical Hazard + Route Handoff
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/input.md`,
`design/gdd/collision-detection.md`, `design/gdd/health-death.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-respawn-002`,
`TR-respawn-004`

**ADR Governing Implementation**: ADR-0004 collision detection; ADR-0007
scene management.

Story230 activates the Tailrace Relay through real contact and leaves Story120
visible but idle. Story231 closes the runoff as a production ACT traversal:
fresh positive movement starts and completes the pocket, active steam applies
real contact damage, and Story121 becomes available without being consumed by
the crossing frame, teleports or held input without displacement.

## Acceptance Criteria

- [x] Story119's activated terminal state exposes Story120 as available,
  visible, idle and non-contacting while Story121 remains unavailable.
- [x] Placing Cinderpaw beyond activation x `13760` without input does not
  activate Story120. Real `move_right` plus positive-x displacement starts it
  and shows `Cross Tailrace Relay Runoff`.
- [x] The vent runs `grace 0.25s -> warning 0.35s -> active 0.40s -> safe
  0.45s`; safe, warning and active each use four-frame `AnimatedSprite2D +
  SpriteFrames` presentation.
- [x] Only active steam enables contact at collision layer `16`, mask `12`.
  Real `Area2D` overlap applies exact HP `100 -> 92`, damage `8`, type `steam`
  and the Story120 hazard source while Cinderpaw shows `hurt`.
- [x] Placing Cinderpaw beyond exit x `14320` without input does not cross the
  pocket. Real `move_right` plus positive displacement persists crossed state,
  disables contact and shows `Tailrace Relay Runoff Crossed`.
- [x] Story121 then becomes available but stays inactive; Spark/Coil Rats are
  hidden, untargeted, non-processing and non-physical throughout the handoff.
- [x] No-input placement beyond Story121 activation x `14640`, and held
  `move_right` without positive displacement, cannot start Story121.
- [x] Focused/related GdUnit, one `180`-frame smoke and one Godot MCP runtime
  pass under Godot 4.7 / Godot AI MCP 3.0.4 with clean current-run logs and
  non-empty screenshots.

## Out of Scope

Story121 production activation or combat; Story122 reward handoff; new visual,
audio, particle or shader assets; new savepoint or SaveSystem schema; enemy
balance changes; full-suite testing.

## Implementation Notes

- Story120 completion now snapshots active state before the frame and requires
  `move_right`, initialized tracking and new positive-x displacement.
- Story121 activation independently snapshots availability and tracks its own
  previous player x. This prevents the Story120 crossing frame, restored state
  and direct placement from consuming the next encounter.
- Public diagnostic and explicit activation/completion APIs remain unchanged;
  only the production auto-routing path gained the movement guards.
- The adjacent Story121 regression now reflects the established live death
  contract: a newly defeated enemy remains visible in its three-frame death
  hold while targeting, collision and physics are disabled.

## Asset Pipeline

Existing imported image-generated Factory environment, Cinderpaw, steam vent,
Spark Rat and Coil Rat assets fully cover this slice. The steam vent already
provides four-frame safe/warning/active animations, and all visible characters
already use `AnimatedSprite2D + SpriteFrames`. No image generation, import or
manifest change was required.

## Test Evidence

- Canonical RED: `reports/report_2384/report_1/results.xml`, `1` case with two
  expected failures for no-input Story120 completion and no-input Story121
  activation.
- Focused GREEN: `reports/report_2385/report_1/results.xml`, `1/1`.
- Final related GREEN: `reports/report_2388/report_1/results.xml`, five suites
  and `7/7`; zero errors, failures, flaky, skipped or orphaned tests.
- Updated headless smoke exited `0` and printed
  `story120_production_smoke=passed frames=180`.
- Godot MCP 3.0.4 session `cinderpaw@198e`, accepted run `r192090587-32`, used
  real `move_right` for activation and crossing, real physics overlap for
  `100 -> 92` steam damage, and verified both Story120 and Story121 stationary
  guards. Current game log was helper-only, editor delta after cursor `2` was
  empty, all inputs were released and playback stopped at readiness `ready`.
- Three non-empty RGB `1278x718` screenshots are recorded in the QA evidence.

## Dependencies

- Depends on: Story230 production Tailrace Relay contact/respawn closure
- Unlocks: Story121 production pincer activation and combat closure

## Verification Summary

Accepted under Godot 4.7 / Godot AI MCP 3.0.4. Story120 is now a real-input,
physical-hazard traversal and hands off to an explicitly waiting Story121.
Full-suite testing was intentionally omitted.
