# Story 005: Boss Phase + Focus Mode Signal Integration

> **Epic**: AI Framework
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/ai-framework.md`
**Requirements**: `TR-ai-004`, `TR-ai-005`

**ADR Governing Implementation**: ADR-0002: Signal communication; ADR-0006: AI behavior system architecture
**ADR Decision Summary**: AI listens to boss phase and focus-mode signals. Boss phase changes switch future pattern sets; focus mode adds `windup_extension_frames` only to newly started attacks.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Signal connection and integer frame adjustments are pure GDScript.

**Control Manifest Rules (Core)**:
- Required: Signal connect uses typed `signal.connect(callable)`.
- Required: Focus mode integration appends windup extension frames.
- Forbidden: Never use EventBus or centralized event bus.
- Guardrail: Signal overhead <0.1ms/frame.

---

## Acceptance Criteria

- [x] AI can connect to HealthComponent-compatible `on_focus_mode_changed(entity_id, active, metadata)` and legacy bool-only focus signals.
- [x] Focus mode active applies `windup_extension_frames` to newly started attacks.
- [x] Focus changes do not alter attacks already in startup/active/recovery.
- [x] AI can connect to `on_boss_phase_change(entity_id, phase, hp_percentage)` and store the current phase.
- [x] Boss phase changes switch future attack pattern sets when phase-specific patterns exist.

## Implementation Notes

- Keep signal adapters duck-typed so tests can use fake Health adapters.
- Do not implement Boss-specific summons or arena changes in AI; those belong to Boss Configuration.

## Out of Scope

- Boss phase transition animation/invulnerability.
- Boss-specific special attacks.
- Weighted pattern selection beyond phase set lookup.

---

## QA Test Cases

- **AC-1**: Focus windup extension
  - Given: focus active metadata includes windup_extension_frames 6
  - When: a new attack starts
  - Then: effective startup is base startup + 6
  - Edge cases: focus changes mid-attack do not change current effective startup

- **AC-2**: Boss phase pattern switching
  - Given: phase 1 and phase 2 pattern sets
  - When: boss phase signal emits phase 2 for this entity
  - Then: future attacks use phase 2 patterns
  - Edge cases: foreign entity phase signal is ignored

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/ai/story_005_boss_phase_focus_mode_signal_integration_test.gd` — must exist and pass

**Status**: [x] Created and passing

## Dependencies

- Depends on: Story 003 Data-Driven Attack Pattern Loading; Story 004 Attack Phase Execution + Collision Adapter
- Unlocks: Boss Configuration epic

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Health-compatible and legacy focus signal connection | `tests/unit/ai/story_005_boss_phase_focus_mode_signal_integration_test.gd::test_health_focus_signal_adds_windup_to_new_attacks_only`; `test_legacy_bool_only_focus_signal_uses_default_windup_extension` | COVERED |
| AC-2: Focus mode appends windup to newly started attacks | `tests/unit/ai/story_005_boss_phase_focus_mode_signal_integration_test.gd::test_health_focus_signal_adds_windup_to_new_attacks_only` | COVERED |
| AC-3: Mid-attack focus changes do not alter current attack startup | `tests/unit/ai/story_005_boss_phase_focus_mode_signal_integration_test.gd::test_health_focus_signal_adds_windup_to_new_attacks_only` | COVERED |
| AC-4: Boss phase signal stores current phase and filters entity id | `tests/unit/ai/story_005_boss_phase_focus_mode_signal_integration_test.gd::test_boss_phase_signal_stores_current_phase_and_ignores_foreign_entity` | COVERED |
| AC-5: Phase-specific patterns drive future attacks | `tests/unit/ai/story_005_boss_phase_focus_mode_signal_integration_test.gd::test_boss_phase_switches_future_pattern_sets_when_available` | COVERED |

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 5/5 passing
**Deviations**: None
**Test Evidence**:
- RED: Story005 first failed on missing `AIComponent.set_entity_id()`, `set_health_adapter()`, focus startup query, and boss phase APIs (`reports/report_204/`).
- GREEN: Story005 suite 5/5 passing after implementation (`reports/report_205/`).
- AI regression: `tests/unit/ai` 24/24 passing (`reports/report_206/`).
- Full regression: `tests/unit` 221/221 passing (`reports/report_207/`).
- Godot/MCP runtime: `godot --headless --path . --quit` exits 0 and logs `[godot_ai game_helper] registered mcp capture`; main scene smoke exits 0 with `reports/ai_story005_main_scene_smoke.log`.
- Static checks: `git diff --check`, trailing-whitespace scan, and changed-method length scan passed.
**Code Review**: Local review complete against ADR-0002, ADR-0006, `docs/architecture/control-manifest.md`, TR-ai-004, TR-ai-005, and Story005 test evidence. Specialist QA/LP gates were not spawned because no multi-agent delegation tool was exposed in this thread.
