# Story 001: FormulaPipeline + DamageResult 核心公式

> **Epic**: Damage Calculation
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/damage-calculation.md`
**Requirements**: `TR-damage-001`, `TR-damage-005`, `TR-damage-006`, `TR-damage-008`

**ADR Governing Implementation**: ADR-0001: Autoload 架构; ADR-0002: 信号通信
**ADR Decision Summary**: DamageCalculator 是 `class_name` 静态工具类，不能做 Autoload。DamageResult 使用 `class_name` 数据类封装 final_damage 和 metadata。

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: 不使用 post-cutoff API；所有参数与返回值必须显式类型化。

**Control Manifest Rules (Foundation)**:
- Required: DamageCalculator is `class_name` static utility, not Autoload.
- Required: Signal/payload data with >3 fields uses `class_name` data class.
- Forbidden: Foundation layer must not reference Core/Feature systems.
- Guardrail: All public methods must be unit-testable.

---

## Acceptance Criteria

*From GDD `design/gdd/damage-calculation.md`, scoped to this story:*

- [x] AC1: weapon_base=10, attack_power=0, attack_type=normal, defense=0 yields base_damage=10, reduction_factor=1.0, final_damage=10.
- [x] AC8: defense=20 yields reduction_factor=60/(20+60)=0.75 and final_damage=7 for base attack_damage=10.
- [x] AC9: defense=50 yields reduction_factor≈0.545 and final_damage=5 for attack_damage=10.
- [x] AC12: attack_damage=100, reduction_factor=0.5, damage_multiplier=1.0 yields final_damage=50.
- [x] AC13: very high defense clamps final_damage floor to 1.
- [x] AC14: attack_damage=2000, reduction_factor=1.0 clamps final_damage cap to 999.
- [x] AC15: attack_damage=100, reduction_factor=0.75, damage_multiplier=1.5 yields final_damage=112.
- [x] AC16: damage_multiplier amplification still respects damage_cap=999.
- [x] DamageResult exposes typed metadata fields: `is_crit`, `crit_type`, `is_parry`, `parry_type`, `combo_stage`, `damage_category`.

---

## Implementation Notes

- Create `src/foundation/damage_result.gd` with `class_name DamageResult`, extending `RefCounted`.
- Create `src/foundation/damage_calculator.gd` with `class_name DamageCalculator`, extending `RefCounted`, using only static methods.
- Implement pure helpers for DC-F1, DC-F3, DC-F4, and damage category classification.
- Use GDScript typed parameters and returns throughout.
- Keep balance values parameterized in method arguments for this story; DataManager integration is Story 004.

---

## Out of Scope

- Story 002 handles crit, combo, and parry multiplier paths.
- Story 003 handles special moves, skill modifiers, charm/focus crit window expansion, and attack_type multipliers.
- Story 004 handles DataManager `damage_params` integration and public API defaults.

---

## QA Test Cases

- **AC1**: full baseline formula
  - Given: weapon_base=10, attack_power=0, attack_damage path multiplier=1.0, defense=0
  - When: calculating baseline damage
  - Then: final_damage is 10
  - Edge cases: attack_power=0 remains valid

- **AC8/AC9**: defense reduction curve
  - Given: attack_damage=10 with defense=20 and defense=50
  - When: computing reduction and final damage
  - Then: results are 7 and 5 respectively
  - Edge cases: negative defense clamps to 0

- **AC12-AC16**: final damage clamp and multiplier
  - Given: direct attack_damage/reduction/multiplier combinations from the GDD
  - When: applying DC-F4
  - Then: exact integer floor and clamp results match 50, 1, 999, 112, 999
  - Edge cases: floor happens before clamp

- **DamageResult metadata defaults**
  - Given: a baseline non-crit, non-parry result
  - When: reading metadata fields
  - Then: fields are typed and default to none/false/0 with correct damage_category
  - Edge cases: category thresholds 1, 5, 6, 15, 16, 30, 31, 60, 61, 150, 151

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/damage/story_001_formula_pipeline_test.gd` — must exist and pass
**Status**: [x] Created (6 test functions covering AC1, AC8-AC9, AC12-AC16, DamageResult metadata, and category thresholds)
**Note**: GdUnit4 Story 001 damage suite passes 6/6; combined `tests/unit/data` + `tests/unit/damage` passes 54/54 as of 2026-06-23.

---

## Dependencies

- Depends on: Data/Balance Infrastructure stories 001-006 COMPLETE
- Unlocks: Story 002, Story 004

---

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 9/9 scoped checks covered
**Code Review**: Complete — local review passed against ADR-0001, ADR-0002, the Foundation control manifest, GDD `TR-damage-001`, `TR-damage-005`, `TR-damage-006`, `TR-damage-008`, and passing GdUnit evidence. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool.
**Deviations**: `calculate_basic_damage()` returns `RefCounted` rather than a direct `DamageResult` return type because the headless GdUnit scan does not always register newly added `class_name` types before parsing dependent scripts. The returned object is still created from `damage_result.gd` and exposes the required typed fields.
**Test Evidence**: Logic — `tests/unit/damage/story_001_formula_pipeline_test.gd` (6 functions)
**Next**: Story 003 — `production/epics/damage-calculator/story-003-special-modifiers.md`
