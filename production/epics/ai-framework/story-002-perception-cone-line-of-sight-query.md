# Story 002: Perception Cone + Line-of-Sight Query

> **Epic**: AI Framework
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/ai-framework.md`
**Requirements**: `TR-ai-002`

**ADR Governing Implementation**: ADR-0006: AI behavior system architecture
**ADR Decision Summary**: AI perception uses configurable radius and angle with a RayCast2D-style line-of-sight query. NavigationAgent2D is not used for MVP AI.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Use deterministic geometry helpers in tests and an injectable line-of-sight adapter for engine physics queries.

**Control Manifest Rules (Core)**:
- Required: RayCast2D-style perception for line-of-sight and angle/distance checks.
- Forbidden: Never use NavigationAgent2D for AI pathfinding.
- Guardrail: AI decisions <1ms/frame per entity.

---

## Acceptance Criteria

- [x] Perception returns visible only when target is within radius, inside the cone, and line-of-sight is clear.
- [x] Perception radius clamps to the GDD safe range 100-500px.
- [x] Perception angle clamps to the GDD safe range 60-180 degrees.
- [x] IDLE transitions to CHASE when the target is visible.
- [x] CHASE transitions to PATROL after target is lost for the configured delay.

## Implementation Notes

- Add deterministic `detect_target(target_position, facing_direction)` and line-of-sight adapter support.
- Keep physics queries injectable so unit tests do not depend on TileMapLayer scenes.
- Do not implement attack pattern execution in this story.

## Out of Scope

- Attack range to ATTACK transition details beyond state entry trigger.
- Collision hitbox activation.
- Boss phase and focus-mode integrations.

---

## QA Test Cases

- **AC-1**: Cone visibility
  - Given: configured radius, angle, facing direction, and clear line-of-sight
  - When: target is inside the cone
  - Then: `can_see` is true with distance and direction populated
  - Edge cases: outside radius, outside angle, blocked line-of-sight

- **AC-2**: State transitions from perception
  - Given: AI in IDLE or CHASE
  - When: visibility appears or remains lost for the chase delay
  - Then: state changes to CHASE or PATROL respectively
  - Edge cases: loss timer resets when target becomes visible again

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/ai/story_002_perception_cone_line_of_sight_query_test.gd` — must exist and pass

**Status**: [x] Created and passing

## Dependencies

- Depends on: Story 001 AI State Machine + Active Enemy Count
- Unlocks: Story 004 Attack Phase Execution + Collision Adapter

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: Perception returns visible only when target is within radius, inside the cone, and line-of-sight is clear. | `tests/unit/ai/story_002_perception_cone_line_of_sight_query_test.gd::test_detect_target_requires_radius_cone_and_clear_line_of_sight` | COVERED |
| AC-2: Perception radius clamps to the GDD safe range 100-500px. | `tests/unit/ai/story_002_perception_cone_line_of_sight_query_test.gd::test_perception_radius_clamps_to_gdd_safe_range` | COVERED |
| AC-3: Perception angle clamps to the GDD safe range 60-180 degrees. | `tests/unit/ai/story_002_perception_cone_line_of_sight_query_test.gd::test_perception_angle_clamps_to_gdd_safe_range` | COVERED |
| AC-4: IDLE transitions to CHASE when the target is visible. | `tests/unit/ai/story_002_perception_cone_line_of_sight_query_test.gd::test_idle_transitions_to_chase_when_target_visible` | COVERED |
| AC-5: CHASE transitions to PATROL after target is lost for the configured delay. | `tests/unit/ai/story_002_perception_cone_line_of_sight_query_test.gd::test_chase_transitions_to_patrol_after_target_lost_delay` | COVERED |

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 5/5 passing
**Deviations**: None
**Implementation**:
- Extended `src/core/ai_component.gd` with configurable perception radius, perception angle, and chase-lost delay.
- Added deterministic `detect_target(target_position, facing_direction)` returning visibility, distance, direction, radius, cone, and line-of-sight fields.
- Added `set_line_of_sight_adapter()` and `set_perception_providers()` so unit tests and later enemy scenes can inject physics visibility, target position, and facing direction without requiring a full TileMapLayer scene.
- Added frame-driven IDLE/PATROL → CHASE and CHASE → PATROL transitions through the existing Story001 state machine and active-enemy counter.
- Runtime fallback uses `PhysicsRayQueryParameters2D.create(origin, target, 1 << 4)` for RayCast2D-style environment line-of-sight checks when no adapter is injected.

**Test Evidence**:
- TDD RED: `reports/report_187/` — Story002 suite failed on missing `set_line_of_sight_adapter()` and `configure_perception()` APIs.
- Story suite: `reports/report_188/` — 5/5 passing.
- AI suite: `reports/report_189/` — 10/10 passing across Story001 and Story002.
- Full unit suite: `reports/report_190/` — 207/207 passing.
- Godot startup: `godot --headless --path . --quit` exited 0.
- Main scene smoke: `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/ai_story002_main_scene_smoke.log` exited 0.
- MCP/game-helper evidence: startup and smoke logs show `[godot_ai game_helper] registered mcp capture (debugger active=false, logger=true)`. No direct Godot editor MCP control tool was exposed in this Codex tool session, so validation used the project-registered MCP helper plus Godot CLI/headless checks.
- Static checks: `git diff --check`, trailing-whitespace scan, and method-length scan passed.

**Code Review**:
- Local review passed against ADR-0006, `docs/architecture/control-manifest.md`, TR-ai-002, GDD perception formula F1, and Story002 unit test evidence.
- Confirmed no `NavigationAgent2D`, EventBus, string-based signal connect, PhysicsBody hit-detection dependency, or class-per-state pattern was introduced.
- Full specialist subagent gates were not spawned because no explicit subagent delegation was requested in this turn.

**Notes**:
- Full unit verification still emits a non-blocking DataManager warning for the pre-existing `enemy_stats` domain lacking a schema. This belongs with Story003 data-driven attack pattern loading/schema cleanup.
