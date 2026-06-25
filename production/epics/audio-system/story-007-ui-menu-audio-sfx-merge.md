# Story 007: UI Menu Audio + Same-SFX Merge

> **Epic**: Audio System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/audio-system.md`, `design/gdd/hud-ui.md`
**Requirements**: `TR-audio-005`, partial `TR-audio-007`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at
review time)*

**ADR Governing Implementation**: ADR-0010: Audio system architecture,
ADR-0011: UI focus management
**ADR Decision Summary**: AudioSystem owns UI cue playback on the UI bus, MENU
audio state boundaries, and same-SFX request coalescing without pushing audio
logic into HUD/UI or gameplay systems.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: UI cues use global `AudioStreamPlayer` instances on the UI
bus. Same-SFX merge reuses an active SFX player when the same cue repeats within
100ms and boosts linear volume by 20%.

**Control Manifest Rules (Presentation layer)**:
- Required: AudioSystem remains Autoload #3 and owns bus/state/playback
  diagnostics.
- Required: Presentation consumes gameplay and HUD events through runtime
  adapters or signals.
- Guardrail: HUD, SaveSystem, SceneManager, and Core gameplay must not gain hard
  dependencies on AudioSystem.

---

## Acceptance Criteria

- [x] UI menu cue WAV files exist under `assets/audio/ui/` for
  `ui_menu_open`, `ui_menu_close`, `ui_navigate`, `ui_confirm`, `ui_cancel`,
  `ui_save`, and `ui_load`.
- [x] UI cue generation/source details are recorded in
  `assets/audio/source/ui_menu_audio_generation_20260625.json`.
- [x] `AudioSystem` loads all UI cue streams by default and plays them through a
  non-spatial UI bus player pool.
- [x] `AudioSystem.on_menu_opened()` enters `MENU`, captures the previous audio
  state, ducks the Music bus to 50% of its current value, and plays
  `ui_menu_open`.
- [x] `AudioSystem.on_menu_closed()` restores the captured Music bus volume,
  returns to the previous audio state, and plays `ui_menu_close`.
- [x] `AudioSystem.play_sfx()` merges the same SFX cue within 100ms by reusing
  the active voice and multiplying linear volume by `1.2`.
- [x] `MainScene` forwards pause/resume/menu navigation/save/load feedback to
  AudioSystem through the runtime adapter.
- [x] Godot MCP verifies runtime AudioSystem UI cue registration, UI bus
  playback, MENU duck/restore, same-SFX merge, clean logs, and a non-empty game
  screenshot.

## Implementation Notes

- UI audio uses flat runtime paths:
  `res://assets/audio/ui/<cue_id>.wav`.
- `AudioSystem` owns the UI player pool and same-SFX merge policy; MainScene
  only sends presentation events such as `on_menu_opened`, `on_ui_save`, and
  `on_ui_load`.
- The UI WAV files are deterministic procedural baseline assets. They are
  intentionally replaceable once authored final UI SFX are available.
- Menu state ducking is idempotent: moving from pause to settings/load/main menu
  keeps the original Music volume capture until the menu actually closes.

## Out of Scope

- Final authored UI SFX, final mix balancing, music/ambience replacement, and
  platform-specific output loudness calibration.
- New HUD layout, menu visual polish, or input navigation changes.
- DEATH and CUTSCENE audio state completion beyond preserving existing state
  restoration behavior.
- New visual/image2 assets; this is an audio-only player-feedback slice.

## QA Test Cases

- **AC-1**: Default UI cue import and playback.
  - Given: AudioSystem is instantiated.
  - When: `_ready()` finishes.
  - Then: all seven UI cue ids are registered, point at
    `res://assets/audio/ui/*.wav`, and play on `UIPlayerXX` with bus `UI`.

- **AC-2**: MENU state music ducking.
  - Given: Music bus volume is 60 and previous state is `BOSS_FIGHT`.
  - When: `on_menu_opened()` is called.
  - Then: audio state becomes `MENU`, Music bus volume becomes 30, and
    `ui_menu_open` plays.
  - When: `on_menu_closed()` is called.
  - Then: Music bus volume restores to 60, state restores to `BOSS_FIGHT`, and
    `ui_menu_close` plays.

- **AC-3**: Same-SFX merge.
  - Given: one SFX cue is active.
  - When: the same cue is requested again within 100ms.
  - Then: the active voice is reused, active SFX count stays at 1, and linear
    volume is multiplied by `1.2`.

- **AC-4**: MainScene menu feedback routing.
  - Given: MainScene has a configured AudioSystem runtime adapter.
  - When: pause/resume/save/load menu signals fire.
  - Then: MainScene dispatches menu open/close and UI save/load events without
    coupling HUD or SaveSystem to AudioSystem.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/presentation/audio_system_test.gd` covers default UI cue loading,
  UI bus playback, MENU duck/restore, and same-SFX merge.
- `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd` covers MainScene
  menu open/close/save/load forwarding.
- Related regression should cover menu save/load runtime, HUD settings, and
  scene transition UI tests.
- Godot headless main-scene smoke should run cleanly.
- Godot MCP should verify runtime UI cue registration, UI bus playback, MENU
  duck/restore, same-SFX merge, logs, and screenshot.

**Status**: [x] Complete

## Evidence

- RED focused: `reports/report_580` failed as expected before the UI audio API,
  default UI streams, and MainScene menu forwarding existed.
- GREEN focused: `reports/report_582` passed `25/25` across AudioSystem and
  MainScene audio event adapter tests.
- Related regression: `reports/report_583` passed `36/36` across AudioSystem,
  MainScene audio adapter, save/load menu runtime, HUD settings runtime, and
  scene transition UI tests. GdUnit still reports existing process-exit
  resource cleanup warnings after success; no test failures or runtime script
  errors were reported.
- Post-fix targeted guard: `reports/report_584` passed `10/10` across MainScene
  audio adapter and save/load menu runtime after preserving the existing save
  menu refresh behavior.
- Godot import generated `.wav.import` files for all seven UI cue WAVs.
- Headless smoke: `reports/audio_ui_menu_audio_main_scene_smoke.log` has no
  error/warning/loader-failure matches.
- Godot MCP runtime probe confirmed `/root/AudioSystem`, UI cue stream paths,
  `UIPlayer00` on bus `UI`, Music duck `60 -> 30 -> 60`, `ui_menu_open`,
  `ui_menu_close`, `ui_save`, `ui_load`, same-SFX merge with one active voice
  and `1.2` volume multiplier, clean game/editor logs, and screenshot:
  `reports/visual/cinderpaw-mcp-ui-menu-audio-20260625.png`.
- QA evidence:
  `production/qa/evidence/audio-ui-menu-audio-sfx-merge-2026-06-25.md`.

## Dependencies

- Depends on: Audio System Stories 001-006, HUD/UI menu runtime, Save System
  menu shell, ADR-0010, and ADR-0011.
- Unlocks: authored/final UI SFX replacement, broader mix polish, DEATH and
  CUTSCENE state completion, and final audio loudness balancing.
