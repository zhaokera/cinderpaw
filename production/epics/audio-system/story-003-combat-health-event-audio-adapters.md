# Story 003: Combat + Health Event Audio Adapters

> **Epic**: Audio System
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/audio-system.md`
**Requirements**: `TR-audio-006`, partial `TR-audio-007`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0010: Audio system architecture
**ADR Decision Summary**: AudioSystem owns SFX cue selection, priority, and
safe missing-asset behavior. Gameplay and Core systems emit domain events;
MainScene may bridge runtime signals to AudioSystem without making Core depend
on Presentation.

**Engine**: Godot 4.6.3 | **Risk**: MEDIUM
**Engine Notes**: Event adapters must stay signal-facing and tolerate missing
streams until generated/imported audio assets exist.

**Control Manifest Rules (Presentation layer)**:
- Required: AudioSystem remains Autoload #3 and owns SFX request diagnostics.
- Required: Presentation consumes Core/Feature data through signals or runtime
  adapters only.
- Guardrail: Core, Health, Combat, and SceneManager must not gain direct
  dependencies on AudioSystem.

---

## Acceptance Criteria

- [x] `AudioSystem.on_hit_event(hit_data)` routes normal and crit hits to
  `sfx_hit_normal` or `sfx_hit_crit` at the hit position with crit taking higher
  priority.
- [x] `AudioSystem.on_parry_event(parry_data)` routes `perfect` and `good`
  parry results to `sfx_parry_perfect` and `sfx_parry_good`; miss/unknown parry
  results remain silent-safe.
- [x] `AudioSystem.on_dodge_event(...)` routes player dodge starts to
  `sfx_dodge` at the player sprite/world position.
- [x] `AudioSystem.on_damage_taken_event(damage_data)` routes player damage to
  `sfx_damage_taken`, but uses `sfx_damage_taken_lowhp` while focus-mode audio
  is active.
- [x] `AudioSystem.on_focus_mode_changed(entity_id, active, metadata)` tracks
  LOW_HP audio state and plays `sfx_focus_mode_activate` only when entering
  focus mode.
- [x] `AudioSystem.on_enemy_defeated(metadata)` routes enemy death to
  `sfx_enemy_death` at the defeated enemy position.
- [x] `AudioSystem.on_boss_phase_transition_started(entity_id, phase, metadata)`
  routes boss phase transitions to `sfx_boss_phase` and records BOSS_FIGHT
  state diagnostics without requiring music assets.
- [x] `MainScene` forwards player attack, enemy damage, player dodge, focus
  mode, enemy defeat, and boss phase transition events to AudioSystem without
  changing Core gameplay components or blocking when streams are missing.
- [x] Godot MCP verifies runtime `/root/AudioSystem`, clean logs, and a
  capturable game frame after the event adapter wiring.

---

## Implementation Notes

- Keep all real cue selection inside `src/presentation/audio_system.gd`.
- Keep MainScene as the runtime integration boundary, mirroring the existing
  SceneManager-to-AudioSystem adapter from Story 002.
- Missing cue streams must continue returning false and recording diagnostics.
- Use public diagnostics such as `get_last_sfx_request()` and event-state
  snapshots for tests; do not inspect private fields from tests.

---

## Out of Scope

- Real SFX/music files and audio import manifests.
- Same-SFX 100ms merge.
- Full MENU/CUTSCENE audio states and menu music ducking.
- UI menu sound playback.
- Actual boss music hard cuts or simultaneous crossfade players.
- New visual/image2 assets; this story adds no visual assets.

---

## QA Test Cases

- **AC-1**: Hit cue routing.
  - Given: a hit event with `hit_position` and `is_crit`.
  - When: `on_hit_event()` is called.
  - Then: the last SFX request records the correct hit cue, position, and
    priority.

- **AC-2**: Focus-mode damage cue routing.
  - Given: focus-mode audio is active.
  - When: player damage is routed to AudioSystem.
  - Then: `sfx_damage_taken_lowhp` replaces `sfx_damage_taken`.

- **AC-3**: MainScene runtime wiring.
  - Given: MainScene is configured with an AudioSystem-like object.
  - When: player attack, enemy attack, dodge, focus, enemy defeat, and boss
    phase signals fire.
  - Then: MainScene forwards each event to AudioSystem while existing Combat
    Presentation and HUD behavior still runs.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- `tests/unit/presentation/audio_system_test.gd` event-adapter tests must pass.
- `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd` must confirm
  MainScene runtime signal forwarding to AudioSystem.
- Related Presentation/Gameplay regressions must keep passing.
- Godot headless main-scene smoke must run.
- Godot MCP must verify runtime AudioSystem state, logs, and screenshot.

**Evidence**:
- `production/qa/evidence/audio-combat-health-event-adapters-2026-06-25.md`
- RED focused:
  `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd --ignoreHeadlessMode`
  - Exit `100`, `reports/report_458/results.xml`; failed because
    `AudioSystem.on_hit_event()` and MainScene gameplay audio forwarding did
    not exist.
- GREEN focused:
  same command.
  - Exit `0`, `reports/report_459/results.xml`, `16/16`, `0` errors, `0`
    failures, `0` orphans.
- Related regression:
  `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd --ignoreHeadlessMode`
  - Exit `0`, `reports/report_460/results.xml`, `90/90`, `0` errors, `0`
    failures, `0` orphans.
- Final focused after adapter refactor:
  `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd --ignoreHeadlessMode`
  - Exit `0`, `reports/report_461/results.xml`, `27/27`, `0` errors, `0`
    failures, `0` orphans.
- Headless smoke:
  `/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/audio_event_adapters_main_scene_smoke.log`
  - Exit `0`; log scan found no error/warning keywords.
- Godot MCP:
  - Editor state ready on `res://scenes/main.tscn`; `project_run(mode="main",
    autosave=true)` reached `game_capture_ready=true`.
  - Runtime probes verified `/root/AudioSystem` exists and MainScene callbacks
    route `sfx_hit_normal`, `sfx_claw_attack`, `sfx_damage_taken`,
    `sfx_focus_mode_activate`, `sfx_damage_taken_lowhp`, `sfx_dodge`, and
    `sfx_boss_phase` while missing streams remain silent-safe.
  - Player and Enemy runtime sprites are `AnimatedSprite2D`; Player has 9
    animations and Enemy has 6 animations.
  - Game log contained only MCP helper registration info; editor log returned
    `0` rows after clearing evaluation-script noise; game screenshot was
    non-empty at 1280x720 source resolution.

**Status**: [x] Complete

---

## Dependencies

- Depends on: Audio System Story 001, Audio System Story 002, ADR-0010.
- Unlocks: UI menu audio, boss music state transitions, real audio asset import
  stories, and audio mix polish.
