# Story 002: CritComboParry 倍率路径

> **Epic**: Damage Calculation
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/damage-calculation.md`
**Requirements**: `TR-damage-002`, `TR-damage-003`, `TR-damage-004`

**ADR Governing Implementation**: ADR-0001: Autoload 架构; ADR-0002: 信号通信
**ADR Decision Summary**: DamageCalculator stays pure and stateless. DamageResult metadata reports crit/parry/combo state for downstream presentation and audio systems.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Use typed `StringName` values for crit/parry labels.

**Control Manifest Rules (Foundation)**:
- Required: DamageCalculator is `class_name` static utility, not Autoload.
- Forbidden: Foundation layer must not call Core/Feature systems.
- Guardrail: All multiplier helpers must be unit-testable in isolation.

---

## Acceptance Criteria

- [x] AC2: PERFECT crit at hit_frame=2 applies 2.5x and final_damage=25.
- [x] AC3: GOOD crit at hit_frame=4 applies 1.8x and final_damage=18.
- [x] AC4: PERFECT parry at frame_diff=3 applies 5.0x and final_damage=50.
- [x] AC5: GOOD parry at frame_diff=10 applies 2.5x and final_damage=25.
- [x] AC6: LATE parry at frame_diff=15 applies 1.5x and final_damage=15.
- [x] AC7: combo finisher + PERFECT crit with base_damage=13 yields final_damage=58.
- [x] AC11: combo timeout reset is represented by combo_index=0, yielding final_damage=10 rather than 12.
- [x] AC20: PERFECT parry + defense=20 yields final_damage=37.
- [x] Boundary intervals are half-open: PERFECT [0,7), GOOD [7,13), LATE [13,19), otherwise NO.

---

## Implementation Notes

- Add pure helper methods for crit multiplier, combo multiplier, parry multiplier, and normal/parry attack_damage paths.
- Combo multipliers are table-driven by weapon_id and combo_index.
- Parry path ignores combo_multiplier by design.
- Metadata must set `crit_type`, `is_crit`, `parry_type`, `is_parry`, and `combo_stage`.
- Story 003 owns charm/focus crit window expansion; this story implements the base 3-frame PERFECT and 3-frame GOOD crit windows.

---

## Out of Scope

- Story 003 handles special moves and third attack_type multiplier path.
- Story 004 handles loading multiplier tables from JSON.

---

## QA Test Cases

- **AC2/AC3**: deterministic crit windows
  - Given: hit_frame inside PERFECT and GOOD windows
  - When: calculating normal damage
  - Then: multipliers are 2.5 and 1.8 with exact final damage
  - Edge cases: hit_frame outside all windows returns normal crit_type

- **AC4-AC6**: parry intervals
  - Given: frame_diff values 3, 10, 15
  - When: calculating parry damage
  - Then: final_damage is 50, 25, and 15
  - Edge cases: frame_diff=-1 and 19 return NO parry multiplier 1.0

- **AC7/AC11**: combo table
  - Given: cat_claw combo_index 2 and reset combo_index 0
  - When: calculating normal attack_damage
  - Then: finisher damage floors to 58, reset hit returns 10
  - Edge cases: invalid combo_index clamps/falls back to 0

- **AC20**: parry plus defense
  - Given: PERFECT parry and defense=20
  - When: applying reduction
  - Then: final_damage is 37
  - Edge cases: parry path never multiplies combo_stage

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/damage/story_002_crit_combo_parry_test.gd` — must exist and pass
**Status**: [x] Created (5 test functions covering AC2-AC7, AC11, AC20, and half-open parry boundaries)
**Note**: GdUnit4 Story 002 damage suite passes 5/5; combined `tests/unit/data` + `tests/unit/damage` passes 54/54 as of 2026-06-23.

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003, Story 004

---

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 9/9 scoped checks covered
**Code Review**: Complete — local review passed against ADR-0001, ADR-0002, the Foundation control manifest, GDD `TR-damage-002`, `TR-damage-003`, `TR-damage-004`, and passing GdUnit evidence. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool.
**Deviations**: Combo multiplier table is currently a `DamageCalculator` constant pending Story 004 data/schema integration. This stays inside Story 002's stated scope; external JSON loading remains Story 004.
**Test Evidence**: Logic — `tests/unit/damage/story_002_crit_combo_parry_test.gd` (5 functions)
**Next**: Story 003 — `production/epics/damage-calculator/story-003-special-modifiers.md`
