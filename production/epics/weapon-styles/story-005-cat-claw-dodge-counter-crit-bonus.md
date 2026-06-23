# Story 005: Cat Claw Dodge-Counter Crit Bonus

> **Epic**: Weapon Styles
> **Status**: Ready
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/weapon-styles.md`
**Requirement**: `TR-weapon-005`

**ADR Governing Implementation**: ADR-0016: Weapon styles architecture;
ADR-0005: Combat state machine
**ADR Decision Summary**: Cat Claw opens a 0.5 second dodge-counter timer and
adds +3 crit-window frames to the next qualifying attack through CombatComponent.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Frame-window behavior is validated with deterministic time and
adapter calls.

## Acceptance Criteria

- [ ] Cat Claw dodge completion opens a 0.5 second counter window.
- [ ] A qualifying hit during that window calls combat crit-window bonus +3.
- [ ] The bonus is consumed by the next qualifying hit.
- [ ] Non-Cat-Claw weapons do not open the bonus.

## Implementation Notes

Do not modify DamageCalculator in this story unless the existing combat adapter
surface lacks the necessary injection point.

## Out of Scope

- VFX claw trails.
- Skill-tree crit-damage modifiers.

## QA Test Cases

- **AC-1**: Bonus applied.
  - Given: Cat Claw and an active dodge-counter timer.
  - When: a hit is confirmed.
  - Then: combat adapter receives `set_crit_window_bonus(3)`.

- **AC-2**: Bonus expires.
  - Given: Cat Claw dodge-counter timer has elapsed.
  - When: a hit is confirmed.
  - Then: no crit bonus is sent.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/weapon/story_005_cat_claw_counter_crit_test.gd`.

**Status**: [ ] Not yet created

## Dependencies

- Depends on: Story 004.
- Unlocks: Story 006.
