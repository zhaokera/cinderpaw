# Dash Gate Authored Visual Replacement QA Evidence

Date: 2026-07-09
Story: Player Abilities Story100
Engine: Godot 4.7-stable
MCP: Godot AI 2.9.1

## Asset Pipeline

- Built-in image generation was used for a pixel-art side-scroller Dash ability
  gate marker on a flat `#00ff00` chroma-key background.
- Source image:
  `res://assets/generated/source/dash_gate_marker_imagegen_20260709.png`
- Alpha source:
  `res://assets/generated/source/dash_gate_marker_alpha_20260709.png`
- Runtime image:
  `res://assets/environment/dash_gate/dash_gate_marker.png`
- Runtime size: `256x256`, transparent RGBA, centered subject with transparent
  corners.
- Godot import generated `.import` sidecars for the runtime PNG and source PNGs.

Prompt summary: pixel-art scrap-metal dash gate/emitter pair with amber-white
dash streak, cat-claw speed slashes, worn blue-grey steel, rust-orange warning
stripes, cyan capacitors, and a pass-through opening.

## Automated Evidence

- RED focused: `reports/report_1254/`
  - Expected failure: old Dash gate still used reused Rat King electric leak,
    `256x181` texture size, old rotation `1.5708`, and non-uniform scale.
- GREEN focused: `reports/report_1255/`
  - `tests/unit/gameplay/main_scene_dash_gate_authored_visual_test.gd`
  - Result: `2/2`, `0` failures, `0` errors.
- Related regression: `reports/report_1256/`
  - `tests/unit/gameplay/main_scene_dash_gate_authored_visual_test.gd`
  - `tests/unit/gameplay/exploration_dash_gate_runtime_test.gd`
  - `tests/unit/gameplay/main_scene_visual_contract_test.gd`
  - Result: `8/8`, `0` failures, `0` errors.
- Headless smoke:
  `reports/dash_gate_authored_visual_main_scene_smoke.log`
  - Exit code: `0`.
  - No script parse, missing-resource, invalid-call, or resource-load error
    occurred during startup. Godot still printed known shutdown resource cleanup
    messages at exit.

## MCP Runtime Evidence

- MCP scene reload: `res://scenes/main.tscn`, `force_reload=true`,
  `reloaded_from_disk=true`.
- Editor node check:
  `/Main/DashExplorationGate/Visual`
  - `texture`: `res://assets/environment/dash_gate/dash_gate_marker.png`
  - `rotation`: `0.0`
  - `scale`: `(0.52, 0.52)`
  - `visible`: `true`
- Runtime `project_run(mode="current", autosave=false)`:
  - `helper_live=true`
  - `current_run_errors=[]`
  - `recent_errors_scope=retained_recent` for older cached parse errors, not
    current Story100 run errors.
- Runtime node check:
  `/Main/DashExplorationGate/Visual`
  - `texture`: `res://assets/environment/dash_gate/dash_gate_marker.png`
  - `rotation`: `0.0`
  - `scale`: `(0.52, 0.52)`
  - `visible`: `true`
- Runtime player check:
  `/Main/Player/Sprite` is `AnimatedSprite2D`, animation `idle`, using
  `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`.
- Runtime screenshot:
  - MCP game framebuffer screenshot returned `960x539`, non-empty.
  - Screenshot showed the new red-orange Dash gate beam on the right side of the
    main scene.
- Cleanup:
  - `project_manage(op="stop")` stopped the running game and editor returned
    to `ready`.
