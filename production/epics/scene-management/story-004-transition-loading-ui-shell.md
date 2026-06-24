# Story 004: Transition Loading UI Shell

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature + Presentation Integration
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/scene-management.md`
**Requirements**: `TR-scene-002`, `TR-scene-007`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0007: Scene management architecture

**ADR Decision Summary**: Scene transitions must be async and masked by a
1-2 second authored transition. The UI shell should be driven by the same
SceneManager lifecycle that owns threaded loading rather than by a fake timer.

**Engine**: Godot 4.6.3 | **Risk**: MEDIUM

**Control Manifest Rules (Feature layer)**:
- Required: scene changes use async loading plus transition animation.
- Required: transition timing masks scene load for 1.5 seconds.
- Guardrail: This story adds player-visible transition/loading presentation only.
  Real scene-tree replacement, deferred unload/cache enforcement, fast travel,
  and audio fades remain later SceneManagement stories.

---

## Acceptance Criteria

- [x] `SceneManager.request_scene_change()` emits a typed
  `on_scene_load_started(scene_id, spawn_point, metadata)` signal only after a
  threaded request is accepted.
- [x] `HUDManager` exposes a scene transition shell that uses generated texture
  assets for the tunnel background and cat-paw spinner, not a pure-color block.
- [x] The transition shell displays the current target scene label, advances the
  spinner over time, and can hide without mutating active menu state.
- [x] `MainScene` connects SceneManager load-start/changed/failed signals and
  prefers async `request_scene_change()` over synchronous `change_scene()` for
  menu-driven scene handoff when the async API is available.
- [x] Scene load failure hides the transition shell and reports `Load failed`
  without corrupting the existing Story002 atomic load contract.
- [x] New image-generated assets are copied into the project, imported by Godot,
  referenced by runtime code, and recorded in the asset manifest/evidence.

---

## Implementation Notes

- `SceneManager` keeps Story003 logical-scene semantics but now exposes the
  async lifecycle boundary that Presentation can consume.
- `HUDManager` builds `HudRoot/SceneTransitionOverlay` procedurally with:
  - `TransitionBackground: TextureRect`
  - `PawSpinner: TextureRect`
  - `TransitionSceneLabel: Label`
- The spinner is a single transparent texture rotated by `advance_time()`. This
  is intentionally separate from the background so MCP can verify animation state
  and asset source independently.
- `MainScene.configure_scene_manager_runtime()` owns signal connection cleanup
  when swapping SceneManager-like adapters in tests or runtime.

---

## Out of Scope

- Real scene-tree unload/add/remove or `PackedScene.instantiate()` ownership.
- Deferred unload/cache eviction and max-two-resident-scenes enforcement.
- Fast travel menu, fast travel portal animation, or target preload scheduling.
- Audio fade-out/fade-in.
- New player/enemy character animation work; existing runtime characters remain
  under the `AnimatedSprite2D + SpriteFrames` audit contract.

---

## QA Test Cases

- **AC-1**: Load-start signal contract.
  - Given: SceneManager is configured with hub/main registry and a fake loader.
  - When: `request_scene_change("main", "east_gate")` is accepted.
  - Then: `on_scene_load_started` fires once with scene, spawn, path, display
    name, and transition duration metadata while current scene remains `hub`.

- **AC-2**: Textured transition shell.
  - Given: HUDManager is ready.
  - When: `show_scene_transition("main", "Scrap Alley")` is called.
  - Then: the shell is visible, target label is shown, and the runtime texture
    paths are `scene_transition_tunnel_overlay.png` and
    `scene_transition_paw_spinner.png`.

- **AC-3**: Spinner animation and menu isolation.
  - Given: the main menu is visible.
  - When: the scene transition shell advances time and hides.
  - Then: the spinner rotation changes and menu mode/focus state remains owned
    by the existing menu shell.

- **AC-4**: MainScene async handoff.
  - Given: a SceneManager-like adapter supports `request_scene_change()`.
  - When: New Game is requested from the main menu.
  - Then: MainScene calls the async request, does not call sync `change_scene()`,
    hides the menu, shows the transition shell, and closes the shell on changed
    or failed signals.

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- RED/GREEN for SceneManager async signal, HUD shell, and MainScene runtime
  wiring.
- Related regression with SceneManagement Story001/003, Story002 title/load
  handoff, SaveSystem Story004/005, HUD, and visual contract.
- Godot import, headless smoke, and Godot MCP runtime screenshot/log evidence.

**Completed evidence**:
- RED: `reports/report_421/` failed because the start signal, HUD transition
  shell API, and async MainScene routing did not exist yet.
- GREEN: `reports/report_422/` passed focused SceneManager/HUD/MainScene
  transition UI suite `28/28`.
- Related regression: `reports/report_423/` passed `59/59` across SceneManager
  Story001/003, Story004, MainScene title/load handoff, SaveSystem Story004/005,
  HUDManager, and MainScene visual contract.
- Headless smoke:
  `reports/scene_transition_loading_ui_shell_main_scene_smoke.log` exited `0`;
  error/warning scan returned no matches.
- Godot MCP: runtime probe verified load-start texture nodes and labels,
  spinner rotation, success cleanup, timeout retry/failure cleanup, clean logs,
  scene tree nodes, and screenshot evidence.

Full evidence:
`production/qa/evidence/scene-transition-loading-ui-shell-2026-06-25.md`.
