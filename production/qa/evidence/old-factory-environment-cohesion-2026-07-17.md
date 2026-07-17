# QA Evidence: Old Factory Environment Cohesion

> **Story**: Combat Presentation 034
> **Date**: 2026-07-17
> **Engine**: Godot 4.7-stable
> **Godot AI MCP**: plugin/server 3.0.2

## Acceptance Summary

| Criterion | Evidence | Result |
| --- | --- | --- |
| Four generated environment variants | Retained RGB sources, exact RGB runtime plates, prompt/hash record | PASS |
| No stretched runtime plates | Story034 diagnostics: 24 tiles, all `scale=(1,1)`, `1280x720` | PASS |
| Full route coverage | `30720px` plate coverage over existing `30080px` ground | PASS |
| Legacy backgrounds covered | New layer `z=-98`, legacy layers `-99/-100` | PASS |
| Foreground contracts preserved | Floor/platform and animated steam-vent related regressions | PASS |
| Visible Godot runtime | Non-empty gameplay screenshot and runtime node inspection | PASS |
| Clean runtime | Info-only game log, zero editor errors, clean stop | PASS |

## Automated Evidence

- Intentional RED: `reports/report_1887`
  - `1/1` test failed with eleven expected missing-artifact/node assertions.
  - No parser or unrelated gameplay failure occurred.
- Focused GREEN: `reports/report_1890/report_1/results.xml`
  - Story034 `1/1` passed.
  - `0` errors, failures, flaky, skipped and orphan cases; exit `0` with clean
    process teardown.
- Bounded related GREEN: `reports/report_1892/report_1/results.xml`
  - Story034, route floor/platform visual pass and steam-vent motion
    readability passed `3/3`.
  - `0` errors, failures, flaky, skipped and orphan cases; exit `0` with clean
    process teardown.
- Godot 4.7 import exited `0`; all four source and runtime PNGs imported.

## MCP Runtime Evidence

- Session: `cinderpaw@af5f`
- Run: `r213728878-59`
- Custom scene:
  `res://scenes/factory_route_transition_shell.tscn`
- Editor filesystem scan completed before force-reloading the disk scene.
- Editor scene query found
  `/FactoryRouteTransitionShellScene/EnvironmentCohesion`.
- Runtime tree showed `EnvironmentCohesion` with exactly 24 children named
  `FactoryBackdropTile00` through `FactoryBackdropTile23`.
- Runtime `get_diagnostics()` returned:
  - `variant_count=4`
  - `tile_count=24`
  - `unique_texture_count=4`
  - `tile_size=(1280,720)`
  - `coverage_width=30720`
  - `all_tiles_unscaled=true`
  - `all_tiles_opaque=true`
  - `legacy_background_covered=true`
- First plate: position `(640,360)`, scale `(1,1)`, entry texture.
- Last plate: position `(30080,360)`, scale `(1,1)`, tailrace texture.
- Player presentation remained `AnimatedSprite2D`, animation `idle`.
- Entrance steam presentation remained `AnimatedSprite2D`, playing four-frame
  `active` animation.
- Game log contained one info-only helper registration line; no warning or
  error. Editor log contained zero lines after the acceptance baseline clear.
- MCP stop returned `stopped=true` and editor readiness `ready`.

## Screenshot

- Path:
  `reports/visual/cinderpaw-mcp-old-factory-environment-cohesion-20260717.png`
- Dimensions: `1278x718`
- SHA-256:
  `b1bddc7394c70644d6e340c60c5df0ade0b3e73ebddf3ec50b3f5544587f3be8`
- Visual review: the frame visibly contains Cinderpaw, animated Factory
  enemies, a live steam vent, foreground platforms and a detailed hard-edged
  assembly-hall background. No stretched color columns, empty viewport or
  placeholder block dominates the gameplay frame.

## Scope Audit

- Ground collision remains `30080px`.
- No camera, collision, movement, enemy, hazard, encounter, reward, route
  state, save or audio value changed.
- The compatibility `Background` and `PostBulkheadBackground` nodes remain for
  existing diagnostics and are covered only by Presentation draw order.
- The broader complete-game objective remains active.
