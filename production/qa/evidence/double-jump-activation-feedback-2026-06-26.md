# QA Evidence: Double Jump Activation Feedback - 2026-06-26

## Scope

Verifies Player Abilities Story004: a successful airborne Double Jump activation
now produces player-visible textured foot-vortex feedback through
`CombatPresentation`, routes a spatial `sfx_double_jump` cue through
`AudioSystem`, and remains wired from the runtime `Player.double_jump_started`
signal in `res://scenes/main.tscn`.

This evidence does not claim a real Double Jump reward source, skill-tree UI,
factory transition, Boss2, hidden boss, or new Cinderpaw character frames.
Story003's existing `jump` `AnimatedSprite2D + SpriteFrames` animation remains
the character animation for this slice.

## Asset Pipeline

New visual asset generated for this slice:

- Source:
  `assets/generated/source/player_double_jump_vortex_imagegen_20260626.png`
- Alpha intermediate:
  `assets/generated/player_double_jump_vortex_alpha_raw.png`
- Runtime transparent PNG:
  `assets/generated/player_double_jump_vortex_runtime.png`
- Godot import metadata:
  `assets/generated/player_double_jump_vortex_runtime.png.import`

Image-generation prompt:

```text
Use case: stylized-concept
Asset type: 2D pixel-art side-scroller game VFX sprite
Primary request: double jump activation foot vortex burst for Cinderpaw
Subject: no character, just a compact foot-level air vortex burst with cat-eye gold core #ECC94B, pale white air spiral, subtle cool blue upward motion strokes, and small star-shaped gold sparklets
Style/medium: crisp pixel-art VFX, hard readable edges, limited color steps, high contrast for dark wasteland scenes
Composition/framing: centered single VFX icon with generous padding, readable when scaled near a 96px character, symmetrical enough to place under the player feet
Background: perfectly flat pure #ff00ff chroma-key background for local background removal
Constraints: background must be one uniform #ff00ff color with no shadows, gradients, texture, floor plane, lighting variation, reflections, or contact shadow. Keep subject fully separated from background. Do not use #ff00ff anywhere in the subject. No character, no UI, no text, no logo, no watermark.
```

Generated source output was copied from:

```text
/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_06ccb7ac77260096016a3d6db8c3fc8199b896f0a001c2cf7c.png
```

Processing:

```bash
python3 /Users/zhaok/.codex/skills/.system/imagegen/scripts/remove_chroma_key.py \
  --input assets/generated/source/player_double_jump_vortex_imagegen_20260626.png \
  --out assets/generated/player_double_jump_vortex_alpha_raw.png \
  --auto-key border --soft-matte --transparent-threshold 12 \
  --opaque-threshold 220 --despill

sips -z 256 256 assets/generated/player_double_jump_vortex_alpha_raw.png \
  --out assets/generated/player_double_jump_vortex_runtime.png
```

Import:

```bash
/opt/homebrew/bin/godot --headless --path . --editor --quit
```

New audio asset generated for this slice:

- Runtime WAV:
  `assets/audio/sfx/sfx_double_jump.wav`
- Godot import metadata:
  `assets/audio/sfx/sfx_double_jump.wav.import`
- Source manifest:
  `assets/audio/source/core_combat_sfx_generation_20260625.json`

The cue is a replaceable deterministic procedural PCM baseline: 16-bit mono
WAV, 44100 Hz, 0.24s, upward chirp plus airy vortex transient.

Runtime screenshot evidence:
`reports/visual/cinderpaw-mcp-double-jump-activation-feedback-20260626.png`.

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_619/`.

Summary: expected RED failure, `59` tests with `11` failures. The failures came
from missing Double Jump VFX presentation methods, missing MainScene forwarding,
and missing `sfx_double_jump` default audio asset/route.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/presentation/audio_system_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_622/`.

Summary: `59/59` passing, `0` errors, `0` failures. Covers textured Double Jump
vortex particles, MainScene runtime signal forwarding, and AudioSystem
`sfx_double_jump` routing.

### Related Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/presentation/audio_system_test.gd -a res://tests/unit/gameplay/player_double_jump_gate_runtime_test.gd -a res://tests/unit/gameplay/player_dash_ability_runtime_test.gd -a res://tests/unit/gameplay/exploration_dash_gate_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_623/`.

