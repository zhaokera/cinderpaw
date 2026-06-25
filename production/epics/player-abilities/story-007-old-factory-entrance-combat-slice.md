# Story 007: Old Factory Entrance Combat Slice

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Visual/Feel + Audio
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/audio-system.md`

**Requirements**: `TR-ability-005`, `TR-explore-001`,
`TR-explore-002`, `TR-explore-006`, `TR-scene-001`

**ADR Governing Implementation**: ADR-0018 Player abilities; ADR-0007 Scene
management; ADR-0021 Save system architecture.

Stories003-006 made Double Jump playable, added the hidden reward source,
unlocked `area_03_factory` through the high-platform gate, and created a small
SceneManager route shell. This story turns the route destination into the first
playable Old Factory entrance slice so the Double Jump-gated route leads to a
recognizable ACT room instead of a gray placeholder.

This is still a small entrance combat room, not the full Old Factory area.

## Acceptance Criteria

- [x] `res://scenes/factory_route_transition_shell.tscn` still loads as
  `area_03_factory` and preserves `FactoryGateEntrySpawn` /
  `factory_gate_entry`.
- [x] The first screen reads as Old Factory through an image-generated
  1280x720 factory backdrop rather than a gray shell, `ColorRect`, debug label,
  or pure placeholder.
- [x] The destination contains safe player spawn, ground and wall collision,
  and does not soft-lock the player immediately after SceneManager transition.
- [x] The destination contains a visible player instance and one visible
  combat object using `AnimatedSprite2D + SpriteFrames`.
- [x] The combat object uses existing Rat Minion runtime contract methods and
  has at least `idle`, `run`, `attack`, `hurt`, and `death` animations with at
  least three frames each.
- [x] Entering `area_03_factory` can resolve to `mus_factory` and
  `amb_factory` through the existing AudioSystem scene cue path.
- [x] RED/GREEN focused test, related regression, Godot import, headless smoke,
  and Godot MCP runtime screenshot/log evidence are recorded.

## Out of Scope

- Full Old Factory layout, multi-room traversal, Boss2, hidden-boss combat,
  savepoints, fast travel, map/minimap completion, shortcuts, or factory
  progression state.
- New enemy family, new enemy AI architecture, new player ability, or new
  Rat Minion character frames.
- SceneManager architecture rewrite, memory profiler work, camera/shader polish,
  or additional area transitions beyond `area_03_factory`.

## Implementation Notes

- The existing `factory_route_transition_shell.tscn` remains the registered
  `area_03_factory` destination, but now acts as `OldFactoryEntranceScene`.
- The route shell prop from Story006 remains as the left-side entrance focus.
- The scene reuses `scenes/player.tscn` and `src/gameplay/rat_minion.tscn` so
  player-visible characters already satisfy project frame-animation rules.
- The new generated backdrop is opaque environment art; it is not a character
  animation asset and does not need alpha processing.
- Audio uses the existing `AudioSystem` stream/cue architecture by adding
  default `area_03_factory` music and ambient cues.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd`
- `tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd`
- `tests/unit/scene/story_005_runtime_scene_tree_swap_test.gd`
- `tests/unit/gameplay/player_double_jump_gate_runtime_test.gd`
- `tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-entrance-combat-slice-2026-06-26.md`

**Status**: [x] Related regression, headless smoke, and MCP runtime evidence
recorded.

- RED: `reports/report_637/` failed as expected because the registered factory
  destination lacked the generated backdrop, player, collision structure, and
  combat object.
- GREEN focused: `reports/report_646/` passed `4/4` for generated backdrop,
  spawn/platform collision, player instance, visible Rat Minion
  `AnimatedSprite2D` animation contract, player attack damage application, and
  SceneManager runtime swap to the combat slice.
- Related regression: `reports/report_647/` passed `55/55` across Old Factory
  entrance, Factory route shell, SceneManager scene swap/preload, Double Jump
  reward/gate, MainScene attack core chain, Rat King summon runtime, transition
  UI, and AudioSystem factory cue coverage.
- Headless smoke: `reports/old_factory_entrance_combat_slice_factory_scene_smoke.log`
  and `reports/old_factory_entrance_combat_slice_main_scene_smoke.log` both
  exited `0`; keyword scans found no script parse, invalid call, or missing
  resource errors. Known cleanup-time ObjectDB/resource messages remain limited
  to process exit.
- MCP runtime: Godot MCP reached `area_03_factory` / `factory_gate_entry`,
  verified `FactoryRouteTransitionShellScene`, generated backdrop path, player
  and Rat Minion `AnimatedSprite2D` nodes, Rat Minion 3-frame animation states,
  `mus_factory` / `amb_factory`, clean game/editor logs, and screenshot
  `reports/visual/cinderpaw-mcp-old-factory-entrance-combat-slice-20260626.png`.
  A fresh Factory runtime attack reduced Rat Minion HP from `24` to `12`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Factory destination still loads as `area_03_factory` | `old_factory_entrance_combat_slice_runtime_test` | COVERED |
| Old Factory generated backdrop replaces gray shell feel | `old_factory_entrance_combat_slice_runtime_test`; MCP screenshot | COVERED |
| Safe spawn and collision exist | `old_factory_entrance_combat_slice_runtime_test` | COVERED |
| Player and animated combat object are visible | `old_factory_entrance_combat_slice_runtime_test`; MCP screenshot | COVERED |
| Rat Minion animation frame counts satisfy rules | `old_factory_entrance_combat_slice_runtime_test`; existing Rat Minion tests | COVERED |
| Factory audio cue resolves through AudioSystem | `audio_system_test`; MCP runtime probe | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence; MCP runtime probe | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 7/7 passing
**Deviations**: This story implements a first Old Factory entrance combat room
only; deeper Old Factory content remains out of scope.
**QA Evidence**:
`production/qa/evidence/old-factory-entrance-combat-slice-2026-06-26.md`
