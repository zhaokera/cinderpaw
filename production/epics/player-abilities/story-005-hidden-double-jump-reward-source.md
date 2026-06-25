# Story 005: Hidden Double Jump Reward Source

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-ability-005`, `TR-explore-001`,
`TR-explore-002`, `TR-explore-006`

**ADR Governing Implementation**: ADR-0018 Player abilities; ADR-0007 Scene
management; ADR-0021 Save system architecture.

Stories003-004 made Double Jump playable, connected it to the high-platform
ExplorationGate, and added activation feedback. This story adds the smallest
player-visible exploration reward source for the GDD's hidden-boss path:
Cinderpaw discovers a hidden boss echo relic, claims it once, immediately gains
`double_jump`, and can then use the existing Double Jump runtime to approach the
factory route gate.

## Acceptance Criteria

- [x] `res://scenes/main.tscn` contains a visible
  `HiddenDoubleJumpRewardSource` node with a generated transparent PNG prop,
  not a `ColorRect`, `Polygon2D`, or solid placeholder.
- [x] The reward source exposes a deterministic claim contract with
  `reward_id="hidden_boss_echo_double_jump"` and
  `ability_id="double_jump"`, and can only be claimed once.
- [x] Claiming the reward source calls the existing `MainScene.unlock_ability`
  path so Player, `AbilityComponent`, ExplorationGate state, HUD notification,
  and runtime progression stay in sync.
- [x] After claim, `DoubleJumpExplorationGate` becomes `unlockable` but remains
  collision-blocking until the player activates Double Jump in range.
- [x] Save snapshots persist both `double_jump` and a claimed world flag; restore
  keeps the source disabled and the ability playable without re-awarding.
- [x] The generated reward source asset, prompt, runtime import path, RED/GREEN
  focused test, related regression, headless smoke, and Godot MCP runtime
  screenshot/log evidence are recorded.

## Out of Scope

- Full Boss2 path, hidden-boss combat AI, hidden-room discovery system, secret
  wall reveal logic, or new enemy animations.
- Full factory area transition, fast travel route, map/minimap updates, or
  scene registry expansion.
- New Cinderpaw Double Jump-only character frames; Story003/004 already cover
  the runtime animation and activation feedback.
- Gate dissolve VFX/SFX, final reward cutscene, skill-tree spending UI, or
  additional ability gates.

## Implementation Notes

- Treat the hidden boss echo as an exploration reward source, not as a defeated
  boss reward. Do not reuse Rat King's victory menu or boss reward summary text.
- `MainScene` remains the integration owner: it should update world flags,
  trigger `unlock_ability(&"double_jump")`, show HUD feedback, sync the reward
  source state, and use the existing save snapshot flow.
- The reward source is a scene-local Feature node and must not introduce a new
  Autoload or EventBus. It should expose small diagnostics for tests and MCP.
- The visual prop is an environment/reward asset under
  `assets/environment/double_jump_reward/`, with image-generation source
  retained under `assets/generated/source/`.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd`
- `tests/unit/gameplay/player_double_jump_gate_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/hidden-double-jump-reward-source-2026-06-26.md`

**Status**: [x] RED/GREEN focused evidence, related regression, asset import,
headless smoke, and MCP runtime evidence complete.

- RED: `reports/report_624/` failed as expected because
  `HiddenDoubleJumpRewardSource` did not exist in `scenes/main.tscn`.
- GREEN focused: `reports/report_626/` passed `2/2` for once-only hidden
  reward claim, runtime sync, save snapshot, restore, and playability.
- Related regression: `reports/report_627/` passed `8/8` across Story005,
  Double Jump gate runtime, Rat King reward runtime, and Dash gate runtime.
- Headless smoke: `reports/hidden_double_jump_reward_source_main_scene_smoke.log`
  exited `0` with no script, invalid call, or resource-load errors; only the
  known cleanup-time ObjectDB/resource warning remained.
- Godot MCP evidence:
  `production/qa/evidence/hidden-double-jump-reward-source-2026-06-26.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Visible generated reward source in MainScene | `hidden_double_jump_reward_source_runtime_test`; MCP screenshot | COVERED |
| Deterministic once-only claim contract | `hidden_double_jump_reward_source_runtime_test` | COVERED |
| Claim uses existing unlock path and syncs runtime | `hidden_double_jump_reward_source_runtime_test` | COVERED |
| DoubleJump gate becomes unlockable, not directly open | `hidden_double_jump_reward_source_runtime_test`; related gate regression | COVERED |
| Save/restore persists ability and claimed flag | `hidden_double_jump_reward_source_runtime_test` | COVERED |
| Asset docs and runtime MCP evidence complete | Asset manifest; QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 6/6 passing
**Deviations**: This is the hidden-boss echo exploration reward source only;
full hidden-boss combat and secret-wall discovery remain out of scope.
**QA Evidence**:
`production/qa/evidence/hidden-double-jump-reward-source-2026-06-26.md`
