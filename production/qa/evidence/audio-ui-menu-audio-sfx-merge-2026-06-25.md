# QA Evidence: UI Menu Audio + Same-SFX Merge

Date: 2026-06-25
Story: `production/epics/audio-system/story-007-ui-menu-audio-sfx-merge.md`
Engine: Godot 4.6.3

## Scope

Implemented player-facing UI audio feedback for menu open/close/navigation,
confirm/cancel, save, and load. `AudioSystem` now owns a small global UI player
pool on the UI bus, enters `MENU` state when a menu opens, ducks Music to 50% of
the captured volume, restores the prior state/volume when the menu closes, and
coalesces repeated same-SFX requests inside 100ms with a 20% linear volume
boost.

No visual/image-generation asset was required for this audio-only slice.

## Assets

Source manifest:
`assets/audio/source/ui_menu_audio_generation_20260625.json`

| Cue | Runtime file | Import file | Source |
|-----|--------------|-------------|--------|
| `ui_menu_open` | `assets/audio/ui/ui_menu_open.wav` | `assets/audio/ui/ui_menu_open.wav.import` | procedural baseline |
| `ui_menu_close` | `assets/audio/ui/ui_menu_close.wav` | `assets/audio/ui/ui_menu_close.wav.import` | procedural baseline |
| `ui_navigate` | `assets/audio/ui/ui_navigate.wav` | `assets/audio/ui/ui_navigate.wav.import` | procedural baseline |
| `ui_confirm` | `assets/audio/ui/ui_confirm.wav` | `assets/audio/ui/ui_confirm.wav.import` | procedural baseline |
| `ui_cancel` | `assets/audio/ui/ui_cancel.wav` | `assets/audio/ui/ui_cancel.wav.import` | procedural baseline |
| `ui_save` | `assets/audio/ui/ui_save.wav` | `assets/audio/ui/ui_save.wav.import` | procedural baseline |
| `ui_load` | `assets/audio/ui/ui_load.wav` | `assets/audio/ui/ui_load.wav.import` | procedural baseline |

## Automated Tests

RED focused:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd --ignoreHeadlessMode
```

Result: exit `100`, `reports/report_580/results.xml`. The new UI audio tests
failed because AudioSystem had no UI cue API/default streams and MainScene did
not forward menu events.

GREEN focused:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_582/results.xml`, `25/25`, `0` errors, `0`
failures, `0` orphans.

Related regression:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_583/results.xml`, `36/36`, `0` test errors,
`0` failures, `0` orphans. The Godot process still printed existing GdUnit
resource cleanup warnings after all tests passed.

Post-fix targeted guard:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_584/results.xml`, `10/10`, `0` test errors,
`0` failures, `0` orphans. This was run after preserving the existing save menu
refresh behavior while keeping the new save/load audio dispatch.

## Import

```bash
/opt/homebrew/bin/godot --headless --path . --import --quit-after 2
```

Result: exit `0`; Godot generated `.wav.import` files for the seven UI WAV
assets.

## Smoke

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/audio_ui_menu_audio_main_scene_smoke.log
rg -n "ERROR|SCRIPT ERROR|WARNING|Failed|failed|No loader|Invalid" reports/audio_ui_menu_audio_main_scene_smoke.log
```

Result: exit `0`; log scan found no matching errors, warnings, loader errors,
or invalid access messages.

## Godot MCP

- `editor_state`: connected to Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, game capture ready.
- Runtime `game_eval` verified `/root/AudioSystem`, all seven UI cue ids, and
  `res://assets/audio/ui/<cue>.wav` stream paths.
- Runtime probe confirmed `get_ui_sfx_pool_size() == 4` and `UIPlayer00.bus ==
  "UI"`.
- HUD pause/resume signal probe confirmed MENU audio state and Music bus duck:
  `60 -> 30 -> 60`, with `ui_menu_open` and `ui_menu_close`.
- Direct UI cue probe confirmed `on_ui_save()` and `on_ui_load()` return true
  and record `ui_save` / `ui_load`.
- Same-SFX probe confirmed repeated `sfx_claw_attack` within 100ms sets
  `merged=true`, keeps active SFX count at `1`, and records volume multiplier
  `1.2`.
- `logs_read(source="game")`: only MCP helper registration and DataManager
  domain load info.
- `logs_read(source="editor")`: `0` rows.
- Saved game frame:
  `reports/visual/cinderpaw-mcp-ui-menu-audio-20260625.png`, 1280x720,
  non-empty frame showing the current gameplay scene.

## Notes

The UI WAVs are deterministic procedural baseline assets meant to make menu
interaction audible now. They should be replaced by authored final UI SFX during
audio polish without changing cue ids or runtime paths.
