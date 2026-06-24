# QA Evidence: AudioSystem Autoload Bus + Pool Baseline

> **Date**: 2026-06-25
> **Epic**: Audio System
> **Story**: 001 Autoload Bus + Pool Baseline
> **Traceability**: TR-audio-001, TR-audio-002, TR-audio-009

## Scope

Implemented the first AudioSystem production slice:

- Added `AudioSystem` as Autoload #3 between `InputManager` and `SaveSystem`.
- Added runtime initialization for Master, Music, SFX, Ambient, and UI buses.
- Added default 0-100% bus volume state and `set_bus_volume()` with clamping.
- Added 16-player `AudioStreamPlayer2D` SFX pool on the SFX bus.
- Added `play_sfx()` with spatial metadata, `pitch_offset`, priority overflow,
  and safe false return when a stream is missing.
- Added music and ambience request/fade diagnostics that are safe before real
  audio assets exist.

No visual/image2 assets were needed for this infrastructure story. Real audio
assets, combat event wiring, and SceneManager fade integration are out of scope.

## TDD Evidence

1. RED focused:
   `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode`

   Result: exit `100`, `reports/report_446/results.xml`, failed because
   `src/presentation/audio_system.gd` did not exist and `project.godot` lacked
   AudioSystem Autoload registration.

2. RED refinement:
   same command.

   Result: exit `100`, `reports/report_448/results.xml`, failed after test
   tightening on missing 600px SFX max distance and bus send assertion.

3. GREEN focused:
   same command.

   Result: exit `0`, `reports/report_449/results.xml`, AudioSystem `6/6`, `0`
   errors, `0` failures, `0` orphans.

## Regression Evidence

Presentation/Input/Save/Scene regression:

```text
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/presentation \
  -a res://tests/unit/input/story_001_action_abstraction_test.gd \
  -a res://tests/unit/save \
  -a res://tests/unit/scene \
  --ignoreHeadlessMode
```

Result: exit `0`, `reports/report_451/results.xml`, `109/109`, `0` errors,
`0` failures, `0` orphans. The CLI emitted an ObjectDB leak warning after
finalization; the GdUnit report itself was clean.

Headless smoke:

```text
/opt/homebrew/bin/godot --headless --path . --quit-after 3
```

Result: exit `0`; DataManager manifest/domains loaded; no script errors.

## Godot MCP Evidence

- `editor_state`: Godot MCP connected, Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, editor readiness `ready`.
- `project_run(mode="main", autosave=true)`: project started and
  `game_capture_ready=true`.
- Runtime `game_eval` probe against `/root/AudioSystem`:
  - AudioSystem path exists at `/root/AudioSystem`.
  - Bus snapshot:
    - Master: index 0, volume percent 80, linear volume approximately 0.8.
    - Music: index 1, send Master, volume percent 60, linear approximately 0.6.
    - SFX: index 2, send Master, volume percent 80, linear approximately 0.8.
    - Ambient: index 3, send Master, volume percent 50, linear 0.5.
    - UI: index 4, send Master, volume percent 70, linear approximately 0.7.
  - `pool_size=16`, `active_sfx_count=0`, `dropped_sfx_count=0`.
  - Missing stream calls returned false for `play_sfx`, `play_music`, and
    `play_ambient`.
  - Last missing SFX request recorded `position=(12,-8)`, `volume_db=-2`,
    `pitch_offset=3`, and `pitch_scale≈1.1892`.
- Logs:
  - `logs_read(source="game")`: only MCP helper registration info.
- Screenshot:
  - `editor_screenshot(source="game")` returned runtime source resolution
    1280x720 and 640x360 captured output metadata.

## Result

PASS. Story001 acceptance criteria are implemented and covered by RED/GREEN
GdUnit, related regression, headless smoke, and Godot MCP runtime validation.
