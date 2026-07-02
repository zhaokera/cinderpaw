# Story 001: HitboxArea + Activation Lifecycle

> **Epic**: Collision Detection
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/collision-detection.md`
**Requirements**: `TR-collision-002`, `TR-collision-005`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0004: Collision detection architecture
**ADR Decision Summary**: Collision is an entity component, not an Autoload. Hitbox lifecycle is owned by `CollisionComponent`, with `HitboxArea` tracking active frames and already-hit targets.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: `Area2D` and `CollisionShape2D` are stable. This story tests activation lifecycle and duplicate tracking without relying on physics overlap timing.

**Control Manifest Rules (Core)**:
- Required: `Area2D + CollisionShape2D` for hitbox/hurtbox detection.
- Required: `HitboxArea` class with `mark_hit(target_id)`, `has_hit(target_id)`, and `clear_hits()`.
- Forbidden: Never use `PhysicsBody` for hit detection.
- Guardrail: Collision detection budget is <3ms/frame.

---

## Acceptance Criteria

- [x] `HitboxArea` starts inactive with no hit targets.
- [x] `mark_hit(target_id)`, `has_hit(target_id)`, and `clear_hits()` prevent duplicate hits for one attack activation.
- [x] `CollisionComponent.activate_hitbox(hitbox_id, duration_frames, offset, size, attack_metadata)` creates or reuses a HitboxArea, applies offset/size, clears old hit targets, and marks it active.
- [x] `advance_hitbox_frames(1)` decrements remaining frames and auto-deactivates after `duration_frames`.
- [x] `deactivate_hitbox(hitbox_id)` safely disables an active hitbox and ignores unknown ids.
- [x] Invalid duration or size uses safe minimum defaults instead of creating zero/negative active hitboxes.

## Implementation Notes

- Create `src/core/hitbox_area.gd` as `class_name HitboxArea extends Area2D`.
- Create or extend `src/core/collision_component.gd` as `class_name CollisionComponent extends Node`.
- Keep public lifecycle APIs deterministic so GdUnit4 can test without waiting for engine physics overlap updates.
- Do not implement full overlap detection in this story; it is Story 003.

## Out of Scope

- Hurtbox state changes and collision layer masks.
- `HitEvent` signal emission and overlap detection.
- Combat adapter wiring beyond lifecycle-safe public methods.
- Debug visualization, VFX, and audio.

---

## QA Test Cases

- **AC-1**: Hitbox duplicate tracking
  - Given: A fresh HitboxArea
  - When: one target id is marked, queried, and hits are cleared
  - Then: `has_hit()` returns true only before `clear_hits()`
  - Edge cases: repeated `mark_hit()` does not create extra state

- **AC-2**: Hitbox activation applies data and resets hit targets
  - Given: A CollisionComponent with an existing hitbox that has already hit target 7
  - When: the same hitbox id is activated with duration, offset, size, and attack metadata
  - Then: the hitbox is active, uses the new data, and no longer has target 7 marked
  - Edge cases: missing metadata defaults to an empty Dictionary

- **AC-3**: Duration and deactivation
  - Given: A hitbox activated for 2 frames
  - When: hitbox frames advance twice
  - Then: the hitbox is inactive and removed from active tracking
  - Edge cases: unknown `deactivate_hitbox()` calls do not crash

- **AC-4**: Safe defaults
  - Given: A hitbox activation with invalid duration and invalid size
  - When: the hitbox is activated
  - Then: remaining frames and size are clamped to safe minimums
  - Edge cases: negative duration and zero vectors are both clamped

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/collision/story_001_hitbox_area_activation_lifecycle_test.gd` — must exist and pass

**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first story run failed during discovery because `res://src/core/hitbox_area.gd` and `res://src/core/collision_component.gd` did not exist yet (exit 105).
- Story suite: `reports/report_163/` — 5/5 passing.
- Collision suite: `reports/report_164/` — 5/5 passing.
- Full unit suite: `reports/report_165/` — 179/179 passing.
- Static checks: `godot --headless --path . --quit`, `git diff --check`, trailing-whitespace scan, and method-length scan all passed.

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| `HitboxArea` starts inactive with no hit targets. | `tests/unit/collision/story_001_hitbox_area_activation_lifecycle_test.gd::test_hitbox_area_starts_inactive_and_tracks_hit_targets` | COVERED |
| `mark_hit(target_id)`, `has_hit(target_id)`, and `clear_hits()` prevent duplicate hits for one attack activation. | `tests/unit/collision/story_001_hitbox_area_activation_lifecycle_test.gd::test_hitbox_area_starts_inactive_and_tracks_hit_targets` | COVERED |
| `CollisionComponent.activate_hitbox(...)` creates or reuses a HitboxArea, applies offset/size, clears old hit targets, and marks it active. | `tests/unit/collision/story_001_hitbox_area_activation_lifecycle_test.gd::test_activate_hitbox_applies_lifecycle_data_and_clears_old_hits` | COVERED |
| `advance_hitbox_frames(1)` decrements remaining frames and auto-deactivates after `duration_frames`. | `tests/unit/collision/story_001_hitbox_area_activation_lifecycle_test.gd::test_advance_hitbox_frames_auto_deactivates_after_duration` | COVERED |
| `deactivate_hitbox(hitbox_id)` safely disables an active hitbox and ignores unknown ids. | `tests/unit/collision/story_001_hitbox_area_activation_lifecycle_test.gd::test_deactivate_hitbox_is_safe_for_active_and_unknown_ids` | COVERED |
| Invalid duration or size uses safe minimum defaults instead of creating zero/negative active hitboxes. | `tests/unit/collision/story_001_hitbox_area_activation_lifecycle_test.gd::test_activate_hitbox_clamps_invalid_duration_and_size_to_safe_minimums` | COVERED |

---

## Dependencies

- Depends on: None
- Unlocks: Story 002 Hurtbox States + Collision Layers

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 6/6 passing
**Deviations**: None. Story 001 intentionally stops before Hurtbox state management, layer/mask filtering, overlap detection, and `HitEvent` emission; those remain assigned to Stories 002-005.
**Test Evidence**: Logic unit test at `tests/unit/collision/story_001_hitbox_area_activation_lifecycle_test.gd`; story suite `reports/report_163/`; collision suite `reports/report_164/`; full unit suite `reports/report_165/`.
**Code Review**: Local automated review complete against ADR-0001, ADR-0004, Core control manifest, and TR-collision-002/TR-collision-005. QL/LP subagent gates skipped because the current multi-agent tool policy requires an explicit user delegation request before spawning subagents.
