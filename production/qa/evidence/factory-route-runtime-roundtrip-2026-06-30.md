# QA Evidence: Factory Route Runtime Roundtrip

> **Story**: Player Abilities Story037
> **Date**: 2026-06-30
> **Engine**: Godot 4.7
> **Scope**: End-to-end runtime-root route loop from main to Old Factory and
> back to Scrap Roost.

## Automated Evidence

- RED focused: `reports/report_902/` failed as expected on the returned player
  position: SceneManager reached `main / scrap_roost`, but `Player` stayed at
  the Factory route trigger position `(970, 352)`.
- GREEN focused: `reports/report_906/` passed `1/1` with `0` orphan nodes.
- Pre-commit focused rerun: `reports/report_907/` passed `1/1` with `0`
  orphan nodes on Godot `4.7.stable.official.5b4e0cb0f`.
- Related regression: `reports/report_905/` passed `17/17` with `0` orphan
  nodes:
  - Story037 Factory route runtime roundtrip
  - Factory route transition shell runtime
  - Old Factory service lift SceneManager exit
  - Old Factory service lift handoff
  - Boss2 victory route handoff
  - SceneManager Story005 runtime scene-tree swap
  - SceneManager Story003 async load timeout fallback
- Headless main-scene smoke:
  `reports/factory_route_runtime_roundtrip_main_scene_smoke.log` exited `0`.
  Keyword scan found no `SCRIPT ERROR`, parse error, invalid call/access,
  missing resource, failed load, or `ERROR:` entry. Godot still reports the
  existing cleanup-time ObjectDB/resource warnings after exit.

## MCP Runtime Evidence

- MCP session `cinderpaw@573d` connected to Godot `4.7-stable (official)`.
- Runtime launched the project main scene with `autosave=false`.
- Probe used public scene APIs to:
  - unlock `area_03_factory_unlocked`
  - activate `FactoryRouteTransitionShell`
  - advance SceneManager async loading into `area_03_factory`
  - clear the authored Factory route
  - activate `FactoryServiceLift`
  - advance SceneManager async loading back into `main / scrap_roost`
- Probe result:
  - `route_requested == true`
  - `factory_reached == true`
  - `factory_route_cleared == true`
  - `lift_activated == true`
  - `returned_main == true`
  - `spawn == "scrap_roost"`
  - player returned near Scrap Roost after physics settle:
    `Player.global_position == (210.0, 455.99)`,
    `ScrapRoostSavepoint.global_position == (210.0, 432.0)`.
    The vertical offset is the existing player collision/origin settling
    behavior; the player is at the authored Scrap Roost x position and visibly
    next to the savepoint.
- Screenshot:
  `reports/visual/cinderpaw-mcp-factory-route-runtime-roundtrip-20260630.png`
  is nonblank and shows the returned main scene with Scrap Roost visible.
- MCP game logs contained only helper/DataManager info lines.
- MCP editor logs, after clearing the temporary eval warning, contained only
  unrelated Godot file-system warnings about auto-recreated `.uid` files for
  existing tests.

## Notes

- No new visual assets were generated for this story.
- The runtime screenshot still shows existing Boss2/HUD context because this
  slice validates route traversal and spawn return, not boss-state cleanup or
  final main-scene composition.
