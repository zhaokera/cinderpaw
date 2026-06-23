# Story 004: Combo Chain + Conflict Resolution

> **Epic**: Input System
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/input.md`
**Requirements**: `TR-input-003`, `TR-input-006`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication
**ADR Decision Summary**: InputManager can compute input metadata such as combo index and priority, but it must not select combat animations or call CombatComponent.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Pure logic should be unit tested without scene tree dependencies.

**Control Manifest Rules (Foundation)**:
- Required: Foundation layer must contain zero game logic.
- Required: Autoload emits signals; consumers decide combat consequences.
- Forbidden: Never call Core systems from InputManager.

---

## Acceptance Criteria

- [x] Consecutive consumed attack inputs within `combo_chain_window_ms` (default 300ms) increment `combo_counter` from 0 to 1 to 2.
- [x] Attack input after the combo window resets `combo_counter` to 0.
- [x] Emitted attack metadata includes the current `combo_index`.
- [x] Same-frame dodge + attack resolves to dodge only.
- [x] Same-frame parry + dodge resolves to parry only.
- [x] Same-frame dash + jump resolves to dash only.
- [x] Pause has highest priority and is not blocked by other Trigger actions.

---

## Implementation Notes

- Keep priority data in InputManager action metadata, not in combat scripts.
- Conflict resolution should operate on action ids and timestamps only.
- Do not infer weapon style, animation id, or damage from combo_counter.

---

## Out of Scope

- Story 003 handles queue lifecycle and pre-input bonus.
- Feline Combat stories consume `combo_index` to choose animations and attacks.

---

## QA Test Cases

- **AC-1**: Combo chain increment
  - Given: attack is consumed at `1000`
  - When: attack is consumed again at `1250`
  - Then: second metadata has `combo_index=1`
  - Edge cases: third valid attack reaches `combo_index=2`

- **AC-2**: Combo timeout reset
  - Given: attack was consumed at `1000`
  - When: attack is consumed at `1401`
  - Then: metadata has `combo_index=0`
  - Edge cases: exact 300ms boundary follows the GDD formula

- **AC-3**: Mutual exclusion priority
  - Given: dodge and attack share a timestamp
  - When: resolving conflicts
  - Then: only dodge is emitted
  - Edge cases: parry beats dodge, dash beats jump

- **AC-4**: Pause priority
  - Given: pause and any other Trigger share a timestamp
  - When: resolving conflicts
  - Then: pause emits first and is never buffered behind combat actions
  - Edge cases: pause in BUFFERING still emits immediately

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/story_004_combo_conflicts_test.gd` — must exist and pass
**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first run failed because attack `combo_index` stayed at 0, report `reports/report_74/`.
- Story suite: `res://tests/unit/input/story_004_combo_conflicts_test.gd` — 6/6 passing, report `reports/report_76/`.
- Input regression: `res://tests/unit/input` — 22/22 passing, report `reports/report_77/`.
- Data regression: `res://tests/unit/data` — 43/43 passing, report `reports/report_78/`.
- Damage regression: `res://tests/unit/damage` — 24/24 passing, report `reports/report_79/`.
- Static checks: `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods remain under 50 lines.

## Completion Notes

- Added `accept_actions()` as a frame-level trigger candidate resolver for same-frame conflicts.
- Added combo counter state and emitted `combo_index` metadata for consumed `attack` actions.
- Combo increments through 0/1/2 inside `combo_chain_window_ms` and resets after the window.
- Same-frame trigger candidates resolve by InputManager priority, keeping pause as the highest-priority action.

---

## Dependencies

- Depends on: Story 003
- Unlocks: Story 005 Coyote Time + Jump Buffer
