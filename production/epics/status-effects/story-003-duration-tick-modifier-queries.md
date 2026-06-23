# Story 003: Duration Tick + Modifier Queries

> **Epic**: Status Effects
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/status-effects.md`
**Requirement**: `TR-status-003`

**ADR Governing Implementation**: ADR-0017: Status effects architecture;
ADR-0019: Health component
**ADR Decision Summary**: Status effects advance deterministically, tick DoT damage
through Health-compatible adapters, expire when duration reaches zero, and expose
movement/damage modifier query functions as pure multipliers.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Deterministic `advance_time(delta)` test hook is preferred over
Timer-node-only behavior for unit tests.

---

## Acceptance Criteria

- [x] `advance_time(delta_seconds)` reduces remaining durations.
- [x] Expired effects are removed and emit `status_expired(target_id, effect_id)`.
- [x] Poison ticks every 1.0 second and calls Health-compatible `apply_damage()`.
- [x] Burn ticks every 1.0 second and calls Health-compatible `apply_damage()`.
- [x] `get_movement_modifier()` multiplies active movement modifiers together.
- [x] `get_damage_modifier()` multiplies active damage modifiers together.

## Implementation Notes

Use duck-typed health adapters with `apply_damage(amount, metadata)` or a minimal
project-compatible method shape. Preserve zero-effect fast paths.

## Out of Scope

- i-frame/debuff immunity.
- HUD icon timers.

## QA Test Cases

- **AC-1**: Duration expiry.
  - Given: `slow` with 2 seconds duration.
  - When: 2.1 seconds advance.
  - Then: `slow` expires and is removed.

- **AC-2**: DoT tick.
  - Given: `poison` and a health adapter.
  - When: 1 second advances.
  - Then: 3 damage is applied with status metadata.

- **AC-3**: Movement multiplier.
  - Given: `slow` and `speed_boost`.
  - When: movement modifier is queried.
  - Then: modifier equals 0.7 * 1.3.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/status/story_003_status_duration_tick_modifiers_test.gd` - must exist and pass.

**Status**: [x] Created and passing

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: `advance_time()` reduces duration and expires effects | `tests/unit/status/story_003_status_duration_tick_modifiers_test.gd::test_advance_time_expires_effect_and_emits_signal` | COVERED |
| AC-2: Expiry removes the effect and emits `status_expired` | `tests/unit/status/story_003_status_duration_tick_modifiers_test.gd::test_advance_time_expires_effect_and_emits_signal` | COVERED |
| AC-3: Poison ticks once per second through Health adapter | `tests/unit/status/story_003_status_duration_tick_modifiers_test.gd::test_poison_ticks_once_per_second_through_health_adapter` | COVERED |
| AC-4: Burn ticks damage and contributes movement modifier | `tests/unit/status/story_003_status_duration_tick_modifiers_test.gd::test_burn_ticks_damage_and_exposes_movement_modifier` | COVERED |
| AC-5: Movement modifiers multiply together | `tests/unit/status/story_003_status_duration_tick_modifiers_test.gd::test_movement_and_damage_modifiers_multiply_active_effects` | COVERED |
| AC-6: Damage modifiers multiply and expired effects stop contributing | `tests/unit/status/story_003_status_duration_tick_modifiers_test.gd::test_expired_effects_no_longer_contribute_modifiers` | COVERED |

## Dependencies

- Depends on: Story 002 Complete; Health & Death epic Complete.
- Unlocks: Combat movement and Damage modifier consumption.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 6/6 passing
**Deviations**: None. Story scope exposes deterministic tick and modifier APIs;
downstream Combat/AI/Presentation consumption remains separate.
**Implementation**:
- Added `status_expired(target_id, effect_id)` to `StatusEffectComponent`.
- Added HealthComponent-compatible `set_health_adapter()` duck-typed injection.
- Added deterministic `advance_time(delta_seconds)` duration processing.
- Added 1.0-second DoT tick accumulation for poison and burn via `apply_damage()`.
- Added `get_movement_modifier()` and `get_damage_modifier()` multiplicative queries.
- Reset same-effect DoT tick accumulation when an active effect is refreshed.

**Test Evidence**:
- RED: `reports/report_258/` failed on missing Story003 duration/tick/modifier APIs.
- GREEN: `reports/report_259/` Story003 suite 5/5 passing.
- Status suite: `reports/report_260/` status suite 15/15 passing.
- Regression: `reports/report_261/` full `tests/unit` suite 268/268 passing.

**Runtime Evidence**:
- `reports/status_story003_project_boot.log`
- `reports/status_story003_main_scene_smoke.log`
- Both logs show `[godot_ai game_helper] registered mcp capture` and no
  `ERROR`, `SCRIPT ERROR`, `Invalid call`, `Parse Error`, or `WARNING` matches.
- No direct Godot MCP run/screenshot tool is exposed in this Codex session, so
  validation used Godot CLI/headless fallback after confirming MCP capture registration.

**Static Evidence**:
- `git diff --check` passed.
- Related source, tests, and Story/Epic/session docs have no trailing whitespace.
- Related source and tests have no lines over 100 characters.

**Code Review**: Complete locally. Reviewed against AGENTS.md, ADR-0017,
ADR-0019, Control Manifest Core rules, TR-status-003, and Story003 acceptance
criteria. Full specialist sub-agent gates were not spawned because the active
Codex multi-agent tool policy requires an explicit user request for delegation.
