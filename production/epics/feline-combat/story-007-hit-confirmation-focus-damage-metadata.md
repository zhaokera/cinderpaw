# Story 007: Hit Confirmation + Focus Damage Metadata

> **Epic**: Feline Combat
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/feline-combat.md`
**Requirements**: `TR-combat-006`, `TR-combat-010`

**ADR Governing Implementation**: ADR-0002: Signal communication; ADR-0004: Collision detection architecture; ADR-0005: Combat state machine architecture
**ADR Decision Summary**: Collision confirms hits, Combat assembles attack metadata and DamageCalculator parameters, Health applies the result, and Presentation only listens to Combat signals.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Use typed methods and dictionaries for provisional adapters; do not require Area2D or AnimationPlayer in unit tests.

**Control Manifest Rules (Core)**:
- Required: `on_hit_confirmed` carries hit payload from Collision to Combat.
- Required: Focus mode integration adds +1 crit window bonus.
- Required: Signal naming and typed signal connections.
- Forbidden: Presentation layer must never be called directly from Core.
- Guardrail: Signal overhead <0.1ms/frame.

---

## Acceptance Criteria

- [x] Combat can receive a hit-confirmed payload from a provisional CollisionComponent adapter.
- [x] Combat assembles attack metadata containing attack_type, weapon_id, hit_frame, combo_index, parry_timing, and crit_window_bonus.
- [x] `on_focus_mode_changed(true)` sets focus mode active and adds +1 crit window bonus to outgoing damage metadata.
- [x] `on_focus_mode_changed(false)` clears the bonus.
- [x] Combat emits `on_attack_hit(metadata)` after a confirmed hit for Presentation consumers.
- [x] `get_battle_stats()` reports total damage dealt, hits landed, parries, dodges, and cat energy snapshot for Health death metadata.
- [x] Missing DamageCalculator, HealthComponent, or CollisionComponent adapters degrade safely without crashing tests.

## Implementation Notes

- Add `handle_focus_mode_changed(active: bool) -> void`.
- Add `on_hit_confirmed(event: Variant) -> void` that accepts a Dictionary or typed object by duck typing until HitEvent exists.
- Keep DamageCalculator call optional or injectable; Story 007 is responsible for metadata assembly and signal emission even when no target HealthComponent exists.
- Update battle stats only after successful confirmed hit metadata is produced.

## Out of Scope

- Combat Presentation frame stop, shake, particles, afterimages, and screen flash.
- Audio feedback.
- Exact HitEvent data class implementation if Collision Epic is not complete yet.

---

## QA Test Cases

- **AC-1**: Hit metadata assembly
  - Given: Combat has combo_index 1 and weapon_id cat_claw
  - When: a hit-confirmed payload arrives
  - Then: outgoing metadata includes attack_type, weapon_id, hit_frame, combo_index, parry_timing, and crit_window_bonus
  - Edge cases: missing optional fields use safe defaults

- **AC-2**: Focus crit bonus
  - Given: focus mode is inactive
  - When: focus mode changes true then false
  - Then: outgoing crit_window_bonus is 1 while active and 0 after deactivation
  - Edge cases: duplicate focus signals do not double-stack the bonus

- **AC-3**: Signal and battle stats
  - Given: a listener records `on_attack_hit`
  - When: a hit is confirmed
  - Then: exactly one signal is emitted and battle stats increment once
  - Edge cases: no adapter dependencies still emits metadata safely

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/combat/story_007_hit_confirmation_focus_damage_metadata_test.gd` — must exist and pass

**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: first run failed on missing `set_collision_adapter`, `handle_focus_mode_changed`, `on_hit_confirmed`, and damage/health adapter setter APIs (`reports/report_156/`).
- Story suite: `res://tests/unit/combat/story_007_hit_confirmation_focus_damage_metadata_test.gd` — 5/5 passing, report `reports/report_157/`.
- Combat regression: `res://tests/unit/combat` — 40/40 passing, report `reports/report_158/`.
- Full unit regression: `res://tests/unit` — 174/174 passing, report `reports/report_159/`.
- Static checks: `godot --headless --path . --quit`, `git diff --check`, trailing whitespace scan, and method-length quick check passed.

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 7/7 passing
**Deviations**: None
**Test Evidence**: `tests/unit/combat/story_007_hit_confirmation_focus_damage_metadata_test.gd`
**Code Review**: Local automated review complete; QA/LP subagent gates skipped because current tool policy requires explicit user delegation for subagents. Story closure used the user's standing approval for local project writes.

**Traceability**:

| Criterion | Test | Status |
|-----------|------|--------|
| Collision adapter signal reaches Combat | `test_collision_adapter_hit_builds_attack_metadata_and_grants_light_energy` | COVERED |
| Hit metadata includes damage request fields | `test_collision_adapter_hit_builds_attack_metadata_and_grants_light_energy` | COVERED |
| Focus true adds exactly +1 crit-window bonus | `test_focus_mode_adds_one_crit_window_bonus_without_stacking` | COVERED |
| Focus false clears crit-window bonus | `test_focus_mode_adds_one_crit_window_bonus_without_stacking` | COVERED |
| Combat emits `on_attack_hit(metadata)` | `test_missing_adapters_still_emit_hit_metadata_safely` | COVERED |
| Battle stats include hit damage, parry, dodge, cat energy | `test_battle_stats_track_hit_damage_parry_dodge_and_cat_energy_snapshot` | COVERED |
| Missing adapters degrade safely | `test_missing_adapters_still_emit_hit_metadata_safely` | COVERED |
| Damage and Health adapters receive confirmed hit payload | `test_damage_and_health_adapters_receive_confirmed_hit_payload` | COVERED |

---

## Dependencies

- Depends on: Story 006 Cat Energy + Special/Ultimate Gates
- Unlocks: Weapon Styles, Combat Presentation, Audio, HUD/UI, and Death metadata integration
