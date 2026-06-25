# Story 006: Weapon Style SFX Asset Expansion

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
`AudioStreamPlayer2D` playback, and silent-safe missing-asset behavior. Story
005 imported the core combat SFX baseline; this story fills the remaining
weapon-style attack cues and GOOD parry cue that were intentionally deferred.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: WAV import and default `AudioStreamWAV` loading are already
validated by Story 005. This story expands the same import/load path without
adding new player, bus, or scene dependencies.

**Control Manifest Rules (Presentation layer)**:
- Required: AudioSystem remains Autoload #3 and owns SFX request diagnostics.
- Required: Presentation consumes Core/Feature data through signals or runtime
  adapters only.
- Guardrail: Core, Weapon, Combat, and SceneManager must not gain direct
  dependencies on AudioSystem.

---

## Acceptance Criteria

- [x] Weapon-style SFX WAV files exist under `assets/audio/sfx/` for
  `sfx_blade_attack`, `sfx_bone_attack`, and `sfx_bell_attack`.
- [x] `sfx_parry_good` exists under `assets/audio/sfx/` and is imported through
  Godot's asset pipeline.
- [x] `AudioSystem` loads all four new cue streams by default on `_ready()` and
  exposes their registered ids and source paths for tests/evidence.
- [x] `AudioSystem.on_weapon_attack_event()` returns true and records
  `stream_found=true` for `long_tail -> sfx_blade_attack`,
  `fish_bone -> sfx_bone_attack`, and `electro_bell -> sfx_bell_attack`.
- [x] `AudioSystem.on_parry_event()` returns true and records
  `stream_found=true` for `parry_type="good"` while unknown/miss parry remains
  silent-safe.
- [x] Asset generation/source details are recorded in QA evidence or a source
  manifest so the baseline WAVs can be replaced by authored assets later.
- [x] Godot MCP verifies runtime `/root/AudioSystem`, registered weapon-style
  streams, clean logs, and a capturable game frame after playback probes.

## Implementation Notes

- Reuse Story005's flat path convention:
  `res://assets/audio/sfx/<cue_id>.wav`.
- Keep all cue id selection inside `src/presentation/audio_system.gd`; do not
  add AudioSystem dependencies to WeaponComponent, CombatComponent, or MainScene
  beyond existing runtime adapter calls.
- Use short procedural WAV placeholders as replaceable baseline assets. The goal
  is to make existing weapon attacks audibly distinct now, not to finalize mix.

## Out of Scope

- UI menu audio and MENU state music ducking.
- Same-SFX 100ms merge and +20% volume behavior.
- Music, ambience, and authored/final audio replacement.
- New visual/image2 assets; this story adds no visual assets.
- New weapon mechanics, weapon VFX, hitbox behavior, or weapon swap UI.

## QA Test Cases

- **AC-1**: Default weapon-style SFX load.
  - Given: AudioSystem is instantiated.
  - When: `_ready()` finishes.
  - Then: `sfx_blade_attack`, `sfx_bone_attack`, `sfx_bell_attack`, and
    `sfx_parry_good` are registered with stream paths under
    `res://assets/audio/sfx/`.

- **AC-2**: Weapon attack cue routing.
  - Given: AudioSystem has loaded the default weapon-style SFX set.
  - When: `on_weapon_attack_event()` receives `long_tail`, `fish_bone`, or
    `electro_bell`.
  - Then: the call returns true, records the expected cue id and position, and
    the last request has `stream_found=true`.

- **AC-3**: GOOD parry cue routing.
  - Given: AudioSystem has loaded `sfx_parry_good`.
  - When: `on_parry_event({"parry_type": "good"})` is called.
  - Then: the call returns true, records `sfx_parry_good`, and keeps miss/unknown
    parry results silent-safe.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/presentation/audio_system_test.gd` must cover default stream
  registration, paths, and playback for the four new cues.
- `tests/unit/presentation/audio_system_test.gd` must cover weapon-style event
  routing and GOOD parry returning true with imported streams.
- Focused related regression should cover AudioSystem, MainScene audio event
  adapter, and main-scene weapon attack runtime tests.
- Godot headless main-scene smoke should run cleanly.
- Godot MCP should verify runtime AudioSystem registered weapon-style streams,
  representative playback, logs, and screenshot.

**Status**: [x] Complete

## Evidence

- RED focused AudioSystem: `reports/report_545` failed as expected before the
  new assets/default stream registrations existed.
- GREEN focused AudioSystem: `reports/report_546` passed `16/16`.
- Related regression: `reports/report_553` passed `25/25` across AudioSystem,
  MainScene audio adapter, and player attack core chain.
- Godot import generated `.wav.import` files for all four new cue WAVs.
- Headless smoke: `reports/audio_weapon_style_sfx_main_scene_smoke.log` has no
  error/warning/loader-failure matches.
- Godot MCP runtime probe confirmed `/root/AudioSystem`, registered cue ids,
  stream paths, direct playback, weapon route playback, GOOD parry playback,
  unknown cue silent-safe behavior, clean game/editor logs, and screenshot:
  `reports/visual/cinderpaw-mcp-weapon-style-sfx-20260625.png`.
- QA evidence:
  `production/qa/evidence/audio-weapon-style-sfx-asset-expansion-2026-06-25.md`.

## Dependencies

- Depends on: Audio System Story 003, Audio System Story 005, Combat
  Presentation Story 013, Weapon Styles Story 006-008, and ADR-0010.
- Unlocks: authored/final weapon SFX replacement, same-SFX merge tuning, and
  broader audio mix polish.
