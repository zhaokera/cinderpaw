# Story 001: HP State + Damage Pipeline

> **Epic**: Health & Death Detection
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/health-death.md`
**Requirements**: `TR-health-001`, `TR-health-002`, `TR-health-003`, `TR-health-011`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0002: Signal communication
**ADR Decision Summary**: HealthComponent is a Core scene component on an entity node, not an Autoload. Health signals must use typed Godot signals and terminal death must emit after state-changing signals.

**Design Reference**: ADR-0019: HealthComponent deep architecture (Proposed)

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Node component pattern and typed signals are stable. Unit tests must instantiate the component directly without requiring gameplay scenes.

**Control Manifest Rules (Core)**:
- Required: Core systems are scene components mounted on entity nodes, not Autoloads.
- Required: Signal emission order must be state change -> conditional signals -> terminal signal.
- Forbidden: Never add Core game logic to Foundation Autoloads.
- Guardrail: Core state transitions should stay below 0.1ms/frame.

---

## Acceptance Criteria

- [x] `HealthComponent` exists at `res://src/core/health_component.gd` and exposes typed HP/shield query APIs.
- [x] Basic damage subtracts HP and emits `on_hp_changed(entity_id, current_hp, max_hp)`.
- [x] Shield absorbs damage first using `shield_absorbed = min(shield, incoming)`, then remaining damage subtracts HP.
- [x] Overkill damage clamps HP to 0 and emits `on_death(entity_id, metadata)` once.
- [x] DYING/DEAD state, zero damage, and negative damage are ignored without HP or signal changes.
- [x] For lethal damage, `on_hp_changed` emits before `on_death`.

---

## Implementation Notes

- Use `extends Node` and `class_name HealthComponent`.
- Keep all state local to the component instance.
- Public setup helpers are allowed for tests and data-driven initialization: `configure(entity_id, max_hp, current_hp, shield, max_shield)`.
- This story only implements `on_hp_changed` and `on_death`; milestone, phase, focus, zone, and metadata expansion are later stories.
- Death metadata may be a duplicated Dictionary passthrough in this story.

---

## Out of Scope

- Story 002: HP milestones and Boss phase transition signals.
- Story 003: i-frame ticking, healing, save-point recovery, and revive.
- Story 004: low-HP focus mode and active enemy gating.
- Story 005: full death metadata and zone death signal.
- Story 006: max HP aggregation and serialization.

---

## QA Test Cases

- **AC-1**: HP state setup and queries
  - Given: a new HealthComponent configured with current_hp=80, max_hp=100, shield=10, max_shield=20
  - When: querying current HP, max HP, shield, life state, and percentages
  - Then: values match configuration and the entity is alive
  - Edge cases: max_hp <= 0 falls back safely to 100

- **AC-2**: Basic damage and HP signal
  - Given: current_hp=100 and max_hp=100
  - When: applying 30 damage
  - Then: current_hp becomes 70 and `on_hp_changed(entity_id, 70, 100)` emits once
  - Edge cases: metadata is not mutated by the component

- **AC-3**: Shield absorption
  - Given: current_hp=80, shield=20, max_shield=20
  - When: applying 50 damage
  - Then: shield becomes 0 and current_hp becomes 50
  - Edge cases: damage fully absorbed by shield leaves HP unchanged but still emits HP/shield state change once

- **AC-4**: Lethal damage and death guard
  - Given: current_hp=10
  - When: applying 15 damage, then another 15 damage
  - Then: current_hp clamps to 0, `on_death` emits once, and subsequent damage is ignored
  - Edge cases: `is_dead()` and `is_alive()` reflect terminal state

- **AC-5**: Non-positive damage guard
  - Given: current_hp=50
  - When: applying 0 or -5 damage
  - Then: HP is unchanged and no signals emit
  - Edge cases: negative values do not heal

- **AC-6**: Lethal signal order
  - Given: current_hp=10
  - When: applying 15 damage
  - Then: `on_hp_changed` is recorded before `on_death`
  - Edge cases: no milestone/focus/phase signals are emitted in this story

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/health/story_001_hp_damage_pipeline_test.gd` — must exist and pass
**Status**: [x] Created and passing

**Evidence**:
- Red: missing `res://src/core/health_component.gd` script caused the first Story 001 test run to fail.
- Red: initial shell implementation failed on missing `configure()` and query/damage APIs (`reports/report_91/`).
- Green: Story 001 suite passed 7/7 (`reports/report_92/`).
- Clean sequential health regression passed 7/7 (`reports/report_95/`).
- Regression: full `tests/unit/input` passed 34/34 (`reports/report_96/`).
- Regression: full `tests/unit/data` passed 43/43 (`reports/report_97/`); expected negative schema/version tests emitted warnings/errors while passing.
- Regression: full `tests/unit/damage` passed 24/24 (`reports/report_98/`).
- Static checks: `godot --headless --path . --quit` passed; `git diff --check` passed; changed GDScript methods are under 50 lines.

**Completion Notes**:
- Implemented local Core `HealthComponent` state for HP, max HP, shield, max shield, and alive/dying/dead queries.
- Implemented damage guards for dead/dying state and non-positive damage.
- Implemented shield-first damage absorption, HP clamp to zero, single terminal death signal, and lethal signal order (`on_hp_changed` before `on_death`).
- Deferred milestones, boss phases, i-frames, healing, revive, focus mode, and expanded death metadata to later Health/Death stories as planned.

---

## Dependencies

- Depends on: Damage Calculation Story 004 complete
- Unlocks: Story 002 HP Milestones + Boss Phase Gates
