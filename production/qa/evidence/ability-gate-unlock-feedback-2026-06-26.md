# QA Evidence: Ability Gate Unlock Feedback

> Story: `production/epics/player-abilities/story-016-ability-gate-unlock-feedback.md`
> Date: 2026-06-26
> Result: PASS

## Scope

Story016 adds shared unlock feedback for existing Dash and Double Jump
`ExplorationGate` nodes. A fresh gate transition into `unlocked` now spawns a
short-lived image-generated `Sprite2D` dissolve burst, closes the gate's
blocking collision, hides the prompt, records deterministic diagnostics, and
routes a spatial `sfx_door_unlock` request through `AudioSystem`.

Restore and duplicate paths remain side-effect free: `set_gate_unlocked(true)`,
already-unlocked gates, duplicate ability activations, and
`refresh_gate_state()` do not replay the VFX or SFX.

Out of scope remained unchanged: no new abilities, new gate nodes, minimap,
fast travel, save schema changes, shader polish, final mastered audio, or
Dash/Double Jump movement-feel changes.

## Asset Pipeline

Visual:

- Runtime asset:
  `assets/environment/ability_gate/vfx/vfx_ability_gate_unlock_dissolve_burst_256.png`
- Image-generation source:
  `assets/generated/source/vfx_ability_gate_unlock_dissolve_burst_imagegen_20260626.png`
- Alpha-matted source:
  `assets/generated/source/vfx_ability_gate_unlock_dissolve_burst_alpha_20260626.png`
- Processing: magenta chroma key was removed to transparent alpha, then the
  result was cropped/resized to a 256x256 runtime PNG.
- Pixel check: runtime PNG is RGBA 256x256 with transparent corners,
  `17323` nonzero-alpha pixels, `2145` partially transparent pixels, and
  `0.2643` alpha coverage.

Audio:

- Runtime asset:
  `assets/audio/sfx/sfx_door_unlock_baseline_short.wav`
- Source recipe:
  `assets/audio/source/ability_gate_unlock_sfx_generation_20260626.json`
- Format: mono 16-bit PCM, 44100 Hz, 0.52s.
- Cue id: `sfx_door_unlock`.

The visual and audio assets are recorded in `design/assets/asset-manifest.md`
and `design/assets/entity-inventory.md`.

## Automated Tests

RED focused gate feedback:

- `reports/report_702/`
- Command:
  `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/exploration_gate_unlock_feedback_test.gd --ignoreHeadlessMode`
- Expected failure: `ExplorationGate` had no unlock-feedback texture path,
  deterministic feedback snapshot, VFX spawn, duplicate/restore replay guard,
  or gate-unlock audio dispatch contract yet.

RED focused audio:

- `reports/report_703/`
- Command:
  `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode`
- Expected failure: `AudioSystem` had no `sfx_door_unlock` stream registration
  or exploration-gate unlock event adapter yet.

GREEN focused gate feedback:

- `reports/report_705/`
- Result: `3/3` passed.
- Coverage: Dash gate feedback spawn/audio once, Double Jump gate same feedback
  contract, duplicate/refresh suppression, VFX expiry, and save-restore
  no-replay behavior.

GREEN focused AudioSystem:

- `reports/report_706/`
- Result: `21/21` passed.
- Coverage: `sfx_door_unlock` default stream registration and
  `on_exploration_gate_unlocked(...)` routing to spatial SFX metadata.

Related regression:

- `reports/report_708/`: MainScene audio event adapter, `7/7` passed.
- `reports/report_709/`: ability-gate and Old Factory related gameplay suites,
  `21/21` passed.
- `reports/report_710/`: MainScene audio adapter plus AudioSystem suites,
  `28/28` passed.

Pre-commit focused verification:

- `reports/report_711/`
- Command:
  `/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/exploration_gate_unlock_feedback_test.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode`
- Result: `24/24` passed, `0` errors, `0` failures.
- Note: the process still printed the known cleanup-time ObjectDB/resource
  warning after the successful GdUnit summary.

## Godot Import and Headless Smoke

Import:

- Command: `/opt/homebrew/bin/godot --headless --path . --import --quit`
- Result: exit `0`.
- Imported the new VFX source PNG, alpha PNG, runtime PNG, and door-unlock WAV.

Headless smoke:

- Command:
  `/opt/homebrew/bin/godot --headless --path . --quit-after 2 > reports/ability_gate_unlock_feedback_main_scene_smoke.log 2>&1`
- Result: exit `0`.
- Keyword scan found no script parse, invalid call, missing-resource, or
  resource-load failures.
- The log still contains the known Godot cleanup-time ObjectDB/resource warning
  at process exit; runtime script/resource loading was clean.

## Godot MCP Runtime Evidence

MCP connection:

- Godot: `4.6.3-stable`
- Scene: `res://scenes/main.tscn`
- Run mode: main scene, `autosave=false`

Restore/no-replay probe:

- `DoubleJumpExplorationGate.set_gate_unlocked(true)` changed state to
  `unlocked` and disabled collision.
- Feedback snapshot after restore: `active_count=0`, `spawn_count=0`,
  `last_spawn={}`, texture path
  `res://assets/environment/ability_gate/vfx/vfx_ability_gate_unlock_dissolve_burst_256.png`,
  asset source `image_generation`.
- AudioSystem gameplay event and SFX request were unchanged before/after the
  restore call.

Runtime ability-trigger probe:

- Dash gate: `request_dash()` returned `true`, gate state became `unlocked`,
  collision became non-blocking, prompt hidden, `UnlockVfx` existed as
  `Sprite2D`, texture path matched the generated runtime PNG, asset source
  metadata was `image_generation`, and feedback snapshot reported
  `active_count=1`, `spawn_count=1`, gate id
  `dash_gate_commercial_street`, ability `dash`, target `area_02_sewer`.
- Double Jump gate: after Dash returned to idle, `request_double_jump()`
  returned `true`, gate state became `unlocked`, collision became non-blocking,
  prompt hidden, `UnlockVfx` existed as `Sprite2D`, texture path matched the
  generated runtime PNG, asset source metadata was `image_generation`, and
  feedback snapshot reported `active_count=1`, `spawn_count=1`, gate id
  `double_jump_high_platform`, ability `double_jump`, target
  `area_03_factory`.

Audio path probe:

- Fresh Dash gate unlock produced AudioSystem event
  `event_id=exploration_gate_unlocked`, `sfx_id=sfx_door_unlock`,
  `priority=90`, `stream_found=true`, position `(1035, 438)`, and metadata
  `gate_id=dash_gate_commercial_street`,
  `required_ability=dash`, `target_area_id=area_02_sewer`.
- Fresh Double Jump gate unlock produced AudioSystem event
  `event_id=exploration_gate_unlocked`, `sfx_id=sfx_door_unlock`,
  `priority=90`, `stream_found=true`, position `(820, 316)`, and metadata
  `gate_id=double_jump_high_platform`,
  `required_ability=double_jump`, `target_area_id=area_03_factory`.
- The second same-cue request merged with the first within the existing
  same-SFX merge window, preserving `stream_found=true` and increasing volume
  through the existing merge logic.

Logs:

- MCP game log after the final screenshot probe contained only
  Godot AI helper and DataManager info lines.
- MCP editor log contained no errors.

Screenshot:

`reports/visual/cinderpaw-mcp-ability-gate-unlock-feedback-20260626.png`

The screenshot was saved from the running game viewport at 1280x720 after both
gate unlock VFX were spawned with a temporarily extended runtime duration for
capture. Pixel validation found the screenshot nonblank with `921365`
nonblank pixels and `0.9997` coverage.
