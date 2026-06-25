# Story 006: Factory Route Transition Shell

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Gameplay Runtime + Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-explore-001`,
`TR-explore-002`, `TR-explore-006`, `TR-scene-001`

**ADR Governing Implementation**: ADR-0018 Player abilities; ADR-0007 Scene
management; ADR-0021 Save system architecture.

Stories003-005 made Double Jump playable, provided a hidden reward source, and
made the high-platform gate persist `area_03_factory_unlocked`. This story adds
the smallest player-visible route continuation: after the player opens the
Double Jump high-platform gate, a generated factory doorway prop becomes
available and can request a SceneManager transition into a minimal factory route
entrance shell.

This is an entrance/transition shell only. It validates the ability-gate to
scene-transition chain and does not claim the full Old Factory area is built.

## Acceptance Criteria

- [x] `data/scene_registry.json` contains `area_03_factory` with
  `path="res://scenes/factory_route_transition_shell.tscn"`,
  `type="route_shell"`, `preload=false`,
  `default_spawn="factory_gate_entry"`, and display name `Factory Route`.
- [x] `res://scenes/main.tscn` contains a visible
  `FactoryRouteTransitionShell` node behind the Double Jump high-platform gate,
  using an image-generated transparent PNG rather than a `ColorRect`,
  `Polygon2D`, or solid placeholder.
- [x] The route shell stays unavailable until `area_03_factory_unlocked` is set
  by the existing `DoubleJumpExplorationGate` unlock path.
- [x] Unlocking `double_jump` alone does not auto-transition; the player must
  first unlock the high-platform gate and then enter the route shell range.
- [x] Triggering the route shell requests SceneManager transition
  `area_03_factory` / `factory_gate_entry`, shows the existing HUD transition
  shell with label `Factory Route`, and prevents duplicate enqueue while a
  request is pending.
- [x] `res://scenes/factory_route_transition_shell.tscn` is a minimal loadable
  visible destination with `FactoryGateEntrySpawn`, generated prop art, and no
  full factory level content.
- [x] Generated asset source, alpha audit, runtime import path, RED/GREEN
  focused test, related regression, headless smoke, and Godot MCP runtime
  screenshot/log evidence are recorded.

## Out of Scope

- Full Old Factory layout, enemies, Boss2, hidden-boss combat, map/minimap,
  factory savepoints, fast travel route, or factory completion state.
- New player ability, new Cinderpaw frame animation, skill-tree spending UI, or
  gate dissolve/SFX polish.
- SceneManager architecture rewrite, full route memory budget tuning, or
  additional area transitions beyond `area_03_factory`.

## Implementation Notes

- `RouteTransitionShell` is a scene-local Feature node. It owns only
  availability, prompt, range, and duplicate-request state.
- `MainScene` remains the integration owner: it syncs the shell from
  `area_03_factory_unlocked`, requests SceneManager transition, and lets the
  existing HUD/audio SceneManager signal bridge drive presentation.
- `SceneManager` keeps `display_name` from the registry so transition UI can
  show `Factory Route` without pretending the full factory area is complete.
- The destination scene is intentionally small and should stay visually clear as
  a route shell until a later story implements real factory content.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd`
- `tests/unit/gameplay/player_double_jump_gate_runtime_test.gd`
- `tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/factory-route-transition-shell-2026-06-26.md`

**Status**: [x] RED/GREEN focused evidence, related regression, asset import,
headless smoke, and MCP runtime evidence complete.

- RED: `reports/report_630/` failed as expected because
  `area_03_factory`, `FactoryRouteTransitionShell`, and the destination shell
  scene did not exist.
- RED refinement: `reports/report_634/` failed as expected because
  `MainScene` requested the transition but had not yet configured
  SceneManager's runtime scene root for actual scene-tree swapping.
- GREEN focused: `reports/report_635/` passed `3/3` for registry entry,
  MainScene route trigger, SceneManager request, runtime scene-root setup, HUD
  transition label, and minimal destination scene.
- Related regression: `reports/report_636/` passed `40/40` across Factory
  Route shell, Double Jump gate/reward, SceneManager runtime swapping, scene
  transition UI, title/load handoff, and fast-travel preload coverage.
- Headless smoke:
  `reports/factory_route_transition_shell_main_scene_smoke.log` exited `0`
  with only the existing cleanup-time ObjectDB/resource messages.
- Godot MCP runtime evidence and screenshot are recorded in
  `production/qa/evidence/factory-route-transition-shell-2026-06-26.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Registry contains loadable factory route shell | `factory_route_transition_shell_runtime_test` | COVERED |
| MainScene contains generated route shell prop | `factory_route_transition_shell_runtime_test`; MCP screenshot | COVERED |
| Availability follows `area_03_factory_unlocked` | `factory_route_transition_shell_runtime_test`; MCP probe | COVERED |
| No auto-transition on ability unlock alone | `factory_route_transition_shell_runtime_test` | COVERED |
| Trigger requests SceneManager and HUD transition | `factory_route_transition_shell_runtime_test`; MCP probe | COVERED |
| Minimal visible destination scene | `factory_route_transition_shell_runtime_test`; MCP probe | COVERED |
| Runtime logs and screenshot verified through MCP | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-06-26
**Criteria**: 7/7 passing
**Deviations**: This story adds a route entrance/transition shell only; full Old
Factory gameplay remains out of scope.
**QA Evidence**:
`production/qa/evidence/factory-route-transition-shell-2026-06-26.md`
