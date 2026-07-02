# Story 005: Effect Priority + Capacity Eviction

> **Epic**: Status Effects
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/status-effects.md`
**Requirement**: `TR-status-005`

**ADR Governing Implementation**: ADR-0017: Status effects architecture
**ADR Decision Summary**: StatusEffectComponent enforces the configured maximum
active effect count, preserves priority metadata, and evicts the oldest active
effect when a sixth distinct effect is applied.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Pure GDScript list management.

---

## Acceptance Criteria

- [x] `get_effect_priority(effect_id)` matches the GDD order: stun > slow >
  poison > burn > speed_boost > damage_boost > invincible.
- [x] At most five distinct active effects are retained.
- [x] Applying a sixth distinct effect removes the oldest active effect.
- [x] Evicting an effect emits `status_expired(target_id, effect_id)`.

## Implementation Notes

Use deterministic insertion ordering for eviction. Do not sort the active list in
a way that makes "oldest" ambiguous.

## Out of Scope

- UI priority ordering for icon display.
- Same-type stacking beyond duration refresh unless explicitly implemented by ADR follow-up.

## QA Test Cases

- **AC-1**: Priority order.
  - Given: all effect ids.
  - When: priorities are queried.
  - Then: they sort according to GDD priority.

- **AC-2**: Capacity.
  - Given: five active distinct effects.
  - When: a sixth distinct effect is applied.
  - Then: active count remains 5.

- **AC-3**: Oldest eviction.
  - Given: five active distinct effects in known order.
  - When: a sixth distinct effect is applied.
  - Then: the first applied effect is removed and expiration signal emits.

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/status/story_005_status_priority_capacity_test.gd` - must exist and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Priority metadata matches GDD order | `tests/unit/status/story_005_status_priority_capacity_test.gd::test_effect_priority_matches_gdd_order` | COVERED |
| AC-2: Sixth distinct effect keeps capacity at five | `tests/unit/status/story_005_status_priority_capacity_test.gd::test_sixth_distinct_effect_keeps_capacity_at_five` | COVERED |
| AC-3: Sixth distinct effect evicts the oldest active effect | `tests/unit/status/story_005_status_priority_capacity_test.gd::test_sixth_distinct_effect_evicts_oldest_and_emits_expired` | COVERED |
| AC-4: Eviction emits `status_expired(target_id, effect_id)` | `tests/unit/status/story_005_status_priority_capacity_test.gd::test_sixth_distinct_effect_evicts_oldest_and_emits_expired` | COVERED |

## Dependencies

- Depends on: Story 002 Complete.
- Unlocks: HUD/UI status icon ordering.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 4/4 passing
**Deviations**: None. This story follows the GDD and Story acceptance rule that
the sixth distinct effect evicts the oldest active effect; priority remains
metadata for ordering and future consumers.
**Implementation**:
- Kept `get_effect_priority(effect_id)` aligned with GDD priority order.
- Replaced the full-capacity rejection path with deterministic oldest-effect eviction.
- Added `status_expired(target_id, effect_id)` emission for capacity eviction.
- Preserved insertion ordering so "oldest" remains unambiguous.

**Test Evidence**:
- RED: `reports/report_266/` failed because the sixth distinct effect returned false.
- GREEN: `reports/report_267/` Story005 suite 3/3 passing.
- Status suite: `reports/report_268/` status suite 22/22 passing.
- Regression: `reports/report_269/` full `tests/unit` suite 275/275 passing.

**Runtime Evidence**:
- `reports/status_story005_project_boot.log`
- `reports/status_story005_main_scene_smoke.log`
- Both logs show `[godot_ai game_helper] registered mcp capture` and no
  `ERROR`, `SCRIPT ERROR`, `Invalid call`, `Parse Error`, or `WARNING` matches.
- No direct Godot MCP run/screenshot tool is exposed in this Codex session, so
  validation used Godot CLI/headless fallback after confirming MCP capture registration.

**Static Evidence**:
- `git diff --check` passed.
- Related source, tests, and Story/Epic/session docs have no trailing whitespace.
- Related source and tests have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0017,
Control Manifest Core rules, TR-status-005, and Story005 acceptance criteria.
Full specialist sub-agent gates were not spawned because the active Codex
multi-agent tool policy requires an explicit user request for delegation.
