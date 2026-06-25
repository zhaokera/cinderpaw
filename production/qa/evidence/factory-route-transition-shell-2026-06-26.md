# Factory Route Transition Shell Evidence

Date: 2026-06-26

Story:
`production/epics/player-abilities/story-006-factory-route-transition-shell.md`

## Scope

Implemented the smallest player-visible continuation after the Double Jump
high-platform gate: once `area_03_factory_unlocked` is set, the running main
scene exposes `FactoryRouteTransitionShell`, a generated scrap-metal route
doorway prop. Entering its range requests the existing SceneManager transition
to `area_03_factory` at `factory_gate_entry` and shows the existing HUD
transition shell as `Factory Route`.

This evidence does not claim full Old Factory gameplay, Boss2, hidden-boss
combat, savepoints, minimap, fast travel routes, enemy content, or factory
completion state.

## Generated Asset

- Source:
  `assets/generated/source/factory_route_transition_shell_imagegen_20260626.png`
- Alpha source:
  `assets/generated/source/factory_route_transition_shell_alpha_20260626.png`
- Runtime transparent PNG:
  `assets/environment/factory_route_transition/factory_route_transition_shell.png`
- Import:
  `assets/environment/factory_route_transition/factory_route_transition_shell.png.import`
- Runtime consumers:
  `scenes/main.tscn` -> `FactoryRouteTransitionShell/Visual`;
  `scenes/factory_route_transition_shell.tscn` -> `RouteShellVisual`

Prompt summary:

```text
Use case: stylized-concept
Asset type: pixel-art game prop sprite for a Godot 2D side-scroller route entrance shell
Primary request: Create a transparent-ready isolated sprite on a perfectly flat solid chroma-key background for background removal.
Subject: scrap-metal factory doorway shell with a circular pipe-mouth opening, welded steel plates, rust-orange panels, cool blue edge glow, cat-paw scratches, and a cat-eye gold unlocked rim light.
Style: sharp nearest-neighbor pixel art, limited palette, readable at small side-scroller scale, clear silhouette, wasteland feline theme.
Composition: centered subject with generous padding, no floor plane, no cast shadow, no text, no UI, no watermark.
```

Post-processing:

- Chroma-key removal used
  `${CODEX_HOME:-$HOME/.codex}/skills/.system/imagegen/scripts/remove_chroma_key.py`.
- Runtime PNG was alpha-matted, cropped, and resized to a transparent `256x256`
  nearest-neighbor sprite.
- Godot import ran via `godot --headless --path . --import --quit`.

## Automated Verification

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd --ignoreHeadlessMode -rd res://reports -c
```

Result: report `reports/report_630/`, `3` tests, `4` failures.

Summary: failed as expected because `area_03_factory` was absent from
`data/scene_registry.json`, `FactoryRouteTransitionShell` was absent from
`scenes/main.tscn`, and the destination shell scene did not exist.

### RED Refinement

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd --ignoreHeadlessMode -rd res://reports -c
```

Result: report `reports/report_634/`, `3` tests, `2` failures.

Summary: registry, visible route shell, and destination scene existed, but the
runtime transition request did not yet configure SceneManager's runtime scene
root, so actual scene-tree swapping would not be enabled.

### GREEN Focused

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd --ignoreHeadlessMode -rd res://reports -c
```

Result: report `reports/report_635/`, `3/3`, `0` errors, `0` failures.

Coverage:

- `data/scene_registry.json` contains loadable `area_03_factory`.
- `scenes/main.tscn` contains the generated route shell prop.
- Unlocking `double_jump` alone does not transition.
- Unlocking the Double Jump high-platform gate makes the route shell available.
- Route request configures SceneManager runtime scene root and requests
  `area_03_factory` / `factory_gate_entry`.
- HUD transition label resolves as `Factory Route`.
- Destination scene is minimal, visible, and uses the generated prop art.

### Related Regression

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd -a res://tests/unit/gameplay/player_double_jump_gate_runtime_test.gd -a res://tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd -a res://tests/unit/scene/story_001_scene_manager_registry_api_test.gd -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd -a res://tests/unit/scene/story_005_runtime_scene_tree_swap_test.gd -a res://tests/unit/scene/story_007_fast_travel_preload_scene_change_test.gd -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd -a res://tests/unit/gameplay/main_scene_title_load_handoff_test.gd --ignoreHeadlessMode -rd res://reports -c
```

