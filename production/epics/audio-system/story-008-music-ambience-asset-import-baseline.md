# Story 008: Music + Ambience Asset Import Baseline

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
**ADR Decision Summary**: AudioSystem owns music and ambience request state,
scene cue playback, and boss music boundaries. Missing assets remain
silent-safe, but default GDD cue ids should be registered once baseline assets
exist.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Baseline music and ambience assets are stereo WAV files
imported by Godot and registered through `AudioSystem.load_audio_streams_from_paths()`.

**Control Manifest Rules (Presentation layer)**:
- Required: AudioSystem remains Autoload #3 and owns bus/state/playback
  diagnostics.
- Required: Scene and boss music playback stays in Presentation-owned
  AudioSystem APIs.
- Guardrail: SceneManager, BossConfig, RatKingBoss, and Core gameplay must not
  gain hard dependencies on AudioSystem.

---

## Acceptance Criteria

- [x] All GDD music cue WAV files exist under `assets/audio/music/`:
  `mus_hub`, `mus_street`, `mus_sewer`, `mus_factory`, `mus_rooftop`,
  `mus_tower`, `mus_boss_rat_p1`, `mus_boss_rat_p2`, and `mus_boss_rat_p3`.
- [x] All GDD ambience cue WAV files exist under `assets/audio/ambient/`:
  `amb_hub`, `amb_street`, `amb_sewer`, `amb_factory`, `amb_rooftop`, and
  `amb_tower`.
- [x] Music and ambience generation/source details are recorded in
  `assets/audio/source/music_ambience_generation_20260625.json`.
- [x] Godot import generated `.wav.import` files for all 15 music/ambience WAVs.
- [x] `AudioSystem` loads all 15 music/ambience streams by default and preserves
  unknown-cue silent-safe behavior.
- [x] `on_scene_changed("hub", "main")` plays real `mus_street` and
  `amb_street` streams on the Music and Ambient buses.
- [x] Rat King boss start and phase 2/3 transitions play real
  `mus_boss_rat_p1`, `mus_boss_rat_p2`, and `mus_boss_rat_p3` streams.
- [x] Godot MCP verifies runtime stream registration, scene music/ambience
  playback, Rat King boss music playback, clean game/editor logs, and a
  non-empty screenshot.

## Implementation Notes

- Runtime paths are flat and stable:
  `res://assets/audio/music/<music_id>.wav` and
  `res://assets/audio/ambient/<ambient_id>.wav`.
- The WAV files are deterministic procedural baseline assets. They exist so
  current gameplay has audible area and boss feedback now, and are intentionally
  replaceable by authored final audio later without changing cue ids.
- Scene cue coverage is currently `hub` and `main`; the remaining area cue
  assets are registered now so later scene registry expansion can use them
  without another asset import story.
- No image2/image generation visual asset is required for this audio-only
  slice.

## Out of Scope

- Final authored music, final ambience recordings, adaptive music layering,
  loudness normalization, or full mix balancing.
- New scene cue mappings for sewer/factory/rooftop/tower beyond registering the
  baseline assets.
- DEATH and CUTSCENE audio state completion.
- New visual assets or character frame animation changes.

## QA Test Cases

- **AC-1**: Default music/ambience import and playback.
  - Given: AudioSystem is instantiated.
  - When: `_ready()` finishes.
  - Then: all 15 cue ids are registered, point at imported WAV paths, and
    default `play_music()` / `play_ambient()` calls return true.

- **AC-2**: Unknown music/ambience cues remain safe.
  - Given: AudioSystem is instantiated.
  - When: an unknown music or ambient cue id is requested.
  - Then: the request returns false, records fade metadata, and does not crash.

- **AC-3**: Scene cue playback.
  - Given: Main gameplay moves from `hub` to `main`.
  - When: `on_scene_changed("hub", "main")` runs.
  - Then: `MusicPlayer.stream` and `AmbientPlayer.stream` are non-null and use
    `mus_street` / `amb_street`.

- **AC-4**: Rat King boss music playback.
  - Given: Rat King encounter and phase transition events fire.
  - When: start, phase 2, and phase 3 audio events run.
  - Then: the current boss music ids are `mus_boss_rat_p1`,
    `mus_boss_rat_p2`, and `mus_boss_rat_p3`, each with `stream_found=true`.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/presentation/audio_system_test.gd` covers default cue loading,
  playback, unknown-cue safety, scene cue playback, and boss music playback.
- Related regression covers MainScene audio adapters, scene transition UI, and
  Rat King runtime boss contracts.
- Godot import must generate `.wav.import` files for all 15 WAV assets.
- Godot MCP must verify runtime AudioSystem stream registration, buses, scene
  playback, boss music playback, logs, and screenshot.

**Status**: [x] Complete

## Evidence

- RED focused: `reports/report_585` failed as expected before music/ambience
  WAV assets and default AudioSystem stream registration existed.
- GREEN focused: `reports/report_586` passed `19/19` in
  `tests/unit/presentation/audio_system_test.gd`.
- Related regression: `reports/report_587` passed `32/32` across AudioSystem,
  MainScene audio adapter, scene transition UI, and Rat King runtime contract
  tests. The Godot process still printed existing GdUnit process-exit resource
  cleanup warnings after success; no test failures or runtime script errors
  were reported.
- Godot import generated `.wav.import` files for all 15 music/ambience cue WAVs.
- Headless smoke:
  `reports/audio_music_ambience_main_scene_smoke.log` exited `0` and has no
  `ERROR`, `SCRIPT ERROR`, `Failed`, `No loader`, or `Invalid` matches.
- Godot MCP runtime probe confirmed `/root/AudioSystem`, all 15 cue stream
  paths, no missing or mismatched cue ids, `MusicPlayer` on bus `Music`,
  `AmbientPlayer` on bus `Ambient`, scene playback of `mus_street` /
  `amb_street`, Rat King phase music playback for `mus_boss_rat_p1`,
  `mus_boss_rat_p2`, and `mus_boss_rat_p3`, clean game/editor logs, and
  screenshot:
  `reports/visual/cinderpaw-mcp-music-ambience-baseline-20260625.png`.
- QA evidence:
  `production/qa/evidence/audio-music-ambience-asset-import-baseline-2026-06-25.md`.

## Dependencies

- Depends on: Audio System Stories 001-007, scene transition audio fades, Rat
  King boss music state transitions, ADR-0010.
- Unlocks: authored/final music replacement, area scene cue expansion,
  DEATH/CUTSCENE state completion, and broader mix polish.
