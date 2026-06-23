# Story 003: Dodge I-Frames + Hurtbox Adapter

> **Epic**: Feline Combat
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/feline-combat.md`
**Requirement**: `TR-combat-003`

**ADR Governing Implementation**: ADR-0004: Collision detection architecture; ADR-0005: Combat state machine architecture
**ADR Decision Summary**: Combat controls dodge timing; CollisionComponent owns the actual Hurtbox state. Combat should call a narrow adapter method and stay testable without physics nodes.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Area2D APIs belong to CollisionComponent. This story should verify the adapter call contract, not full physics overlap behavior.

**Control Manifest Rules (Core)**:
- Required: Dodge i-frames active during frames 3-10.
- Required: Hurtbox has normal/shrunk/gone states through CollisionComponent.
- Forbidden: Never use PhysicsBody for hit detection.
- Guardrail: Collision detection <3ms/frame; Combat transitions <0.1ms/frame.

---

## Acceptance Criteria

- [x] Dodge starts from IDLE and eligible attack recovery states.
- [x] Dodge i-frame window is active on frames 3 through 10 inclusive.
- [x] Combat calls the hurtbox adapter with `"gone"` during active i-frame frames and `"normal"` after dodge ends.
- [x] Given enemy damage arrives during i-frame, Combat exposes an invulnerable/dodging state that Health can treat as zero damage.
- [x] Given consecutive dodge input before 0.5s cooldown expires, Combat ignores the second dodge.
- [x] Given airborne metadata, Combat rejects dodge input.
- [x] Cat claw dodge end opens `dodge_counter_window` for 30 frames and emits `on_dodge_counter_active(true/false)`.

## Implementation Notes

- Keep the collision dependency injected or duck-typed: call `set_hurtbox_state(entity, state)` or `set_hurtbox_state(state)` only when the adapter exists.
- Store `DODGE_IFRAME_START = 3`, `DODGE_IFRAME_END = 10`, `DODGE_COOLDOWN_SEC = 0.5`, and `DODGE_COUNTER_WINDOW_FRAMES = 30`.
- Add `is_dodge_iframe_active()` for tests and Health integration.
- Airborne logic may be metadata-based until PlayerMovement exists.

## Out of Scope

- Actual movement displacement and animation playback.
- Full CollisionComponent implementation.

---

## QA Test Cases

- **AC-1**: I-frame window
  - Given: Combat is DODGING
  - When: dodge frames 1 through 12 are advanced
  - Then: frames 3-10 return i-frame active and other frames do not
  - Edge cases: frame boundaries 2/3 and 10/11 are asserted explicitly

- **AC-2**: Hurtbox adapter calls
  - Given: a fake hurtbox adapter records states
  - When: dodge advances through active and end frames
  - Then: `"gone"` is requested during i-frames and `"normal"` when dodge completes
  - Edge cases: missing adapter does not crash

- **AC-3**: Cooldown and airborne rejection
  - Given: dodge just completed
  - When: dodge is triggered before 0.5s cooldown
  - Then: the input is ignored
  - Edge cases: airborne metadata rejects dodge even when cooldown is ready

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/combat/story_003_dodge_iframes_hurtbox_adapter_test.gd` — must exist and pass

**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first run failed on missing dodge i-frame, hurtbox adapter, cooldown, and dodge counter APIs (`reports/report_138/`).
- Story suite: `res://tests/unit/combat/story_003_dodge_iframes_hurtbox_adapter_test.gd` — 6/6 passing, report `reports/report_139/`.
- Combat regression: `res://tests/unit/combat` — 16/16 passing, report `reports/report_140/`.
- Full unit regression: `res://tests/unit` — 150/150 passing, report `reports/report_141/`.
- Static checks: `godot --headless --path . --quit`, `git diff --check`, trailing whitespace scan, and method-length quick check passed.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 7/7 passing
**Deviations**: None
**Test Evidence**: `tests/unit/combat/story_003_dodge_iframes_hurtbox_adapter_test.gd`
**Code Review**: Local automated review complete; QA/LP subagent gates skipped because current tool policy requires explicit user delegation for subagents.

**Traceability**:

| Criterion | Test | Status |
|-----------|------|--------|
| Dodge starts from IDLE and attack recovery | `test_dodge_starts_from_idle_and_attack_recovery` | COVERED |
| I-frame boundaries are frames 3-10 | `test_dodge_iframe_boundaries_are_frames_three_through_ten` | COVERED |
| Hurtbox adapter receives gone/normal | `test_hurtbox_adapter_receives_gone_during_iframe_and_normal_on_end` | COVERED |
| Health can query dodge invulnerability | `test_dodge_iframe_exposes_invulnerability_for_health_integration` | COVERED |
| Cooldown blocks repeated dodge | `test_dodge_cooldown_and_airborne_rejection` | COVERED |
| Airborne metadata rejects dodge | `test_dodge_cooldown_and_airborne_rejection` | COVERED |
| Cat claw dodge counter window emits true/false | `test_cat_claw_dodge_end_opens_and_closes_counter_window` | COVERED |

---

## Dependencies

- Depends on: Story 002 Light Combo Chain + Cancel Windows
- Unlocks: Story 004 Parry Timing Windows + Counter Outcome
