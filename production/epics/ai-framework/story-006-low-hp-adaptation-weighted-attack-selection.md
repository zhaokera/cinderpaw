# Story 006: Low-HP Adaptation + Weighted Attack Selection

> **Epic**: AI Framework
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/ai-framework.md`
**Requirements**: `TR-ai-009`, `TR-ai-010`

**ADR Governing Implementation**: ADR-0006: AI behavior system architecture
**ADR Decision Summary**: AI queries health percentage for low-HP FLEE/berserk behavior and uses weighted random attack selection with base, phase, and HP modifiers clamped to the GDD range.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Deterministic selection can use injectable roll values in tests.

**Control Manifest Rules (Core)**:
- Required: AI behavior machine includes FLEE state.
- Required: Attack patterns are data-driven.
- Guardrail: AI decisions <1ms/frame per entity.

---

## Acceptance Criteria

- [x] AI queries a HealthComponent-compatible adapter for HP percentage.
- [x] If HP <20% and flee is enabled, AI transitions to FLEE from combat states.
- [x] If HP <30%, berserk mode applies attack speed modifier 1.2 to future pattern timing.
- [x] Attack selection computes `base_weight * phase_modifier * hp_modifier` and clamps output to 0.05-40.0.
- [x] Weighted selection is deterministic in tests through an injectable roll value.

## Implementation Notes

- Keep Health adapter duck-typed.
- Do not implement navigation or path movement for FLEE; only state and selection behavior belong here.
- Preserve predictable enemy behavior; weighted selection should be testable and reproducible.

## Out of Scope

- Movement pathfinding for FLEE.
- Boss summons, arena changes, and reward logic.
- Presentation feedback for berserk or flee states.

---

## QA Test Cases

- **AC-1**: Low-HP state adaptation
  - Given: health percentage below flee threshold and flee enabled
  - When: AI evaluates HP behavior
  - Then: state changes to FLEE
  - Edge cases: flee disabled, HP above threshold

- **AC-2**: Weighted attack selection
  - Given: patterns with base, phase, and HP modifiers
  - When: selection runs with a deterministic roll
  - Then: the expected pattern id is selected and weights are clamped
  - Edge cases: zero/negative weight, overlarge weight

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/ai/story_006_low_hp_adaptation_weighted_attack_selection_test.gd` — must exist and pass

**Status**: [x] Created and passing

## Dependencies

- Depends on: Story 003 Data-Driven Attack Pattern Loading; Story 005 Boss Phase + Focus Mode Signal Integration
- Unlocks: Boss Configuration and enemy tuning pass

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Query HealthComponent-compatible HP percentage | `tests/unit/ai/story_006_low_hp_adaptation_weighted_attack_selection_test.gd::test_low_hp_queries_health_and_enters_flee_from_chase_when_enabled`; `test_flee_disabled_keeps_combat_state_but_still_queries_health` | COVERED |
| AC-2: HP <20% with flee enabled enters FLEE from combat state | `tests/unit/ai/story_006_low_hp_adaptation_weighted_attack_selection_test.gd::test_low_hp_queries_health_and_enters_flee_from_chase_when_enabled` | COVERED |
| AC-3: HP <30% applies 1.2 berserk attack speed to future timing | `tests/unit/ai/story_006_low_hp_adaptation_weighted_attack_selection_test.gd::test_berserk_speed_modifier_applies_to_future_pattern_timing` | COVERED |
| AC-4: Selection weight is base * phase * hp and clamped 0.05-40.0 | `tests/unit/ai/story_006_low_hp_adaptation_weighted_attack_selection_test.gd::test_attack_weight_computation_clamps_base_phase_hp_product` | COVERED |
| AC-5: Weighted selection supports injectable deterministic roll | `tests/unit/ai/story_006_low_hp_adaptation_weighted_attack_selection_test.gd::test_weighted_selection_uses_injected_roll_value` | COVERED |

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 5/5 passing
**Deviations**: None
**Test Evidence**:
- RED: Story006 first failed on missing low-HP behavior, HP query, weight-list, and attack selection APIs (`reports/report_208/`).
- GREEN: Story006 suite 5/5 passing after implementation (`reports/report_209/`).
- AI regression: `tests/unit/ai` 29/29 passing (`reports/report_210/`).
- Full regression: `tests/unit` 226/226 passing (`reports/report_211/`).
- Godot/MCP runtime: `godot --headless --path . --quit` exits 0 and logs `[godot_ai game_helper] registered mcp capture`; main scene smoke exits 0 with `reports/ai_story006_main_scene_smoke.log`.
- Static checks: `git diff --check`, trailing-whitespace scan, and changed-method length scan passed.
**Code Review**: Local review complete against ADR-0006, `docs/architecture/control-manifest.md`, TR-ai-009, TR-ai-010, and Story006 test evidence. Specialist QA/LP gates were not spawned because no multi-agent delegation tool was exposed in this thread.
