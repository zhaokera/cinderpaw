# Story 005: Core Combat SFX Asset Import Baseline

> **Epic**: Audio System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/audio-system.md`
**Requirements**: `TR-audio-006`, partial `TR-audio-003`, partial `TR-audio-007`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at
review time)*

**ADR Governing Implementation**: ADR-0010: Audio system architecture
**ADR Decision Summary**: AudioSystem owns SFX cue selection, spatial
`AudioStreamPlayer2D` playback, and silent-safe missing-asset behavior. This
story moves the first combat cue set from diagnostics-only ids to actual Godot
AudioStream assets loaded through the project asset pipeline.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: WAV import and `load()` of `AudioStreamWAV` resources are
stable. This story does not add music crossfade players, UI audio, or same-SFX
merge behavior.

**Control Manifest Rules (Presentation layer)**:
- Required: AudioSystem remains Autoload #3 and owns SFX request diagnostics.
- Required: Presentation consumes Core/Feature data through signals or runtime
  adapters only.
- Guardrail: Core, Health, Combat, BossConfig, and SceneManager must not gain
  direct dependencies on AudioSystem.

---

## Acceptance Criteria

- [x] Core combat SFX WAV files exist under `assets/audio/sfx/` for
  `sfx_claw_attack`, `sfx_hit_normal`, `sfx_hit_crit`,
  `sfx_parry_perfect`, `sfx_dodge`, `sfx_damage_taken`,
  `sfx_damage_taken_lowhp`, `sfx_enemy_death`, `sfx_boss_phase`, and
  `sfx_focus_mode_activate`.
- [x] `AudioSystem` loads the core combat SFX set by default on `_ready()` and
  exposes registered stream ids and source paths for tests/evidence.
- [x] `play_sfx()` returns true for every imported core combat cue, assigns a
  SFX pool player, and records `stream_found=true` in the last SFX request.
- [x] Existing combat/health event adapters keep their cue selection behavior
  but now play available core combat streams instead of only returning false.
- [x] Missing or not-yet-imported SFX ids remain silent-safe and do not consume
  a pool voice.
- [x] Asset generation/source details are recorded in QA evidence or a source
  manifest so the baseline WAVs can be replaced by authored assets later.
- [x] Godot MCP verifies runtime `/root/AudioSystem`, registered core SFX
  streams, clean logs, and a capturable game frame after playback probes.

## Implementation Notes

- Add the smallest default stream manifest inside AudioSystem or a local helper
  API; do not introduce a new Autoload or external asset database in this
  slice.
- Keep all SFX cue ids stable with Story 003 and the GDD asset list.
- Use short procedural WAV placeholders as shippable baseline assets for this
  story. They must be clearly recorded as generated baseline assets and can be
  replaced by authored audio later without changing cue ids.
- Keep `register_audio_stream()` usable for tests and future tools.

## Out of Scope

- UI menu audio (`ui_menu_open`, `ui_navigate`, `ui_confirm`, etc.).
- Same-SFX 100ms merge and +20% volume behavior.
- Music, ambience, and authored boss score files.
- `sfx_blade_attack`, `sfx_bone_attack`, `sfx_bell_attack`, and
  `sfx_parry_good` import beyond diagnostics-only behavior.
- New visual/image2 assets; this story adds no visual assets.

## QA Test Cases

- **AC-1**: Default core combat SFX load.
  - Given: AudioSystem is instantiated.
  - When: `_ready()` finishes.
  - Then: all ten core combat cue ids are registered with stream paths under
    `res://assets/audio/sfx/`.

- **AC-2**: Imported stream playback.
  - Given: a core combat cue id such as `sfx_hit_normal`.
  - When: `play_sfx()` is called with a world position and priority.
  - Then: the call returns true, a SFX pool player receives a non-null stream,
    and diagnostics record `stream_found=true`.

- **AC-3**: Gameplay adapter uses imported streams.
  - Given: AudioSystem has loaded the default core combat SFX set.
  - When: hit, dodge, damage, focus, enemy defeat, or boss phase events fire.
  - Then: the existing adapter returns true for imported cues and preserves
    event metadata.

- **AC-4**: Missing stream safety.
  - Given: an unknown cue id.
  - When: `play_sfx()` is called.
  - Then: the call returns false, diagnostics record `stream_found=false`, and
    the SFX pool is not consumed.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/presentation/audio_system_test.gd` must cover default stream
  registration, source paths, and imported stream playback.
- `tests/unit/presentation/audio_system_test.gd` must update relevant adapter
  expectations from missing-stream false to imported-stream true.
- Focused related regression should cover AudioSystem and MainScene audio event
  adapter tests.
- Godot headless main-scene smoke should run cleanly.
- Godot MCP should verify runtime AudioSystem registered SFX streams, logs, and
  screenshot.

**Status**: [x] Complete

## Evidence

- RED: `reports/report_539/results.xml` failed because AudioSystem did not yet
  expose default stream query APIs or load imported combat SFX.
- Import failure checkpoint: `reports/report_540/results.xml` captured Godot
  `No loader found` errors before the WAV files entered the import pipeline.
- Import: `/opt/homebrew/bin/godot --headless --path . --import --quit-after 2`
  generated `.import` files and imported `.sample` resources for all ten WAVs.
- GREEN focused: `reports/report_542/results.xml`, `15/15`.
- Related regression: `reports/report_543/results.xml`, `20/20`.
- Headless smoke: `reports/audio_core_combat_sfx_main_scene_smoke.log`, exit
  `0`, no error/warning/loader keyword matches.
- MCP runtime: `/root/AudioSystem` registered all ten cue ids, returned the
  expected paths, played representative weapon/hit/damage/focus/dodge/death/boss
  phase SFX with `stream_found=true` on `SFX` bus, kept missing cue silent-safe,
  and produced clean game/editor logs.
- MCP screenshot:
  `reports/visual/cinderpaw-mcp-core-combat-sfx-20260625.png`.
- QA evidence:
  `production/qa/evidence/audio-core-combat-sfx-asset-import-2026-06-25.md`.

## Dependencies

- Depends on: Audio System Story 001, Story 003, Story 004, and ADR-0010.
- Unlocks: UI menu audio, same-SFX merge, real authored weapon SFX expansion,
  and mix polish.
