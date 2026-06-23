# Story 006: Max HP Aggregation + Serialization Prep

> **Epic**: Health & Death Detection
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/health-death.md`
**Requirements**: `TR-health-012`, `TR-health-014`

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0008: Save serialization
**Design Reference**: ADR-0019: HealthComponent deep architecture (Proposed)

## Acceptance Criteria

- [x] Max HP is calculated with HD-F0: base_hp + skill_hp_flat + charm_hp_flat.
- [x] Invalid max HP values fall back to safe defaults without crashing.
- [x] Current HP preserves percentage when max HP changes.
- [x] `get_injury_pitch_offset()` implements HD-F4.
- [x] `serialize()` and `deserialize(data, version)` preserve health state for future SaveSystem registration.

## Out of Scope

- Actual SaveSystem registration and external skill/charm system ownership.

## QA Test Cases

- **AC-1**: HD-F0 aggregation
- **AC-2**: Invalid max HP fallback
- **AC-3**: Percentage-preserving max HP resize
- **AC-4**: HD-F4 pitch offset
- **AC-5**: Serialization round trip

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/unit/health/story_006_max_hp_serialization_prep_test.gd` — must exist and pass
**Status**: [x] Created and passing

**Evidence**:
- Red: `reports/report_125/` — failed on missing `recalculate_max_hp()`, `get_injury_pitch_offset()`, `serialize()`, and `deserialize()`.
- Green Story 006: `reports/report_126/` — 5/5 passing.
- Full health: `reports/report_127/` — 33/33 passing.
- Input regression: `reports/report_128/` — 34/34 passing.
- Data regression: `reports/report_129/` — 43/43 passing.
- Damage regression: `reports/report_130/` — 24/24 passing.
- Static: `godot --headless --path . --quit`, `git diff --check`, method-length quick check, and trailing-whitespace scan passed.

## Implementation Notes

- `recalculate_max_hp(base_hp, skill_hp_flat, charm_hp_flat)` implements HD-F0 and stores the three source values for future skill/charm ownership integration.
- Max HP recalculation preserves current HP percentage and emits `on_hp_changed` when current or max HP changes.
- Invalid aggregated max HP falls back to `DEFAULT_MAX_HP`.
- `get_injury_pitch_offset()` implements HD-F4 with default 10 semitones and an optional caller-supplied max semitone value.
- `serialize()` returns JSON-safe primitive values for health state; runtime-only fields such as i-frames and battle stats are intentionally reset on `deserialize()`.

## Dependencies

- Depends on: Story 001, Story 003
- Unlocks: SaveSystem integration and skill/charm HP modifiers
