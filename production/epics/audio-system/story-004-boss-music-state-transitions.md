# Story 004: Rat King Boss Music State Transitions

> **Epic**: Audio System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/audio-system.md`
**Requirements**: `TR-audio-004`, partial `TR-audio-007`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at
review time)*

**ADR Governing Implementation**: ADR-0010: Audio system architecture
**ADR Decision Summary**: AudioSystem owns music state, music cue ids, and fade
timing. Gameplay and Boss systems emit domain events; MainScene may bridge the
runtime Rat King encounter into AudioSystem without making gameplay components
depend on Presentation.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: This story records music requests and state transitions. Real
music assets, simultaneous crossfade players, and authored score files remain
future audio asset stories.

**Control Manifest Rules (Presentation layer)**:
- Required: AudioSystem remains Autoload #3 and owns music request diagnostics.
- Required: Presentation consumes Core/Feature data through signals or runtime
  adapters only.
- Guardrail: Core, BossConfig, SceneManager, and RatKingBoss must not gain direct
  dependencies on AudioSystem.

---

## Acceptance Criteria

- [x] `AudioSystem.on_boss_encounter_started(boss_id, metadata)` enters
  `BOSS_FIGHT`, requests `mus_boss_rat_p1`, and records a 1.0 second hard-cut
  fade-in for Rat King phase 1.
- [x] `AudioSystem.on_boss_phase_transition_started(entity_id, phase, metadata)`
  keeps existing `sfx_boss_phase` behavior and requests `mus_boss_rat_p2` or
  `mus_boss_rat_p3` with a 2.0 second phase transition record.
- [x] `AudioSystem.on_boss_encounter_ended(boss_id, metadata)` clears boss music
  state, stops music with a 3.0 second fade-out record, and returns to `NORMAL`
  unless focus-mode audio remains active.
- [x] `MainScene` forwards Rat King encounter start and defeat/end events to
  AudioSystem while preserving existing enemy defeat, CombatPresentation, HUD,
  and GameFlow behavior.
- [x] Missing music streams remain silent-safe: cue requests update diagnostics
  and return false instead of blocking gameplay.
- [x] Godot MCP verifies runtime `/root/AudioSystem`, Rat King boss music state,
  clean logs, and a capturable game frame.

## Implementation Notes

- Add the smallest public surface needed for boss music:
  `on_boss_encounter_started()`, `on_boss_encounter_ended()`,
  `get_boss_music_state()`, and default Rat King boss cue mapping.
- Reuse `play_music()` and `stop_music()` diagnostics; do not introduce a second
  music player or real crossfade graph in this slice.
- Keep MainScene as the runtime adapter boundary. Do not add AudioSystem
  references to RatKingBoss, BossConfigComponent, AIComponent, or GameFlow.
- Keep existing `sfx_boss_phase` request behavior intact.

## Out of Scope

- Real music files, authored score import, or asset manifest entries for audio.
- Simultaneous two-player crossfade implementation.
- UI menu ducking, MENU/CUTSCENE states, and same-SFX 100ms merge.
- Non-Rat-King boss cue catalogs.
- New visual/image2 assets; this story adds no visual assets.

## QA Test Cases

- **AC-1**: Boss encounter start cue.
  - Given: AudioSystem has no real music streams loaded.
  - When: `on_boss_encounter_started("boss_01_rat_king", metadata)` is called.
  - Then: current music id is `mus_boss_rat_p1`, fade-in is `1.0`, boss music
    diagnostics are active, and the call remains silent-safe.

- **AC-2**: Boss phase music transition.
  - Given: Rat King boss music is active.
  - When: phase 2 or phase 3 transition starts.
  - Then: current music id changes to `mus_boss_rat_p2` or
    `mus_boss_rat_p3`, fade-in is `2.0`, and `sfx_boss_phase` is still the last
    SFX request.

- **AC-3**: Boss encounter end cue.
  - Given: Rat King boss music is active.
  - When: the boss encounter ends because Rat King is defeated.
  - Then: boss music diagnostics clear, current music id clears, fade-out is
    `3.0`, and audio state returns to `NORMAL`.

- **AC-4**: MainScene runtime wiring.
  - Given: MainScene is configured with an AudioSystem-like object.
  - When: the Rat King encounter starts and then `_on_enemy_defeated()` runs.
  - Then: MainScene forwards boss music start and end events to AudioSystem
    without blocking existing gameplay presentation.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/presentation/audio_system_test.gd` boss music tests must pass.
- `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd` must confirm
  MainScene runtime boss music forwarding.
- Focused related regression should cover AudioSystem, MainScene audio event
  adapter, and Rat King runtime boss contracts.
- Godot headless main-scene smoke should run cleanly.
- Godot MCP should verify runtime AudioSystem boss music state, logs, and
  screenshot.

**Status**: [x] Complete

## Evidence

- RED: `reports/report_535/results.xml` failed on missing boss music API and
  MainScene start forwarding.
- GREEN focused: `reports/report_536/results.xml`, `19/19`.
- Final related regression after Godot warning cleanup:
  `reports/report_538/results.xml`, `24/24`.
- Headless smoke:
  `reports/audio_boss_music_state_main_scene_smoke.log`, exit `0`, no
  Error/Warning matches.
- MCP runtime: `/root/AudioSystem` existed, initial Rat King music state was
  `mus_boss_rat_p1` with `1.0` fade-in, phase 2/3 became
  `mus_boss_rat_p2`/`mus_boss_rat_p3` with `2.0` fade-in and
  `sfx_boss_phase`, defeat cleared music with `3.0` fade-out and returned to
  `NORMAL`.
- MCP screenshot:
  `reports/visual/cinderpaw-mcp-boss-music-state-20260625.png`.
- QA evidence:
  `production/qa/evidence/audio-boss-music-state-transitions-2026-06-25.md`.

## Dependencies

- Depends on: Audio System Story 001, Story 002, Story 003, BossConfig Story
  007, and ADR-0010.
- Unlocks: real audio asset import, score authoring, UI menu ducking, and same
  SFX merge polish.
