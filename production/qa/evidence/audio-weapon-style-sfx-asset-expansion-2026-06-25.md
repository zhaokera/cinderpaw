# QA Evidence: Audio Weapon Style SFX Asset Expansion

Date: 2026-06-25
Story: `production/epics/audio-system/story-006-weapon-style-sfx-asset-expansion.md`
Type: Integration

## Scope

Story006 imports replaceable baseline WAV assets for the remaining weapon-style
attack startup cues and GOOD parry cue:

- `sfx_blade_attack` -> `res://assets/audio/sfx/sfx_blade_attack.wav`
- `sfx_bone_attack` -> `res://assets/audio/sfx/sfx_bone_attack.wav`
- `sfx_bell_attack` -> `res://assets/audio/sfx/sfx_bell_attack.wav`
- `sfx_parry_good` -> `res://assets/audio/sfx/sfx_parry_good.wav`

`AudioSystem` now loads these four streams by default on `_ready()`. Existing
weapon attack routing remains unchanged: `long_tail`, `fish_bone`, and
`electro_bell` now return true because the mapped streams are imported.

## Asset Source

The WAVs are deterministic procedural PCM baseline assets created with Python's
standard `wave` module. They are intended to make the current ACT combat slice
audibly distinct now and remain replaceable by authored final audio later.

Source manifest:
`assets/audio/source/weapon_style_sfx_generation_20260625.json`

Generated/imported assets:

- `assets/audio/sfx/sfx_blade_attack.wav`
- `assets/audio/sfx/sfx_blade_attack.wav.import`
- `assets/audio/sfx/sfx_bone_attack.wav`
- `assets/audio/sfx/sfx_bone_attack.wav.import`
- `assets/audio/sfx/sfx_bell_attack.wav`
- `assets/audio/sfx/sfx_bell_attack.wav.import`
- `assets/audio/sfx/sfx_parry_good.wav`
- `assets/audio/sfx/sfx_parry_good.wav.import`

## Automated Verification

RED focused test:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode
```

Result: `reports/report_545` failed as expected before the WAV assets and
default registrations were present. The failures were missing file/default stream
registration/playback expectations for the four Story006 cues.

Godot import:

```bash
/opt/homebrew/bin/godot --headless --path . --import --quit-after 2
```

Result: exit `0`; Godot scanned/imported the four new WAV files and generated
their `.wav.import` sidecars.

GREEN focused test:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode
```

Result: `reports/report_546`, `16/16` passed, `0` errors, `0` failures.

Related regression:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: `reports/report_553`, `25/25` passed, `0` errors, `0` failures, clean
process exit.

Headless main-scene smoke:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/audio_weapon_style_sfx_main_scene_smoke.log
```

Result: exit `0`. Log scan for `ERROR|SCRIPT ERROR|WARNING|Failed|failed|No loader|Invalid|resources still in use|leaked`
returned no matches.

## Godot MCP Runtime Verification

MCP state before run:

- Project: `废土喵影 (Cat Shadow Wasteland)`
- Engine: Godot `4.6.3-stable`
- Current scene: `res://scenes/main.tscn`
- Readiness: `ready`

Runtime probe result:

- `/root/AudioSystem` exists.
- `get_registered_audio_stream_ids()` contains:
  - `sfx_blade_attack`
  - `sfx_bone_attack`
  - `sfx_bell_attack`
  - `sfx_parry_good`
- `get_audio_stream_path()` returns the expected `res://assets/audio/sfx/*.wav`
  path for each cue.
- Direct `play_sfx()` returns true for all four cues.
- `on_weapon_attack_event()` returns true with `stream_found=true` for:
  - `long_tail -> sfx_blade_attack`
  - `fish_bone -> sfx_bone_attack`
  - `electro_bell -> sfx_bell_attack`
- `on_parry_event({"parry_type": "good"})` returns true and records
  `sfx_parry_good` with `stream_found=true`.
- Unknown cue `missing_weapon_style_sfx` returns false, records
  `stream_found=false`, and does not increase active SFX count.
- Game logs contained only DataManager/game helper info lines.
- Editor logs returned no entries.

Screenshot evidence:

- `reports/visual/cinderpaw-mcp-weapon-style-sfx-20260625.png`
- Saved from runtime viewport, `1280x720`, non-empty.

## Notes

Subagent audio review recommended short, conservative startup cues so weapon
attacks remain distinct without overpowering hit, crit, or perfect parry
feedback. Subagent QA review recommended keeping the primary assertions in
`tests/unit/presentation/audio_system_test.gd` and using MainScene audio adapter
and weapon attack chain tests as related regressions; this is the implemented
verification shape.
