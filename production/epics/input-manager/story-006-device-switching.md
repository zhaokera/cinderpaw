# Story 006: Device Detection + Debounced Switching

> **Epic**: Input System
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/input.md`
**Requirements**: `TR-input-005`, `TR-input-009`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication
**ADR Decision Summary**: InputManager owns device detection and emits `device_changed(old, new)`; HUD and UI listen to the signal instead of being called directly.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: SDL3 gamepad handling is noted in Godot 4.6 engine reference; validate with injected InputEvent tests and headless-safe logic.

**Control Manifest Rules (Foundation)**:
- Required: Autoload -> HUD communication only through signals.
- Required: Signal payload <=3 fields can use direct parameters.
- Forbidden: InputManager must not reference HUD/UI scenes.
- Guardrail: Device detection must not add measurable per-frame overhead.

---

## Acceptance Criteria

- [x] InputManager classifies input sources as `gamepad`, `kbm`, or `touch`.
- [x] Device switching uses `device_switch_debounce_ms` (default 500ms).
- [x] Gamepad has priority over kbm, and kbm has priority over touch when competing within debounce logic.
- [x] `device_changed(old, new)` emits only after a valid switch.
- [x] During combat lock, device icon switching is suppressed and current mapping is preserved.
- [x] Gamepad disconnect during Boss combat does not switch away from the current mapping.

---

## Implementation Notes

- Provide an event ingestion method that accepts `InputEvent` for production and synthetic tests.
- Combat lock must be represented as an InputManager state flag set by callers; do not reference boss or combat classes.
- HUD update behavior is out of scope; only signal contract is implemented here.

---

## Out of Scope

- Actual UI icon rendering and animation.
- Mobile touch layout sizing and placement.

---

## QA Test Cases

- **AC-1**: Debounced switch
  - Given: current device is gamepad and a mouse event arrives
  - When: the event is within 500ms of the last switch
  - Then: current device remains gamepad and no signal emits
  - Edge cases: after 501ms, switch is allowed if not combat-locked

- **AC-2**: Signal contract
  - Given: current device is kbm
  - When: a valid gamepad event arrives outside debounce
  - Then: `device_changed(kbm, gamepad)` emits once
  - Edge cases: repeated same-device events emit nothing

- **AC-3**: Combat suppression
  - Given: combat input lock is active
  - When: a competing device event or disconnect event arrives
  - Then: current device is preserved
  - Edge cases: unlocking combat allows future switches

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/unit/input/story_006_device_switching_test.gd` — must exist and pass
**Status**: [x] Created and passing

**Evidence**:
- TDD red: `tests/unit/input/story_006_device_switching_test.gd` failed on missing device switching APIs (`reports/report_85/`).
- Story suite: 7/7 passing (`reports/report_86/`).
- Input regression: 34/34 passing (`reports/report_88/`).
- Data regression: 43/43 passing (`reports/report_89/`).
- Damage regression: 24/24 passing (`reports/report_90/`).
- Static checks: `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 50 lines.

---

## Completion Notes

- Added headless-safe event classification for gamepad, keyboard/mouse, and touch `InputEvent` families.
- Added dominant-device state, debounced event ingestion, and priority handling for competing devices.
- Added combat input lock APIs so callers can suppress prompt switching without InputManager referencing combat, boss, HUD, or UI nodes.
- Added explicit gamepad disconnect notification handling; combat lock preserves the current mapping and emits no device switch.

---

## Dependencies

- Depends on: Story 001
- Unlocks: HUD input prompt integration
