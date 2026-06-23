# Story 004: Attack Phase Execution + Collision Adapter

> **Epic**: AI Framework
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/ai-framework.md`
**Requirements**: `TR-ai-007`, `TR-ai-008`

**ADR Governing Implementation**: ADR-0004: Collision detection architecture; ADR-0006: AI behavior system architecture
**ADR Decision Summary**: AI attack execution is a three-phase startup/active/recovery sequence. At the exact startup boundary, AI calls a CollisionComponent-compatible `activate_hitbox()` adapter.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Pure frame counting and adapter calls; no new engine APIs.

**Control Manifest Rules (Core)**:
- Required: 3-phase attack execution: startup -> active -> recovery.
- Required: AI attack execution activates CollisionComponent hitboxes.
- Forbidden: Never use PhysicsBody for hit detection.
- Guardrail: AI decisions <1ms/frame per entity.

---

## Acceptance Criteria

- [x] Starting an attack enters ATTACK state and startup phase at frame 0.
- [x] At the exact effective startup frame, AI calls `activate_hitbox(hitbox_id, active_frames, offset, size, metadata)` once.
- [x] Active and recovery frames advance deterministically and return AI to IDLE after recovery.
- [x] Parry/counter interruption during startup enters STUN and prevents late hitbox activation.
- [x] Missing Collision adapter does not crash the AI.

## Implementation Notes

- Use the pattern data loaded by Story 003.
- Keep Collision adapter duck-typed.
- Do not calculate damage in AI; Collision/Combat/Damage systems handle downstream effects.

## Out of Scope

- Weighted pattern selection.
- Visual attack telegraphs.
- Boss phase pattern switching.

---

## QA Test Cases

- **AC-1**: Startup boundary activation
  - Given: a pattern with startup 3, active 4, recovery 5
  - When: attack frames advance three times
  - Then: Collision adapter receives one `activate_hitbox()` call with active_frames 4
  - Edge cases: no double activation while staying active

- **AC-2**: Attack lifecycle
  - Given: an active attack
  - When: active and recovery frames complete
  - Then: state returns to IDLE
  - Edge cases: missing adapter, interruption during startup

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/ai/story_004_attack_phase_execution_collision_adapter_test.gd` — must exist and pass

**Status**: [x] Created and passing

## Dependencies

- Depends on: Story 001 AI State Machine + Active Enemy Count; Story 003 Data-Driven Attack Pattern Loading
- Unlocks: Boss Configuration, Combat Presentation, and enemy combat loop integration

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Starting an attack enters ATTACK startup at frame 0 | `tests/unit/ai/story_004_attack_phase_execution_collision_adapter_test.gd::test_start_attack_enters_attack_state_and_startup_frame_zero` | COVERED |
| AC-2: Startup boundary activates one Collision hitbox with metadata | `tests/unit/ai/story_004_attack_phase_execution_collision_adapter_test.gd::test_startup_boundary_activates_collision_hitbox_once_with_metadata` | COVERED |
| AC-3: Active/recovery frames finish deterministically into IDLE | `tests/unit/ai/story_004_attack_phase_execution_collision_adapter_test.gd::test_active_and_recovery_frames_return_to_idle_deterministically` | COVERED |
| AC-4: Startup interruption enters STUN and prevents late activation | `tests/unit/ai/story_004_attack_phase_execution_collision_adapter_test.gd::test_startup_interruption_enters_stun_and_prevents_late_activation` | COVERED |
| AC-5: Missing Collision adapter is safe | `tests/unit/ai/story_004_attack_phase_execution_collision_adapter_test.gd::test_missing_collision_adapter_does_not_crash_attack_lifecycle` | COVERED |

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 5/5 passing
**Deviations**: None
**Test Evidence**:
- RED: Story004 first failed on missing `AIComponent.start_attack()`, `set_collision_adapter()`, and attack phase APIs (`reports/report_200/`).
- GREEN: Story004 suite 5/5 passing after implementation (`reports/report_201/`).
- AI regression: `tests/unit/ai` 19/19 passing (`reports/report_202/`).
- Full regression: `tests/unit` 216/216 passing (`reports/report_203/`).
- Godot/MCP runtime: `godot --headless --path . --quit` exits 0 and logs `[godot_ai game_helper] registered mcp capture`; main scene smoke exits 0 with `reports/ai_story004_main_scene_smoke.log`.
- Static checks: `git diff --check`, trailing-whitespace scan, and changed-method length scan passed.
**Code Review**: Local review complete against ADR-0004, ADR-0006, `docs/architecture/control-manifest.md`, TR-ai-007, TR-ai-008, and Story004 test evidence. Specialist QA/LP gates were not spawned because no multi-agent delegation tool was exposed in this thread.
