# Godot 4.7 Baseline Recheck — 2026-07-02

## Scope

The project baseline is Godot 4.7. This recheck records the current user
decision that future formal CLI/headless/MCP validation should use Godot 4.7,
not the previous 4.6.3 baseline.

## Version Evidence

```text
/Applications/Godot 2.app/Contents/MacOS/Godot --version
4.7.stable.official.5b4e0cb0f
```

Current baseline files point to Godot 4.7:

- `AGENTS.md`
- `.claude/docs/technical-preferences.md`
- `docs/engine-reference/godot/VERSION.md`
- `project.godot` (`config/features=PackedStringArray("4.7")`)

## Verification

Command:

```bash
/Applications/Godot\ 2.app/Contents/MacOS/Godot --headless --path . --quit
```

Result:

- Exit code: `0`.
- Log: `reports/godot_4_7_project_boot_recheck_20260702.log`.
- Startup completed with DataManager domain loads.
- Godot AI helper registered MCP capture.
- Keyword scan found no startup script, parse, invalid-call, missing-resource,
  or resource-load errors.
- The log still includes known Godot shutdown-time ObjectDB/resource cleanup
  messages after the process exits; these are not new 4.7 startup failures.

## MCP Evidence

- `session_activate("cinderpaw")` selected `cinderpaw@4400`.
- `editor_state` reported Godot `4.7-stable (official)`.
- Editor readiness: `ready`.
- Current scene: `res://scenes/factory_route_transition_shell.tscn`.
- Runtime play state: stopped, with no active helper session at the time of
  this baseline check.

## Follow-up Rule

All future scene, resource, animation, SpriteFrames, import, gameplay runtime,
and GdUnit validation work should use Godot 4.7 CLI/MCP. Do not save committed
Godot project assets with Godot 4.6.x after this baseline.
