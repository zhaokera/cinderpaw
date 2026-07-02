# Story 002: Scene Transition Audio Fades

> **Epic**: Audio System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/audio-system.md`
**Requirements**: `TR-audio-004`, `TR-audio-008`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0007: Scene management architecture;
ADR-0010: Audio system architecture
**ADR Decision Summary**: SceneManager owns scene lifecycle signals while
AudioSystem owns music, ambience, and fade state. MainScene may wire runtime
Presentation services together without pushing audio decisions into
SceneManager.

**Engine**: Godot 4.7 | **Risk**: MEDIUM
**Engine Notes**: This story records fade requests and safe missing-asset
behavior. Real crossfade tweening and generated audio assets remain later audio
asset stories.

**Control Manifest Rules (Presentation layer)**:
- Required: AudioSystem owns music and ambience request/fade diagnostics.
- Required: Scene transition events remain emitted by SceneManager and consumed
  by Presentation/runtime wiring.
- Guardrail: SceneManager must not gain direct dependencies on AudioSystem.

---

## Acceptance Criteria

- [x] `AudioSystem.on_scene_load_started(scene_id, spawn_point, metadata)`
  marks scene-transition audio active and forces current music and ambience to
  stop with a 2.0 second fade-out record.
- [x] `AudioSystem.on_scene_changed(old_scene, new_scene)` clears the
  transition-active flag and starts configured scene music/ambience cues with a
  3.0 second fade-in/crossfade record.
- [x] Default area cue mapping includes `main -> mus_street + amb_street` and
  `hub -> mus_hub + amb_hub`, matching the GDD area music/ambient catalog.
- [x] `AudioSystem.on_scene_load_failed(scene_id, reason)` clears the
  transition-active flag without starting new cues and records failure
  diagnostics.
- [x] `MainScene` wires SceneManager load-start/changed/failed callbacks into
  AudioSystem without adding any AudioSystem dependency to SceneManager.
- [x] Missing streams remain silent-safe: cue requests update diagnostics and
  return false instead of blocking scene transitions.
- [x] Godot MCP verifies runtime `/root/AudioSystem`, scene-transition audio
  state, clean logs, and a capturable game frame.

---

## Implementation Notes

- Added default scene audio cue mapping inside `AudioSystem` for `hub` and
  `main`; cues can be replaced later through `configure_scene_audio_cues()`.
- Added scene-transition audio diagnostics:
  `is_scene_transition_audio_active()`,
  `get_scene_transition_audio_state()`, and `get_scene_audio_cue()`.
- Added signal-facing methods `on_scene_load_started()`,
  `on_scene_changed()`, and `on_scene_load_failed()` so MainScene can forward
  SceneManager transition signals through a small runtime adapter boundary.
- Added `MainScene.configure_audio_system_runtime()` for tests and runtime
  Autoload resolution, mirroring existing SaveSystem/SceneManager injection
  patterns.
- MainScene continues to drive the HUD loading shell from SceneManager signals;
  audio work happens in the same callbacks but remains owned by AudioSystem.

---

## Out of Scope

- Real music, ambience, or SFX assets.
- Runtime tweened crossfade curves between two simultaneous music players.
- Boss fight hard cuts and boss phase transition music.
- Combat, health, dodge, parry, death, UI, and boss audio event adapters.
- New visual/image2 assets; this story adds no visual assets.

---

## QA Test Cases

- **AC-1**: Forced fade on scene load start.
  - Given: music and ambience request state is active.
  - When: `on_scene_load_started("hub", "clan_base", metadata)` is called.
  - Then: both current ids clear, fade-out diagnostics are `2.0`, and
    transition state records the target scene, spawn, and metadata.

- **AC-2**: Default area cue crossfade on scene changed.
  - Given: the default cue map.
  - When: `on_scene_changed("hub", "main")` is called.
  - Then: current music is `mus_street`, current ambience is `amb_street`, and
    both fade-in diagnostics are `3.0`.

- **AC-3**: Failure path does not start target cue.
  - Given: a scene transition is active.
  - When: `on_scene_load_failed("main", "timeout")` is called.
  - Then: transition audio is inactive, failure diagnostics are recorded, and no
    new music/ambience id is set.

- **AC-4**: MainScene runtime wiring.
  - Given: MainScene is configured with a SceneManager-like object and an
    AudioSystem-like object.
  - When: New Game triggers SceneManager load-start, changed, or failed signals.
  - Then: MainScene forwards each event to AudioSystem while preserving the HUD
    transition shell behavior.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/presentation/audio_system_test.gd` scene-transition tests must
  pass.
- `tests/unit/gameplay/main_scene_scene_transition_ui_test.gd` must confirm
  SceneManager signal forwarding to AudioSystem.
- Related Presentation/Scene/Gameplay/Save regressions must keep passing.
- Godot headless main-scene smoke must run.
- Godot MCP must verify runtime AudioSystem state, logs, and screenshot.

**Evidence**:
- `production/qa/evidence/audio-scene-transition-fades-2026-06-25.md`
- RED focused:
  `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd --ignoreHeadlessMode`
  - Exit `100`, `reports/report_452/results.xml`; failed because
    `AudioSystem.on_scene_load_started()` and
    `MainScene.configure_audio_system_runtime()` did not exist.
- GREEN focused:
  same command.
  - Exit `0`, `reports/report_453/results.xml`, `11/11`, `0` errors, `0`
    failures, `0` orphans.
- Focused regression after cue override and visual-contract hardening:
  `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd --ignoreHeadlessMode`
  - Exit `0`, `reports/report_455/results.xml`, `19/19`, `0` errors, `0`
    failures, `0` orphans.
- Related regression:
  `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation -a res://tests/unit/input/story_001_action_abstraction_test.gd -a res://tests/unit/save -a res://tests/unit/scene -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd --ignoreHeadlessMode`
  - Exit `0`, `reports/report_456/results.xml`, `122/122`, `0` errors, `0`
    failures, `0` orphans. CLI emitted an ObjectDB leak warning after
    finalization; the GdUnit report itself was clean.
- Headless smoke:
  `/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/audio_scene_transition_fades_main_scene_smoke.log`
  - Exit `0`; log scan found no error/warning keywords.
- Godot MCP:
  - Editor state ready on `res://scenes/main.tscn`; stale Enemy editor cache was
    repaired by re-instancing `/Main/Enemy` from `src/gameplay/simple_enemy.tscn`
    and saving through MCP.
  - Runtime `game_eval` verified SceneManager signals reach AudioSystem:
    2.0 second Music/Ambient fade-out on load start, `mus_street` +
    `amb_street` with 3.0 second fade-in after scene changed, HUD transition
    shell visible then hidden.
  - Runtime Player/Enemy sprites are both `AnimatedSprite2D`; Player has 9
    animations, Enemy has 6 animations and 3 attack frames.
  - Game log contained only MCP helper registration info; editor log returned
    `0` rows; game screenshot was non-empty at 1280x720 source resolution.

**Status**: [x] Complete

---

## Dependencies

- Depends on: Audio System Story 001, SceneManagement Story 004 transition
  loading UI shell, ADR-0007, ADR-0010.
- Unlocks: combat event audio adapters, boss music state transitions, UI menu
  ducking, and real audio asset import stories.
