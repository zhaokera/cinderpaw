# Story 006: Death + Scene Cleanup Hooks

> **Epic**: Status Effects
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/status-effects.md`
**Requirement**: `TR-status-006`

**ADR Governing Implementation**: ADR-0017: Status effects architecture;
ADR-0002: Signal communication
**ADR Decision Summary**: StatusEffectComponent clears all active effects when
Health-compatible death signals or SceneManager-compatible scene transition hooks
fire. Cleanup is idempotent and emits expiration/removal signals once.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Typed signal connection and duck-typed adapter behavior only.

---

## Acceptance Criteria

- [x] Health-compatible death events clear all effects for the owning entity.
- [x] Foreign death events do not clear this component.
- [x] Scene transition cleanup clears all effects.
- [x] Repeated cleanup calls are safe and do not emit duplicate expiration signals.

## Implementation Notes

Use adapter setters compatible with existing Health and SceneManager boundaries.
Keep cleanup local to the component; SceneManager should not know internal effect state.

## Out of Scope

- SceneManager implementation.
- Death/Respawn flow implementation.

## QA Test Cases

- **AC-1**: Owner death cleanup.
  - Given: two active effects.
  - When: owner death is observed.
  - Then: active effects are cleared.

- **AC-2**: Foreign death ignored.
  - Given: effects are active for entity 7.
  - When: entity 8 death is observed.
  - Then: effects remain.

- **AC-3**: Scene transition cleanup.
  - Given: effects are active.
  - When: scene cleanup is requested.
  - Then: all effects are cleared once.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/status/story_006_status_cleanup_hooks_test.gd` - must exist and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Owner death clears all active effects | `tests/unit/status/story_006_status_cleanup_hooks_test.gd::test_owner_death_clears_all_effects_and_emits_expiration_once` | COVERED |
| AC-2: Foreign death events are ignored | `tests/unit/status/story_006_status_cleanup_hooks_test.gd::test_foreign_death_does_not_clear_this_component` | COVERED |
| AC-3: Scene transition cleanup clears all effects | `tests/unit/status/story_006_status_cleanup_hooks_test.gd::test_scene_transition_signal_clears_all_effects_once` | COVERED |
| AC-4: Repeated cleanup calls emit no duplicate expirations | `tests/unit/status/story_006_status_cleanup_hooks_test.gd::test_direct_cleanup_is_idempotent` | COVERED |

## Dependencies

- Depends on: Story 002 Complete; Health & Death epic Complete.
- Unlocks: Death/Respawn and Scene Management integration.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 4/4 passing
**Deviations**: None. SceneManager is not implemented yet, so the component
connects to ADR-0007 `on_scene_changed` and compatible transition signal names
through a duck-typed scene adapter.
**Implementation**:
- Added `clear_all_effects()` with one `status_expired` emission per removed effect.
- Extended `set_health_adapter()` to connect/disconnect `on_death` and clear only
  for the owning entity id.
- Added `set_scene_adapter()` and `handle_scene_transition_cleanup()` for
  SceneManager-compatible cleanup hooks.
- Made death and scene cleanup idempotent with zero-effect fast paths.

**Test Evidence**:
- RED: `reports/report_270/` failed because owner death did not clear effects.
- GREEN: `reports/report_271/` Story006 suite 4/4 passing.
- Status suite: `reports/report_272/` status suite 26/26 passing.
- Regression: `reports/report_273/` full `tests/unit` suite 279/279 passing.

**Runtime Evidence**:
- `reports/status_story006_project_boot.log`
- `reports/status_story006_main_scene_smoke.log`
- Both logs show `[godot_ai game_helper] registered mcp capture` and no
  `ERROR`, `SCRIPT ERROR`, `Invalid call`, `Parse Error`, or `WARNING` matches.
- No direct Godot MCP run/screenshot tool is exposed in this Codex session, so
  validation used Godot CLI/headless fallback after confirming MCP capture registration.

**Static Evidence**:
- `git diff --check` passed.
- Related source, tests, and Story/Epic/index/session docs have no trailing whitespace.
- Related source and tests have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0002,
ADR-0007, ADR-0017, Control Manifest Core/SceneManager rules, TR-status-006,
and Story006 acceptance criteria. Full specialist sub-agent gates were not
spawned because the active Codex multi-agent tool policy requires an explicit
user request for delegation.
