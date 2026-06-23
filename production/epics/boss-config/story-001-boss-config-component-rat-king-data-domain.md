# Story 001: BossConfigComponent + Rat King Data Domain

> **Epic**: Boss Configuration
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: 3 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/boss-config.md`
**Requirement**: `TR-boss-001`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` - read fresh at review time)*

**ADR Governing Implementation**: ADR-0003: Data management
**ADR Decision Summary**: Boss configuration source data must be JSON, registered in `data/manifest.json`, validated by schema when present, and consumed through DataManager-compatible query APIs.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: FileAccess/JSON/DirAccess read APIs are stable; no post-cutoff API is required.

**Control Manifest Rules (this layer)**:
- Required: Core layer systems are scene components mounted on entity nodes, not Autoloads.
- Required: Attack patterns are data-driven and loaded through DataManager domains.
- Forbidden: Do not add another Autoload for Boss configuration.
- Guardrail: AI decisions stay under 1ms/frame per entity.

---

## Acceptance Criteria

*From GDD `design/gdd/boss-config.md`, scoped to this story:*

- [x] `boss_configs` data contains `boss_01_rat_king` with `max_hp` 300, 3 phases, and defeat rewards for dash, 50 gear coins, and 5 skill points.
- [x] Each Rat King phase contains `hp_threshold`, `attack_patterns`, `attack_speed_modifier`, `special_attacks`, `transition_animation`, and `arena_changes`.
- [x] BossConfigComponent can load a Boss config by `boss_id` from a DataManager-compatible adapter and expose phase thresholds, phase attack patterns, rewards, and arena bounds.
- [x] Missing or malformed config leaves BossConfigComponent in a safe empty configuration without throwing.
- [x] The project `boss_configs` JSON validates against its schema and loads through the DataManager pipeline.

## Implementation Notes

*Derived from ADR-0003 and ADR-0001:*

Create `res://src/core/boss_config_component.gd` as a scene component. It may accept a DataManager-compatible adapter for tests and runtime injection. Add a `boss_configs` JSON domain under `data/combat/`, register it in `data/manifest.json`, and create `data/schemas/boss_configs.schema.json`. The component should not own phase execution; it exposes normalized data for AI, Health, Scene, Reward, HUD, Audio, and Presentation consumers.

## Out of Scope

*Handled by neighbouring stories - do not implement here:*

- Story 002: phase transition timing, invulnerability, and AI adapter application.
- Story 003: minion summon scheduling and boss death cleanup.
- Story 004: arena layout mutation and scene lock integration.
- Story 005: desperation defense modifier and reward dispatch side effects.

## QA Test Cases

- **AC-1**: Rat King data exists with required MVP values.
  - Given: project data files are loaded.
  - When: `boss_01_rat_king` is queried from `boss_configs`.
  - Then: `max_hp == 300`, phases count is 3, and rewards are dash/50/5.
  - Edge cases: missing reward fields should fail schema or normalize to safe empty rewards.

- **AC-2**: Phase data contains all required fields.
  - Given: Rat King config is loaded.
  - When: each phase is inspected.
  - Then: phase fields include thresholds, patterns, speed modifier, special attacks, transition animation, and arena changes.
  - Edge cases: an empty `attack_patterns` array is allowed only if a later phase has special attacks.

- **AC-3**: Component exposes normalized config queries.
  - Given: a DataManager-compatible adapter with Rat King config.
  - When: BossConfigComponent loads `boss_01_rat_king`.
  - Then: thresholds, phase patterns, rewards, arena bounds, and current phase config are returned through public APIs.
  - Edge cases: querying an unknown phase returns an empty dictionary or empty array.

- **AC-4**: Missing config fails safely.
  - Given: a DataManager-compatible adapter returns null or malformed data.
  - When: BossConfigComponent loads a boss id.
  - Then: load returns false and all query APIs return safe empty/default values.
  - Edge cases: malformed `phases` field must not throw.

- **AC-5**: Project JSON validates and loads through DataManager.
  - Given: `data/combat/boss_configs.json` and `data/schemas/boss_configs.schema.json`.
  - When: SchemaValidator and DataManager load the project domain.
  - Then: schema validation passes and DataManager returns the Rat King config.
  - Edge cases: manifest registration must be preload false to keep boot cost low.

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/boss/story_001_boss_config_component_test.gd` - must exist and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| Rat King data contains MVP values and rewards | `tests/unit/boss/story_001_boss_config_component_test.gd::test_load_boss_config_exposes_rat_king_required_values` | COVERED |
| Each phase contains required fields | `tests/unit/boss/story_001_boss_config_component_test.gd::test_phase_queries_expose_patterns_speed_modifiers_and_arena_bounds` | COVERED |
| Component exposes normalized config queries | `tests/unit/boss/story_001_boss_config_component_test.gd::test_phase_queries_expose_patterns_speed_modifiers_and_arena_bounds` | COVERED |
| Missing or malformed config fails safely | `tests/unit/boss/story_001_boss_config_component_test.gd::test_missing_or_malformed_config_fails_safely` | COVERED |
| Project JSON validates and loads via DataManager | `tests/unit/boss/story_001_boss_config_component_test.gd::test_project_boss_config_data_loads_through_data_manager_and_schema` | COVERED |

## Dependencies

- Depends on: AI Framework Story 003 and Story 005 Complete; DataManager Story 003 Complete.
- Unlocks: Story 002, Story 003, Story 004, Story 005.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 5/5 passing
**Deviations**: None
**Test Evidence**: Logic unit test at `tests/unit/boss/story_001_boss_config_component_test.gd`; Story suite `reports/report_219` 5/5 passing; full unit suite `reports/report_220` 231/231 passing.
**Code Review**: Complete locally. Checked component scope, ADR-0003/DataManager compliance, no added Autoload, DataManager-compatible injection, strict required-field validation, method length, trailing whitespace, and `git diff --check`.
**Runtime Evidence**: `godot --headless --path . --quit --log-file reports/boss_story001_project_boot_after_review.log` and main scene smoke `reports/boss_story001_main_scene_smoke_after_review.log` exited 0; both logs show Godot AI helper MCP capture registration and no error keywords.
