# Story 001: StatusEffectComponent + Effect Catalog

> **Epic**: Status Effects
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/status-effects.md`
**Requirement**: `TR-status-001`

**ADR Governing Implementation**: ADR-0017: Status effects architecture;
ADR-0001: Autoload architecture; ADR-0003: Data management
**ADR Decision Summary**: Status effects are owned by an entity-mounted Core
component. The effect catalog defines seven effect ids, categories, durations,
modifier metadata, DoT values, priorities, and a maximum of five active effects.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Pure GDScript data structures; no new engine APIs.

**Control Manifest Rules (Core)**:
- Required: StatusEffectComponent is a scene component, not an Autoload.
- Required: Core component APIs must be testable without full scenes.
- Required: Tuning values use the existing DataManager/tuning knob pipeline.
- Forbidden: Do not add visual/audio/UI behavior in the Core status component.

---

## Acceptance Criteria

- [x] `StatusEffectComponent` instantiates without a full entity scene.
- [x] The catalog defines exactly seven effect ids: poison, slow, stun, burn,
  speed_boost, damage_boost, and invincible.
- [x] Each catalog entry exposes category, base duration, priority, DoT damage,
  movement modifier, and damage modifier.
- [x] New components start with zero active effects and `get_active_effects()`
  returns a defensive copy.
- [x] `get_max_effects()` returns 5 by default.
- [x] Status tuning keys are present in `data/tuning_knobs.json` and validated
  by `data/schemas/tuning_knobs.schema.json`.

## Implementation Notes

Create `src/core/status_effect_component.gd`. Keep Story001 limited to component
construction, catalog lookup, constants, and data/schema tuning entries.

Do not implement `apply_status()`, ticking, immunity checks, DoT damage, modifier
math, or cleanup hooks in this story.

## Out of Scope

- Story 002: status application, refresh, and Boss STUN immunity.
- Story 003: duration processing, DoT ticks, and modifier queries.
- Story 004: i-frame and invincible debuff immunity.
- Story 005: priority and full-list eviction.
- Story 006: death and scene cleanup.

## QA Test Cases

- **AC-1**: Component construction.
  - Given: a new StatusEffectComponent.
  - When: it is added to a test tree.
  - Then: it has no active effects and max effect count is 5.

- **AC-2**: Catalog completeness.
  - Given: the built-in status catalog.
  - When: all effect ids are queried.
  - Then: exactly seven configured ids are present.

- **AC-3**: Catalog metadata.
  - Given: each configured effect.
  - When: catalog data is queried.
  - Then: category, duration, priority, DoT, movement, and damage fields exist.

- **AC-4**: DataManager validation.
  - Given: project tuning knob data.
  - When: DataManager loads `tuning_knobs`.
  - Then: status tuning keys validate through the schema.

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/status/story_001_status_effect_catalog_test.gd` - must exist and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Component instantiates and starts empty | `tests/unit/status/story_001_status_effect_catalog_test.gd::test_component_starts_empty_with_default_capacity` | COVERED |
| AC-2: Catalog defines exactly seven GDD effect ids | `tests/unit/status/story_001_status_effect_catalog_test.gd::test_catalog_defines_exactly_gdd_effect_ids` | COVERED |
| AC-3: Catalog entries expose required metadata | `tests/unit/status/story_001_status_effect_catalog_test.gd::test_catalog_entries_expose_required_metadata` | COVERED |
| AC-4: Active effects are returned as a defensive copy | `tests/unit/status/story_001_status_effect_catalog_test.gd::test_active_effects_returns_defensive_copy` | COVERED |
| AC-5: Status tuning knobs validate through schema | `tests/unit/status/story_001_status_effect_catalog_test.gd::test_project_status_tuning_knobs_validate_through_schema` | COVERED |

## Dependencies

- Depends on: Data Manager Complete.
- Unlocks: Story 002 Status Application + Boss STUN Immunity.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 6/6 passing
**Deviations**: None. Story scope is intentionally limited to catalog and initial
state; apply/tick/cleanup behavior remains in later stories.
**Implementation**:
- Added `src/core/status_effect_component.gd` as a Core scene component.
- Defined the seven GDD effect ids and catalog metadata for category, duration,
  priority, DoT, movement modifier, and damage modifier.
- Added `get_effect_ids()`, `get_effect_config()`, `get_effect_priority()`,
  `get_active_effects()`, and `get_max_effects()`.
- Added status tuning entries to `data/tuning_knobs.json` and
  `data/schemas/tuning_knobs.schema.json`.

**Test Evidence**:
- RED: `reports/report_247/` failed because `StatusEffectComponent` did not exist.
- GREEN: `reports/report_252/` Story001 suite 5/5 passing.
- Status suite: `reports/report_250/` 5/5 passing.
- Regression: `reports/report_253/` full `tests/unit` suite 258/258 passing.

**Runtime Evidence**:
- `reports/status_story001_project_boot.log`
- `reports/status_story001_main_scene_smoke.log`
- Both logs show `[godot_ai game_helper] registered mcp capture` and no
  `ERROR`, `SCRIPT ERROR`, `Invalid call`, `Parse Error`, or `WARNING` matches.
- No direct Godot MCP run/screenshot tool is exposed in this Codex session, so
  validation used Godot CLI/headless fallback after confirming MCP capture registration.

**Static Evidence**:
- `git diff --check` passed.
- Related source, data, schema, tests, and Story/Epic docs have no trailing whitespace.
- Related source, data, schema, and tests have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0001, ADR-0003,
ADR-0017, Control Manifest Core rules, TR-status-001, and Story001 acceptance
criteria. Full specialist sub-agent gates were not spawned because the active Codex
multi-agent tool policy requires an explicit user request for delegation.
