# Story 019: Parry Laser Gate Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/feline-combat.md`

**Requirements**: `TR-ability-002`, `TR-ability-003`,
`TR-ability-004`, `TR-ability-005`, `TR-explore-001`,
`TR-explore-002`, `TR-explore-006`, `TR-combat-004`

**ADR Governing Implementation**: ADR-0005 Combat state machine; ADR-0018
Player abilities; ADR-0007 Scene management; ADR-0021 Save system.

Stories001-018 made Dash, Double Jump, gate feedback, Old Factory slices, and
the first skill-tree spend playable. This story lands another player-visible
ability consumer from the GDD gate matrix: Cinderpaw can actively request
`parry`, play a generated multi-frame parry animation, consume the 0.3s
AbilityComponent cooldown, enter the Core combat `PARRYING` state, and open the
main-scene laser gate toward the Central Tower route.

## Acceptance Criteria

- [x] `PlayerController` exposes `request_parry()` and routes the `parry`
  input through AbilityComponent cooldowns and Core combat timing.
- [x] `request_parry()` succeeds only when player control and Core combat state
  allow it; blocked Core combat states do not emit `ability_activated` and do
  not consume the 0.3s parry cooldown.
- [x] Cinderpaw's player-visible parry state uses `AnimatedSprite2D` +
  `SpriteFrames` with three imported transparent PNG frames under
  `assets/characters/cinderpaw/parry/`.
- [x] `scenes/main.tscn` contains `ParryLaserExplorationGate` with
  `gate_id="parry_laser_central_tower"`,
  `required_ability="parry"`, and `target_area_id="area_05_central_tower"`.
- [x] The laser gate starts `unlockable` because parry is an initial ability,
  blocks collision before use, and unlocks when Cinderpaw performs parry in
  range.
- [x] Gate unlock state persists through `world_state.exploration_gates`,
  `gate_parry_laser_central_tower_unlocked`, and
  `area_05_central_tower_unlocked`.
- [x] The generated parry animation source, alpha source, runtime PNG frames,
  and SpriteFrames resource are imported through the Godot asset pipeline and
  recorded in asset/evidence docs.
- [x] Godot MCP verifies `res://scenes/main.tscn` runs, Player uses
  `AnimatedSprite2D`, `parry` has three frames, the parry laser gate exists and
  unlocks through runtime parry, logs are clean, and a nonblank screenshot shows
  the runtime scene.

## Out of Scope

- Full Central Tower scene, all prerequisite-route checks, minimap/fast-travel
  updates, and final laser-gate art replacement.
- Full parry success resolution against live enemy attacks, PERFECT/GOOD/LATE
  presentation/audio expansion, counterattack automation, and balance tuning.
- New parry SFX. This story reuses existing AbilityComponent, CombatComponent,
  ExplorationGate, and shared ability-gate feedback systems.
- Aerial attack, wall climb, breakable narrow-gap gates, Boss2 reward source,
  full ability HUD icons, and skill-tree parry-window modifiers.

## Implementation Notes

- Keep AbilityComponent as the owner of ability unlock, activation, and
  cooldown. PlayerController may refuse parry before activation if Core combat
  is not ready, so a rejected parry does not consume cooldown.
- Keep the visible player state in PlayerController aligned with the Core
  `CombatComponent.CombatState.PARRYING` state; this slice does not replace the
  combat-side parry timing resolver.
- Use the existing `ExplorationGate` signal integration and save snapshot flow.
  The parry laser gate is a configured scene node, not a new manager.
- Generated frames follow the project rule:
  `assets/characters/cinderpaw/parry/cinderpaw_parry_000.png` through `_002.png`.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/player_parry_laser_gate_runtime_test.gd`
- `tests/unit/combat/story_004_parry_timing_counter_outcome_test.gd`
- `tests/unit/gameplay/player_dash_ability_runtime_test.gd`
- `tests/unit/gameplay/player_double_jump_gate_runtime_test.gd`
- `tests/unit/gameplay/exploration_gate_unlock_feedback_test.gd`
- Headless main-scene smoke
- Godot MCP runtime evidence under
  `production/qa/evidence/parry-laser-gate-runtime-2026-06-26.md`

**Status**: [x] RED/GREEN focused evidence, related regression, headless smoke,
asset import, and MCP runtime evidence complete.

- RED: `reports/report_726/` failed as expected on the missing Cinderpaw
  `parry` SpriteFrames animation and runtime gate behavior.
- RED import refinement: `reports/report_727/` exposed that the new PNG frames
  needed Godot import metadata before SpriteFrames could load them.
- GREEN focused before cooldown-order refinement: `reports/report_728/` passed
  Story019 `3/3`.
- Related regression before cooldown-order refinement: `reports/report_729/`
  passed `25/25`.
- RED cooldown-order refinement: `reports/report_730/` failed because a blocked
  Core combat state still consumed the `parry` cooldown.
- Final focused: `reports/report_731/` passed Story019 `4/4`.
- Final related regression: `reports/report_732/` passed `26/26` across parry,
  dash, double jump, exploration-gate feedback, core parry timing, player
  attack chain, and dodge animation suites.
- Headless smoke:
  `reports/parry_laser_gate_runtime_main_scene_smoke.log`.
- Godot MCP evidence:
  `production/qa/evidence/parry-laser-gate-runtime-2026-06-26.md`.
- MCP runtime screenshot:
  `reports/visual/cinderpaw-mcp-parry-laser-gate-runtime-20260626.png`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Parry public API and input consumer exist | `player_parry_laser_gate_runtime_test` | COVERED |
| Ability cooldown and Core combat state order | `player_parry_laser_gate_runtime_test` | COVERED |
| Generated `parry` SpriteFrames has 3 imported frames | `player_parry_laser_gate_runtime_test`; MCP probe | COVERED |
| MainScene parry laser gate configuration | `player_parry_laser_gate_runtime_test`; MCP probe | COVERED |
| Runtime parry unlocks the laser gate in range | `player_parry_laser_gate_runtime_test`; MCP probe | COVERED |
| Gate unlock persists into save snapshot | `player_parry_laser_gate_runtime_test`; MCP probe | COVERED |
| Generated asset source/import/evidence recorded | Asset manifest; QA evidence | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 8/8 passing
**Deviations**: The parry laser gate visual currently reuses the existing
generated electric-leak gate texture as a replaceable baseline. The new
generated visual asset in this story is the player-facing Cinderpaw `parry`
animation, which is the higher-priority ACT readability gap.
**QA Evidence**:
`production/qa/evidence/parry-laser-gate-runtime-2026-06-26.md`
