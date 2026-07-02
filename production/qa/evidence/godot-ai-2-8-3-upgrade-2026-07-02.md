# Godot AI MCP 2.8.3 Upgrade Evidence

## Scope
- Upgraded the project-local Godot AI plugin from `2.8.1` to `2.8.3`.
- Source package: `/Users/zhaok/Downloads/godot-ai-2.8.3/plugin/addons/godot_ai/`.
- Project plugin path: `res://addons/godot_ai/plugin.cfg`.

## Validation
- `addons/godot_ai/plugin.cfg` reports `version="2.8.3"`.
- Godot editor was restarted on Godot `4.7-stable (official)`.
- MCP session `cinderpaw@b83b` reported:
  - `plugin_version="2.8.3"`
  - `server_version="2.8.3"`
  - `readiness="ready"`
  - `current_scene="res://scenes/factory_route_transition_shell.tscn"`
- Local MCP status endpoint reported:
  - `server_version="2.8.3"`
  - `tool_surface="rollup"`
  - `package_path="/Users/zhaok/.cache/uv/archive-v0/uwpVAeekssPuKsD8/lib/python3.11/site-packages/godot_ai"`
- Runtime smoke launched `res://scenes/factory_route_transition_shell.tscn`
  through MCP with `autosave=false` and returned the game helper live.
- Runtime game log after launch only contained the expected MCP capture
  registration line and no new game/editor errors were reported.

## Notes
- `project.godot` editor ordering noise was intentionally not kept as part of
  this upgrade.
- Story062 gameplay changes remain uncommitted and are outside this technical
  maintenance slice.
