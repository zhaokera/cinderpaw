# Story 004: Parry Timing Windows + Counter Outcome

> **Epic**: Feline Combat
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/feline-combat.md`
**Requirement**: `TR-combat-004`

**ADR Governing Implementation**: ADR-0004: Collision detection architecture; ADR-0005: Combat state machine architecture
**ADR Decision Summary**: Combat owns the 18-frame parry window and reports timing metadata for downstream stun, damage, and presentation systems.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Parry timing is pure frame logic and should be covered without physics or animations.

**Control Manifest Rules (Core)**:
- Required: Parry window 18 frames total, PERFECT=0-6, GOOD=7-12, LATE=13-18.
- Required: State transitions run from `_physics_process`.
- Forbidden: Never use AnimationTree for combat state management.
- Guardrail: Combat state transitions <0.1ms/frame.

---

## Acceptance Criteria

- [x] Given action `parry` while IDLE, Combat enters PARRYING.
- [x] Frames 0-6 classify as PERFECT.
- [x] Frames 7-12 classify as GOOD.
- [x] Frames 13-18 classify as LATE.
- [x] After frame 18, Combat exits PARRYING to IDLE if no counter transition is pending.
- [x] On successful parry, Combat emits or returns metadata containing `parry_type` and `stun_seconds = 1.0`.
- [x] Failed parry does not apply extra punishment beyond normal damage handling.

## Implementation Notes

- Add `classify_parry_timing(frame: int) -> StringName` or equivalent public testable API.
- Use StringName values `&"perfect"`, `&"good"`, `&"late"`, `&"miss"`.
- Keep the enemy stun outcome as metadata; the AI or StatusEffect system applies the actual stun later.
- Do not route through DamageCalculator until Story 007.

## Out of Scope

- Presentation effects for flash, sparks, frame stop, and audio.
- AI stun implementation.

---

## QA Test Cases

- **AC-1**: Parry timing classification
  - Given: parry frame values 0, 6, 7, 12, 13, 18, and 19
  - When: timing is classified
  - Then: results are PERFECT, PERFECT, GOOD, GOOD, LATE, LATE, and MISS
  - Edge cases: negative frames return MISS

- **AC-2**: PARRYING lifecycle
  - Given: Combat enters PARRYING
  - When: 19 physics frames pass without hit confirmation
  - Then: Combat returns to IDLE
  - Edge cases: repeated parry input during PARRYING is ignored

- **AC-3**: Counter metadata
  - Given: a hit arrives during GOOD timing
  - When: Combat handles the parry outcome
  - Then: metadata includes `parry_type = "good"` and `stun_seconds = 1.0`
  - Edge cases: MISS metadata does not include stun

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/combat/story_004_parry_timing_counter_outcome_test.gd` — must exist and pass

**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first run failed on missing `get_parry_frame()`, `classify_parry_timing()`, `advance_parry_frames()`, and `resolve_parry_result()` APIs (`reports/report_142/`).
- Story suite: `res://tests/unit/combat/story_004_parry_timing_counter_outcome_test.gd` — 6/6 passing, report `reports/report_144/`.
- Combat regression: `res://tests/unit/combat` — 22/22 passing, report `reports/report_145/`.
- Full unit regression: `res://tests/unit` — 156/156 passing, report `reports/report_146/`.
- Static checks: `godot --headless --path . --quit`, `git diff --check`, trailing whitespace scan, and method-length quick check passed.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 7/7 passing
**Deviations**: None
**Test Evidence**: `tests/unit/combat/story_004_parry_timing_counter_outcome_test.gd`
**Code Review**: Local automated review complete; QA/LP subagent gates skipped because current tool policy requires explicit user delegation for subagents.

**Traceability**:

| Criterion | Test | Status |
|-----------|------|--------|
| Parry action from IDLE enters PARRYING | `test_parry_action_from_idle_enters_parrying` | COVERED |
| Frames 0-6 classify as PERFECT | `test_classify_parry_timing_boundaries` | COVERED |
| Frames 7-12 classify as GOOD | `test_classify_parry_timing_boundaries` | COVERED |
| Frames 13-18 classify as LATE | `test_classify_parry_timing_boundaries` | COVERED |
| PARRYING exits after frame 18 without counter | `test_parrying_lifecycle_exits_after_frame_eighteen` | COVERED |
| Successful parry returns stun metadata and counter state | `test_successful_parry_returns_counter_metadata` | COVERED |
| Failed parry has no stun or extra punishment | `test_missed_parry_returns_no_stun_or_extra_punishment` | COVERED |
| Repeated parry input during PARRYING is ignored | `test_repeated_parry_input_during_parrying_is_ignored` | COVERED |

---

## Dependencies

- Depends on: Story 003 Dodge I-Frames + Hurtbox Adapter
- Unlocks: Story 005 Heavy Charge + Hit Stun + Aerial Hooks
