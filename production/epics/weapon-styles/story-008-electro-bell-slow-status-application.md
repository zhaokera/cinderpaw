# Story 008: Electro Bell Slow Status Application

> **Epic**: Weapon Styles
> **Status**: Ready
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

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

- [ ] Electro Bell hits call `apply_status(target_id, slow, source_id)`.
- [ ] Slow metadata remains 2 seconds and -30% movement.
- [ ] Repeated Electro Bell hits refresh slow through StatusEffectComponent.
- [ ] Missing status APIs degrade without errors.

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

**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 007.
- Unlocks: Weapon Styles epic completion.
