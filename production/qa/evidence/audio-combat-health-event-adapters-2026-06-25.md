# QA Evidence: Audio Combat + Health Event Adapters

Date: 2026-06-25
Story: `production/epics/audio-system/story-003-combat-health-event-audio-adapters.md`
Engine: Godot 4.6.3

## Scope

Implemented Presentation-layer gameplay SFX adapters for AudioSystem and
MainScene runtime forwarding. The slice covers combat hit, weapon attack, parry,
dodge, damage taken, focus-mode enter, enemy defeated, and boss phase SFX cue
requests. No real audio files or visual assets were added.

## Automated Tests

RED focused:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd --ignoreHeadlessMode
```

Result: exit `100`, `reports/report_458/results.xml`. The focused suite failed
because `AudioSystem.on_hit_event()` and MainScene gameplay audio forwarding did
not exist.

GREEN focused:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_459/results.xml`, `16/16`, `0` errors, `0`
failures, `0` orphans.

Related regression:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd -a res://tests/unit/gameplay/simple_enemy_character_animation_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_460/results.xml`, `90/90`, `0` errors, `0`
failures, `0` orphans.

Final focused after adapter refactor:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_461/results.xml`, `27/27`, `0` errors, `0`
failures, `0` orphans.

## Smoke

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/audio_event_adapters_main_scene_smoke.log
rg -n "ERROR|SCRIPT ERROR|WARNING|Invalid call|Parse Error|FAILED" reports/audio_event_adapters_main_scene_smoke.log || true
```

Result: exit `0`; log scan found no matching errors or warnings.

## Godot MCP

- `editor_state`: connected to Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`.
- `project_run(mode="main", autosave=true)`: game capture ready.
- Runtime `game_eval` verified `/root/AudioSystem` exists and MainScene
  callbacks route:
  - `sfx_hit_normal` from `_on_player_attack_landed()`
  - `sfx_claw_attack` from `_on_player_attack_started()`
  - `sfx_damage_taken` from `_on_enemy_attack_landed()` before focus mode
  - `sfx_focus_mode_activate` from focus-mode enter
  - `sfx_damage_taken_lowhp` from damage while focus mode is active
  - `sfx_dodge` from `_on_player_dodge_started()`
  - `sfx_boss_phase` from `_handle_boss_phase_transition_started()`
- Missing streams stayed silent-safe (`stream_found=false`) and still recorded
  SFX id, position, priority, pitch metadata.
- Runtime Player and Enemy sprites are `AnimatedSprite2D`; Player has 9
  animations and Enemy has 6 animations.
- `logs_read(source="game")`: only MCP helper registration info.
- `logs_read(source="editor")`: `0` rows after clearing evaluation-script noise.
- `editor_screenshot(source="game")`: non-empty 1280x720 source frame showing
  the generated wasteland scene and visible animated Player/Enemy.

## Notes

No new visual assets were generated in this story. The next audio slices should
cover UI menu audio, Boss music state transitions, same-SFX merge behavior, and
real audio asset import.
