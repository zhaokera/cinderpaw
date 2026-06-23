# Story 007: Fish Bone Charged Shield Break

> **Epic**: Weapon Styles
> **Status**: Ready
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/weapon-styles.md`
**Requirement**: `TR-weapon-007`

**ADR Governing Implementation**: ADR-0016: Weapon styles architecture;
ADR-0019: Health component
**ADR Decision Summary**: Fish Bone breaks shields only when a full-charge hit is
confirmed and the target exposes a HealthComponent-compatible `break_shield()`
method.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Adapter checks use `has_method` before calling Health hooks.

## Acceptance Criteria

- [ ] Fish Bone full-charge hits call target `break_shield()`.
- [ ] Partial-charge hits do not break shields.
- [ ] Missing shield APIs degrade to normal hit metadata without errors.

## Implementation Notes

Use combat adapter charge ratio/current state rather than owning charge state in
WeaponComponent.

## Out of Scope

- Knockback physics.
- Ground crack VFX and screen shake.

## QA Test Cases

- **AC-1**: Full charge.
  - Given: Fish Bone and combat charge ratio 1.0.
  - When: a hit is confirmed on a shield-capable target.
  - Then: target `break_shield()` is called once.

- **AC-2**: Partial charge.
  - Given: Fish Bone and combat charge ratio below 1.0.
  - When: a hit is confirmed.
  - Then: target shield is not broken.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/weapon/story_007_fish_bone_shield_break_test.gd`.

**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 006.
- Unlocks: Story 008.
