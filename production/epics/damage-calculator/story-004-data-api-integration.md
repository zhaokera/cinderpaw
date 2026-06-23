# Story 004: DamageParams Data API Integration

> **Epic**: Damage Calculation
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/damage-calculation.md`
**Requirements**: `TR-damage-001` through `TR-damage-011`

**ADR Governing Implementation**: ADR-0003: 数据管理; ADR-0001: Autoload 架构; ADR-0002: 信号通信
**ADR Decision Summary**: DamageCalculator reads `damage_params` through DataManager but remains a static utility. Data errors must degrade gracefully; metadata is returned through DamageResult.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Validate FileAccess/JSON changes through existing DataManager tests and new damage integration tests.

**Control Manifest Rules (Foundation)**:
- Required: Standard data consumer contract uses `get_entry()` and handles null gracefully.
- Required: JSON is source data format; SchemaValidator validates loaded data.
- Forbidden: Never bypass SchemaValidator.
- Guardrail: Data-driven gameplay values must live in JSON/tuning knobs, not hardcoded implementation constants.

---

## Acceptance Criteria

- [x] `calculate_damage()` matches the GDD public signature and returns a DamageResult for all supported paths.
- [x] `damage_params` contains the required data for cat_claw, long_tail, fish_bone, and electro_bell placeholder entries.
- [x] `damage_params.schema.json` validates weapon_base, combo multipliers, crit multipliers, parry multipliers, special move parameters, attack_type multipliers, and category thresholds.
- [x] DamageCalculator uses DataManager values when available and deterministic safe defaults when unavailable.
- [x] `damage_multiplier`, `defense_curve_constant`, `damage_floor`, and `damage_cap` are registered as tuning knobs or read from existing registered tuning values.
- [x] Metadata in DamageResult is complete for normal, crit, parry, combo, special, and clamp/category cases.
- [x] All 20 GDD AC are represented by automated tests across `tests/unit/damage/`.

---

## Implementation Notes

- Complete `data/combat/damage_params.json` and its schema.
- Register damage tuning knobs using DataManager's TuningKnobRegistry without adding a new Autoload.
- Public API should accept optional injected params/data for tests so unit tests do not require the whole scene tree unless they are integration tests.
- Keep failure behavior graceful: missing weapon_id or invalid params returns a minimum non-crashing DamageResult with diagnostic metadata.
- Update `production/epics/damage-calculator/EPIC.md` only after story completion review.

---

## Out of Scope

- Visual damage numbers, hitstop, screen shake, audio, and VFX are Presentation stories.
- Actual HealthComponent HP reduction is Health/Death epic scope.
- CombatComponent calling DamageCalculator is Feline Combat epic scope.

---

## QA Test Cases

- **Public API parity**
  - Given: the GDD signature inputs for AC1-AC20
  - When: calling `DamageCalculator.calculate_damage(...)`
  - Then: exact expected final_damage and metadata are returned
  - Edge cases: missing optional skill_modifiers uses neutral defaults

- **DataManager integration**
  - Given: DataManager has loaded `damage_params`
  - When: calculating damage for supported weapons
  - Then: DataManager values are used
  - Edge cases: missing weapon_id falls back without crashing

- **Schema coverage**
  - Given: valid and invalid damage_params fixtures
  - When: DataManager validates the domain
  - Then: valid data loads and invalid data is rejected or falls back according to ADR-0003
  - Edge cases: integral JSON floats accepted only where schema allows numeric compatibility

- **Tuning knobs**
  - Given: runtime debug overrides for damage_multiplier/floor/cap/defense constant
  - When: calculating final damage
  - Then: tuning values affect results and are clamped to safe ranges
  - Edge cases: unregistered knobs use provided fallback values

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/unit/damage/story_004_data_api_integration_test.gd` — must exist and pass
**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: initial run failed on missing `DamageCalculator.calculate_damage()` / tuning integration; nested schema regression then failed until `SchemaValidator` validated nested Dictionary fields outside range-only checks.
- Story suite: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/damage/story_004_data_api_integration_test.gd --ignoreHeadlessMode` — 7/7 passing, report `reports/report_56/`.
- Damage regression: `res://tests/unit/damage` — 24/24 passing, report `reports/report_57/`.
- Data regression: `res://tests/unit/data` — 43/43 passing, report `reports/report_58/`.
- Integration coverage: public API, DataManager-backed params, tuning knobs, missing weapon fallback, nested schema validation, remaining GDD AC10/AC17 examples.

## Completion Notes

- Implemented data-driven `calculate_damage(...)` integration while keeping deterministic helper APIs used by Stories 001-003.
- Expanded `damage_params` and schema for `_global`, all supported weapon ids, combo/crit/parry/special/attack-type/category tables, and placeholder `electro_bell` data.
- Registered and consumed `damage.multiplier`, `damage.defense_curve_constant`, `damage.floor`, and `damage.cap` tuning knobs.
- Fixed `SchemaValidator` nested Dictionary validation so required nested fields are rejected even when the parent field has no numeric range constraints.

---

## Dependencies

- Depends on: Story 001, Story 002, Story 003, Data/Balance Infrastructure COMPLETE
- Unlocks: Health/Death, Feline Combat, Combat Presentation, Audio integration
