# Godot 4.7 Baseline Recheck — 2026-07-01

## Scope

The project baseline is Godot 4.7. This recheck confirms that the currently
available local CLI matches the project baseline after the editor-side upgrade.

## Version Evidence

```text
/Applications/Godot 2.app/Contents/MacOS/Godot --version
4.7.stable.official.5b4e0cb0f
```

Current baseline files already point to Godot 4.7:

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
- Startup completed with the expected DataManager domain loads.
- Godot AI helper registered MCP capture.
- No script parse, scene load, invalid call, or missing resource error appeared
  during startup.
- The known Godot shutdown-time ObjectDB/resource cleanup messages still appear
  at process exit and are not new to the 4.7 baseline.

## Follow-up Rule

All future scene, resource, animation, SpriteFrames, import, and runtime
validation work should use Godot 4.7 CLI/MCP. Do not save committed Godot
project assets with Godot 4.6.x after this baseline.
