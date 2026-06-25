# QA Evidence: Core Combat SFX Asset Import Baseline

Date: 2026-06-25
Story: `production/epics/audio-system/story-005-core-combat-sfx-asset-import-baseline.md`
Engine: Godot 4.6.3

## Scope

Imported the first real core combat SFX baseline for AudioSystem. Ten cue ids
now have generated WAV files under `assets/audio/sfx/`, Godot `.import` files,
and default AudioSystem stream registration on `_ready()`. Existing combat,
health, focus, enemy death, and boss phase event adapters now play available
SFX streams while unknown SFX remain silent-safe.

No visual/image-generation asset was required for this audio-only slice.

## Assets

Source manifest:
`assets/audio/source/core_combat_sfx_generation_20260625.json`

| Cue | Runtime file | Import file | Source |
|-----|--------------|-------------|--------|
| `sfx_claw_attack` | `assets/audio/sfx/sfx_claw_attack.wav` | `assets/audio/sfx/sfx_claw_attack.wav.import` | procedural baseline |
| `sfx_hit_normal` | `assets/audio/sfx/sfx_hit_normal.wav` | `assets/audio/sfx/sfx_hit_normal.wav.import` | procedural baseline |
| `sfx_hit_crit` | `assets/audio/sfx/sfx_hit_crit.wav` | `assets/audio/sfx/sfx_hit_crit.wav.import` | procedural baseline |
| `sfx_parry_perfect` | `assets/audio/sfx/sfx_parry_perfect.wav` | `assets/audio/sfx/sfx_parry_perfect.wav.import` | procedural baseline |
| `sfx_dodge` | `assets/audio/sfx/sfx_dodge.wav` | `assets/audio/sfx/sfx_dodge.wav.import` | procedural baseline |
| `sfx_damage_taken` | `assets/audio/sfx/sfx_damage_taken.wav` | `assets/audio/sfx/sfx_damage_taken.wav.import` | procedural baseline |
| `sfx_damage_taken_lowhp` | `assets/audio/sfx/sfx_damage_taken_lowhp.wav` | `assets/audio/sfx/sfx_damage_taken_lowhp.wav.import` | procedural baseline |
| `sfx_enemy_death` | `assets/audio/sfx/sfx_enemy_death.wav` | `assets/audio/sfx/sfx_enemy_death.wav.import` | procedural baseline |
| `sfx_boss_phase` | `assets/audio/sfx/sfx_boss_phase.wav` | `assets/audio/sfx/sfx_boss_phase.wav.import` | procedural baseline |
| `sfx_focus_mode_activate` | `assets/audio/sfx/sfx_focus_mode_activate.wav` | `assets/audio/sfx/sfx_focus_mode_activate.wav.import` | procedural baseline |

## Automated Tests

RED focused:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode
```

Result: exit `100`, `reports/report_539/results.xml`. The new default core
combat SFX test failed because AudioSystem had no default stream query API and
no default imported combat SFX files were loaded.

Import failure checkpoint:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode
```

Result: exit `100`, `reports/report_540/results.xml`. Godot reported no loader
for the newly written WAV files before the asset import step. This confirmed
that file presence alone was not enough; the assets had to enter Godot's import
pipeline.

Asset import:

```bash
/opt/homebrew/bin/godot --headless --path . --import --quit-after 2
```

Result: exit `0`. Godot generated `.import` files and `.godot/imported/*.sample`
files for the ten WAV assets.

GREEN focused:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_542/results.xml`, `15/15`, `0` errors, `0`
failures, `0` orphans.

Related regression:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_543/results.xml`, `20/20`, `0` errors, `0`
failures, `0` orphans.

## Smoke

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/audio_core_combat_sfx_main_scene_smoke.log
rg -n "ERROR|SCRIPT ERROR|WARNING|Failed|failed|No loader|Invalid" reports/audio_core_combat_sfx_main_scene_smoke.log
```

Result: exit `0`; log scan found no matching errors, warnings, loader errors,
or invalid access messages.

## Godot MCP

- `editor_state`: connected to Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, game capture ready.
- Runtime `game_eval` verified `/root/AudioSystem` exists and
  `get_sfx_pool_size() == 16`.
- `get_registered_audio_stream_ids()` included all ten Story005 cue ids.
- `get_audio_stream_path(id)` returned `res://assets/audio/sfx/<cue>.wav` for
  every imported cue.
- Runtime probes called representative event paths:
  `on_weapon_attack_event(cat_claw)`, `on_hit_event`, `on_damage_taken_event`,
  `on_focus_mode_changed(true)`, `on_dodge_event`, `on_enemy_defeated`, and
  `on_boss_phase_transition_started`.
- Every representative event returned `true`, recorded the expected SFX id,
  set `stream_found=true`, assigned a valid `player_index`, and the matching
  `SFXPlayerXX` had a non-null stream on the `SFX` bus.
- A `missing_story005_probe` call returned `false`, recorded
  `stream_found=false`, and did not increase active SFX voice count.
- `logs_read(source="game")`: only MCP helper registration and DataManager
  domain load info.
- `logs_read(source="editor")`: `0` rows.
- Saved game frame:
  `reports/visual/cinderpaw-mcp-core-combat-sfx-20260625.png`, 1280x720,
  non-empty frame showing the main scene and Rat King.

## Notes

These WAVs are deterministic procedural baseline assets meant to make the ACT
combat loop audible now. `sfx_parry_good`, non-claw weapon SFX, UI audio,
music/ambience, same-SFX merge, and authored/final mix replacement remain
future audio stories.
