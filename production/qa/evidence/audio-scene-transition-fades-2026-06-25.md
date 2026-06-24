# QA Evidence: Audio Scene Transition Fades

> **Date**: 2026-06-25
> **Epic**: Audio System
> **Story**: 002 Scene Transition Audio Fades
> **Traceability**: TR-audio-004, TR-audio-008

## Scope

Implemented the SceneManager-to-AudioSystem transition audio slice:

- `AudioSystem` now exposes scene-transition methods for load-start, changed,
  and failed events.
- Scene load start forces current music and ambience to record a 2.0 second
  fade-out, matching TR-audio-008.
- Scene changed starts configured scene music/ambience cues with a 3.0 second
  fade-in/crossfade diagnostic, matching TR-audio-004.
- Default cue map covers `main -> mus_street + amb_street` and
  `hub -> mus_hub + amb_hub`.
- `MainScene` forwards SceneManager transition callbacks to AudioSystem while
  keeping SceneManager free of AudioSystem dependencies.

No visual/image2 assets were needed for this infrastructure story. Real audio
files and tweened dual-player crossfade playback remain future asset/system
stories.

## TDD Evidence

1. RED focused:

```text
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/presentation/audio_system_test.gd \
  -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd \
  --ignoreHeadlessMode
```

Result: exit `100`, `reports/report_452/results.xml`, failed because
`AudioSystem.on_scene_load_started()` and
`MainScene.configure_audio_system_runtime()` did not exist.

2. GREEN focused:

```text
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/presentation/audio_system_test.gd \
  -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd \
  --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_453/results.xml`, `11/11`, `0` errors,
`0` failures, `0` orphans.

## Regression Evidence

Focused regression after cue override and visual-contract hardening:

```text
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/presentation/audio_system_test.gd \
  -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd \
  -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd \
  -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd \
  --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_455/results.xml`, `19/19`, `0` errors,
`0` failures, `0` orphans.

Related Presentation/Input/Save/Scene/Gameplay regression:

```text
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/presentation \
  -a res://tests/unit/input/story_001_action_abstraction_test.gd \
  -a res://tests/unit/save \
  -a res://tests/unit/scene \
  -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd \
  -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd \
  -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd \
  --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_456/results.xml`, `122/122`, `0` errors,
`0` failures, `0` orphans. The CLI emitted an ObjectDB leak warning after
finalization; the GdUnit report itself was clean.

Headless main-scene smoke:

```text
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn \
  --fixed-fps 60 --quit-after 3 \
  --log-file reports/audio_scene_transition_fades_main_scene_smoke.log
```

Result: exit `0`; log scan found no `ERROR`, `SCRIPT ERROR`, `WARNING`,
`Invalid call`, or `Parse Error` lines.

## Godot MCP Evidence

- MCP editor state: Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, project readiness `ready`.
- The editor initially exposed stale in-memory `/Main/Enemy/Sprite` as a
  `Sprite2D` using `res://assets/generated/shadow_beast_enemy.png`. Disk and
  CLI loads were already correct, so the edited main scene was repaired by
  re-instancing `/Main/Enemy` from `res://src/gameplay/simple_enemy.tscn` and
  saving through MCP.
- MCP `node_find(type="AnimatedSprite2D")` after the fix returned both
  `/Main/Player/Sprite` and `/Main/Enemy/Sprite`.
- MCP `node_get_properties("/Main/Enemy/Sprite")` confirmed:
  - class `AnimatedSprite2D`
  - `sprite_frames = res://assets/characters/shadow_beast/shadow_beast_sprite_frames.tres`
  - script `res://src/characters/shadow_beast.gd`
  - animation `idle`
- MCP `project_run(mode="main", autosave=true)` started the game and
  `game_capture_ready=true`.
- Runtime `game_eval` emitted SceneManager signals and verified:
  - `/root/AudioSystem` exists and `/root/SceneManager` exists.
  - Before changed: transition audio active, target `main`, spawn `default`,
    Music/Ambient ids cleared, fade-out diagnostics `2.0` seconds, HUD
    transition shell visible.
  - After changed: transition audio inactive, music `mus_street`, ambience
    `amb_street`, fade-in diagnostics `3.0` seconds, HUD shell hidden.
  - Player sprite class `AnimatedSprite2D`, `9` animations.
  - Enemy sprite class `AnimatedSprite2D`, `6` animations, `attack` has `3`
    frames.
- Logs:
  - `logs_read(source="game")`: only MCP helper registration info.
  - `logs_read(source="editor")`: `0` rows.
- Screenshot:
  - `editor_screenshot(source="game")` captured a non-empty runtime frame at
    1280x720 source resolution, with the wasteland arena and visible
    Player/Enemy animated characters.

## Result

PASS. Scene transition audio fade diagnostics are wired through MainScene from
SceneManager signals, safe before real audio streams exist, and covered by
RED/GREEN GdUnit, related regression, headless smoke, and Godot MCP runtime
validation. The concurrent character-animation MCP drift was repaired and
covered by a new legacy-single-image regression assertion.
