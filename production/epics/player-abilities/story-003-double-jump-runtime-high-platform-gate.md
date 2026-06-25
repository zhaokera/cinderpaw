# Story 003: Double Jump Runtime + High Platform Gate

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-ability-002`, `TR-ability-003`,
`TR-ability-004`, `TR-ability-005`, `TR-explore-001`,
`TR-explore-002`, `TR-explore-006`

**ADR Governing Implementation**: ADR-0018 Player abilities; ADR-0007 Scene
management; ADR-0021 Save system architecture.

Stories001-002 made Dash playable and connected it to an ExplorationGate. This
story adds the next player-visible ability slice: Cinderpaw can consume
`double_jump` once while airborne, reuse the existing imported `jump`
SpriteFrames animation, and open a high-platform route marker in the main scene.

## Acceptance Criteria

- [x] `PlayerController` exposes `request_double_jump()`, `set_airborne()`,
  `reset_air_abilities()`, and `double_jump_started(texture, world_position,
  facing)`.
- [x] `request_double_jump()` fails while locked, fails on the ground, succeeds
  once while airborne after unlock, emits `ability_activated("double_jump")`,
  applies upward velocity, and plays the `jump` animation.
- [x] Air-count use resets after landing or explicit `reset_air_abilities()`;
  respawn also clears any consumed air-count state.
- [x] Double Jump presentation uses the existing `AnimatedSprite2D +
  SpriteFrames` `jump` animation with three transparent imported frames under
  `assets/characters/cinderpaw/jump/`.
- [x] `scenes/main.tscn` contains `DoubleJumpExplorationGate` with
  `gate_id="double_jump_high_platform"`,
  `required_ability="double_jump"`, and `target_area_id="area_03_factory"`.
- [x] The high-platform gate starts locked, becomes unlockable after
  `MainScene.unlock_ability("double_jump")`, and unlocks after Double Jump
  activation in range.
- [x] Gate unlock state persists through `world_state.exploration_gates`,
  `gate_double_jump_high_platform_unlocked`, and `area_03_factory_unlocked`.
- [x] The high-platform marker uses an image-generated transparent PNG imported
  through the Godot asset pipeline and recorded in asset/evidence docs.
- [x] Godot MCP verifies `res://scenes/main.tscn` runs, Player uses
  `AnimatedSprite2D`, `jump` has three frames, both Dash and Double Jump gates
  exist, Double Jump opens the high-platform gate, logs are clean, and a
  nonblank screenshot shows the runtime gate.

## Out of Scope

- Full factory area scene, fast-travel route, map UI, minimap completion, or
  area transition implementation.
- Boss2 or hidden-boss reward sources for unlocking `double_jump`.
- New authored Double Jump-only Cinderpaw frames beyond reusing the existing
  imported `jump` frames for this runtime slice.
- Door dissolve particles, gate-specific SFX, skill-tree upgrade UI, or extra
  ability modifiers.
- Other ability gates such as aerial attack, wall climb, parry, or breakable
  walls.

## Implementation Notes

- `AbilityComponent` remains the owner of unlocks, cooldowns, and air-count
  usage. PlayerController only delegates runtime activation and movement
  response.
- Ground contact calls `set_airborne(false)`, which clears air-count usage.
  Airborne movement calls `set_airborne(true)`.
- `MainScene` uses the existing `ExplorationGate` integration and save snapshot
  flow; the new gate is a configured scene node, not a new manager.
- The high-platform visual is a replaceable generated baseline under
  `assets/environment/high_platform_gate/`.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/player_double_jump_gate_runtime_test.gd`
- `tests/unit/ability/ability_component_runtime_gate_test.gd`
- `tests/unit/gameplay/player_dash_ability_runtime_test.gd`
- `tests/unit/gameplay/exploration_dash_gate_runtime_test.gd`
- `tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd`
- `tests/unit/input/story_005_coyote_jump_buffer_test.gd`

**Status**: [x] RED/GREEN focused evidence, related regression, headless smoke,
asset import, and MCP runtime evidence complete.

- RED: `reports/report_611/` failed as expected because `PlayerController`
  did not yet expose the Double Jump signal/methods.
- GREEN focused: `reports/report_613/` passed `3/3` for Double Jump runtime,
  imported jump frames, MainScene high-platform gate unlock, and save restore.
- Scene sanity after final `main.tscn` reload: `reports/report_616/` passed
  `5/5` across Double Jump and Dash gate scene tests.
- Related regression: `reports/report_618/` passed `19/19` across Double Jump,
  AbilityComponent, Player Dash, Dash gate, SaveSystem handoff, and coyote/jump
  buffer suites.
- Headless smoke: `reports/double_jump_high_platform_gate_runtime_smoke.log`
  had no script error, invalid call, missing node, or resource-load keyword
  matches. Godot still printed existing cleanup-time ObjectDB/resource messages
  at process exit.
- Godot MCP evidence:
  `production/qa/evidence/double-jump-high-platform-gate-runtime-2026-06-26.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Double Jump public API and signal exist | `player_double_jump_gate_runtime_test` | COVERED |
| Locked/grounded/airborne activation flow | `player_double_jump_gate_runtime_test` | COVERED |
| Air-count reset after landing/reset | `player_double_jump_gate_runtime_test`; related input regression | COVERED |
| `jump` SpriteFrames reused with 3 imported frames | `player_double_jump_gate_runtime_test`; MCP probe | COVERED |
| MainScene high-platform gate state machine | `player_double_jump_gate_runtime_test`; MCP probe | COVERED |
| Gate unlock persists into save snapshot | `player_double_jump_gate_runtime_test`; save regression; MCP probe | COVERED |
| Generated gate marker imported and visible | Asset manifest; MCP screenshot | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 9/9 passing
**Deviations**: Double Jump currently reuses the existing imported Cinderpaw
`jump` frames rather than adding a separate `double_jump` animation. This keeps
the slice small while still meeting the player-visible frame-animation rule.
**QA Evidence**:
`production/qa/evidence/double-jump-high-platform-gate-runtime-2026-06-26.md`
