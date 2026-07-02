# Story 003: Buffer Queue + Pre-input

> **Epic**: Input System
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/input.md`
**Requirement**: `TR-input-002`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0003: Data management
**ADR Decision Summary**: InputManager owns the input buffer internally, while buffer timing and queue limits use registered tuning values.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Use `Time.get_ticks_msec()` or injected timestamps; do not use deprecated `OS.get_ticks_msec()`.

**Control Manifest Rules (Foundation)**:
- Required: Tuning values come from DataManager when available.
- Forbidden: Never put Core animation or combat logic in InputManager.
- Guardrail: Input buffer processing must stay below signal/autoload frame budgets.

---

## Acceptance Criteria

- [x] Trigger inputs received during BUFFERING are stored for up to `buffer_window_ms` (default 150ms).
- [x] Buffer queue depth is capped by `buffer_queue_size` (default 3).
- [x] When a fourth buffered input arrives, the oldest entry is discarded and the newest is kept.
- [x] Inputs pressed within `pre_input_window_ms` before animation end are marked `is_pre_input=true` and receive `priority_pre_input_bonus` (default +20).
- [x] `notify_animation_unlock()` consumes the highest priority valid buffered input within one frame.
- [x] `clear_buffer()` removes all buffered entries and prevents later consumption.

---

## Implementation Notes

- Use deterministic timestamp arguments in private/test helper paths.
- Expired entries must be pruned before selecting a buffered action.
- Queue entries should be typed Dictionaries or a small typed RefCounted class if metadata grows beyond a simple structure.

---

## Out of Scope

- Story 004 handles combo_counter and mutual exclusion conflict rules.
- Story 005 handles jump-specific coyote/jump buffering.

---

## QA Test Cases

- **AC-1**: 150ms buffer expiry
  - Given: BUFFERING mode and a buffered dodge at `1000`
  - When: unlock happens at `1149`
  - Then: dodge is consumed
  - Edge cases: unlock at `1151` expires the input

- **AC-2**: Queue depth
  - Given: three buffered entries
  - When: a fourth Trigger action arrives
  - Then: the oldest entry is discarded
  - Edge cases: duplicate action keeps the latest timestamp

- **AC-3**: Pre-input priority
  - Given: animation ends at `1200`
  - When: attack is pressed at `1160`
  - Then: metadata marks `is_pre_input=true` and priority includes +20
  - Edge cases: press at `1140` is not pre-input with a 50ms window

- **AC-4**: Clear buffer
  - Given: buffered actions exist
  - When: `clear_buffer()` is called
  - Then: unlock emits nothing from the old buffer
  - Edge cases: clear_buffer is safe when buffer is empty

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/story_003_buffer_queue_preinput_test.gd` — must exist and pass
**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first run failed because BUFFERING `accept_action()` returned false and unlock did not consume a buffered input, report `reports/report_69/`.
- Story suite: `res://tests/unit/input/story_003_buffer_queue_preinput_test.gd` — 6/6 passing, report `reports/report_70/`.
- Input regression: `res://tests/unit/input` — 16/16 passing, report `reports/report_71/`.
- Data regression: `res://tests/unit/data` — 43/43 passing, report `reports/report_72/`.
- Damage regression: `res://tests/unit/damage` — 24/24 passing, report `reports/report_73/`.
- Static checks: `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods remain under 50 lines.

## Completion Notes

- Added deterministic buffered input queue APIs and snapshot accessors for diagnostics/tests.
- `accept_action()` now stores bufferable trigger actions during BUFFERING and keeps `pause` immediate.
- `notify_animation_unlock()` prunes expired entries, applies pre-input priority bonus, consumes the highest priority valid entry, and emits deterministic metadata.
- `clear_buffer()` removes pending entries and prevents old buffered actions from being emitted after unlock.

---

## Dependencies

- Depends on: Story 002
- Unlocks: Story 004 Combo Chain + Conflict Resolution
