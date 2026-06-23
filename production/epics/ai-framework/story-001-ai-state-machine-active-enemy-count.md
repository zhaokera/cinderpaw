# Story 001: AI State Machine + Active Enemy Count

> **Epic**: AI Framework
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-23

## Context

**GDD**: `design/gdd/ai-framework.md`
**Requirements**: `TR-ai-001`, `TR-ai-006`

**ADR Governing Implementation**: ADR-0006: AI behavior system architecture; ADR-0001: Autoload architecture; ADR-0002: Signal communication
**ADR Decision Summary**: AIComponent is a Core entity component with a six-state enum + match state machine. `get_active_enemy_count()` is backed by a shared counter for enemies currently in CHASE or ATTACK.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Pure GDScript state transitions; no post-cutoff APIs.

**Control Manifest Rules (Core)**:
- Required: Core layer systems are scene components, not Autoloads.
- Required: 6-state AI behavior machine: IDLE / PATROL / CHASE / ATTACK / FLEE / STUN.
- Required: `get_active_enemy_count()` static counter updated on combat-state enter/exit.
- Forbidden: Never use State Pattern class-per-state for this Core FSM.
- Guardrail: AI decisions <1ms/frame per entity.

---

## Acceptance Criteria

- [x] AIComponent starts in IDLE with no active enemy count contribution.
- [x] `change_state()` supports IDLE, PATROL, CHASE, ATTACK, FLEE, and STUN without requiring a full Enemy scene.
- [x] Entering CHASE or ATTACK increments the shared active enemy count once per entity.
- [x] Leaving CHASE or ATTACK decrements the shared active enemy count and never drops below zero.
- [x] `on_state_changed(old_state, new_state)` emits exactly once for real state changes and not for duplicate state requests.

## Implementation Notes

- Create `src/core/ai_component.gd`.
- Use a local enum and `match`-driven processing hooks, matching ADR-0006.
- Keep active-enemy counting deterministic in tests by exposing a reset helper only if needed.
- Do not implement perception, attack phases, data loading, Boss phase switching, or low-HP behavior in this story.

## Out of Scope

- Story 002: perception cone and line-of-sight.
- Story 003: attack pattern loading.
- Story 004: attack execution and CollisionComponent adapter.
- Story 005: Boss phase and focus-mode signal integration.
- Story 006: low-HP adaptation and weighted attack selection.

---

## QA Test Cases

- **AC-1**: Idle defaults
  - Given: a new AIComponent
  - When: it is added to a test tree
  - Then: state is IDLE and active enemy count is 0
  - Edge cases: resetting static count between tests

- **AC-2**: Six-state transition support
  - Given: an AIComponent
  - When: each valid AI state is requested
  - Then: the component enters that state without requiring an Enemy scene
  - Edge cases: duplicate state request emits no signal

- **AC-3**: Active enemy count
  - Given: two AIComponents
  - When: each enters CHASE or ATTACK
  - Then: the shared count increments once per component
  - Edge cases: CHASE -> ATTACK does not double count; ATTACK -> IDLE decrements

## Test Evidence

**Story Type**: Logic
**Required evidence**:
- Logic: `tests/unit/ai/story_001_ai_state_machine_active_enemy_count_test.gd` — must exist and pass

**Status**: [x] Created and passing

## Dependencies

- Depends on: None
- Unlocks: Story 002 Perception Cone + Line-of-Sight Query; Story 004 Attack Phase Execution + Collision Adapter

## Test-Criterion Traceability

| Criterion | Test | Status |
|-----------|------|--------|
| AC-1: AIComponent starts in IDLE with no active enemy count contribution. | `tests/unit/ai/story_001_ai_state_machine_active_enemy_count_test.gd::test_component_starts_idle_without_active_count_contribution` | COVERED |
| AC-2: `change_state()` supports IDLE, PATROL, CHASE, ATTACK, FLEE, and STUN without requiring a full Enemy scene. | `tests/unit/ai/story_001_ai_state_machine_active_enemy_count_test.gd::test_all_ai_states_can_be_entered_without_enemy_scene` | COVERED |
| AC-3: Entering CHASE or ATTACK increments the shared active enemy count once per entity. | `tests/unit/ai/story_001_ai_state_machine_active_enemy_count_test.gd::test_entering_chase_or_attack_counts_each_entity_once` | COVERED |
| AC-4: Leaving CHASE or ATTACK decrements the shared active enemy count and never drops below zero. | `tests/unit/ai/story_001_ai_state_machine_active_enemy_count_test.gd::test_leaving_combat_states_decrements_without_going_negative` | COVERED |
| AC-5: `on_state_changed(old_state, new_state)` emits exactly once for real state changes and not for duplicate state requests. | `tests/unit/ai/story_001_ai_state_machine_active_enemy_count_test.gd::test_state_changed_signal_emits_for_real_changes_only` | COVERED |

## Completion Notes

**Completed**: 2026-06-23
**Criteria**: 5/5 passing
**Deviations**: None
**Implementation**:
- Created `src/core/ai_component.gd` as a Core scene component, not an Autoload.
- Implemented the ADR-0006 six-state enum + `match` processing hooks: IDLE, PATROL, CHASE, ATTACK, FLEE, STUN.
- Implemented `change_state()`, `on_state_changed(old_state, new_state)`, static `get_active_enemy_count()`, and deterministic `reset_active_enemy_count()` for tests.
- Added per-instance active-count contribution tracking and `_exit_tree()` cleanup so CHASE/ATTACK count once per entity and cannot leak after node teardown.

**Test Evidence**:
- TDD RED: first Story001 run failed because `src/core/ai_component.gd` did not exist.
- Story suite: `reports/report_184/` — 5/5 passing.
- AI suite: `reports/report_185/` — 5/5 passing.
- Full unit suite: `reports/report_186/` — 202/202 passing.
- Godot startup: `godot --headless --path . --quit` exited 0.
- Main scene smoke: `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/ai_story001_main_scene_smoke.log` exited 0.
- MCP/game-helper evidence: Godot startup and smoke logs show `[godot_ai game_helper] registered mcp capture (debugger active=false, logger=true)`. No direct Godot editor MCP control tool was exposed in this Codex tool session, so runtime validation used the project-registered MCP helper plus Godot CLI/headless checks.
- Static checks: `git diff --check`, trailing-whitespace scan, and method-length scan passed.

**Code Review**:
- Local review passed against ADR-0001, ADR-0002, ADR-0006, `docs/architecture/control-manifest.md`, TR-ai-001, TR-ai-006, and Story001 unit test evidence.
- Full specialist subagent gates were not spawned because no explicit subagent delegation was requested in this turn.

**Notes**:
- Full unit verification still emits a non-blocking DataManager warning for the pre-existing `enemy_stats` domain lacking a schema. This belongs with Story003 data-driven attack pattern loading/schema cleanup, not Story001 FSM behavior.
