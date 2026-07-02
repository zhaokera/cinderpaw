# Story 002: Light Combo Chain + Cancel Windows

> **Epic**: Feline Combat
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/feline-combat.md`
**Requirements**: `TR-combat-002`, `TR-combat-005`

**ADR Governing Implementation**: ADR-0005: Combat state machine architecture
**ADR Decision Summary**: Combat owns `_combo_index`, a 300ms combo timeout, and explicit cancellation paths. Light combo logic stays inside the FSM rather than in InputManager.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Use frame counters and deterministic helper methods in tests; do not require real animations for timing tests.

**Control Manifest Rules (Core)**:
- Required: 3-segment combo chain with combo_index 0 -> 1 -> 2 and 300ms timeout.
- Required: State transitions run from `_physics_process`.
- Forbidden: Never use State Pattern for combat FSM.
- Guardrail: Combat state transitions <0.1ms/frame.

---

## Acceptance Criteria

- [x] Light attack stages use frame parameters 4+8, 6+12, and 10+20 for startup and recovery.
- [x] Given attack while ATTACKING during valid recovery for stage 0 or 1, Combat advances to the next combo stage.
- [x] Given combo timeout >300ms, the next attack starts again at combo_index 0.
- [x] Given dodge during attack recovery, Combat cancels ATTACKING and enters DODGING.
- [x] Given attack during stage 2 recovery, Combat does not advance to a fourth stage.
- [x] Given dodge during stage 2 recovery, Combat may still cancel into DODGING.

## Implementation Notes

- Store light attack stage data in typed constants or typed arrays inside CombatComponent for this story.
- Add test helpers only if necessary, but keep production methods useful: `get_attack_frame()`, `is_in_attack_recovery()`, `reset_combo()`.
- The GDD says "第1击后摇期间按attack, combo超时未触发, combo_index重置, 播放第1击"; implement this as timeout taking precedence over chain advance.
- InputManager owns combo metadata, but Combat must be deterministic when no metadata is provided.

## Out of Scope

- Story 003: Actual hurtbox i-frame state.
- Story 007: Calling DamageCalculator on hit.

---

## QA Test Cases

- **AC-1**: Stage frame parameters
  - Given: a new CombatComponent
  - When: each light combo stage is started
  - Then: startup and recovery frames match 4+8, 6+12, and 10+20
  - Edge cases: invalid stage indexes clamp or fall back safely

- **AC-2**: Combo advance and timeout
  - Given: stage 0 attack is in recovery
  - When: attack is triggered before timeout
  - Then: combo_index becomes 1
  - Edge cases: after 0.301 seconds, attack resets combo_index to 0

- **AC-3**: Cancel rules
  - Given: Combat is in ATTACKING recovery for stage 0, 1, and 2
  - When: dodge is triggered
  - Then: Combat enters DODGING for all stages
  - Edge cases: attack at stage 2 recovery does not create stage 3

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/combat/story_002_light_combo_cancel_windows_test.gd` — must exist and pass

**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first run failed on missing `get_light_attack_frame_data()`, `advance_attack_frames()`, `advance_combo_time()`, and `start_light_attack_stage()` APIs (`reports/report_133/`).
- Test correction: an edge-case assertion was aligned from "invalid stage always falls back to stage 0" to the story's "clamp or fall back safely"; implementation clamps stage 99 to stage 2.
- Story suite: `res://tests/unit/combat/story_002_light_combo_cancel_windows_test.gd` — 5/5 passing, report `reports/report_135/`.
- Combat regression: `res://tests/unit/combat` — 10/10 passing, report `reports/report_136/`.
- Full unit regression: `res://tests/unit` — 144/144 passing, report `reports/report_137/`.
- Static checks: `godot --headless --path . --quit`, `git diff --check`, trailing whitespace scan, and method-length quick check passed.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 6/6 passing
**Deviations**: None
**Test Evidence**: `tests/unit/combat/story_002_light_combo_cancel_windows_test.gd`
**Code Review**: Local automated review complete; QA/LP subagent gates skipped because current tool policy requires explicit user delegation for subagents.

**Traceability**:

| Criterion | Test | Status |
|-----------|------|--------|
| Light stage frame data | `test_light_attack_stage_frame_data_matches_gdd` | COVERED |
| Attack during recovery advances combo | `test_attack_in_recovery_advances_combo_before_timeout` | COVERED |
| Combo timeout resets to stage 0 | `test_combo_timeout_resets_next_attack_to_stage_zero` | COVERED |
| Dodge cancels recovery for stages 0-2 | `test_dodge_cancels_light_attack_recovery_for_all_stages` | COVERED |
| Stage 2 cannot create a fourth combo stage | `test_stage_two_attack_does_not_create_fourth_combo_stage` | COVERED |

---

## Dependencies

- Depends on: Story 001 Combat State Machine + Input Entry Points
- Unlocks: Story 003 Dodge I-Frames + Hurtbox Adapter
