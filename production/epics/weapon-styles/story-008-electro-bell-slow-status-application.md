# Story 008: Electro Bell Slow Status Application

> **Epic**: Weapon Styles
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/weapon-styles.md`
**Requirement**: `TR-weapon-006`

**ADR Governing Implementation**: ADR-0016: Weapon styles architecture;
ADR-0017: Status effects architecture
**ADR Decision Summary**: Electro Bell applies slow through the target's
StatusEffectComponent-compatible adapter and refreshes duration instead of
stacking duplicate slows.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Status integration is tested through adapter calls.

## Acceptance Criteria

- [x] Electro Bell hits call `apply_status(target_id, slow, source_id)`.
- [x] Slow metadata remains 2 seconds and -30% movement.
- [x] Repeated Electro Bell hits refresh slow through StatusEffectComponent.
- [x] Missing status APIs degrade without errors.

## Implementation Notes

Reuse `StatusEffectComponent.EFFECT_SLOW` when available; otherwise use the
canonical `slow` StringName.

## Out of Scope

- Blue electric hit VFX.
- HUD status icon display.

## QA Test Cases

- **AC-1**: Slow application.
  - Given: Electro Bell is current weapon.
  - When: a hit is confirmed on a target with StatusEffectComponent.
  - Then: slow is applied for the target.

- **AC-2**: Missing adapter.
  - Given: target lacks status APIs.
  - When: Electro Bell hit is handled.
  - Then: no error is raised and hit flow continues.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/weapon/story_008_electro_bell_slow_test.gd`.

**Created evidence**:
- `tests/unit/weapon/story_008_electro_bell_slow_test.gd`
- `production/qa/evidence/electro-bell-slow-status-2026-06-24.md`
- RED: `reports/report_337/`
- GREEN: `reports/report_338/`
- Focused regression: `reports/report_340/`
- MCP screenshot:
  `reports/visual/cinderpaw-mcp-electro-bell-slow-runtime-20260624.png`

**Status**: [x] Complete

## Dependencies

- Depends on: Story 007.
- Unlocks: Weapon Styles epic completion.
