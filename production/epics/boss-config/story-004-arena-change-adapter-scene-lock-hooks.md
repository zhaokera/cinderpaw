# Story 004: Arena Change Adapter + Scene Lock Hooks

> **Epic**: Boss Configuration
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: 3 hours
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/boss-config.md`
**Requirement**: `TR-boss-004`

**ADR Governing Implementation**: ADR-0007: Scene management
**ADR Decision Summary**: SceneManager owns scene lock and scene-state coordination;
BossConfigComponent requests arena changes through an adapter.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: No async scene loading is required in this story; only adapter calls
are verified.

---

## Acceptance Criteria

- [x] Boss encounter start requests scene lock.
- [x] Phase 2 transition applies configured garbage pile obstacle arena changes.
- [x] Phase 3 transition applies configured overturned trash can obstacle and damage-zone
  arena changes.
- [x] Boss defeat requests scene unlock.

## Implementation Notes

Use a scene adapter with `lock_scene()`, `unlock_scene()`, and
`apply_arena_changes(boss_id, phase, changes)`. Do not instantiate actual obstacles here.

## Out of Scope

- Actual arena obstacle art and collision scenes.
- Combat Presentation VFX for phase transition.

## QA Test Cases

- **AC-1**: Encounter lock.
  - Given: Boss encounter starts.
  - When: BossConfigComponent receives start command.
  - Then: scene adapter `lock_scene()` is called.

- **AC-2**: Phase 2 changes apply.
  - Given: phase 2 config has garbage pile arena changes.
  - When: phase 2 transition applies arena changes.
  - Then: adapter receives those changes with phase 2.

- **AC-3**: Phase 3 changes apply.
  - Given: phase 3 config has obstacle and damage zone changes.
  - When: phase 3 transition applies arena changes.
  - Then: adapter receives both changes with phase 3.

- **AC-4**: Defeat unlock.
  - Given: scene is locked by boss encounter.
  - When: boss defeat is observed.
  - Then: scene adapter `unlock_scene()` is called.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/boss/story_004_arena_change_adapter_test.gd` - must exist and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Boss encounter start requests scene lock | `tests/unit/boss/story_004_arena_change_adapter_test.gd::test_boss_encounter_start_requests_scene_lock_once` | COVERED |
| AC-2: Phase 2 applies garbage pile arena changes | `tests/unit/boss/story_004_arena_change_adapter_test.gd::test_phase_two_transition_applies_garbage_pile_arena_change` | COVERED |
| AC-3: Phase 3 applies obstacle and damage-zone changes | `tests/unit/boss/story_004_arena_change_adapter_test.gd::test_phase_three_transition_applies_obstacle_and_damage_zone_changes` | COVERED |
| AC-4: Boss defeat requests scene unlock | `tests/unit/boss/story_004_arena_change_adapter_test.gd::test_boss_death_unlocks_scene_locked_by_encounter_once` | COVERED |

## Dependencies

- Depends on: Story 001 and Story 002 Complete.
- Unlocks: Presentation-layer arena VFX work.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 4/4 passing
**Deviations**: None
**Test Evidence**:
- RED: `reports/report_238/` failed on missing Story004 scene adapter API.
- GREEN: `reports/report_239/` Boss suite 19/19 passing.
- Regression: `reports/report_240/` full `tests/unit` suite 245/245 passing.

**Runtime Evidence**:
- `reports/boss_story004_project_boot.log`
- `reports/boss_story004_main_scene_smoke.log`
- Both logs show `[godot_ai game_helper] registered mcp capture` and no
  `ERROR`, `SCRIPT ERROR`, `Parse Error`, or `WARNING` matches.
- No direct Godot MCP run/screenshot tool is exposed in this Codex session, so
  validation used Godot CLI/headless fallback after confirming MCP capture registration.

**Static Evidence**:
- `git diff --check` passed.
- Related source, test, and Story/Epic docs have no trailing whitespace.
- Related source and test files have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0007,
Control Manifest Core/SceneManager rules, TR-boss-004, and story acceptance criteria.
Full specialist sub-agent gates were not spawned because the active Codex
multi-agent tool policy requires an explicit user request for delegation.