Result: report `reports/report_636/`, `40/40`, `0` errors, `0` failures.

### Headless Smoke

Command:

```bash
godot --headless --path . res://scenes/main.tscn --quit-after 3
```

Result: `reports/factory_route_transition_shell_main_scene_smoke.log`, exit
`0`; no script error, invalid call, parse error, missing node, missing resource,
or resource-load failure was present. The existing cleanup-time
ObjectDB/resource messages still appeared at process exit.

## Godot MCP Runtime Evidence

Runtime scene: `res://scenes/main.tscn`

MCP screenshot:
`reports/visual/cinderpaw-mcp-factory-route-transition-shell-20260626.png`

Final MCP runtime probe:

```json
{
  "double_jump_ok": true,
  "player_sprite_class": "AnimatedSprite2D",
  "player_sprite_frames": [
    "attack",
    "dash",
    "death",
    "dodge",
    "fall",
    "hurt",
    "idle",
    "jump",
    "revive",
    "run"
  ],
  "gate_state": "unlocked",
  "world_flag_area_03_factory_unlocked": true,
  "route_available_after_gate": true,
  "route_texture": "res://assets/environment/factory_route_transition/factory_route_transition_shell.png",
  "request_ok": true,
  "transition_visible": true,
  "transition_label": "Factory Route",
  "pending_scene": "area_03_factory",
  "pending_spawn": "factory_gate_entry",
  "current_scene": "area_03_factory",
  "current_spawn": "factory_gate_entry",
  "runtime_scene_name": "FactoryRouteTransitionShellScene",
  "runtime_scene_id": "area_03_factory",
  "runtime_visual_visible": true,
  "runtime_visual_texture": "res://assets/environment/factory_route_transition/factory_route_transition_shell.png",
  "runtime_spawn_marker_class": "Marker2D",
  "screenshot_save_error": 0,
  "screenshot_exists": true
}
```

Logs after clearing earlier eval-script warning noise:

- `logs_read(source="game")`: MCP helper registration and DataManager domain
  load info only.
- `logs_read(source="editor")`: `0` entries.
- No script errors, invalid calls, missing nodes, or resource-load errors were
  present in the final MCP checks.

Screenshot check:

- `reports/visual/cinderpaw-mcp-factory-route-transition-shell-20260626.png`
  is a nonblank `1280x720` PNG and shows the `Factory Route` label plus the
  generated route doorway prop in the minimal destination shell.

## Acceptance Trace

| Criterion | Evidence | Status |
|-----------|----------|--------|
| Registry contains loadable factory route shell | `report_635`, `report_636` | PASS |
| MainScene contains generated route shell prop | `report_635`, MCP scene tree/screenshot | PASS |
| Availability follows `area_03_factory_unlocked` | `report_635`, MCP probe | PASS |
| No auto-transition on ability unlock alone | `report_635` | PASS |
| Trigger requests SceneManager and HUD transition | `report_635`, MCP probe | PASS |
| Runtime scene-tree swap reaches destination shell | `report_635`, `report_636`, MCP probe | PASS |
| Destination scene is minimal and visible | `report_635`, MCP screenshot | PASS |
| Generated asset imported through Godot pipeline | `.png.import`, asset manifest, MCP texture path | PASS |
| Runtime logs checked through MCP | MCP logs | PASS |

## Result

Story006 acceptance criteria are covered. The game now has a visible
Double-Jump-gated route entrance that reaches a minimal Factory Route shell
through the actual SceneManager runtime swap path, not just a registry entry.
