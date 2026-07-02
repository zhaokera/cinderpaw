# Story 004: Special Attack Cooldown + Cat Energy Gate

> **Epic**: Weapon Styles
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/weapon-styles.md`
**Requirement**: `TR-weapon-003`

**ADR Governing Implementation**: ADR-0016: Weapon styles architecture;
ADR-0005: Combat state machine
**ADR Decision Summary**: WeaponComponent gates special attacks by per-weapon
cooldown and CombatComponent cat energy, then emits start signals and starts the
configured cooldown.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Cooldowns are advanced deterministically via `_physics_process`
or public test helper.

**Control Manifest Rules (Core)**:
- Required: Cat energy stays owned by CombatComponent.
- Forbidden: WeaponComponent must not duplicate combat resources.

## Acceptance Criteria

- [x] Each weapon exposes the GDD special id and cooldown.
- [x] Insufficient cat energy rejects the special and emits an insufficient signal.
- [x] Active cooldown rejects the special and emits remaining cooldown.
- [x] Passing gates consumes cat energy through the combat adapter.
- [x] Passing gates emits `on_special_attack_started(attack_id)`.

## Implementation Notes

Use existing combat special costs: Cat Claw 30, Long Tail 40, Fish Bone 50,
Electro Bell 60.

## Out of Scope

- Special hitbox activation and visual effects.
- Weapon-specific hit callbacks.

## QA Test Cases

- **AC-1**: Gate success.
  - Given: Cat Claw with enough cat energy and no cooldown.
  - When: `request_special_attack()` is called.
  - Then: energy is consumed, cooldown starts, and start signal emits.

- **AC-2**: Gate failure.
  - Given: Electro Bell with insufficient energy.
  - When: `request_special_attack()` is called.
  - Then: no cooldown starts and insufficient-energy signal emits.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/weapon/story_004_special_attack_gates_test.gd`.

**Created evidence**:
- `tests/unit/weapon/story_004_special_attack_gates_test.gd`
- `production/qa/evidence/special-attack-gates-2026-06-24.md`

**Status**: [x] Complete

## Dependencies

- Depends on: Story 003.
- Unlocks: Story 005.
