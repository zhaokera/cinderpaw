# Story 021: Mainline Boss2 Double Jump Payoff Shell

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/boss-config.md`

**Requirements**: `TR-ability-001`, `TR-ability-002`,
`TR-ability-003`, `TR-ability-004`, `TR-ability-005`,
`TR-explore-001`, `TR-explore-002`, `TR-explore-006`

**ADR Governing Implementation**: ADR-0018 Player abilities; ADR-0007 Scene
management; ADR-0021 Save system architecture.

Stories003-005 made Double Jump playable and added the hidden-boss echo reward
source. The GDD/ADR route also calls out `double_jump` as a Boss2-or-hidden-boss
unlock, so the mainline route still needed a visible boss payoff instead of
leaving the ability progression mostly hidden.

This story adds a minimal mainline Boss2 shell to `res://scenes/main.tscn`:
Cinderpaw can defeat the generated `Boss2EchoGuardian`, reveal a generated
Double Jump reward source, claim it once, immediately use Double Jump, and open
the existing high-platform ExplorationGate.

## Acceptance Criteria

- [x] `res://scenes/main.tscn` contains a visible `Boss2EchoGuardian` runtime
  entity with `entity_id=2200` and no solid-color placeholder body.
- [x] Boss2 player-facing art uses `AnimatedSprite2D + SpriteFrames` with
  image-generated transparent PNG frames under
  `assets/characters/boss2_echo_guardian/<animation>/`.
- [x] Boss2 has at least three frames for each required gameplay animation:
  `idle`, `attack`, `hurt`, and `death`.
- [x] Defeating Boss2 makes `Boss2DoubleJumpRewardSource` claimable and records
  `boss_02_echo_guardian_defeated`.
- [x] Claiming the reward source calls the existing
  `MainScene.unlock_ability("double_jump")` path so Player, AbilityComponent,
  HUD, ExplorationGate state, runtime progression, and save snapshots stay in
  sync.
- [x] If the hidden Double Jump path was already claimed, Boss2 reward claiming
  remains idempotent: the ability is not duplicated and both world flags persist.
- [x] After the Boss2 claim, Cinderpaw can immediately activate Double Jump in
  range of `DoubleJumpExplorationGate`, opening the gate and persisting the
  unlocked area flags.
- [x] Godot MCP verifies scene load, runtime nodes, frame counts, reward state
  transitions, Double Jump activation, clean logs, and a nonblank screenshot.

## Out of Scope

- Full Boss2 arena layout, multi-phase boss AI, authored attack patterns, boss
  music, cutscene, camera scripting, or final boss balancing.
- Replacing Rat King as the complete first-boss flow.
- New Double Jump activation VFX/SFX; this story reuses existing Double Jump
  runtime feedback.
- Full map/minimap updates, route registry expansion, secret-wall discovery, or
  final factory route content.

## Implementation Notes

- Keep the shell scene-local. Do not add a new Autoload or global EventBus.
- Use the existing `MainScene.unlock_ability()` and ExplorationGate sync path
  instead of creating a parallel reward pipeline.
- Keep Boss2 entity routing deterministic through `MainScene.apply_damage(2200,
  damage, metadata)` so tests and MCP can defeat the boss without relying on
  input simulation.
- Treat the new reward source as a visible mainline payoff for the existing
  `double_jump` ability; it must stay compatible with the hidden reward source.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd`
- `tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd`
- `tests/unit/gameplay/player_double_jump_gate_runtime_test.gd`
- `tests/unit/gameplay/exploration_gate_unlock_feedback_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/mainline-boss2-double-jump-payoff-shell-2026-06-26.md`

**Status**: [x] RED/GREEN focused evidence, related regression, asset import,
headless/MCP runtime evidence complete.

- RED: `reports/report_756/` failed as expected because the Boss2 character
  scene, script, SpriteFrames, and main-scene reward flow did not exist.
- Intermediate RED: `reports/report_757/` caught the hidden-path/Boss2 reward
  idempotence issue before the reward source position and availability sync were
  corrected.
- GREEN focused: `reports/report_758/` passed `3/3`.
- RED related regression: `reports/report_762/` reproduced an existing
  SceneManager pending-load ordering issue after ExplorationGate tests.
- Focused regression RED/GREEN: `reports/report_768/` failed the new stale
  pending SceneManager menu-load test, then `reports/report_769/` passed `10/10`
  after local MainScene save restore stopped depending on stale root pending
  transitions.
- Final related regression: `reports/report_771/` passed `22/22` across Boss2
  payoff, hidden Double Jump reward, Double Jump gate runtime, ability-gate
  feedback, Rat King reward, and MainScene audio/menu adapter suites.
- Headless smoke:
  `reports/mainline_boss2_double_jump_payoff_shell_main_scene_smoke.log`
  exited `0`; keyword scan found no script, parse, invalid-call, missing
  resource, or resource-load errors.
- Godot MCP evidence:
  `production/qa/evidence/mainline-boss2-double-jump-payoff-shell-2026-06-26.md`.
- MCP runtime screenshot:
  `reports/visual/cinderpaw-mcp-mainline-boss2-double-jump-payoff-shell-20260626.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Boss2 visible runtime entity exists | `boss2_double_jump_payoff_runtime_test`; MCP tree | COVERED |
| Boss2 uses AnimatedSprite2D + SpriteFrames | `boss2_double_jump_payoff_runtime_test`; MCP probe | COVERED |
| Required animations have at least three frames | `boss2_double_jump_payoff_runtime_test`; MCP probe | COVERED |
| Boss2 defeat reveals reward source | `boss2_double_jump_payoff_runtime_test`; MCP probe | COVERED |
| Reward claim uses existing Double Jump unlock path | `boss2_double_jump_payoff_runtime_test`; MCP probe | COVERED |
| Hidden path and Boss2 path remain idempotent | `boss2_double_jump_payoff_runtime_test`; hidden reward regression | COVERED |
| Double Jump can open high-platform gate after claim | `boss2_double_jump_payoff_runtime_test`; `player_double_jump_gate_runtime_test`; MCP probe | COVERED |
| MCP runtime logs and screenshot verified | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 8/8 passing
**Deviations**: This is a mainline Boss2 payoff shell, not the final Boss2 arena
or complete boss AI implementation.
**QA Evidence**:
`production/qa/evidence/mainline-boss2-double-jump-payoff-shell-2026-06-26.md`
