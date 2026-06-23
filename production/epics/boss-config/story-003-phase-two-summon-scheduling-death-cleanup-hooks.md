# Story 003: Phase 2 Summon Scheduling + Death Cleanup Hooks

> **Epic**: Boss Configuration
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: 3 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/boss-config.md`
**Requirement**: `TR-boss-003`

**ADR Governing Implementation**: ADR-0006: AI behavior
**ADR Decision Summary**: Boss behavior is data-driven and phase-aware; summoning is exposed
through adapters rather than hardcoded scene dependencies.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Timer-like scheduling can be verified with deterministic `advance_time()`
in tests.

---

## Acceptance Criteria

- [x] In phase 2, every 15 seconds BossConfigComponent requests one minion summon
  if active summons are below 2.
- [x] When active summons are already 2, no additional summon request is emitted.
- [x] Leaving phase 2 resets summon timer state.
- [x] Boss death requests cleanup for all summons created by this boss.

## Implementation Notes

Use a summon adapter with `get_active_summon_count(boss_id)`,
`request_summon(boss_id, summon_id)`, and `cleanup_summons(boss_id)`. Keep the component
independent from scene instantiation.

## Out of Scope

- Actual minion scene spawning.
- Minion AI implementation.

## QA Test Cases

- **AC-1**: Phase 2 summon interval fires.
  - Given: phase is 2 and active summons are below cap.
  - When: 15 seconds are advanced.
  - Then: one summon request is recorded.

- **AC-2**: Summon cap suppresses requests.
  - Given: phase is 2 and active summons are 2.
  - When: 15 seconds are advanced.
  - Then: no summon request is recorded.

- **AC-3**: Leaving phase 2 resets timer.
  - Given: partial summon time has accumulated.
  - When: phase changes away from 2.
  - Then: accumulated time returns to 0.

- **AC-4**: Death cleans summons.
  - Given: summons were requested by this boss.
  - When: boss death is observed.
  - Then: cleanup is requested once.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/boss/story_003_summon_scheduling_test.gd` - must exist and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Phase 2 requests one summon every 15 seconds below cap | `tests/unit/boss/story_003_summon_scheduling_test.gd::test_phase_two_summon_interval_requests_one_minion_below_cap` | COVERED |
| AC-2: Active summon cap suppresses additional requests | `tests/unit/boss/story_003_summon_scheduling_test.gd::test_phase_two_summon_cap_suppresses_additional_requests` | COVERED |
| AC-3: Leaving phase 2 resets summon timer state | `tests/unit/boss/story_003_summon_scheduling_test.gd::test_leaving_phase_two_resets_summon_timer_state` | COVERED |
| AC-4: Boss death requests cleanup for this boss | `tests/unit/boss/story_003_summon_scheduling_test.gd::test_boss_death_requests_cleanup_for_this_boss_once` | COVERED |
| Data-driven summon rules | `tests/unit/boss/story_003_summon_scheduling_test.gd::test_summon_rules_are_loaded_from_boss_config_data` | COVERED |

## Dependencies

- Depends on: Story 001 Complete.
- Unlocks: None.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 4/4 passing
**Deviations**: None
**Test Evidence**:
- RED: `reports/report_227/` failed on missing Story003 summon adapter API.
- RED: `reports/report_233/` failed because summon scheduling still ignored data-driven
  `summon_rules`.
- GREEN: `reports/report_236/` Boss suite 15/15 passing.
- Regression: `reports/report_237/` full `tests/unit` suite 241/241 passing.

**Runtime Evidence**:
- `reports/boss_story003_project_boot.log`
- `reports/boss_story003_main_scene_smoke.log`
- Both logs show `[godot_ai game_helper] registered mcp capture` and no
  `ERROR`, `SCRIPT ERROR`, `Parse Error`, or `WARNING` matches.

**Static Evidence**:
- `git diff --check` passed.
- Related source, test, schema, and JSON files have no trailing whitespace.
- Related source, test, schema, and JSON files have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0006,
Control Manifest Core rules, TR-boss-003, and story acceptance criteria.
Full specialist sub-agent gates were not spawned because the active Codex
multi-agent tool policy requires an explicit user request for delegation.
