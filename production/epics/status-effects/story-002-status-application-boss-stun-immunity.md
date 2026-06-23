# Story 002: Status Application + Boss STUN Immunity

> **Epic**: Status Effects
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/status-effects.md`
**Requirement**: `TR-status-002`

**ADR Governing Implementation**: ADR-0017: Status effects architecture;
ADR-0002: Signal communication
**ADR Decision Summary**: Status application checks immunity first, refreshes
existing same-type effects, applies new effect metadata, and emits direct local
signals. Boss STUN immunity consumes the Boss Configuration parry outcome boundary.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Use typed signals and duck-typed adapters only.

---

## Acceptance Criteria

- [x] `apply_status(target_id, effect_id, source_id)` returns true when an effect is applied.
- [x] Applying the same effect refreshes the existing effect duration instead of duplicating it.
- [x] `status_applied(target_id, effect_id)` emits for successful new applications.
- [x] Boss entities reject `stun` and return false without emitting `status_applied`.
- [x] Non-Boss entities can receive `stun`.

## Implementation Notes

Add entity identity/boss configuration to StatusEffectComponent via local setters or
adapter injection. Keep the component independent from concrete Boss nodes.

## Out of Scope

- Actual CombatComponent or AIComponent STUN state transition.
- Visual stun feedback.

## QA Test Cases

- **AC-1**: Apply effect.
  - Given: an empty component.
  - When: `slow` is applied.
  - Then: it returns true and the effect is active.

- **AC-2**: Refresh same type.
  - Given: an existing `poison` with reduced remaining duration.
  - When: `poison` is applied again.
  - Then: active effect count stays 1 and duration refreshes.

- **AC-3**: Boss STUN immunity.
  - Given: component is configured as Boss.
  - When: `stun` is applied.
  - Then: it returns false and `stun` is not active.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/status/story_002_status_application_immunity_test.gd` - must exist and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Applying a valid effect stores metadata and emits signal | `tests/unit/status/story_002_status_application_immunity_test.gd::test_apply_status_adds_effect_and_emits_signal` | COVERED |
| AC-2: Reapplying same effect refreshes without duplicate | `tests/unit/status/story_002_status_application_immunity_test.gd::test_reapplying_same_effect_refreshes_without_duplicate` | COVERED |
| AC-3: Boss rejects STUN without signal | `tests/unit/status/story_002_status_application_immunity_test.gd::test_boss_rejects_stun_without_emitting_signal` | COVERED |
| AC-4: Non-Boss can receive STUN | `tests/unit/status/story_002_status_application_immunity_test.gd::test_non_boss_can_receive_stun` | COVERED |
| Safety: Unknown effect is rejected | `tests/unit/status/story_002_status_application_immunity_test.gd::test_unknown_effect_is_rejected_safely` | COVERED |

## Dependencies

- Depends on: Story 001 Complete; Boss Configuration Story 006 Complete.
- Unlocks: AI/Combat STUN consumer integration.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 5/5 passing
**Deviations**: None. This story exposes Boss STUN immunity at the status component
boundary; downstream Combat/AI state consumption remains separate.
**Implementation**:
- Added `status_applied(target_id, effect_id)` to `StatusEffectComponent`.
- Added `configure_entity(entity_id, is_boss)`, `apply_status()`, `has_status()`,
  and `get_remaining_duration()`.
- Added active status instance metadata for target/source/effect ids, remaining
  duration, base duration, category, priority, DoT, and modifier values.
- Implemented same-effect refresh without duplicate active entries or duplicate
  `status_applied` emissions.
- Implemented Boss immunity for `stun` while allowing non-Boss STUN application.

**Test Evidence**:
- RED: `reports/report_254/` failed on missing `status_applied`.
- GREEN: `reports/report_255/` Story002 suite 5/5 passing.
- Status suite: `reports/report_256/` status suite 10/10 passing.
- Regression: `reports/report_257/` full `tests/unit` suite 263/263 passing.

**Runtime Evidence**:
- `reports/status_story002_project_boot.log`
- `reports/status_story002_main_scene_smoke.log`
- Both logs show `[godot_ai game_helper] registered mcp capture` and no
  `ERROR`, `SCRIPT ERROR`, `Invalid call`, `Parse Error`, or `WARNING` matches.
- No direct Godot MCP run/screenshot tool is exposed in this Codex session, so
  validation used Godot CLI/headless fallback after confirming MCP capture registration.

**Static Evidence**:
- `git diff --check` passed.
- Related source, tests, and Story/Epic docs have no trailing whitespace.
- Related source and tests have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0002,
ADR-0017, Control Manifest Core rules, TR-status-002, TR-boss-005, and Story002
acceptance criteria. Full specialist sub-agent gates were not spawned because the
active Codex multi-agent tool policy requires an explicit user request for delegation.
