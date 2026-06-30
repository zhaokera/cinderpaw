# Godot 4.7 Upgrade Evidence — 2026-06-30

## Scope

Project engine baseline upgraded from Godot 4.6.3 to Godot 4.7 for current
development and validation.

## Files Updated

- `project.godot` — feature metadata now pins `config/features=PackedStringArray("4.7")`.
- `AGENTS.md` — Technology Stack now lists `Godot 4.7`.
- `CLAUDE.md`, `design/gdd/game-concept.md`, and
  `design/art/art-bible.md` — legacy current-baseline references now point to
  `Godot 4.7` instead of `Godot 4.6.3`.
- `.claude/docs/technical-preferences.md` — Engine baseline now lists
  `Godot 4.7`; physics notes clarify the project has no authored 3D physics
  dependency.
- `docs/engine-reference/godot/` — version reference, breaking-change notes,
  deprecated API watch list, current practices, and module headers updated for
  Godot 4.7.

## Version Evidence

```text
/Applications/Godot 2.app/Contents/MacOS/Godot --version
4.7.stable.official.5b4e0cb0f
```

Godot MCP editor state also reports:

```text
godot_version: 4.7-stable (official)
readiness: ready
current_scene: res://scenes/factory_route_transition_shell.tscn
```

## Migration Audit

Searched the project for the 4.7 high-risk migration watch list:

- `RichTextLabel.add_image`
- `RichTextLabel.update_image`
- `tap_back_pos`
- `AudioEffectSpectrumAnalyzer`
- direct `InputEvent.device` assumptions
- removed physics/particle server names
- compatibility-sensitive override hooks

No project `src/` usage requiring migration was found. Matches were limited to
ordinary plugin/test references such as `RichTextLabel` node creation and
`is_class()` test helpers, not the removed or changed APIs recorded in the 4.7
reference notes.

## Verification

Commands run with Godot 4.7:

```bash
/Applications/Godot\ 2.app/Contents/MacOS/Godot --headless --path . --quit \
  --log-file reports/godot_4_7_upgrade_project_boot.log

/Applications/Godot\ 2.app/Contents/MacOS/Godot --headless --path . \
  --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 \
  --log-file reports/godot_4_7_upgrade_main_scene_smoke.log

/Applications/Godot\ 2.app/Contents/MacOS/Godot --headless --path . \
  -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/scene/story_003_async_load_timeout_fallback_test.gd \
  -a res://tests/unit/gameplay/old_factory_service_lift_handoff_test.gd \
  --ignoreHeadlessMode
```

Results:

- Project boot exited `0`; keyword scan found no script/parse/invalid/missing
  resource errors.
- Main scene smoke exited `0`; keyword scan found no script/parse/invalid/missing
  resource errors.
- Focused GdUnit report `reports/report_891/` passed `6/6`.
- Both headless runs still emit the project's existing Godot cleanup-time
  ObjectDB/resource messages at exit; no runtime script or scene loading error
  was introduced by the upgrade.

## Sources

- Godot 4.7 docs: https://docs.godotengine.org/en/4.7/
- 4.6 to 4.7 migration guide:
  https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.7.html
- Godot 4.7 release notes: https://godotengine.org/releases/4.7/
