# Story 006: Long Tail Multi-Target Range Contract

> **Epic**: Weapon Styles
> **Status**: Ready
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/weapon-styles.md`
**Requirement**: `TR-weapon-001`

**ADR Governing Implementation**: ADR-0016: Weapon styles architecture;
ADR-0004: Collision detection
**ADR Decision Summary**: Long Tail exposes range and multi-target metadata to
CollisionComponent instead of owning hit detection itself.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Adapter calls can be tested without physics scenes.

## Acceptance Criteria

- [ ] Long Tail attack parameters expose 2.0 tile range and multi-target type.
- [ ] Hitbox metadata marks the attack as multi-target with a bounded max target count.
- [ ] WeaponComponent does not bypass CollisionComponent duplicate-hit tracking.

## Implementation Notes

This story should prepare the collision contract, not reimplement hit detection.

## Out of Scope

- Actual enemy overlap simulation.
- Combat Presentation slash VFX.

## QA Test Cases

- **AC-1**: Range metadata.
  - Given: Long Tail is current weapon.
  - When: attack parameters are queried.
  - Then: range is 2.0 and mechanism type is `multi_target`.

- **AC-2**: Collision adapter.
  - Given: a collision adapter is injected.
  - When: Long Tail attack hitbox metadata is requested.
  - Then: adapter receives multi-target metadata without duplicate-hit bypass.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/weapon/story_006_long_tail_multi_target_test.gd`.

**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 005.
- Unlocks: Story 007.
