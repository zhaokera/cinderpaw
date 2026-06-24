# QA Evidence: Scene Transition Loading UI Shell — 2026-06-25

## Scope

Verifies Scene Management Story 004. The slice connects the SceneManager async
load lifecycle to a player-visible HUD transition shell with image-generated
runtime assets. It does not claim real scene-tree swap, deferred unload/cache,
fast travel, or audio fade completion.

## Story

- Story:
  `production/epics/scene-management/story-004-transition-loading-ui-shell.md`
- Requirements: `TR-scene-002`, `TR-scene-007`
- Runtime assets:
  - `res://assets/generated/scene_transition_tunnel_overlay.png`
  - `res://assets/generated/scene_transition_paw_spinner.png`
- Image generation sources:
  - `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_01f0c474bc5b0488016a3c33793eb48191904afb7be6b60b66.png`
  - `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_0d902e81efe4a685016a3c341d8e5c8191ad52ba85c59f878c.png`
- Project source copies:
  - `assets/generated/source/scene_transition_tunnel_overlay_imagegen_20260625.png`
  - `assets/generated/source/scene_transition_paw_spinner_imagegen_20260625.png`

## Image Generation Prompt Summary

### Tunnel Overlay

16:9 pixel-art / painterly-pixel scene transition background for a 2D action
game: scrap-metal doorway/tunnel, smoky ember-orange wasteland city glow,
teal-gray rusted metal framing, dark vignette, small cat-warrior silhouette,
and lower-center room for loading UI. Avoided words, logos, UI widgets, progress
bars, pure black screens, flat single-color rectangles, and photorealism.

### Paw Spinner

Pixel-art cat paw loading spinner on flat `#ff00ff` chroma-key background:
warm bone-white and muted cat-eye gold paw prints in a circular swirl, readable
at UI scale, no text, no rectangular frame, no progress bar, no cast shadow.

## Asset Processing

- Tunnel source generated at `1672x941` RGB PNG.
- Tunnel source copied to
  `assets/generated/source/scene_transition_tunnel_overlay_imagegen_20260625.png`.
- Tunnel runtime PNG resized to `1280x720` RGB:
  `assets/generated/scene_transition_tunnel_overlay.png`.
- Paw spinner source generated at `1254x1254` RGB PNG.
- Paw spinner source copied to
  `assets/generated/source/scene_transition_paw_spinner_imagegen_20260625.png`.
- Paw spinner chroma-key removed locally with:

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/.system/imagegen/scripts/remove_chroma_key.py" \
  --input assets/generated/source/scene_transition_paw_spinner_imagegen_20260625.png \
  --out /tmp/scene_transition_paw_spinner_alpha.png \
  --auto-key border \
  --soft-matte \
  --transparent-threshold 12 \
  --opaque-threshold 220 \
  --despill
```

- Paw spinner runtime PNG resized to `256x256` RGBA:
  `assets/generated/scene_transition_paw_spinner.png`.
- Godot import command exited `0` and generated `.import` files for both runtime
  assets and both source copies:

```bash
godot --headless --path . --import --quit-after 1
```

## Automated Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd \
  -a res://tests/unit/presentation/hud_manager_test.gd \
  -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd \
  --ignoreHeadlessMode
```

Result: exit `100`, `6` executed tests, `1` runtime error, `8` failures,
`reports/report_421/`.

Observed failure:

- `SceneManager` lacked `on_scene_load_started`.
- `HUDManager` lacked transition shell APIs.
- `MainScene` still routed async-capable adapters through synchronous
  `change_scene()`.

### GREEN

Focused command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd \
  -a res://tests/unit/presentation/hud_manager_test.gd \
  -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd \
  --ignoreHeadlessMode
