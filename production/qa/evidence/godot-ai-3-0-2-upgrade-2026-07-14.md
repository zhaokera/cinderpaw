# Godot AI MCP 3.0.2 Upgrade Evidence

## Scope

- Upgraded the project-local Godot AI plugin from `2.9.2` to `3.0.2`.
- Source package:
  `/Users/zhaok/Downloads/godot-ai-3.0.2/plugin/addons/godot_ai/`.
- Project plugin path: `res://addons/godot_ai/`.
- Historical Story evidence remains pinned to the MCP version used for each
  original validation run.

## Static Validation

- Download package `pyproject.toml` and `plugin.cfg` both report `3.0.2`.
- `diff -qr` confirms the project plugin directory exactly matches the supplied
  `3.0.2` plugin directory after replacement.
- `addons/godot_ai/plugin.cfg` reports `version="3.0.2"`.
- The running managed CLI reports `godot-ai 3.0.2`.
- Godot 4.7 editor settings record:
  - `godot_ai/managed_server_version = "3.0.2"`
  - `godot_ai/managed_server_pid = 5173`
  - `godot_ai/managed_server_ws_port = 9500`

## MCP Connection Validation

- Godot editor restarted with project path
  `/Users/zhaok/Desktop/wxgame/cinderpaw`.
- Managed server process command pins
  `uvx --from godot-ai==3.0.2 godot-ai`.
- MCP session `cinderpaw@3736` reported:
  - `plugin_version="3.0.2"`
  - `server_version="3.0.2"`
  - `server_launch_mode="uvx"`
  - `godot_version="4.7-stable (official)"`
  - `current_scene="res://scenes/main.tscn"`
  - `readiness="ready"`
- The HTTP MCP `initialize.serverInfo.version` is FastMCP's framework version
  (`3.4.4`), not the Godot AI package version. The Godot session handshake and
  executable `--version` output are the authoritative package checks above.

## Runtime Validation

- Cleared MCP/editor logs and launched `res://scenes/main.tscn` through MCP.
- Run `r233874-1` returned `current_run_errors=[]`, `helper_live=true`, and
  `status="live"`.
- Game log contained three expected info-only lines: game helper registration,
  `boss_configs` load, and `enemy_stats` load.
- Editor log contained zero lines and no debugger errors.
- MCP stopped the game cleanly and returned editor readiness to `ready`.

## Result

Godot AI MCP `3.0.2` is the verified project baseline for subsequent cinderpaw
runtime acceptance. No commit or push was performed.
