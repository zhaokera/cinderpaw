# Story 001: Autoload Bus + Pool Baseline

> **Epic**: Audio System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/audio-system.md`
**Requirements**: `TR-audio-001`, `TR-audio-002`, `TR-audio-009`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0001: Autoload architecture; ADR-0010:
Audio system architecture
**ADR Decision Summary**: AudioSystem is a Presentation-layer global service
that owns audio buses, SFX pooling, music request state, and safe playback
entrypoints.

**Engine**: Godot 4.6.3 | **Risk**: MEDIUM
**Engine Notes**: `AudioServer` is global state, so bus initialization must be
idempotent and tests must not assume a fresh engine process beyond managed bus
defaults.

**Control Manifest Rules (Presentation layer)**:
- Required: AudioSystem is Autoload #3 and owns the Master/Music/SFX/Ambient/UI
  bus layout.
- Required: `play_sfx`, `play_music`, and `set_bus_volume` are available from
  AudioSystem.
- Guardrail: SFX playback is capped to 16 simultaneous voices with overflow
  dropping a lower-priority voice.

---

## Acceptance Criteria

- [x] `project.godot` registers `AudioSystem` between `InputManager` and
  `SaveSystem`.
- [x] AudioSystem initializes Master, Music, SFX, Ambient, and UI buses with
  default volumes 80/60/80/50/70.
- [x] `set_bus_volume(bus_name, volume_percent)` clamps values to 0-100 and
  rejects unknown buses without crashing.
- [x] AudioSystem creates a 16-player `AudioStreamPlayer2D` SFX pool on the SFX
  bus with 600px max distance.
- [x] `play_sfx(sfx_id, position, volume_db, pitch_offset, priority)` records
  spatial, volume, pitch, and priority metadata, maps `pitch_offset` to
  `pitch_scale`, and enforces the 16-voice cap.
- [x] `play_music`, `stop_music`, `play_ambient`, and `stop_ambient` record
  fade state and fail safely when assets are not yet registered.
- [x] Godot MCP verifies runtime `/root/AudioSystem`, bus state, public API,
  clean logs, and a capturable game frame.

---

## Implementation Notes

- Added `src/presentation/audio_system.gd` as a Node Autoload following the
  existing manager style. It intentionally does not declare `class_name` to
  avoid colliding with the singleton name and to match current Data/Input/Save
  manager patterns.
- Runtime bus setup uses `AudioServer.get_bus_index()` and only adds missing
  buses; it never resets the whole bus count.
- Bus volume is applied through `AudioServer.set_bus_volume_linear()` so the GDD
  percentages map directly to engine linear volume.
- `register_audio_stream(audio_id, stream)` provides a deterministic test seam
  and future asset-manifest hook without preloading missing assets.
- Missing audio streams return `false` and update request diagnostics without
  consuming SFX pool voices or throwing.
- Music and ambience true crossfade, boss hard cuts, same-SFX 100ms merge, and
  upstream signal wiring remain future stories.

---

## Out of Scope

- Real SFX, music, ambience, or UI audio assets.
- SceneManager transition fade wiring.
- Combat, health, death, dodge, parry, and boss signal listeners.
- Music state machine transitions beyond request/fade diagnostics.
- Persistent `default_bus_layout.tres` authoring.
- Visual/image2 asset generation; this story adds no visual assets.

---

## QA Test Cases

- **AC-1**: AudioSystem Autoload order.
  - Given: `project.godot`.
  - When: the `[autoload]` entries are read.
  - Then: `AudioSystem` appears after `InputManager` and before `SaveSystem`.

- **AC-2**: Default bus state.
  - Given: AudioSystem is instantiated.
  - When: `_ready()` runs.
  - Then: Master/Music/SFX/Ambient/UI exist in `AudioServer` and expose default
    percent and linear volumes.

- **AC-3**: Volume controls.
  - Given: the Music bus.
  - When: volume is set to 50, below 0, above 100, or an unknown bus is used.
  - Then: valid buses clamp and update engine state; unknown buses return false.

- **AC-4**: SFX pool and pitch.
  - Given: a test `AudioStreamGenerator` is registered.
  - When: 17 SFX requests are sent with increasing priority.
  - Then: active voices remain capped at 16, dropped count increments once, and
    the final request records position, volume, pitch offset, and pitch scale.

- **AC-5**: Missing assets are safe.
  - Given: no audio stream exists for a requested id.
  - When: `play_sfx`, `play_music`, or `play_ambient` are called.
  - Then: each call returns false without consuming a pool voice or crashing.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/presentation/audio_system_test.gd` must exist and pass.
- Related Presentation, Input, Save, and Scene suites must keep passing after
  Autoload order changes.
- Godot headless main-scene smoke must run.
- Godot MCP must verify `/root/AudioSystem`, buses, public API, runtime logs,
  and game capture.

**Evidence**:
- `production/qa/evidence/audio-system-autoload-bus-pool-baseline-2026-06-25.md`
- RED focused:
  `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode`
  - Exit `100`, `reports/report_446/results.xml`; failed because
    `src/presentation/audio_system.gd` and AudioSystem Autoload registration did
    not exist yet.
- RED refinement:
  same command.
  - Exit `100`, `reports/report_448/results.xml`; failed on SFX 2D
    `max_distance` and bus send assertion after tests were tightened.
- GREEN focused:
  same command.
  - Exit `0`, `reports/report_449/results.xml`, AudioSystem `6/6`, `0`
    errors, `0` failures, `0` orphans.
- Related regression:
  `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation -a res://tests/unit/input/story_001_action_abstraction_test.gd -a res://tests/unit/save -a res://tests/unit/scene --ignoreHeadlessMode`
  - Exit `0`, `reports/report_451/results.xml`, `109/109`, `0` errors, `0`
    failures, `0` orphans. CLI emitted an ObjectDB leak warning after
    finalization; the GdUnit report itself stayed clean.
- Headless smoke:
  `/opt/homebrew/bin/godot --headless --path . --quit-after 3`
  - Exit `0`; DataManager domains loaded; no script errors.
- Godot MCP:
  - `editor_state`: connected to Godot `4.6.3-stable`, current scene
    `res://scenes/main.tscn`.
  - `project_run(mode="main", autosave=true)`: game capture ready.
  - Runtime `game_eval` verified `/root/AudioSystem`, bus default volumes,
    `pool_size=16`, missing SFX/music/ambient calls returning false, and last
    SFX metadata including position, volume, `pitch_offset=3`, and
    `pitch_scale≈1.1892`.
  - `logs_read(source="game")`: only MCP helper registration info.
  - `editor_screenshot(source="game")`: runtime frame captured at 1280x720
    source resolution.

**Status**: [x] Complete

---

## Dependencies

- Depends on: DataManager/InputManager Autoload ordering, ADR-0001, ADR-0010.
- Unlocks: Audio System scene-transition fade integration, combat audio event
  adapters, music state machine, and future audio asset import stories.
