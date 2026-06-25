# Story 001: Dash Runtime Ability Gate

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/boss-config.md`, `design/gdd/combat-presentation.md`

**Requirements**: `TR-ability-001`, `TR-ability-002`, `TR-ability-003`,
`TR-ability-004`, `TR-ability-005`, `TR-boss-007`

**ADR Governing Implementation**: ADR-0003 Data management; ADR-0005 Combat
state machine; ADR-0018 Player abilities; ADR-0021 Save system architecture.

BossConfig Story010 makes Rat King defeat grant `dash` in runtime progression
and save snapshots. This story turns that reward into a playable ability:
Player owns an `AbilityComponent`, the ability registry is data-driven, and
`PlayerController.request_dash()` plays a visible Dash animation with a 1.0s
cooldown after the ability is unlocked.

## Acceptance Criteria

- [x] `data/abilities.json` defines the eight GDD abilities and is registered in
  `data/manifest.json` with schema validation.
- [x] `src/core/ability_component.gd` loads ability config through DataManager
  when available, preserves safe fallback behavior for isolated tests, and
  exposes `has_ability`, `get_unlocked_abilities`,
  `is_ability_on_cooldown`, `get_ability_cooldown_remaining`,
  `unlock_ability`, `try_activate_ability`, `set_unlocked_abilities`, and
  `reset_air_abilities`.
- [x] Game start abilities include `basic_attack`, `jump`, `dodge`, and
  `parry`; `dash` starts locked.
- [x] Unlocking `dash` once emits ability events, duplicate unlock returns
  false, and `try_activate_ability("dash")` starts a 1.0s cooldown.
- [x] `scenes/player.tscn` mounts `AbilityComponent` under Player and
  `PlayerController` delegates ability state/cooldown checks to it.
- [x] `PlayerController.request_dash()` fails while locked, succeeds after
  unlock, emits `dash_started` and `ability_activated`, applies a forward
  movement burst, and plays the `dash` animation.
- [x] Cinderpaw Dash uses `AnimatedSprite2D` + `SpriteFrames` with at least
  three transparent 96x96 frames in
  `assets/characters/cinderpaw/dash/cinderpaw_dash_000.png` through `_002.png`.
- [x] `MainScene.unlock_ability("dash")` and Rat King reward restoration
  synchronize the runtime Player controller, so the reward becomes playable
  without restarting the scene.
- [x] Godot MCP verifies `res://scenes/main.tscn` loads and runs, Player has
  `AbilityComponent`, `SpriteFrames` has `dash` with three dash-folder frames,
  Dash can be activated after unlock, runtime/editor logs are clean, and a
  nonblank gameplay screenshot shows Cinderpaw in Dash state.

## Out of Scope

- Full skill-tree spending UI or ability upgrade menu.
- ExplorationGate doors that require `dash`.
- New authored Dash-only image generation beyond this slice's derivative use
  of the existing image-generated Cinderpaw dodge strip.
- Double jump, aerial attack, wall climb, or parry runtime consumers.
- Replacing dodge, attack, hurt, death, or boss animations.

## Implementation Notes

- `AbilityComponent` is a Player child component and not an Autoload.
- Ability configuration is source JSON under `data/abilities.json`; Player code
  should not own the authoritative cooldown table.
- `MainScene` may keep progression/save unlock state, but PlayerController must
  delegate runtime ability gates and cooldowns to its `AbilityComponent`.
- Dash presentation can reuse the existing dodge afterimage/audio adapter for
  this slice, but it must emit its own `dash_started` signal and play its own
  `dash` SpriteFrames animation.

## Test Evidence

**Required evidence**:

- `tests/unit/ability/ability_component_runtime_gate_test.gd`
- `tests/unit/gameplay/player_dash_ability_runtime_test.gd`
- `tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd`
- `tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd`

**Status**: [x] RED/GREEN focused evidence, related regression, headless
smoke, and MCP runtime evidence complete.

- RED: focused GdUnit command exited `105` while
  `res://src/core/ability_component.gd` was missing. Earlier player runtime RED
  `reports/report_596/` also failed because `dash` animation did not exist.
- GREEN focused: `reports/report_597/` passed `6/6` across AbilityComponent
  and Player Dash runtime tests.
- Related regression: `reports/report_598/` passed `40/40` across Ability,
  Dash, Dodge, Rat King reward, BossConfig reward, SaveSystem handoff, and
  Input dash-priority suites.
- Headless smoke:
  `reports/player_dash_runtime_main_scene_smoke.log` had no script error,
  warning, or failed resource-load keyword matches.
- Godot MCP evidence:
  `production/qa/evidence/player-dash-runtime-ability-gate-2026-06-25.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Ability registry data loads through DataManager | `ability_component_runtime_gate_test`; MCP runtime logs | COVERED |
| Initial abilities and locked dash | `ability_component_runtime_gate_test`; `player_dash_ability_runtime_test` | COVERED |
| Dash unlock, activation, cooldown | `ability_component_runtime_gate_test`; `player_dash_ability_runtime_test`; MCP runtime probe | COVERED |
| Player scene mounts AbilityComponent | `player_dash_ability_runtime_test`; MCP node probe | COVERED |
| Dash animation uses dash-folder frames | `player_dash_ability_runtime_test`; MCP SpriteFrames probe | COVERED |
| MainScene reward sync makes dash playable | `player_dash_ability_runtime_test`; reward runtime regression; MCP runtime probe | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-25
**Criteria**: 9/9 passing
**Deviations**: Dash presentation reuses the existing dodge afterimage/audio
adapter and image-generated dodge-strip source frames as a replaceable runtime
Dash slice. A later authored Dash-only generation pass may replace the frames.
**QA Evidence**:
`production/qa/evidence/player-dash-runtime-ability-gate-2026-06-25.md`
