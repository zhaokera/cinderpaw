# QA Evidence: Old Factory Service Lift SceneManager Exit

> **Story**: Player Abilities Story036
> **Date**: 2026-06-30
> **Engine**: Godot 4.7
> **Scope**: Old Factory service lift request into SceneManager.

## Automated Evidence

- RED focused: `reports/report_893/` failed before the service lift exposed
  SceneManager exit request semantics.
- GREEN focused: `reports/report_894/` passed `2/2`.
- Story035 + Story036 focused regression: `reports/report_895/` passed `4/4`.
- Related regression: `reports/report_896/` passed `28/28`.
- Headless scene smoke:
  `reports/old_factory_service_lift_scene_manager_exit_factory_scene_smoke.log`
  exited `0`; keyword scan found no script, parse, invalid-call,
  missing-resource, or resource-load errors.

## MCP Runtime Evidence

- MCP session `cinderpaw@573d` connected to Godot `4.7-stable (official)`.
- Open scene: `res://scenes/factory_route_transition_shell.tscn`.
- Runtime probe launched the current scene with `autosave=false`, cleared the
  Factory route through existing public scene APIs, moved the player to
  `FactoryServiceLift`, and called `try_activate_factory_service_lift`.
- Probe result:
  - `activation_result == true`
  - `exit_requested == true`
  - `exit_target_scene_id == "main"`
  - `exit_spawn_point == "scrap_roost"`
  - `route_label_text == "Service Lift Departing"`
  - `SceneManager.is_loading() == true` immediately after request
  - `SceneManager.get_pending_scene() == "main"`
  - `SceneManager.get_pending_spawn_point() == "scrap_roost"`
- MCP game screenshot was nonblank and showed the Old Factory background,
  visible service lift prop, service lift VFX, and `Service Lift Departing`
  route label.
- MCP game logs after the clean probe contained only the helper registration
  info line. MCP editor logs contained two unrelated Godot file-system warnings
  about auto-recreated `.uid` files for existing tests.

## Notes

- Directly launching the Factory scene through MCP does not configure the
  Story005 runtime scene-root swap owner. In that mode SceneManager still
  accepts and commits the logical request contract; end-to-end runtime scene-tree
  swap remains covered by the main scene/runtime-root pipeline and the
  SceneManager Story005 tests.
- No new visual assets were generated for this story.
