# Story 006: Boss Parry Damage + STUN Immunity

> **Epic**: Boss Configuration
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: 3 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/boss-config.md`
**Requirement**: `TR-boss-005`

**ADR Governing Implementation**: ADR-0005: Combat state machine architecture
**Secondary ADRs**: ADR-0003: Data management
**ADR Decision Summary**: Combat owns parry timing and STUN state transitions; BossConfigComponent
exposes Boss-specific parry outcome data so downstream Damage, AI, and StatusEffect systems
can apply the Boss exception without hardcoding it.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: No animation or status-effect node implementation is required in this story.

**Control Manifest Rules (this layer)**:
- Required: Combat/AI systems use enum state machines; Boss config remains a Core component.
- Required: Configuration values are loaded from JSON source data through schema validation.
- Forbidden: Do not create a new Autoload or EventBus for parry outcome routing.

---

## Acceptance Criteria

*From GDD `design/gdd/boss-config.md`, scoped to this story:*

- [x] Successful Boss parry outcome exposes a 5.0x damage multiplier.
- [x] Successful Boss parry outcome suppresses STUN entry for the Boss.
- [x] Missed or non-parry outcomes keep a neutral 1.0x multiplier and do not request STUN.
- [x] Boss parry outcome values are loaded from `boss_configs` data and schema.

## Implementation Notes

Add data-driven Boss parry rules to `boss_configs` with `damage_multiplier` and
`enter_stun` fields. BossConfigComponent should expose a small query method for downstream
systems, e.g. `resolve_parry_outcome(parry_type)`, returning plain metadata:
`damage_multiplier`, `enter_stun`, and `parry_type`.

Do not implement StatusEffectManager, actual STUN immunity lists, or animation behavior here.

## Out of Scope

- StatusEffectManager implementation.
- AIComponent STUN state integration.
- Combat Presentation parry VFX/audio.

## QA Test Cases

- **AC-1**: Successful parry uses Boss 5.0x damage.
  - Given: Rat King config is loaded.
  - When: Boss parry outcome is resolved for `perfect`.
  - Then: `damage_multiplier == 5.0`.

- **AC-2**: Successful parry suppresses Boss STUN.
  - Given: Rat King config is loaded.
  - When: Boss parry outcome is resolved for `good`.
  - Then: `enter_stun == false`.

- **AC-3**: Missed parry is neutral.
  - Given: Rat King config is loaded.
  - When: Boss parry outcome is resolved for `none` or `miss`.
  - Then: `damage_multiplier == 1.0` and `enter_stun == false`.

- **AC-4**: Parry rules are data-driven.
  - Given: a test Boss config overrides `damage_multiplier`.
  - When: Boss parry outcome is resolved.
  - Then: the returned multiplier matches the config override.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/boss/story_006_parry_immunity_test.gd` - must exist and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Successful Boss parry exposes 5.0x damage | `tests/unit/boss/story_006_parry_immunity_test.gd::test_successful_boss_parry_outcome_uses_five_times_damage` | COVERED |
| AC-2: Successful Boss parry suppresses STUN | `tests/unit/boss/story_006_parry_immunity_test.gd::test_successful_boss_parry_outcome_suppresses_stun` | COVERED |
| AC-3: Missed and non-parry outcomes remain neutral | `tests/unit/boss/story_006_parry_immunity_test.gd::test_missed_or_none_parry_outcomes_are_neutral` | COVERED |
| AC-4: Boss parry rules are loaded from config data | `tests/unit/boss/story_006_parry_immunity_test.gd::test_parry_rules_are_loaded_from_boss_config_data` | COVERED |
| DataManager/schema integration | `tests/unit/boss/story_001_boss_config_component_test.gd::test_project_boss_config_data_loads_through_data_manager_and_schema` | COVERED |

## Dependencies

- Depends on: Story 001 Complete; Damage Calculator parry multiplier path exists.
- Unlocks: StatusEffect/AI integration for Boss STUN immunity.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 4/4 passing
**Deviations**: None for the BossConfigComponent boundary. This story exposes data-driven
Boss parry outcome metadata; downstream Damage, AI, and StatusEffect consumers remain
separate integration stories.
**Test Evidence**:
- RED: `reports/report_244/` failed on missing `resolve_parry_outcome()`.
- GREEN: `reports/report_245/` Boss suite 27/27 passing.
- Regression: `reports/report_246/` full `tests/unit` suite 253/253 passing.

**Runtime Evidence**:
- `reports/boss_story006_project_boot.log`
- `reports/boss_story006_main_scene_smoke.log`
- Both logs show `[godot_ai game_helper] registered mcp capture` and no
  `ERROR`, `SCRIPT ERROR`, `Invalid call`, `Parse Error`, or `WARNING` matches.
- No direct Godot MCP run/screenshot tool is exposed in this Codex session, so
  validation used Godot CLI/headless fallback after confirming MCP capture registration.

**Static Evidence**:
- `git diff --check` passed before story closure.
- Related source, test, schema, JSON, and Story/Epic docs have no trailing whitespace.
- Related source, test, schema, and JSON files have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0005, ADR-0003,
Control Manifest Core/Data rules, TR-boss-005, and story acceptance criteria. Full
specialist sub-agent gates were not spawned because the active Codex multi-agent tool
policy requires an explicit user request for delegation.
