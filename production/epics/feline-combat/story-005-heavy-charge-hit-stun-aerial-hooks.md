# Story 005: Heavy Charge + Hit Stun + Aerial Hooks

> **Epic**: Feline Combat
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/feline-combat.md`
**Requirements**: `TR-combat-011`, `TR-combat-012`

**ADR Governing Implementation**: ADR-0005: Combat state machine architecture
**ADR Decision Summary**: Combat owns CHARGING, HIT_STUN, and combat-action hooks that later movement/health systems can consume.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Heavy charge and hit-stun timers are deterministic float/frame logic. Aerial bounce should be emitted as a signal or metadata hook until PlayerMovement exists.

**Control Manifest Rules (Core)**:
- Required: Heavy charge uses CHARGING and can be cancelled by dodge or interrupted by hit stun.
- Required: State transitions run from `_physics_process`.
- Forbidden: Do not call Presentation systems from Core.
- Guardrail: Combat state transitions <0.1ms/frame.

---

## Acceptance Criteria

- [x] Holding `heavy_attack` for at least 0.5s and releasing before 1.5s starts a charged heavy attack.
- [x] Holding `heavy_attack` for 1.5s auto-releases a full charge heavy attack.
- [x] Releasing before 0.5s does not fire a charged heavy attack and returns to IDLE or safe default behavior.
- [x] Dodge cancels CHARGING and enters DODGING.
- [x] Damage taken during CHARGING interrupts into HIT_STUN.
- [x] HIT_STUN duration stacks up to 3 times and then clamps.
- [x] Aerial attack hit emits an aerial bounce hook so PlayerMovement can restore a jump later.

## Implementation Notes

- Store `HEAVY_CHARGE_MIN_SEC = 0.5` and `HEAVY_CHARGE_MAX_SEC = 1.5`.
- Add `get_charge_ratio()` returning 0.0-1.0 for later UI, but do not build the UI here.
- Add `on_damage_taken(damage: int) -> void` for Health integration and battle stats.
- Add `on_aerial_hit_confirmed()` or emit `on_aerial_bounce_requested` when an aerial hit is confirmed.

## Out of Scope

- Charge bar UI and charge visual glow.
- PlayerMovement implementation of the bounce.
- Heavy damage formula, which is owned by DamageCalculator.

---

## QA Test Cases

- **AC-1**: Heavy charge thresholds
  - Given: Combat is CHARGING
  - When: charge is released at 0.49s, 1.0s, and 1.5s
  - Then: only 1.0s and 1.5s produce heavy attack release, with 1.5s clamped to full ratio
  - Edge cases: auto-release happens at max charge

- **AC-2**: Charge cancellation and interruption
  - Given: Combat is CHARGING
  - When: dodge is triggered
  - Then: Combat enters DODGING
  - Edge cases: damage taken during CHARGING enters HIT_STUN instead

- **AC-3**: Hit-stun stacking and aerial hook
  - Given: Combat receives repeated damage-taken events
  - When: four hit-stun stacks are requested
  - Then: stacks clamp at 3
  - Edge cases: aerial hit emits one bounce request

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/combat/story_005_heavy_charge_hit_stun_aerial_hooks_test.gd` — must exist and pass

**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first run failed on missing Story 005 heavy charge, hit-stun, and aerial hook APIs/signals (`reports/report_147/`).
- Story suite: `res://tests/unit/combat/story_005_heavy_charge_hit_stun_aerial_hooks_test.gd` — 7/7 passing, report `reports/report_148/`.
- Combat regression: `res://tests/unit/combat` — 29/29 passing, report `reports/report_149/`.
- Full unit regression: `res://tests/unit` — 163/163 passing, report `reports/report_150/`.
- Static checks: `godot --headless --path . --quit`, `git diff --check`, trailing whitespace scan, and method-length quick check passed.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 7/7 passing
**Deviations**: None
**Test Evidence**: `tests/unit/combat/story_005_heavy_charge_hit_stun_aerial_hooks_test.gd`
**Code Review**: Local automated review complete; QA/LP subagent gates skipped because current tool policy requires explicit user delegation for subagents. Story closure used the user's standing approval for local project writes.

**Traceability**:

| Criterion | Test | Status |
|-----------|------|--------|
| Heavy release after 0.5s starts attack | `test_heavy_release_after_minimum_charge_starts_attack` | COVERED |
| Full charge auto-releases at 1.5s | `test_full_charge_auto_releases_at_maximum` | COVERED |
| Early release returns to IDLE without attack | `test_releasing_before_minimum_charge_returns_to_idle_without_attack` | COVERED |
| Dodge cancels CHARGING into DODGING | `test_dodge_cancels_charging_into_dodging` | COVERED |
| Damage taken interrupts CHARGING into HIT_STUN | `test_damage_taken_interrupts_charging_into_hit_stun` | COVERED |
| HIT_STUN stacks clamp at three | `test_hit_stun_duration_stacks_and_clamps_at_three` | COVERED |
| Aerial hit emits bounce hook | `test_aerial_hit_confirmation_emits_bounce_request` | COVERED |

---

## Dependencies

- Depends on: Story 004 Parry Timing Windows + Counter Outcome
- Unlocks: Story 006 Cat Energy + Special/Ultimate Gates
