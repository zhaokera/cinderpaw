# Story 105: Main Scene Gate Prompt Proximity

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + UI/Visual Feel
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-10

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-ability-003`, `TR-explore-001`,
`TR-presentation-001`

**ADR Governing Implementation**: ADR-0004 Scene Tree Composition; ADR-0005
Combat State Machine; ADR-0007 Scene Management; ADR-0018 Player Abilities.

Story104 removed far-away reward prompts from MainScene. The same clutter
remained on ability gates: `Requires Double Jump` and `Requires Dash` could stay
visible from across the arena, competing with Boss2, HUD, reward objects, and
route visuals. Story105 applies the same interaction pattern to
`ExplorationGate`: a gate can stay locked/unlockable, but its prompt only
appears when Cinderpaw is close enough to read and act on it.

## Acceptance Criteria

- [x] `ExplorationGate` supports a finite prompt radius separate from unlock
  radius.
- [x] Gate prompt labels are hidden while the provider is outside prompt radius.
- [x] Gate prompt labels become visible when the provider is inside prompt
  radius but still outside unlock radius.
- [x] Dash, Double Jump, and Parry gate unlock behavior remains unchanged.
- [x] Unlock VFX/SFX, authored Dash gate visual, Factory Route transition, and
  save-state regressions remain green.
- [x] Godot MCP verifies MainScene runs with `project_run.current_run_errors=[]`,
  current game log is clean, and a non-empty screenshot shows no far-away ability
  gate prompt clutter in the Boss2 arena.

## Out of Scope

- Gate art replacement, new image-generation assets, route collision changes,
  camera layout, HUD redesign, or new input prompts.
- Character frame animation changes. This story only adjusts ability gate prompt
  behavior.

## Implementation Notes

- `src/feature/exploration_gate.gd` now exposes `prompt_radius_px`,
  `is_provider_in_prompt_range()`, `get_prompt_text()`, and
  `is_prompt_visible()`.
- Prompt labels are visible only when the gate is not unlocked and the ability
  provider is inside `max(prompt_radius_px, unlock_radius_px)`.
- `_process` refreshes prompt visibility while a Node2D provider exists, and
  still advances unlock feedback VFX when active.
- Unlock radius and unlock activation behavior are unchanged.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/exploration_dash_gate_runtime_test.gd`
- `tests/unit/gameplay/player_double_jump_gate_runtime_test.gd`
- `tests/unit/gameplay/exploration_gate_unlock_feedback_test.gd`
- `tests/unit/gameplay/main_scene_dash_gate_authored_visual_test.gd`
- `tests/unit/gameplay/player_parry_laser_gate_runtime_test.gd`
- `tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/main-scene-gate-prompt-proximity-2026-07-10.md`

**Status**: [x] RED/GREEN focused evidence, related regression, and MCP runtime
evidence complete.

- RED focused: `reports/report_1279/` failed as expected because
  `ExplorationGate` had no prompt visibility API and far-away prompts remained
  visible.
- GREEN focused: `reports/report_1280/` passed Dash and Double Jump gate
  prompt-proximity coverage `5/5`.
- Related regression: `reports/report_1281/` passed Dash, Double Jump, unlock
  feedback, authored Dash visual, Parry gate, and Factory Route shell coverage
  `18/18`.
- Godot MCP evidence:
  `production/qa/evidence/main-scene-gate-prompt-proximity-2026-07-10.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Prompt radius separate from unlock radius | `report_1279`, `report_1280` | COVERED |
| Far-away Dash/DoubleJump prompts hidden | `report_1280`, MCP eval, screenshot | COVERED |
| Near but not unlock-range prompts visible | `report_1280` | COVERED |
| Dash/DoubleJump/Parry unlock behavior remains intact | `report_1281` | COVERED |
| MainScene current-run logs and screenshot verified through MCP | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-07-10
**Criteria**: 6/6 passing
**Deviations**: No new visual asset was required; this is a runtime prompt
behavior pass over existing generated gate visuals.
**QA Evidence**:
`production/qa/evidence/main-scene-gate-prompt-proximity-2026-07-10.md`
