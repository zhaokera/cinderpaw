# Story 004: I-frame + Invincible Debuff Immunity

> **Epic**: Status Effects
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/status-effects.md`
**Requirement**: `TR-status-004`

**ADR Governing Implementation**: ADR-0017: Status effects architecture;
ADR-0019: Health component
**ADR Decision Summary**: i-frames and invincible status block debuffs before
application. Invincible is represented as a status effect and can also expose
invulnerability metadata to Health-compatible consumers.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Pure adapter/query behavior.

---

## Acceptance Criteria

- [x] Health adapter i-frames reject debuffs before application.
- [x] Active `invincible` rejects debuffs before application.
- [x] Buffs can still be applied during i-frames.
- [x] `has_status("invincible")` can be used by Health integration as an invulnerability query.

## Implementation Notes

Use HealthComponent-compatible adapters to query invulnerability. Keep immunity
checks ordered and side-effect free when application fails.

## Out of Scope

- Combat dodge implementation.
- HealthComponent internals.

## QA Test Cases

- **AC-1**: i-frame debuff immunity.
  - Given: health adapter reports invulnerable.
  - When: `poison` is applied.
  - Then: application returns false and no effect is added.

- **AC-2**: buff allowed during i-frames.
  - Given: health adapter reports invulnerable.
  - When: `speed_boost` is applied.
  - Then: application succeeds.

- **AC-3**: invincible blocks debuffs.
  - Given: `invincible` is active.
  - When: `slow` is applied.
  - Then: `slow` is rejected.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/status/story_004_status_iframe_immunity_test.gd` - must exist and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Health adapter i-frames reject debuffs before application | `tests/unit/status/story_004_status_iframe_immunity_test.gd::test_health_adapter_invincible_rejects_debuff_before_application` | COVERED |
| AC-2: Buffs can still be applied during i-frames | `tests/unit/status/story_004_status_iframe_immunity_test.gd::test_buff_can_apply_while_health_adapter_is_invincible` | COVERED |
| AC-3: Active `invincible` rejects later debuffs | `tests/unit/status/story_004_status_iframe_immunity_test.gd::test_active_invincible_status_rejects_later_debuffs` | COVERED |
| AC-4: `has_status("invincible")` exposes Health integration query | `tests/unit/status/story_004_status_iframe_immunity_test.gd::test_invincible_status_is_queryable_for_health_integration` | COVERED |

## Dependencies

- Depends on: Story 002 Complete; Health & Death epic Complete.
- Unlocks: dodge/status interaction verification.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 4/4 passing
**Deviations**: None. Story and ADR scope require debuff immunity during i-frames;
buffs remain allowed during i-frames per this Story's explicit acceptance criteria.
**Implementation**:
- Extended `StatusEffectComponent` immunity checks to reject debuffs while the
  Health-compatible adapter reports invulnerability.
- Added compatibility with `is_invincible()`, `is_invulnerable()`,
  `is_invulnerable_to_damage()`, and `get_iframe_remaining()` adapter queries.
- Added active `invincible` status as a debuff-immunity source.
- Kept buff application valid during i-frames.
- Added optional 30-frame `grant_iframes()` dispatch when `invincible` is applied
  to a compatible Health adapter.

**Test Evidence**:
- RED: `reports/report_262/` failed because debuffs still applied during Health
  adapter i-frames.
- GREEN: `reports/report_263/` Story004 suite 4/4 passing.
- Status suite: `reports/report_264/` status suite 19/19 passing.
- Regression: `reports/report_265/` full `tests/unit` suite 272/272 passing.

**Runtime Evidence**:
- `reports/status_story004_project_boot.log`
- `reports/status_story004_main_scene_smoke.log`
- Both logs show `[godot_ai game_helper] registered mcp capture` and no
  `ERROR`, `SCRIPT ERROR`, `Invalid call`, `Parse Error`, or `WARNING` matches.
- No direct Godot MCP run/screenshot tool is exposed in this Codex session, so
  validation used Godot CLI/headless fallback after confirming MCP capture registration.

**Static Evidence**:
- `git diff --check` passed.
- Related source, tests, and Story/Epic/session docs have no trailing whitespace.
- Related source and tests have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0017,
ADR-0019, Control Manifest Core rules, TR-status-004, and Story004 acceptance
criteria. Full specialist sub-agent gates were not spawned because the active
Codex multi-agent tool policy requires an explicit user request for delegation.