Summary: `67/67` passing, `0` errors, `0` failures. Godot still emitted the
existing cleanup-time ObjectDB/resource messages at process exit in this mixed
GdUnit run; the test result itself was clean.

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --quit-after 3 res://scenes/main.tscn
```

Result: Godot exited `0`. The output loaded DataManager domains and the main
scene without script parse errors, invalid calls, missing-node errors, or
resource-load failures. The process still printed the project's existing
cleanup-time ObjectDB/resource messages at exit.

## Godot MCP Evidence

Runtime session:

- Godot version: `4.6.3-stable (official)`.
- Current scene: `res://scenes/main.tscn`.
- Runtime launched through MCP with `project_run(mode="custom",
  scene="res://scenes/main.tscn", autosave=false)`.
- Runtime state: playing, `game_capture_ready=true`.

MCP scene tree check:

- `/Main/Player/Sprite` is `AnimatedSprite2D`.
- `/Main/CombatPresentation` is present.
- `/Main/DoubleJumpExplorationGate` and `/Main/DashExplorationGate` are present.

MCP runtime probe after restarting the scene and clearing logs:

```json
{
  "activation_ok": true,
  "audio_exists": true,
  "jump_frame_count": 3,
  "last_gameplay_audio": {
    "event_id": "double_jump",
    "metadata": {
      "facing": 1.0,
      "position": {
        "x": 300.0,
        "y": 416.0
      }
    },
    "position": {
      "x": 300.0,
      "y": 416.0
    },
    "priority": 60.0,
    "sfx_id": "sfx_double_jump"
  },
  "last_sfx": {
    "position": {
      "x": 300.0,
      "y": 416.0
    },
    "priority": 60.0,
    "sfx_id": "sfx_double_jump",
    "stream_found": true,
    "volume_db": 0.0
  },
  "paused_for_screenshot": true,
  "player_animation": "jump",
  "player_has_double_jump": true,
  "player_sprite_class": "AnimatedSprite2D",
  "sprite_nodes": [
    {
      "alpha": 0.899999976158142,
      "texture_path": "res://assets/generated/player_double_jump_vortex_runtime.png",
      "visible": true
    },
    {
      "alpha": 0.740000009536743,
      "texture_path": "res://assets/generated/player_double_jump_vortex_runtime.png",
      "visible": true
    },
    {
      "alpha": 0.579999983310699,
      "texture_path": "res://assets/generated/player_double_jump_vortex_runtime.png",
      "visible": true
    }
  ],
  "vfx_count": 3,
  "vfx_texture_path": "res://assets/generated/player_double_jump_vortex_runtime.png"
}
```

Screenshot save probe:

```json
{
  "saved_path": "res://reports/visual/cinderpaw-mcp-double-jump-activation-feedback-20260626.png",
  "error": 0,
  "width": 1280,
  "height": 720,
  "paused": true
}
```

Logs after final probe:

- `logs_read(source="game")`: only MCP helper registration and DataManager
  domain load info lines.
- `logs_read(source="editor")`: `0` lines.
- No script errors, invalid calls, missing nodes, or resource-load errors were
  present in the final MCP log checks.

Screenshot:

- `reports/visual/cinderpaw-mcp-double-jump-activation-feedback-20260626.png`
  is nonblank and shows the white/gold textured Double Jump foot vortex in the
  running main scene.

## Acceptance Trace

| Criterion | Evidence | Status |
|-----------|----------|--------|
| `CombatPresentation.on_double_jump_event(texture, world_position, facing)` exists and spawns textured Sprite2D VFX | `report_622`, MCP probe, screenshot | PASS |
| VFX uses `assets/generated/` texture, is short-lived, and counts toward particle cleanup/cap | `report_622`, `report_623`, `src/presentation/combat_presentation.gd` | PASS |
| MainScene connects `Player.double_jump_started` and forwards to presentation/audio | `report_622`, MCP probe | PASS |
| AudioSystem routes `on_double_jump_event(...)` to imported `sfx_double_jump` | `report_622`, MCP probe | PASS |
| Generated source/runtime PNG and import path recorded | Asset manifest, entity inventory, this evidence | PASS |
| Godot MCP verifies main scene run, VFX, SFX request, logs, screenshot | MCP probe/log/screenshot evidence | PASS |
