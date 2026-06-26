# Story 016: Ability Gate Unlock Feedback

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
`design/gdd/audio-system.md`

**Requirements**: `TR-ability-004`, `TR-ability-005`, `TR-explore-001`,
`TR-explore-006`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0007
Scene management; ADR-0010 Audio system; ADR-0018 Player abilities; ADR-0021
Save system.

Stories002 and 003 made the Dash and Double Jump exploration gates functional.
This story makes the moment of actually opening those gates readable in play:
when a player uses the required ability in range, the gate opens, plays a short
generated dissolve burst, and routes a door-unlock sound through `AudioSystem`.

## Acceptance Criteria

- [x] `ExplorationGate` exposes deterministic unlock-feedback diagnostics for
  tests and MCP probes, including texture path, active VFX count, spawn count,
  last spawn metadata, and generated asset source.
- [x] Unlocking `DashExplorationGate` from `unlockable` to `unlocked` spawns a
  short-lived generated `Sprite2D` VFX at the gate, disables collision, hides
  the prompt, and records `dash_gate_commercial_street` /
  `area_02_sewer` metadata.
- [x] Unlocking `DoubleJumpExplorationGate` from `unlockable` to `unlocked`
  spawns the same gate-unlock VFX and records `double_jump_high_platform` /
  `area_03_factory` metadata.
- [x] Already-unlocked gates, duplicate ability activations, `refresh_gate_state()`,
  and save restore via `set_gate_unlocked(true)` do not replay the VFX or SFX.
- [x] `MainScene` dispatches an `on_exploration_gate_unlocked(...)` audio event
  only for fresh gate unlocks, with gate id, required ability, target area, and
  gate world position.
- [x] `AudioSystem` maps exploration gate unlock events to imported
  `sfx_door_unlock` playback and records spatial request metadata with
  `stream_found=true`.
- [x] The new visual and audio assets are generated/imported through the project
  asset pipeline and recorded in asset manifest, entity inventory, and QA
  evidence.
- [x] Focused RED/GREEN tests, related ability-gate/audio regression, Godot
  import/headless smoke, and Godot MCP runtime screenshot/log evidence are
  recorded.

## Out of Scope

- Adding new abilities, new ability gates, minimap/area-completion UI, fast
  travel, save schema changes, cutscenes, final mastered audio, shader polish,
  or changes to Dash/Double Jump movement feel.
- Replacing Story012 Old Factory endpoint feedback; this story adds the shared
  ability-gate feedback used by `ExplorationGate`.
- Ability acquisition feedback. This story is about opening a gate after the
  player already owns the required ability.

## Implementation Notes

- Treat feedback as a one-shot side effect of a real state transition into
  `STATE_UNLOCKED`. State restore must apply visuals/collision without replay.
- Keep the gate component deterministic: expose snapshot methods for tests and
  MCP probes, and drive VFX expiry through a testable time-advance method.
- Use `Sprite2D` with the imported generated PNG for the VFX. Do not create
  player-visible `ColorRect` or `Polygon2D` placeholders.
- Route audio through `MainScene` to `AudioSystem`; do not add an EventBus or a
  new Autoload.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/exploration_gate_unlock_feedback_test.gd`
- `tests/unit/presentation/audio_system_test.gd`
- `tests/unit/gameplay/exploration_dash_gate_runtime_test.gd`
- `tests/unit/gameplay/player_double_jump_gate_runtime_test.gd`
- `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/ability-gate-unlock-feedback-2026-06-26.md`

**Status**: [x] Complete.
