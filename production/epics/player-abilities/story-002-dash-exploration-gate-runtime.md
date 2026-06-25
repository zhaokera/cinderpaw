# Story 002: Dash Exploration Gate Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/exploration-ability-gating.md`,
`design/gdd/player-abilities.md`

**Requirements**: `TR-explore-001`, `TR-explore-002`,
`TR-explore-006`, `TR-ability-002`, `TR-ability-005`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system architecture.

Story001 made Rat King's `dash` reward playable by Cinderpaw. This story makes
that reward change the level: the main scene contains a Dash-required electric
fence gate that starts locked, reacts to the runtime Player ability state, and
opens after Dash is activated.

## Acceptance Criteria

- [x] `src/feature/exploration_gate.gd` implements a scene-level
  `ExplorationGate` component with `LOCKED`, `UNLOCKABLE`, and `UNLOCKED`
  states driven by a configured `required_ability`.
- [x] The gate queries the Player/AbilityComponent `has_ability("dash")`, listens
  for `ability_unlocked` and `ability_activated`, and moves from locked to
  unlockable when Dash is gained, then to unlocked when Dash is activated.
- [x] Locked and unlockable gates keep collision enabled; unlocked gates disable
  collision and dim the electric-fence visual so the path is visibly open.
- [x] `scenes/main.tscn` contains `DashExplorationGate` using the existing
  image-generated Rat King arena electric leak texture as its electric fence
  visual source.
- [x] `MainScene.unlock_ability("dash")`, Rat King reward restore, and save
  restore synchronize existing exploration gates without restarting the scene.
- [x] Dash gate unlocked state is captured in MainScene world save snapshots and
  restored into a fresh scene as already unlocked.
- [x] Godot MCP verifies `res://scenes/main.tscn` loads and runs,
  `DashExplorationGate` exists, starts locked before Dash, becomes unlockable
  after `unlock_ability("dash")`, becomes unlocked after `request_dash()`,
  runtime/editor logs are clean, and a nonblank screenshot shows the gate.

## Out of Scope

- Full map UI, minimap color transitions, or area-completion percentage.
- Double jump, aerial attack, wall climb, parry, hidden-room, shortcut, or
  breakable-wall gates.
- New authored gate image generation beyond reusing the existing
  image-generated electric leak runtime asset.
- Save-slot UI redesign, skill-tree spending UI, or extra ability upgrades.
- Multi-area scene registry route unlocks beyond this main-scene gate.

## Implementation Notes

- `ExplorationGate` is a scene component, not an Autoload.
- Gate state should be queryable by tests and MCP through stable public methods
  such as `get_gate_state()`, `is_collision_blocking()`, and `is_unlocked()`.
- `MainScene` owns integration: it syncs Player ability state into all nodes in
  the `exploration_gate` group and serializes unlocked gate ids under
  `world_state.exploration_gates`.
- The electric fence visual should remain replaceable and record its reuse in
  asset/evidence docs.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/exploration_dash_gate_runtime_test.gd`
- `tests/unit/gameplay/player_dash_ability_runtime_test.gd`
- `tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd`
- `tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd`

**Status**: [x] RED/GREEN focused evidence, related regression, headless smoke,
and MCP runtime evidence complete.

- RED: `reports/report_599/` failed as expected because
  `src/feature/exploration_gate.gd` did not exist.
- GREEN focused: `reports/report_604/` passed `2/2` for the
  `ExplorationGate` state machine and MainScene gate persistence.
- Related regression: `reports/report_606/` passed `12/12` across Dash gate,
  AbilityComponent, Player Dash, Rat King reward, and SaveSystem handoff.
- Headless smoke: `reports/exploration_gate_dash_main_scene_smoke.log` had no
  script error, invalid call, missing-node, or resource-load matches. Godot
  still printed existing cleanup-time ObjectDB/resource messages at process
  exit.
- Godot MCP evidence:
  `production/qa/evidence/dash-exploration-gate-runtime-2026-06-26.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| ExplorationGate state machine | `exploration_dash_gate_runtime_test` | COVERED |
| Dash unlock/activation drives gate | `exploration_dash_gate_runtime_test`; MCP probe | COVERED |
| MainScene contains visible Dash gate | `exploration_dash_gate_runtime_test`; MCP screenshot | COVERED |
| Save snapshot restores unlocked gate | `exploration_dash_gate_runtime_test`; save regression | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 7/7 passing
**Deviations**: The electric fence visual reuses the existing image-generated
Rat King arena `electric_leak.png` asset as a replaceable baseline instead of
adding a new authored gate-specific image generation pass.
**QA Evidence**:
`production/qa/evidence/dash-exploration-gate-runtime-2026-06-26.md`
