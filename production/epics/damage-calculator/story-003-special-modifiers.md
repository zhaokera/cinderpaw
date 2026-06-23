# Story 003: SpecialMoves + Skill/Window Modifiers

> **Epic**: Damage Calculation
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/damage-calculation.md`
**Requirements**: `TR-damage-007`, `TR-damage-009`, `TR-damage-010`, `TR-damage-011`

**ADR Governing Implementation**: ADR-0001: Autoload 架构
**ADR Decision Summary**: DamageCalculator is a pure static utility. Skill tree and charm systems provide modifiers through input dictionaries rather than being called by Foundation code.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Keep `skill_modifiers: Dictionary` optional and typed at call boundaries.

**Control Manifest Rules (Foundation)**:
- Required: Upper layers provide data to Foundation; Foundation does not call them.
- Forbidden: Foundation layer must not reference SkillTree or Charm components directly.
- Guardrail: Public methods must be unit-testable with injected dictionaries.

---

## Acceptance Criteria

- [x] AC18: cat_claw special 疾风连爪 uses special_multiplier=0.8, hits=5, no combo multiplier, and totals final_damage=30.
- [x] AC19: long_tail special 旋风斩 uses special_multiplier=1.5, hits=1, PERFECT crit, and final_damage=63.
- [x] TR-damage-009: `skill_weapon_bonus` can override weapon_base with `weapon_base * (1 + skill_weapon_bonus)` before DC-F1.
- [x] TR-damage-010: `charm_crit_window_bonus_frames` and `focus_crit_window_bonus_frames` expand the PERFECT crit sub-window without changing multiplier values.
- [x] TR-damage-011: heavy/aerial attack_type multipliers use the third DC-F2 path and do not use combo/parry multipliers.
- [x] Multi-hit special moves floor each hit independently before summing.

---

## Implementation Notes

- Add special move table support for cat_claw and long_tail first; fish_bone/electro_bell remain data-compatible placeholders.
- Implement `skill_modifiers` keys as data input only: `skill_weapon_bonus`, `charm_crit_window_bonus_frames`, `focus_crit_window_bonus_frames`, `attack_type_multiplier`.
- Treat missing modifier keys as zero/neutral values.
- For multi-hit special moves, calculate each hit independently through DC-F1 -> DC-F2 special path -> DC-F3 -> DC-F4.
- Do not add dependencies on future SkillTree, CharmEquipment, or FocusMode components.

---

## Out of Scope

- Story 004 handles external JSON data/schema for special tables.
- Weapon cooldown, cat energy cost, stun duration, and animation timing belong to weapon-styles/feline-combat stories.

---

## QA Test Cases

- **AC18**: cat_claw multi-hit special
  - Given: weapon_base=10, attack_power=5, NORMAL crit, defense=20
  - When: calculating cat_claw special
  - Then: each hit floors to 6 and total final_damage is 30
  - Edge cases: per-hit floor differs from one combined 4.0x hit

- **AC19**: long_tail single special
  - Given: weapon_base=15, attack_power=10, PERFECT crit, defense=0
  - When: calculating long_tail special
  - Then: final_damage is 63
  - Edge cases: combo_index is ignored for special attacks

- **TR-damage-009**: skill weapon base override
  - Given: weapon_base=10 and skill_weapon_bonus=0.2
  - When: calculating base damage
  - Then: weapon_base path uses 12 before attack_power scaling
  - Edge cases: missing bonus leaves weapon_base unchanged

- **TR-damage-010**: crit window expansion
  - Given: charm/focus bonus frames expand PERFECT window
  - When: hit_frame falls inside the expanded region
  - Then: crit_type becomes perfect without changing multiplier value
  - Edge cases: GOOD window shifts after expanded PERFECT window

- **TR-damage-011**: third attack path
  - Given: attack_type_multiplier for heavy/aerial attacks
  - When: calculating attack_damage
  - Then: multiplier is applied with crit multiplier but without combo/parry
  - Edge cases: unknown attack_type falls back to normal multiplier 1.0

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/damage/story_003_special_modifiers_test.gd` — must exist and pass
**Status**: [x] Created (6 test functions covering AC18, AC19, TR-damage-009, TR-damage-010, TR-damage-011, and per-hit floor summing)
**Note**: GdUnit4 Story 003 damage suite passes 6/6; full `tests/unit/damage` passes 17/17; combined `tests/unit/data` + `tests/unit/damage` passes 60/60 as of 2026-06-23.

---

## Dependencies

- Depends on: Story 001, Story 002
- Unlocks: Story 004

---

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 6/6 scoped checks covered
**Code Review**: Complete — local review passed against ADR-0001, the Foundation control manifest, GDD `TR-damage-007`, `TR-damage-009`, `TR-damage-010`, `TR-damage-011`, and passing GdUnit evidence. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool.
**Deviations**: Special move, hit-count, and attack-type multiplier tables remain in `DamageCalculator` constants/helpers until Story 004 moves DamageParams tables into JSON/schema/DataManager integration.
**Test Evidence**: Logic — `tests/unit/damage/story_003_special_modifiers_test.gd` (6 functions)
**Next**: Story 004 — `production/epics/damage-calculator/story-004-data-api-integration.md`