```

Result: exit `0`, `28/28` passing, `reports/report_422/`.

Related regression command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/scene/story_001_scene_manager_registry_api_test.gd \
  -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd \
  -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd \
  -a res://tests/unit/gameplay/main_scene_title_load_handoff_test.gd \
  -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd \
  -a res://tests/unit/save/story_005_async_write_performance_budget_test.gd \
  -a res://tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd \
  -a res://tests/unit/presentation/hud_manager_test.gd \
  -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd \
  --ignoreHeadlessMode
```

Result: exit `0`, `59/59` passing, `reports/report_423/`. GdUnit printed an
ObjectDB leaked-at-exit warning after success; no test failed and the standalone
main-scene smoke log below had no warning/error matches.

### Headless Main Scene Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn \
  --fixed-fps 60 --quit-after 180 \
  --log-file reports/scene_transition_loading_ui_shell_main_scene_smoke.log

rg -n "ERROR|Error|error|WARNING|Warning|warning|Parse Error|SCRIPT ERROR|Invalid call|Failed" \
  reports/scene_transition_loading_ui_shell_main_scene_smoke.log
```

Result: Godot exited `0`; log scan returned no matches.

## Godot MCP Runtime Evidence

- MCP connected to Godot `4.6.3-stable (official)`.
- Open scene: `res://scenes/main.tscn`.
- Project run: current scene, `game_capture_ready=true`.
- Runtime logs:
  - Game log contained only `[godot_ai game_helper] registered mcp capture`.
  - Editor log returned zero entries.
- Scene tree inspection verified:
  - `/Main/Player/Sprite` and `/Main/Enemy/Sprite` are `AnimatedSprite2D`.
  - `/Main/HUD/HudRoot/SceneTransitionOverlay/TransitionBackground` is
    `TextureRect`.
  - `/Main/HUD/HudRoot/SceneTransitionOverlay/PawSpinner` is `TextureRect`.
  - `/Main/HUD/HudRoot/SceneTransitionOverlay/TransitionSceneLabel` is `Label`.

### Success Path Probe

MCP `game_eval` called
`/root/SceneManager.request_scene_change("main", "mcp_transition_probe")`.

Observed:

```json
{
  "ok": true,
  "is_loading": true,
  "pending_scene": "main",
  "pending_spawn": "mcp_transition_probe",
  "transition_visible": true,
  "label": "Scrap Alley",
  "background_is_texture_rect": true,
  "spinner_is_texture_rect": true,
  "background_path": "res://assets/generated/scene_transition_tunnel_overlay.png",
  "spinner_path": "res://assets/generated/scene_transition_paw_spinner.png"
}
```

After advancing transition time:

```json
{
  "rotation_changed": true,
  "is_loading": false,
  "current_scene": "hub",
  "current_spawn": "mcp_overlay_capture",
  "transition_visible": false
}
```

### Timeout Path Probe

MCP injected a runtime `GDScript` fake loader that stayed in
`THREAD_LOAD_IN_PROGRESS`.

Observed:

```json
{
  "ok": true,
  "visible_after_start": true,
  "visible_after_retry": true,
  "retry_count": 1,
  "request_count": 2,
  "is_loading": false,
  "transition_visible_after_failure": false,
  "notification": "Load failed",
  "last_error": "timeout",
  "current_scene": "hub",
  "current_spawn": "clan_base"
}
```

### Screenshot

- MCP live screenshot captured the authored tunnel overlay, cat paw spinner, and
  dynamic `Clan Base` label.
- Saved framebuffer:
  `reports/visual/cinderpaw-mcp-scene-transition-loading-ui-shell-20260625.png`.
  The saved framebuffer shows the authored tunnel overlay and spinner; runtime
  eval recorded the label as `Clan Base` during the same capture state.

## Result

PASS with scope notes:

- Scene transition/loading shell is implemented and driven by SceneManager async
  lifecycle signals.
- Assets are image-generated, copied into project source/runtime paths, imported
  by Godot, and recorded in `design/assets/asset-manifest.md`.
- Real scene-tree swap, deferred unload/cache, fast travel, audio fade, and
  memory budget verification remain future SceneManagement stories.
