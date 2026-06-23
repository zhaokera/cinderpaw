# Story 005: Entity Death Cleanup + Combat Adapter Integration

> **Epic**: Collision Detection
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/collision-detection.md`
**Requirements**: `TR-collision-007`

**ADR Governing Implementation**: ADR-0002: Signal communication; ADR-0004: Collision detection architecture; ADR-0005: Combat state machine architecture
**ADR Decision Summary**: Collision listens to entity death, deactivates active hitboxes, and exposes a narrow adapter contract that Combat can use for hitbox activation and hurtbox state changes.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Signal connection and active hitbox cleanup are pure GDScript.

**Control Manifest Rules (Core)**:
- Required: Component-to-component communication uses direct calls on the same entity and signals across entities.
- Required: Collision provides `activate_hitbox()` and `set_hurtbox_state()` for Combat.
- Forbidden: Presentation must never be called directly from Core.
- Guardrail: Signal overhead <0.1ms/frame.

---

## Acceptance Criteria

- [x] CollisionComponent can connect to a HealthComponent-compatible `on_death` signal.
- [x] When the owning entity dies, all active hitboxes are deactivated.
- [x] Death cleanup leaves hurtbox state safe and does not emit extra hit events.
- [x] Combat can set the CollisionComponent as its hurtbox/collision adapter and receive `on_hit_confirmed` events through the existing Story 007 Combat path.

## Implementation Notes

- Add a narrow `set_health_adapter(health_adapter)` or equivalent connection helper if needed.
- Avoid making Collision depend directly on HealthComponent class names.
- Keep Combat integration duck-typed so tests can use fake adapters.

## Out of Scope

- Death animation, VFX, audio, or respawn behavior.
- Save/load registration.

---

## QA Test Cases

- **AC-1**: Death cleanup
  - Given: A CollisionComponent has multiple active hitboxes
  - When: a compatible death signal fires
  - Then: all hitboxes become inactive and no hit events emit afterward
  - Edge cases: repeated death signals are idempotent

- **AC-2**: Combat adapter integration
  - Given: CombatComponent is connected to CollisionComponent
  - When: Collision emits a confirmed hit
  - Then: Combat receives metadata through its existing hit-confirmation path
  - Edge cases: missing Combat adapter does not crash Collision

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/collision/story_005_entity_death_cleanup_combat_adapter_integration_test.gd` — must exist and pass

**Status**: [x] Created and passing

---

## Dependencies

- Depends on: Story 004 Multi-Target Hits + Duplicate Suppression
- Unlocks: AI Framework, Combat Presentation, and Weapon Styles collision-specific mechanisms

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: CollisionComponent can connect to a HealthComponent-compatible `on_death` signal. | `tests/unit/collision/story_005_entity_death_cleanup_combat_adapter_integration_test.gd::test_health_adapter_death_signal_deactivates_all_active_hitboxes`; `test_repeated_or_foreign_death_signals_are_safe` | COVERED |
| AC-2: When the owning entity dies, all active hitboxes are deactivated. | `tests/unit/collision/story_005_entity_death_cleanup_combat_adapter_integration_test.gd::test_health_adapter_death_signal_deactivates_all_active_hitboxes` | COVERED |
| AC-3: Death cleanup leaves hurtbox state safe and does not emit extra hit events. | `tests/unit/collision/story_005_entity_death_cleanup_combat_adapter_integration_test.gd::test_death_cleanup_sets_hurtbox_safe_and_blocks_late_hit_events` | COVERED |
| AC-4: Combat can set the CollisionComponent as its hurtbox/collision adapter and receive `on_hit_confirmed` events through the existing Story 007 Combat path. | `tests/unit/collision/story_005_entity_death_cleanup_combat_adapter_integration_test.gd::test_combat_can_use_collision_as_hurtbox_and_hit_adapter` | COVERED |

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 4/4 passing
**Deviations**: None
**Implementation**: Added `CollisionComponent.set_health_adapter()` for duck-typed `on_death` signal wiring, `deactivate_all_hitboxes()` for terminal cleanup, and death handling that ignores foreign entity deaths, idempotently clears active hitboxes, and leaves the hurtbox in `gone` state. Combat integration used the existing Story 007 `set_hurtbox_adapter()` / `set_collision_adapter()` path.
**Test Evidence**:
- TDD RED: `reports/report_177/` — Story 005 test suite failed because `CollisionComponent.set_health_adapter()` did not exist.
- Story suite: `reports/report_178/` — 4/4 passing
- Collision suite: `reports/report_179/` — 23/23 passing
- Full unit suite: `reports/report_180/` — 197/197 passing
- Static/startup checks: `godot --headless --path . --quit`, `git diff --check`, trailing-whitespace scan, and changed-method length scan passed during closure.
**Code Review**: Local automated review complete against ADR-0002, ADR-0004, ADR-0005, `TR-collision-007`, and Core control-manifest collision/combat rules. Specialist QA/LP subagent gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
