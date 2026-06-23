# Story 003: Data-Driven Attack Pattern Loading

> **Epic**: AI Framework
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/ai-framework.md`
**Requirements**: `TR-ai-003`

**ADR Governing Implementation**: ADR-0003: Data manager architecture; ADR-0006: AI behavior system architecture
**ADR Decision Summary**: Enemy attack patterns are loaded from the `enemy_stats` data domain and contain startup, active, recovery, hitbox, vulnerability, and weighting fields.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Pure JSON/domain adapter consumption; no new engine APIs.

**Control Manifest Rules (Core/Foundation boundary)**:
- Required: Attack patterns are data-driven and loaded from DataManager `enemy_stats`.
- Required: Core listens to Foundation through adapters/signals; Foundation does not reference Core.
- Forbidden: Never bypass SchemaValidator for loaded source data.
- Guardrail: AI decisions <1ms/frame per entity.

---

## Acceptance Criteria

- [x] AIComponent can load attack patterns for an enemy id from a DataManager-compatible adapter.
- [x] Loaded patterns preserve startup_frames, active_frames, recovery_frames, hitbox_config, vulnerability_window, and base_weight.
- [x] Invalid or missing pattern fields fall back to safe defaults instead of crashing.
- [x] Empty pattern lists leave the component in a safe no-attack configuration.

## Implementation Notes

- Keep the data adapter duck-typed so tests can provide fake domains.
- Do not hardcode specific enemy ids or pattern names in production code.
- Story 004 will consume the loaded pattern data for frame execution.

## Out of Scope

- Weighted attack selection.
- Collision hitbox activation.
- Boss phase pattern set switching.

---

## QA Test Cases

- **AC-1**: Pattern load success
  - Given: an `enemy_stats` adapter with one enemy and two attack patterns
  - When: AI loads patterns for that enemy id
  - Then: both patterns are available with required fields preserved
  - Edge cases: nested Vector2-like hitbox values

- **AC-2**: Safe fallback
  - Given: malformed or empty pattern data
  - When: AI loads patterns
  - Then: defaults are applied or attack availability is false without crash
  - Edge cases: missing hitbox_config, nonnumeric frames

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/ai/story_003_data_driven_attack_pattern_loading_test.gd` — must exist and pass

**Status**: [x] Created and passing

## Dependencies

- Depends on: Story 001 AI State Machine + Active Enemy Count
- Unlocks: Story 004 Attack Phase Execution + Collision Adapter; Story 006 Low-HP Adaptation + Weighted Attack Selection

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Load attack patterns from a DataManager-compatible adapter | `tests/unit/ai/story_003_data_driven_attack_pattern_loading_test.gd::test_load_attack_patterns_from_data_adapter_preserves_required_fields`; `test_project_enemy_stats_data_loads_through_data_manager_and_schema` | COVERED |
| AC-2: Preserve startup/active/recovery/hitbox/vulnerability/base_weight fields | `tests/unit/ai/story_003_data_driven_attack_pattern_loading_test.gd::test_load_attack_patterns_from_data_adapter_preserves_required_fields` | COVERED |
| AC-3: Invalid or missing fields use safe defaults | `tests/unit/ai/story_003_data_driven_attack_pattern_loading_test.gd::test_invalid_or_missing_pattern_fields_use_safe_defaults` | COVERED |
| AC-4: Empty pattern lists are safe no-attack configuration | `tests/unit/ai/story_003_data_driven_attack_pattern_loading_test.gd::test_empty_pattern_lists_leave_component_in_safe_no_attack_configuration` | COVERED |

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 4/4 passing
**Deviations**: None
**Test Evidence**:
- RED: Story003 first failed on missing `AIComponent.load_attack_patterns()`, missing `data/schemas/enemy_stats.schema.json`, and missing `attack_patterns` data (`reports/report_191/`).
- GREEN: Story003 suite 4/4 passing after implementation and test refactor (`reports/report_197/`).
- AI regression: `tests/unit/ai` 14/14 passing (`reports/report_198/`).
- Full regression: `tests/unit` 211/211 passing (`reports/report_199/`).
- Data fixture compatibility: existing DataManager lazy-loading fixture updated to include the new `attack_patterns` schema field; focused data suite 7/7 passing (`reports/report_195/`).
- Godot/MCP runtime: `godot --headless --path . --quit` exits 0 and logs `[godot_ai game_helper] registered mcp capture`; main scene smoke exits 0 with `reports/ai_story003_main_scene_smoke.log`.
- Static checks: `git diff --check`, trailing-whitespace scan, and changed-method length scan passed.
**Code Review**: Local review complete against ADR-0003, ADR-0006, `docs/architecture/control-manifest.md`, TR-ai-003, and Story003 test evidence. Specialist QA/LP gates were not spawned because no multi-agent delegation tool was exposed in this thread.
