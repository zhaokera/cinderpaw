# Story 003: Weapon Swap State Machine + Combat Adapter

> **Epic**: Weapon Styles
> **Status**: Ready
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/weapon-styles.md`
**Requirement**: `TR-weapon-002`

**ADR Governing Implementation**: ADR-0016: Weapon styles architecture;
ADR-0005: Combat state machine; ADR-0002: Signal communication
**ADR Decision Summary**: WeaponComponent owns READY/SWAPPING state, a 0.5
second deterministic timer, cyclic swap order, and adapter calls that reset
Combat combo and dodge cooldown after a completed swap.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Deterministic `advance_time()` tests cover timing without
depending on real AnimationPlayer playback.

**Control Manifest Rules (Core)**:
- Required: State transitions are deterministic and testable.
- Required: Signal payloads stay small and typed.
- Forbidden: Do not use AnimationTree for combat state management.

## Acceptance Criteria

- [ ] In combat, `request_swap()` enters SWAPPING only when the combat adapter is
  not attacking.
- [ ] Swap remains active for 0.5 seconds and cannot be cancelled.
- [ ] Completion cycles Cat Claw -> Long Tail -> Fish Bone -> Electro Bell -> Cat Claw.
- [ ] Completion calls combat adapter combo reset and dodge reset hooks.
- [ ] Completion emits `on_weapon_changed(weapon)`.

## Implementation Notes

Use an injected CombatComponent-compatible adapter. If optional reset methods do
not exist, degrade gracefully.

## Out of Scope

- Actual swap animation assets.
- HUD next-weapon preview.

## QA Test Cases

- **AC-1**: Timed swap.
  - Given: WeaponComponent with a non-attacking combat adapter.
  - When: `request_swap()` and `advance_time(0.5)` run.
  - Then: current weapon changes to Long Tail.

- **AC-2**: Attacking gate.
  - Given: combat adapter reports ATTACKING.
  - When: `request_swap()` is called.
  - Then: current weapon and state remain unchanged.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/weapon/story_003_weapon_swap_state_machine_test.gd`.

**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 002.
- Unlocks: Story 004.
