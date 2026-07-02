# Story 002: Direct Dispatch + FSM Signals

> **Epic**: Input System
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/input.md`
**Requirements**: `TR-input-007`, `TR-input-008`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication
**ADR Decision Summary**: InputManager emits signals to consumers and never calls Core systems directly. Simple signals with <=3 fields use direct parameters.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Typed signal syntax is stable; use `signal.connect(callable)` in tests and code.

**Control Manifest Rules (Foundation)**:
- Required: Autoload -> Component communication only through signals.
- Required: Signal payload <=3 fields may be direct parameters.
- Forbidden: Never use EventBus or string-based connect.
- Guardrail: Signal overhead <0.1ms/frame.

---

## Acceptance Criteria

- [x] InputManager exposes DIRECT, BUFFERING, and TRANSITIONING states.
- [x] In DIRECT mode, a Trigger action such as attack emits `action_triggered(action_id, metadata)` on the same frame it is accepted.
- [x] `notify_animation_lock(duration_ms)` moves trigger handling into BUFFERING mode.
- [x] `notify_animation_unlock()` returns to DIRECT mode after pending dispatch rules are evaluated.
- [x] Pause is always accepted immediately from any state, including BUFFERING.
- [x] `action_triggered` metadata includes combo_index, is_pre_input, buffer_delay_ms, and source_device keys.

---

## Implementation Notes

- Use test-facing methods to accept injected actions/timestamps so unit tests do not depend on real input events.
- Do not reference animation players, combat components, or player state. Animation lock is represented only by timing values supplied by callers.
- Keep metadata a Dictionary because ADR-0002 allows <=3 direct signal fields and the GDD defines metadata as a dictionary parameter.

---

## Out of Scope

- Story 003 handles queue expiry, queue depth, pre-input priority, and clear_buffer.
- Story 004 handles combo increment and conflict selection.

---

## QA Test Cases

- **AC-1**: Direct same-frame dispatch
  - Given: InputManager is in DIRECT mode
  - When: attack is accepted at time `1000`
  - Then: `action_triggered` emits immediately with action `attack`
  - Edge cases: Continuous move actions do not emit trigger events

- **AC-2**: Lock and unlock FSM transitions
  - Given: InputManager is DIRECT
  - When: `notify_animation_lock(200)` is called
  - Then: state becomes BUFFERING
  - Edge cases: zero or negative lock duration returns DIRECT safely

- **AC-3**: Pause immediate
  - Given: InputManager is BUFFERING
  - When: pause is accepted
  - Then: pause emits immediately without waiting for unlock
  - Edge cases: pause and attack in the same timestamp still emits pause first

- **AC-4**: Metadata contract
  - Given: any emitted Trigger action
  - When: inspecting metadata
  - Then: combo_index, is_pre_input, buffer_delay_ms, and source_device keys exist
  - Edge cases: defaults are deterministic for non-combat actions

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/story_002_direct_dispatch_fsm_test.gd` — must exist and pass
**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first run failed on missing `get_input_state()`, `notify_animation_lock()`, `notify_animation_unlock()`, and `accept_action()`.
- Story suite: `res://tests/unit/input/story_002_direct_dispatch_fsm_test.gd` — 5/5 passing, report `reports/report_65/`.
- Input regression: `res://tests/unit/input` — 10/10 passing, report `reports/report_66/`.
- Data regression: `res://tests/unit/data` — 43/43 passing, report `reports/report_67/`.
- Damage regression: `res://tests/unit/damage` — 24/24 passing, report `reports/report_68/`.

## Completion Notes

- Added DIRECT/BUFFERING/TRANSITIONING state tracking to InputManager.
- Added `accept_action()`, `notify_animation_lock()`, `notify_animation_unlock()`, and `get_input_state()`.
- `action_triggered` emits deterministic metadata with combo_index, is_pre_input, buffer_delay_ms, source_device, and timestamp_ms.
- Buffer queue consumption remains intentionally out of scope for Story 003.

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003 Buffer Queue + Pre-input
