# Story 004: Multi-Target Hits + Duplicate Suppression

> **Epic**: Collision Detection
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/collision-detection.md`
**Requirements**: `TR-collision-005`, `TR-collision-006`

**ADR Governing Implementation**: ADR-0004: Collision detection architecture
**ADR Decision Summary**: One active hitbox may hit multiple hurtboxes in the same frame, but `mark_hit(target_id)` prevents repeated hits against the same target during one activation.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Pure active-hitbox bookkeeping and frame-level detection rules.

**Control Manifest Rules (Core)**:
- Required: `HitboxArea` prevents duplicate hits with `mark_hit()` / `has_hit()`.
- Required: Same-frame area attacks emit one event per independent hurtbox.
- Forbidden: Never use PhysicsBody for hit detection.
- Guardrail: Collision detection budget is <3ms/frame.

---

## Acceptance Criteria

- [x] One active hitbox overlapping three target hurtboxes emits three hit events in one detection frame.
- [x] The same hitbox overlapping the same target for two consecutive frames emits only the first hit.
- [x] Reactivating the hitbox clears previous target marks and allows the target to be hit again.
- [x] Simultaneous opposing attacks can each emit their own hit event.

## Implementation Notes

- Reuse `HitboxArea` target tracking; do not add global target suppression.
- Keep each hit event independent so long-tail range attacks can fan out.

## Out of Scope

- Damage calculation, status effects, and presentation feedback.
- Death cleanup.

---

## QA Test Cases

- **AC-1**: Multi-target hit fan-out
  - Given: One wide active hitbox and three valid hurtboxes
  - When: detection runs once
  - Then: three hit events emit with distinct target ids
  - Edge cases: ordering is not gameplay-significant

- **AC-2**: Duplicate suppression
  - Given: A hitbox already marked against target 7
  - When: detection runs again with the same target still overlapping
  - Then: no second hit event emits
  - Edge cases: reactivation clears marks and allows a new hit

- **AC-3**: Mutual hits
  - Given: Player and enemy each have an active hitbox
  - When: both overlap the other's hurtbox
  - Then: two hit events emit
  - Edge cases: self-hit prevention still applies

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/collision/story_004_multi_target_hits_duplicate_suppression_test.gd` — must exist and pass

**Status**: [x] Created and passing

---

## Dependencies

- Depends on: Story 003 Frame-Level Hit Detection + HitEvent Signal
- Unlocks: Story 005 Entity Death Cleanup + Combat Adapter Integration

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: One active hitbox overlapping three target hurtboxes emits three hit events in one detection frame. | `tests/unit/collision/story_004_multi_target_hits_duplicate_suppression_test.gd::test_one_hitbox_overlapping_three_hurtboxes_emits_three_events` | COVERED |
| AC-2: The same hitbox overlapping the same target for two consecutive frames emits only the first hit. | `tests/unit/collision/story_004_multi_target_hits_duplicate_suppression_test.gd::test_same_target_overlapping_for_two_frames_emits_only_first_hit` | COVERED |
| AC-3: Reactivating the hitbox clears previous target marks and allows the target to be hit again. | `tests/unit/collision/story_004_multi_target_hits_duplicate_suppression_test.gd::test_reactivating_hitbox_clears_previous_target_marks` | COVERED |
| AC-4: Simultaneous opposing attacks can each emit their own hit event. | `tests/unit/collision/story_004_multi_target_hits_duplicate_suppression_test.gd::test_simultaneous_opposing_attacks_emit_independent_events` | COVERED |

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 4/4 passing
**Deviations**: None
**Implementation**: No new production code was required for this story. Story 003 already implemented per-target hit iteration and `HitboxArea` target tracking; Story 004 adds focused coverage that locks in fan-out, duplicate suppression, hitbox reactivation clearing, and mutual-hit behavior.
**Test Evidence**:
- Story suite: `reports/report_174/` — 4/4 passing
- Collision suite: `reports/report_175/` — 19/19 passing
- Full unit suite: `reports/report_176/` — 193/193 passing
- Static/startup checks: `godot --headless --path . --quit`, `git diff --check`, trailing-whitespace scan, and changed-method length scan passed during closure.
**Code Review**: Local automated review complete against ADR-0004, `TR-collision-005`, `TR-collision-006`, and Core control-manifest collision rules. Specialist QA/LP subagent gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
