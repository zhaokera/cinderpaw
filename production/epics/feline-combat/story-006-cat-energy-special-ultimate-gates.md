# Story 006: Cat Energy + Special/Ultimate Gates

> **Epic**: Feline Combat
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/feline-combat.md`
**Requirements**: `TR-combat-007`, `TR-combat-008`, `TR-combat-009`

**ADR Governing Implementation**: ADR-0005: Combat state machine architecture; ADR-0016: Weapon styles architecture
**ADR Decision Summary**: Combat owns cat energy accumulation and consumption. WeaponComponent/SkillTree-specific special behavior is a proposed ADR-0016 extension, so this story implements only the shared gates and safe provider hooks.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Pure GDScript state and timers; no post-cutoff engine APIs required.

**Control Manifest Rules (Core)**:
- Required: Cat energy max 100, no decay, 10 seconds out-of-combat reset to 0.
- Required: Component pattern and testable public methods.
- Forbidden: Never add Combat as an Autoload.
- Guardrail: Combat state transitions <0.1ms/frame.

---

## Acceptance Criteria

- [x] Cat energy starts at 0 and clamps at max 100.
- [x] Cat energy gain table covers: light_0 +5, light_1 +8, light_2 +12, heavy +10, aerial +8, special +3, parry_counter +15, perfect_dodge +15, perfect_parry +20, good_parry +10, damage_taken +3.
- [x] Any damage interaction resets the out-of-combat timer.
- [x] After 10 seconds without damage interaction, cat energy resets to 0.
- [x] Special move gate checks both weapon-specific energy cost and cooldown.
- [x] Ultimate gate requires `has_unlocked_ultimate(weapon_id)` and 80 cat energy.
- [x] Failed gates do not consume cat energy.

## Implementation Notes

- Add public APIs `add_cat_energy_for_event(event_id: StringName)`, `consume_cat_energy(amount: int)`, `can_use_special(weapon_id: StringName)`, and `can_use_ultimate(weapon_id: StringName)`.
- Keep weapon costs/cooldowns as constants or data maps until WeaponComponent data exists.
- Inject a skill/ultimate provider by setter or duck-typed node; if missing, ultimate is locked.
- Use ADR-0016 only as proposed reference; avoid implementing weapon-specific special effects here.

## Out of Scope

- Actual special move execution.
- Weapon upgrade data and WeaponComponent persistence.
- SkillTree implementation.

---

## QA Test Cases

- **AC-1**: Energy gain and clamp
  - Given: Combat starts with 0 cat energy
  - When: each gain event is applied
  - Then: energy increases by the GDD amount and clamps at 100
  - Edge cases: unknown events add 0

- **AC-2**: Out-of-combat reset
  - Given: Combat has cat energy and no new interactions
  - When: 10.01 seconds pass
  - Then: energy resets to 0
  - Edge cases: an interaction at 9.9 seconds resets the timer

- **AC-3**: Special and ultimate gates
  - Given: Combat has different energy amounts and cooldown states
  - When: special or ultimate gates are checked
  - Then: both energy and cooldown/unlock requirements must pass
  - Edge cases: failed checks consume no energy

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/combat/story_006_cat_energy_special_ultimate_gates_test.gd` — must exist and pass

**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first run failed on missing Story 006 cat-energy and special/ultimate gate APIs (`reports/report_151/`).
- Story suite: `res://tests/unit/combat/story_006_cat_energy_special_ultimate_gates_test.gd` — 6/6 passing, report `reports/report_153/`.
- Combat regression: `res://tests/unit/combat` — 35/35 passing, report `reports/report_154/`.
- Full unit regression: `res://tests/unit` — 169/169 passing, report `reports/report_155/`.
- Static checks: `godot --headless --path . --quit`, `git diff --check`, trailing whitespace scan, and method-length quick check passed.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 7/7 passing
**Deviations**: None against the explicit event table. The TR summary says "12种行为", but the current GDD/story table lists 11 event ids; implementation covers every listed id and does not invent a missing 12th event.
**Test Evidence**: `tests/unit/combat/story_006_cat_energy_special_ultimate_gates_test.gd`
**Code Review**: Local automated review complete; QA/LP subagent gates skipped because current tool policy requires explicit user delegation for subagents. Story closure used the user's standing approval for local project writes.

**Traceability**:

| Criterion | Test | Status |
|-----------|------|--------|
| Cat energy starts at 0 and clamps at 100 | `test_cat_energy_starts_at_zero_and_gain_table_clamps_at_max` | COVERED |
| Listed gain table events use GDD values | `test_cat_energy_starts_at_zero_and_gain_table_clamps_at_max` | COVERED |
| Damage interaction resets out-of-combat timer | `test_out_of_combat_timer_resets_on_damage_interaction_and_clears_energy_after_ten_seconds` | COVERED |
| 10 seconds without interaction clears energy | `test_out_of_combat_timer_resets_on_damage_interaction_and_clears_energy_after_ten_seconds` | COVERED |
| Special gate checks energy and cooldown | `test_special_gate_checks_weapon_cost_and_cooldown` | COVERED |
| Ultimate gate checks provider unlock and 80 energy | `test_ultimate_requires_provider_unlock_and_eighty_cat_energy` | COVERED |
| Failed gates do not consume energy | `test_special_gate_failed_energy_check_does_not_consume_energy`, `test_ultimate_failed_energy_check_does_not_consume_energy` | COVERED |

---

## Dependencies

- Depends on: Story 005 Heavy Charge + Hit Stun + Aerial Hooks
- Unlocks: Story 007 Hit Confirmation + Focus Damage Metadata
