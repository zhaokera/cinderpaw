# Story 006: Long Tail Multi-Target Range Contract

> **Epic**: Weapon Styles
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/weapon-styles.md`
**Requirement**: `TR-weapon-001`

**ADR Governing Implementation**: ADR-0016: Weapon styles architecture;
ADR-0004: Collision detection
**ADR Decision Summary**: Long Tail exposes range and multi-target metadata to
CollisionComponent instead of owning hit detection itself.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Adapter calls can be tested without physics scenes.

## Acceptance Criteria

- [x] Long Tail attack parameters expose 2.0 tile range and multi-target type.
- [x] Hitbox metadata marks the attack as multi-target with a bounded max target count.
- [x] WeaponComponent does not bypass CollisionComponent duplicate-hit tracking.

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

**Created evidence**:
- `tests/unit/weapon/story_006_long_tail_multi_target_test.gd`
- `production/qa/evidence/long-tail-multi-target-2026-06-24.md`
- RED: `reports/report_328/`
- GREEN: `reports/report_329/`
- Focused regression: `reports/report_330/`
- Final verification: `reports/report_331/`
- MCP screenshot:
  `reports/visual/cinderpaw-mcp-long-tail-multi-target-runtime-20260624.png`

**Status**: [x] Complete

## Dependencies

- Depends on: Story 005.
- Unlocks: Story 007.
