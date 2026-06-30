# Story 009: Boss2 Authored Audio Feedback Runtime

> **Epic**: Audio System
> **Status**: Complete
> **Layer**: Presentation / Gameplay Runtime Bridge
> **Type**: Integration + Audio/Feel
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/audio-system.md`, `design/gdd/feline-combat.md`,
`design/gdd/player-abilities.md`

**Requirements**: `TR-audio-002`, `TR-audio-003`, `TR-audio-006`,
`TR-audio-007`

**ADR Governing Implementation**: ADR-0010 Audio system architecture; ADR-0002
Signal communication; ADR-0004 Collision detection; ADR-0005 Combat state
machine; ADR-0006 AI behavior system architecture.

Stories021-026 made Boss2 visible, dangerous, animated during chase, HUD-focused,
and bounded/resettable. The encounter still leans on generic hit/death audio,
so Boss2 does not yet sound like a distinct ACT boss in chase, telegraph,
damage, defeat, or reward moments.

This story adds a small authored/procedural Boss2 SFX pack and runtime event
bridge. The goal is audible feedback that follows the existing Boss2 gameplay
states without changing AI, damage, reward rules, music state, or arena layout.

## Acceptance Criteria

- [x] Boss2-specific WAV cues exist under `assets/audio/sfx/` for
  `sfx_boss2_chase_start`, `sfx_boss2_attack_startup`, `sfx_boss2_hurt`,
  `sfx_boss2_attack_active`, `sfx_boss2_defeat`, and
  `sfx_boss2_reward_claim`.
- [x] Boss2 SFX generation/source details are recorded under
  `assets/audio/source/`.
- [x] Godot import generates `.wav.import` files for all Boss2 SFX assets.
- [x] `AudioSystem` loads the Boss2 SFX streams by default and exposes
  `on_boss2_audio_event(event_id, metadata)` for safe cue routing.
- [x] `on_boss2_audio_event()` maps `chase_start`, `attack_startup`, `hurt`,
  `attack_active`, `defeated`, and `reward_claimed` to Boss2-specific SFX ids
  with spatial positions and priority metadata.
- [x] `Boss2EchoGuardian` emits deterministic audio-domain events for first
  chase entry, attack startup, hurt, and defeated states without spamming
  repeated chase/startup events every frame.
- [x] `MainScene` forwards Boss2 audio events to `AudioSystem`, and reward
  claim routes `reward_claimed` through the same API.
- [x] Focused RED/GREEN tests, related audio/Boss2 regression, headless smoke,
  and Godot MCP runtime evidence are recorded.

## Out of Scope

- Final mastered SFX, middleware, adaptive mix, compressor/EQ setup, audio
  subtitles, or accessibility sound visualization.
- New Boss2 music, phase music, DEATH/CUTSCENE audio-state completion, or
  global boss encounter manager.
- New visual assets, character animation changes, arena art, camera locks, or
  Boss2 AI/damage/balance changes.

## Implementation Notes

- AudioSystem owns cue ids, streams, SFX priority, and playback diagnostics.
- Boss2 and MainScene may emit/forward events but must not hard-code stream
  paths or audio bus details.
- Reuse the existing `AudioStreamPlayer2D` SFX pool and same-SFX merge behavior.
- Missing streams must remain silent-safe: event APIs return false without
  blocking gameplay.
- No image2/image generation is required; this is an audio-only player-feedback
  slice. Procedural WAV assets are acceptable as replaceable authored baseline
  cues and must be documented.

## Test Evidence

**Required evidence**:

- `tests/unit/presentation/audio_system_test.gd`
- `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`
- Related Boss2 regression:
  `tests/unit/gameplay/boss2_arena_bounds_reset_runtime_test.gd`,
  `tests/unit/gameplay/boss2_autonomous_pressure_runtime_test.gd`,
  `tests/unit/gameplay/boss2_echo_guardian_telegraph_strike_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/boss2-authored-audio-feedback-runtime-2026-06-30.md`

**Status**: [x] Complete. Evidence recorded in
`production/qa/evidence/boss2-authored-audio-feedback-runtime-2026-06-30.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Boss2 WAV cues and source record exist | `assets/audio/sfx/sfx_boss2_*.wav`, `assets/audio/source/boss2_authored_audio_feedback_generation_20260630.json`, `reports/report_818/` | PASS |
| Godot import metadata exists | `assets/audio/sfx/sfx_boss2_*.wav.import`, Godot import exit `0`, `reports/report_818/` | PASS |
| AudioSystem loads cues and maps events | `tests/unit/presentation/audio_system_test.gd::test_boss2_authored_sfx_assets_load_and_event_router_maps_runtime_states`, `reports/report_818/` | PASS |
| Boss2 emits chase/startup/hurt/defeated events | `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd::test_boss2_runtime_states_and_reward_claim_route_authored_audio_events`, `reports/report_818/` | PASS |
| MainScene forwards events and reward claim | `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`, `reports/report_818/` | PASS |
| Focused/related tests and MCP evidence recorded | `reports/report_817/`, `reports/report_818/`, `reports/report_823/`-`reports/report_826/`, QA evidence | PASS |
