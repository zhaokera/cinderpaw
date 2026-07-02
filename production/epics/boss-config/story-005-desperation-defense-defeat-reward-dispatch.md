# Story 005: Desperation Defense + Defeat Reward Dispatch

> **Epic**: Boss Configuration
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: 4 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/boss-config.md`
**Requirement**: `TR-boss-006`, `TR-boss-007`

**ADR Governing Implementation**: ADR-0002: Signal communication
**ADR Decision Summary**: Defeat rewards and HP-derived state changes are dispatched
through direct signals/adapters with deterministic ordering.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Use typed signal connections; no post-cutoff API.

---

## Acceptance Criteria

- [x] In phase 3, when Boss HP percentage is below 10%, BossConfigComponent exposes
  a defense modifier of 0.7.
- [x] Above or equal to 10% HP, the defense modifier remains 1.0.
- [x] Boss defeat dispatches dash unlock, 50 gear coins, and 5 skill points through
  a reward adapter.
- [x] Reward dispatch is idempotent and cannot fire twice for the same defeat event.

## Implementation Notes

Use HealthComponent-compatible HP percentage queries and a reward adapter with
`unlock_ability(ability_id)`, `grant_currency(amount)`, and
`grant_skill_points(amount)`. Actual AbilityComponent, currency storage, and
SkillTreeManager implementation remain separate systems.

## Out of Scope

- AbilityComponent implementation.
- Currency persistence.
- Skill tree spend UI.

## QA Test Cases

- **AC-1**: Desperation modifier activates below 10%.
  - Given: phase is 3 and HP percentage is 0.099.
  - When: defense modifier is queried.
  - Then: returned modifier is 0.7.

- **AC-2**: Threshold boundary stays normal.
  - Given: phase is 3 and HP percentage is 0.1.
  - When: defense modifier is queried.
  - Then: returned modifier is 1.0.

- **AC-3**: Defeat rewards dispatch.
  - Given: Rat King defeat rewards are loaded.
  - When: boss defeat is observed.
  - Then: dash unlock, 50 currency, and 5 skill points are sent.

- **AC-4**: Defeat dispatch is idempotent.
  - Given: defeat has already been handled.
  - When: the same defeat event is observed again.
  - Then: no additional reward calls are sent.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/boss/story_005_desperation_reward_test.gd` - must exist and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Phase 3 below 10% HP exposes 0.7 defense modifier | `tests/unit/boss/story_005_desperation_reward_test.gd::test_phase_three_below_ten_percent_hp_uses_desperation_defense` | COVERED |
| AC-2: Boundary and non-phase-three states remain 1.0 | `tests/unit/boss/story_005_desperation_reward_test.gd::test_desperation_defense_boundary_and_non_phase_three_remain_normal` | COVERED |
| AC-3: Defeat dispatches dash, currency, and skill-point rewards | `tests/unit/boss/story_005_desperation_reward_test.gd::test_boss_defeat_dispatches_configured_rewards_for_this_boss` | COVERED |
| AC-4: Defeat reward dispatch is idempotent | `tests/unit/boss/story_005_desperation_reward_test.gd::test_boss_defeat_reward_dispatch_is_idempotent` | COVERED |
| Data-driven desperation rules | `tests/unit/boss/story_001_boss_config_component_test.gd::test_project_boss_config_data_loads_through_data_manager_and_schema` | COVERED |

## Dependencies

- Depends on: Story 001 Complete.
- Unlocks: Ability, Save, HUD, and SkillTree reward integration stories.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 4/4 passing
**Deviations**: None for TR-boss-006 and TR-boss-007. TR-boss-005 remains outside this
story and still needs Boss-specific parry immunity coverage.
**Test Evidence**:
- RED: `reports/report_241/` failed on missing Story005 defense/reward adapter APIs.
- GREEN: `reports/report_242/` Boss suite 23/23 passing.
- Regression: `reports/report_243/` full `tests/unit` suite 249/249 passing.

**Runtime Evidence**:
- `reports/boss_story005_project_boot.log`
- `reports/boss_story005_main_scene_smoke.log`
- Both logs show `[godot_ai game_helper] registered mcp capture` and no
  `ERROR`, `SCRIPT ERROR`, `Parse Error`, or `WARNING` matches.
- No direct Godot MCP run/screenshot tool is exposed in this Codex session, so
  validation used Godot CLI/headless fallback after confirming MCP capture registration.

**Static Evidence**:
- `git diff --check` passed.
- Related source, test, schema, JSON, and Story/Epic docs have no trailing whitespace.
- Related source, test, schema, and JSON files have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0002, ADR-0003,
Control Manifest Core/Data rules, TR-boss-006, TR-boss-007, and story acceptance
criteria. Full specialist sub-agent gates were not spawned because the active Codex
multi-agent tool policy requires an explicit user request for delegation.
