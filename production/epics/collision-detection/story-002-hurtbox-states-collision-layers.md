# Story 002: Hurtbox States + Collision Layers

> **Epic**: Collision Detection
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/collision-detection.md`
**Requirements**: `TR-collision-003`, `TR-collision-004`

**ADR Governing Implementation**: ADR-0004: Collision detection architecture
**ADR Decision Summary**: Hurtbox is one `Area2D` per entity with normal, shrunk, and gone states. Collision layers use Godot layer/mask bits for player attack, enemy attack, player hurt, enemy hurt, and environment.

**Engine**: Godot 4.7 | **Risk**: LOW
**Engine Notes**: Area2D monitorable and layer/mask APIs are stable.

**Control Manifest Rules (Core)**:
- Required: One Hurtbox per entity with 3 states: normal/shrunk/gone.
- Required: 5 collision layers: player_attack, enemy_attack, player_hurt, enemy_hurt, environment.
- Forbidden: Never use PhysicsBody for hit detection.
- Guardrail: Collision detection budget is <3ms/frame.

---

## Acceptance Criteria

- [x] `set_hurtbox_state("normal")` makes the hurtbox monitorable at full configured size.
- [x] `set_hurtbox_state("shrunk")` makes the hurtbox monitorable at 50% configured size.
- [x] `set_hurtbox_state("gone")` makes the hurtbox non-monitorable.
- [x] Unknown hurtbox states fall back to `normal`.
- [x] Player/enemy/environment layer and mask constants match ADR-0004.
- [x] `configure_entity(entity_id, allegiance)` applies the correct hitbox and hurtbox layer/mask for player and enemy entities.

## Implementation Notes

- Extend `CollisionComponent` with entity configuration and one managed Hurtbox Area2D.
- Keep layer constants public and named after the GDD layers.
- Use `RectangleShape2D` for default hitbox/hurtbox shapes.

## Out of Scope

- Overlap detection and hit signal emission.
- Death cleanup.
- Debug visualization.

---

## QA Test Cases

- **AC-1**: Hurtbox state transitions
  - Given: A configured CollisionComponent
  - When: normal, shrunk, and gone states are applied
  - Then: monitorable state and rectangle sizes match the GDD rules
  - Edge cases: unknown state returns to normal

- **AC-2**: Collision layers
  - Given: Player and enemy CollisionComponents
  - When: entities are configured
  - Then: hitbox and hurtbox layer/mask values match ADR-0004
  - Edge cases: environment masks both player and enemy hurt layers

---

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/collision/story_002_hurtbox_states_collision_layers_test.gd` — must exist and pass

**Status**: [x] Created and passing

**Evidence 2026-06-23**:
- TDD red: Story 002 suite failed on missing `configure_entity()` and collision layer constants (`reports/report_166/`).
- Story suite: `reports/report_167/` — 5/5 passing.
- Collision suite: `reports/report_168/` — 10/10 passing.
- Full unit suite: `reports/report_169/` — 184/184 passing.
- Static checks: `godot --headless --path . --quit`, `git diff --check`, trailing-whitespace scan, and method-length scan all passed.

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| `set_hurtbox_state("normal")` makes the hurtbox monitorable at full configured size. | `tests/unit/collision/story_002_hurtbox_states_collision_layers_test.gd::test_hurtbox_state_transitions_apply_monitorable_and_size` | COVERED |
| `set_hurtbox_state("shrunk")` makes the hurtbox monitorable at 50% configured size. | `tests/unit/collision/story_002_hurtbox_states_collision_layers_test.gd::test_hurtbox_state_transitions_apply_monitorable_and_size` | COVERED |
| `set_hurtbox_state("gone")` makes the hurtbox non-monitorable. | `tests/unit/collision/story_002_hurtbox_states_collision_layers_test.gd::test_hurtbox_state_transitions_apply_monitorable_and_size` | COVERED |
| Unknown hurtbox states fall back to `normal`. | `tests/unit/collision/story_002_hurtbox_states_collision_layers_test.gd::test_unknown_hurtbox_state_falls_back_to_normal` | COVERED |
| Player/enemy/environment layer and mask constants match ADR-0004. | `tests/unit/collision/story_002_hurtbox_states_collision_layers_test.gd::test_collision_layer_constants_match_adr_bitmasks` | COVERED |
| `configure_entity(entity_id, allegiance)` applies the correct hitbox and hurtbox layer/mask for player and enemy entities. | `tests/unit/collision/story_002_hurtbox_states_collision_layers_test.gd::test_player_configuration_applies_hitbox_and_hurtbox_layers`; `test_enemy_configuration_applies_to_existing_hitboxes` | COVERED |

---

## Dependencies

- Depends on: Story 001 HitboxArea + Activation Lifecycle
- Unlocks: Story 003 Frame-Level Hit Detection + HitEvent Signal

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 6/6 passing
**Deviations**: None. Story 002 intentionally stops before overlap detection, `HitEvent` signal emission, death cleanup, and debug visualization; those remain assigned to Stories 003-005 or downstream Presentation work.
**Test Evidence**: Logic unit test at `tests/unit/collision/story_002_hurtbox_states_collision_layers_test.gd`; story suite `reports/report_167/`; collision suite `reports/report_168/`; full unit suite `reports/report_169/`.
**Code Review**: Local automated review complete against ADR-0004, Core control manifest, and TR-collision-003/TR-collision-004. QL/LP subagent gates skipped because the current multi-agent tool policy requires an explicit user delegation request before spawning subagents.
