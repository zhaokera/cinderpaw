# Story 003: Frame-Level Hit Detection + HitEvent Signal

> **Epic**: Collision Detection
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/collision-detection.md`
**Requirements**: `TR-collision-001`, `TR-collision-005`

**ADR Governing Implementation**: ADR-0002: Signal communication; ADR-0004: Collision detection architecture
**ADR Decision Summary**: Collision performs frame-level active hitbox vs hurtbox detection and emits `on_hit_confirmed(event: HitEvent)` with typed payload data.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Verify deterministic frame-level behavior without relying on deferred physics update timing.

**Control Manifest Rules (Core)**:
- Required: Frame-level detection in `_physics_process`.
- Required: `on_hit_confirmed` carries `HitEvent` payload.
- Forbidden: No centralized event bus.
- Guardrail: Signal overhead <0.1ms/frame; collision detection <3ms/frame.

---

## Acceptance Criteria

- [x] `HitEvent` exposes attacker_id, target_id, hitbox_id, hit_position, hit_frame, and attack_metadata.
- [x] Active hitbox overlap with a valid opposing hurtbox emits exactly one `on_hit_confirmed` payload.
- [x] The emitted hit payload preserves attack metadata from `activate_hitbox()`.
- [x] Hitbox vs own hurtbox does not emit.
- [x] Hurtbox in `gone` state does not emit.
- [x] Hitbox duration still decrements once per frame after detection.

## Implementation Notes

- Create `src/core/events/hit_event.gd` as `class_name HitEvent extends RefCounted`.
- Implement detection through `_physics_process` and a deterministic test hook if needed for GdUnit4.
- Keep payload creation in Collision; Combat only consumes the signal.

## Out of Scope

- Multi-target fan-out and duplicate suppression beyond a single target.
- Death cleanup.
- VFX/audio feedback.

---

## QA Test Cases

- **AC-1**: HitEvent payload
  - Given: A confirmed hit
  - When: the signal is captured
  - Then: all HitEvent fields are populated from hitbox/hurtbox data
  - Edge cases: missing attack metadata becomes an empty Dictionary

- **AC-2**: Valid and invalid overlap
  - Given: An active player hitbox and enemy hurtbox
  - When: they overlap during detection
  - Then: one hit is emitted
  - Edge cases: own hurtbox and gone hurtbox are ignored

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/collision/story_003_frame_level_hit_detection_hit_event_signal_test.gd` — must exist and pass

**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first story run failed during discovery because `res://src/core/events/hit_event.gd` did not exist yet (exit 105).
- Story suite: `reports/report_171/` — 5/5 passing.
- Collision suite: `reports/report_172/` — 15/15 passing.
- Full unit suite: `reports/report_173/` — 189/189 passing.
- Static checks: `godot --headless --path . --quit`, `git diff --check`, trailing-whitespace scan, and method-length scan all passed.

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| `HitEvent` exposes attacker_id, target_id, hitbox_id, hit_position, hit_frame, and attack_metadata. | `tests/unit/collision/story_003_frame_level_hit_detection_hit_event_signal_test.gd::test_hit_event_exposes_all_payload_fields` | COVERED |
| Active hitbox overlap with a valid opposing hurtbox emits exactly one `on_hit_confirmed` payload. | `tests/unit/collision/story_003_frame_level_hit_detection_hit_event_signal_test.gd::test_valid_opposing_hurtbox_overlap_emits_one_hit_event` | COVERED |
| The emitted hit payload preserves attack metadata from `activate_hitbox()`. | `tests/unit/collision/story_003_frame_level_hit_detection_hit_event_signal_test.gd::test_valid_opposing_hurtbox_overlap_emits_one_hit_event` | COVERED |
| Hitbox vs own hurtbox does not emit. | `tests/unit/collision/story_003_frame_level_hit_detection_hit_event_signal_test.gd::test_hitbox_vs_own_hurtbox_does_not_emit` | COVERED |
| Hurtbox in `gone` state does not emit. | `tests/unit/collision/story_003_frame_level_hit_detection_hit_event_signal_test.gd::test_gone_target_hurtbox_does_not_emit` | COVERED |
| Hitbox duration still decrements once per frame after detection. | `tests/unit/collision/story_003_frame_level_hit_detection_hit_event_signal_test.gd::test_valid_opposing_hurtbox_overlap_emits_one_hit_event`; `test_physics_process_decrements_active_hitboxes_once_per_frame` | COVERED |

---

## Dependencies

- Depends on: Story 002 Hurtbox States + Collision Layers
- Unlocks: Story 004 Multi-Target Hits + Duplicate Suppression

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 6/6 passing
**Deviations**: Advisory note only — `on_hit_confirmed` is annotated as `RefCounted` to avoid Godot/GdUnit `class_name HitEvent` discovery-order failures for newly added scripts. Runtime payloads are still created from `src/core/events/hit_event.gd`, and the Story 003 test asserts the emitted event's script is `HIT_EVENT_SCRIPT`.
**Test Evidence**: Integration/unit test at `tests/unit/collision/story_003_frame_level_hit_detection_hit_event_signal_test.gd`; story suite `reports/report_171/`; collision suite `reports/report_172/`; full unit suite `reports/report_173/`.
**Code Review**: Local automated review complete against ADR-0002, ADR-0004, Core control manifest, and TR-collision-001/TR-collision-005. QL/LP subagent gates skipped because the current multi-agent tool policy requires an explicit user delegation request before spawning subagents.
