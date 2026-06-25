# QA Evidence: Music + Ambience Asset Import Baseline

Date: 2026-06-25
Story: `production/epics/audio-system/story-008-music-ambience-asset-import-baseline.md`
Engine: Godot 4.6.3

## Scope

Imported the full GDD baseline music and ambience cue list as replaceable
procedural WAV assets, registered them by default in `AudioSystem`, and verified
that scene music/ambience and Rat King boss music now play real streams instead
of only recording missing-stream diagnostics.

No visual/image-generation asset was required for this audio-only slice.

## Assets

Source manifest:
`assets/audio/source/music_ambience_generation_20260625.json`

| Cue | Runtime file | Import file | Source |
|-----|--------------|-------------|--------|
| `mus_hub` | `assets/audio/music/mus_hub.wav` | `assets/audio/music/mus_hub.wav.import` | procedural baseline |
| `mus_street` | `assets/audio/music/mus_street.wav` | `assets/audio/music/mus_street.wav.import` | procedural baseline |
| `mus_sewer` | `assets/audio/music/mus_sewer.wav` | `assets/audio/music/mus_sewer.wav.import` | procedural baseline |
| `mus_factory` | `assets/audio/music/mus_factory.wav` | `assets/audio/music/mus_factory.wav.import` | procedural baseline |
| `mus_rooftop` | `assets/audio/music/mus_rooftop.wav` | `assets/audio/music/mus_rooftop.wav.import` | procedural baseline |
| `mus_tower` | `assets/audio/music/mus_tower.wav` | `assets/audio/music/mus_tower.wav.import` | procedural baseline |
| `mus_boss_rat_p1` | `assets/audio/music/mus_boss_rat_p1.wav` | `assets/audio/music/mus_boss_rat_p1.wav.import` | procedural baseline |
| `mus_boss_rat_p2` | `assets/audio/music/mus_boss_rat_p2.wav` | `assets/audio/music/mus_boss_rat_p2.wav.import` | procedural baseline |
| `mus_boss_rat_p3` | `assets/audio/music/mus_boss_rat_p3.wav` | `assets/audio/music/mus_boss_rat_p3.wav.import` | procedural baseline |
| `amb_hub` | `assets/audio/ambient/amb_hub.wav` | `assets/audio/ambient/amb_hub.wav.import` | procedural baseline |
| `amb_street` | `assets/audio/ambient/amb_street.wav` | `assets/audio/ambient/amb_street.wav.import` | procedural baseline |
| `amb_sewer` | `assets/audio/ambient/amb_sewer.wav` | `assets/audio/ambient/amb_sewer.wav.import` | procedural baseline |
| `amb_factory` | `assets/audio/ambient/amb_factory.wav` | `assets/audio/ambient/amb_factory.wav.import` | procedural baseline |
| `amb_rooftop` | `assets/audio/ambient/amb_rooftop.wav` | `assets/audio/ambient/amb_rooftop.wav.import` | procedural baseline |
| `amb_tower` | `assets/audio/ambient/amb_tower.wav` | `assets/audio/ambient/amb_tower.wav.import` | procedural baseline |

## Automated Tests

RED focused:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode
```

Result: exit `100`, `reports/report_585/results.xml`. The new music/ambience
tests failed because the WAV assets did not exist yet, the cue ids were not
registered, and `MusicPlayer` / `AmbientPlayer` streams were null.

GREEN focused:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_586/results.xml`, `19/19`, `0` errors, `0`
failures, `0` orphans.

Related regression:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_587/results.xml`, `32/32`, `0` test errors,
`0` failures, `0` orphans. The Godot process still printed existing GdUnit
resource cleanup warnings after all tests passed.

## Import

```bash
/opt/homebrew/bin/godot --headless --path . --import --quit-after 2
```

Result: exit `0`; Godot generated `.wav.import` files for all 15 music and
ambience WAV assets.

## Smoke

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/audio_music_ambience_main_scene_smoke.log
rg -n "SCRIPT ERROR|ERROR:|Failed|No loader|Invalid" reports/audio_music_ambience_main_scene_smoke.log
```

Result: exit `0`; log scan found no matching script errors, loader failures, or
invalid access messages.

## Godot MCP

- `editor_state`: connected to Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, game capture ready.
- Runtime `game_eval` verified `/root/AudioSystem`, all 15 cue ids, no missing
  ids, no mismatched stream paths, and `registered_count == 36`.
- Runtime scene cue probe called `on_scene_changed("hub", "main")` and confirmed
  current music `mus_street`, current ambience `amb_street`,
  `MusicPlayer.bus == "Music"`, `AmbientPlayer.bus == "Ambient"`, and both
  player streams were non-null.
- Runtime Rat King probe confirmed encounter start and phase 2/3 transitions
  return true and use `mus_boss_rat_p1`, `mus_boss_rat_p2`, and
  `mus_boss_rat_p3` with `stream_found=true`.
- `logs_read(source="game")`: only MCP helper registration and DataManager
  domain load info.
- `logs_read(source="editor")`: `0` rows.
- Saved game frame:
  `reports/visual/cinderpaw-mcp-music-ambience-baseline-20260625.png`, non-empty
  gameplay frame showing the current main scene and Rat King encounter.

## Notes

These WAVs are deterministic procedural baseline assets. They should be
replaced by authored final music and ambience during audio polish without
changing cue ids or runtime paths.
