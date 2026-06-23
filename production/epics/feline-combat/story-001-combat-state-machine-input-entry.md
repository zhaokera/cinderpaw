# Story 001: Combat State Machine + Input Entry Points

> **Epic**: Feline Combat
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/feline-combat.md`
**Requirements**: `TR-combat-001`, `TR-combat-006`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication; ADR-0005: Combat state machine architecture
**ADR Decision Summary**: CombatComponent is a per-entity Core component. It uses a 6-state enum + match FSM and consumes normalized action input without becoming an Autoload.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: AnimationPlayer API is stable; this story should keep animation dependencies optional so unit tests do not need a complete scene.

**Control Manifest Rules (Core)**:
- Required: Core layer systems are scene components, not Autoloads.
- Required: 6-state combat state machine IDLE / ATTACKING / DODGING / PARRYING / HIT_STUN / CHARGING.
- Required: State transitions run from `_physics_process`.
- Forbidden: Do not use AnimationTree or State Pattern for this 6-state FSM.
- Guardrail: Combat state transitions <0.1ms/frame.

---

## Acceptance Criteria

*From GDD `design/gdd/feline-combat.md`, scoped to this story:*

- [x] `CombatComponent` exists at `res://src/core/combat_component.gd` and can be instantiated without a full Player scene.
- [x] `CombatState` exposes IDLE, ATTACKING, DODGING, PARRYING, HIT_STUN, and CHARGING.
- [x] Given action `attack` while IDLE, Combat enters ATTACKING and starts combo stage 0.
- [x] Given action `dodge` while IDLE, Combat enters DODGING.
- [x] Given action `parry` while IDLE, Combat enters PARRYING.
- [x] Given action `heavy_attack` with pressed metadata while IDLE, Combat enters CHARGING.
- [x] Public query APIs exist and are typed: `get_current_state()`, `get_combo_index()`, `get_cat_energy()`, `is_focus_mode_active()`, `get_battle_stats()`.
- [x] `on_state_changed(old_state, new_state)` emits after successful state transitions.

## Implementation Notes

*Derived from ADR-0005 Implementation Guidelines:*

- Implement `extends Node` and `class_name CombatComponent`.
- Use enum + match; keep `_change_state(new_state)` as the single transition path.
- Add `on_action_triggered(action_id: StringName, metadata: Dictionary = {}) -> void` as the testable entry point for InputManager signal consumption.
- Keep animation calls behind optional methods or node lookups; tests should pass when no `AnimationPlayer` child exists.
- Notify input locking through optional callables or duck-typed methods only when injected. Do not hard-reference the InputManager singleton from Core tests.

## Out of Scope

- Story 002: Combo chain frame parameters and cancel windows.
- Story 003: Dodge i-frame and hurtbox state integration.
- Story 004: Parry timing result and counter outcome.
- Story 005: Heavy release, hit-stun stacking, and aerial bounce.
- Story 006: Cat energy and special move gates.
- Story 007: Damage calculation and hit-confirmation metadata.

---

## QA Test Cases

- **AC-1**: Component instantiation
  - Given: a GdUnit4 test creates `CombatComponent.new()`
  - When: it is added to a test node and processed once
  - Then: the component remains in IDLE and exposes typed public query APIs
  - Edge cases: missing AnimationPlayer and missing InputManager must not crash

- **AC-2**: Base action transitions
  - Given: Combat starts in IDLE
  - When: `on_action_triggered()` receives `attack`, `dodge`, `parry`, and pressed `heavy_attack` on fresh instances
  - Then: the resulting states are ATTACKING, DODGING, PARRYING, and CHARGING
  - Edge cases: unknown actions are ignored and keep the current state

- **AC-3**: State changed signal
  - Given: a connected listener records `on_state_changed`
  - When: Combat changes from IDLE to ATTACKING
  - Then: exactly one signal is emitted with old=IDLE and new=ATTACKING
  - Edge cases: no signal is emitted when an ignored action keeps the state unchanged

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/combat/story_001_combat_state_machine_input_entry_test.gd` — must exist and pass

**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first run failed because `res://src/core/combat_component.gd` did not exist, and the test could not resolve `CombatComponent`.
- Debug note: after adding `class_name CombatComponent`, headless GdUnit still could not resolve the new global class during test-file parsing. The test now follows the existing DamageCalculator pattern and references `COMBAT_COMPONENT_SCRIPT.CombatState` from the preloaded script.
- Story suite: `res://tests/unit/combat/story_001_combat_state_machine_input_entry_test.gd` — 5/5 passing, report `reports/report_131/`.
- Full unit regression: `res://tests/unit` — 139/139 passing, report `reports/report_132/`.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 8/8 passing
**Deviations**: None
**Test Evidence**: `tests/unit/combat/story_001_combat_state_machine_input_entry_test.gd`
**Code Review**: Local automated review complete; QA/LP subagent gates skipped because current tool policy requires explicit user delegation for subagents.

**Traceability**:

| Criterion | Test | Status |
|-----------|------|--------|
| Component instantiates and query APIs default safely | `test_component_instantiates_with_idle_defaults` | COVERED |
| Attack enters ATTACKING stage 0 | `test_attack_from_idle_enters_attacking_and_stage_zero` | COVERED |
| Dodge, parry, heavy enter base states | `test_defensive_and_heavy_actions_enter_base_states` | COVERED |
| Unknown action ignored | `test_unknown_action_is_ignored` | COVERED |
| State changed signal emits once | `test_state_changed_signal_emits_once_for_valid_transition` | COVERED |

---

## Dependencies

- Depends on: InputManager Story 002 Direct Dispatch + FSM Signals complete
- Unlocks: Story 002 Light Combo Chain + Cancel Windows
