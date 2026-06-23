# Story 001: InputManager Action Abstraction + Query API

> **Epic**: Input System
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/input.md`
**Requirements**: `TR-input-001`, `TR-input-011`, `TR-input-012`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0003: Data management
**ADR Decision Summary**: InputManager is Autoload #2 after DataManager and must stay Foundation-only. Input tuning knobs are registered through DataManager's TuningKnobRegistry.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Autoload API is stable; verify `project.godot` initializes DataManager before InputManager.

**Control Manifest Rules (Foundation)**:
- Required: DataManager #1, InputManager #2, exact Autoload order.
- Required: Foundation layer must contain zero game logic.
- Required: TuningKnobRegistry uses debug override > JSON > registered default.
- Forbidden: Never add more than 5 Autoloads; never put Core game logic in InputManager.
- Guardrail: Autoload initialization total <1 second.

---

## Acceptance Criteria

- [x] InputManager exists at `res://src/foundation/input_manager.gd` and is registered as Autoload #2 after DataManager.
- [x] The 12 core actions are normalized as `StringName` actions: move_left/right/up/down, jump, dash, attack, heavy_attack, dodge, parry, interact, pause.
- [x] Trigger and Continuous action metadata is available without referencing Core systems.
- [x] `is_action_pressed()`, `is_action_just_pressed()`, `get_action_strength()`, `get_action_duration()`, and `clear_buffer()` public APIs exist and are typed.
- [x] The 8 input tuning knobs are registered with DataManager: buffer_window_ms, buffer_queue_size, pre_input_window_ms, combo_chain_window_ms, coyote_frames, jump_buffer_frames, device_switch_debounce_ms, priority_pre_input_bonus.
- [x] Missing DataManager or unregistered tuning knobs degrade to deterministic defaults without crashing unit tests.

---

## Implementation Notes

- Use `extends Node` and register the script as the `InputManager` Autoload.
- Do not use `class_name InputManager`; Godot 4.6 reports that this hides the same-named Autoload singleton.
- Register as `InputManager="*res://src/foundation/input_manager.gd"` directly after DataManager in `project.godot`.
- Add no references to Player, CombatComponent, HealthComponent, HUD, or scenes.
- Use `Input` singleton only behind public query wrappers so tests can verify API behavior without depending on gameplay scenes.
- Keep action metadata data-driven inside the Foundation system; do not encode combat outcomes.

---

## Out of Scope

- Story 002: Direct dispatch, FSM, and `action_triggered` signal behavior.
- Story 003: Buffer queue, pre-input, and clear-on-knockback behavior.
- Story 004: Combo chain and conflict resolution.
- Story 005: Coyote Time and Jump Buffer.
- Story 006: Device detection and `device_changed` signal.
- Story 007: Key rebinding persistence, deferred to Polish.

---

## QA Test Cases

- **AC-1**: InputManager Autoload order
  - Given: `project.godot`
  - When: reading the `[autoload]` section
  - Then: DataManager appears before InputManager and InputManager points to `res://src/foundation/input_manager.gd`
  - Edge cases: missing DataManager must fail the test

- **AC-2**: Action abstraction
  - Given: a new InputManager instance
  - When: querying supported actions and action metadata
  - Then: all 12 actions exist, Trigger actions are bufferable as designed, and Continuous movement actions are not bufferable
  - Edge cases: unknown actions return safe defaults

- **AC-3**: Query API surface
  - Given: a new InputManager instance
  - When: calling each public query method with a known and unknown action
  - Then: calls return typed values and never crash
  - Edge cases: unknown action strength is `0.0`

- **AC-4**: Tuning knob registration
  - Given: a DataManager instance
  - When: InputManager registers tuning knobs
  - Then: all 8 knob ids return their default values through DataManager
  - Edge cases: null DataManager uses InputManager defaults

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/unit/input/story_001_action_abstraction_test.gd` — must exist and pass
**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first run failed because `res://src/foundation/input_manager.gd` did not exist.
- Implementation correction: `class_name InputManager` was removed after Godot reported it hides the `InputManager` Autoload singleton.
- Story suite: `res://tests/unit/input/story_001_action_abstraction_test.gd` — 5/5 passing, report `reports/report_60/`.
- Input regression: `res://tests/unit/input` — 5/5 passing, report `reports/report_61/`.
- Data regression: `res://tests/unit/data` — 43/43 passing, report `reports/report_62/`.
- Damage regression: `res://tests/unit/damage` — 24/24 passing, report `reports/report_63/`.

## Completion Notes

- Added `src/foundation/input_manager.gd` as Autoload #2 after DataManager.
- Added the missing `dash`, `heavy_attack`, and `parry` InputMap actions, and aligned `dodge` with the GDD default key.
- Added input tuning defaults to `data/tuning_knobs.json` and `data/schemas/tuning_knobs.schema.json`.

---

## Dependencies

- Depends on: Data/Balance Infrastructure Story 005 TuningKnobRegistry complete
- Unlocks: Story 002 Direct Dispatch + FSM Signals
