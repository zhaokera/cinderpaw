# QA Evidence: Scene Management Story 001 — SceneManager Registry + Public API Baseline

> Date: 2026-06-25
> Story: `production/epics/scene-management/story-001-scene-manager-registry-api-baseline.md`
> Epic: Scene Management
> Scope: `TR-scene-001`, `TR-scene-004`, `TR-scene-005`

## Result

PASS

## Summary

SceneManager now exists as the Feature-layer logical scene service. Story001
adds the Autoload registration, `scene_registry` data domain, schema validation,
logical preload/change-scene state, boss scene lock, scene-state cache, and
SaveSystem-compatible `serialize()` / `deserialize(data, version)`.

This is intentionally not the full ADR-0007 transition implementation. It does
not perform real `ResourceLoader` threaded scene replacement, deferred unload,
timeout/retry, transition UI/audio, or fast travel. It provides the deterministic
API boundary needed by Death & Respawn Story004.

## Acceptance Coverage

| AC | Result | Evidence |
|----|--------|----------|
| `project.godot` registers SceneManager after SaveSystem | PASS | Story001 unit test checks Autoload order and script load. |
| `scene_registry` loads through DataManager and schema validation | PASS | Story001 unit test and DataManager regression verify `hub`/`main` entries. |
| Public API baseline exists | PASS | Story001 unit test calls registry, preload, change, lock, state, and serialization APIs. |
| Logical preload and scene change update state without tree swap | PASS | Story001 unit test verifies loaded state, current scene, current spawn, and signal order. |
| Invalid or locked changes reject without side effects | PASS | Story001 unit test verifies `false`, unchanged state, and no signals. |
| Scene state is deep-copied | PASS | Story001 unit test mutates original/returned dictionaries and verifies stored state remains stable. |
| SaveSystem can call `deserialize(data, version)` | PASS | Story001 unit test registers SceneManager with SaveSystem and loads a save payload. |

## TDD Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene/story_001_scene_manager_registry_api_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_396/`. Expected failures:
`project.godot` lacked `SceneManager` Autoload and
`res://src/feature/scene_manager.gd` did not exist.

### GREEN

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene/story_001_scene_manager_registry_api_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_397/`.

Summary: `9/9` passing, `0` errors, `0` failures.

## Regression Evidence

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene/story_001_scene_manager_registry_api_test.gd -a res://tests/unit/data/story_001_manifest_test.gd -a res://tests/unit/data/story_003_domain_cache_test.gd -a res://tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_398/`.

Summary: `29/29` passing, `0` errors, `0` failures.

## Headless Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/scene_manager_story001_main_scene_smoke.log
```

Result: exit `0`. Log scan found no `ERROR`, `WARNING`, `SCRIPT ERROR`,
`FATAL`, or related matches.

## Godot MCP Runtime Evidence

MCP checks:

- Godot MCP connected to Godot `4.6.3-stable`, current scene
  `res://scenes/main.tscn`, editor ready.
- Ran the current scene through MCP.
- Runtime `/root/SceneManager` existed.
- Runtime `/root/DataManager` reported `scene_registry` loaded.
- Runtime `/root/SaveSystem` existed.
- Runtime `SceneManager.change_scene(&"main", &"mcp_probe")` returned `true`.

Observed runtime result:

```json
{
  "scene_manager_exists": true,
  "data_manager_has_scene_registry": true,
  "save_system_exists": true,
  "current_scene": "hub",
  "current_spawn_point": "clan_base",
  "hub_loaded": true,
  "main_loaded": true,
  "change_main": true,
  "after_change_scene": "main",
  "after_change_spawn": "mcp_probe",
  "serialized": {
    "current_scene_id": "main",
    "current_spawn_point": "mcp_probe",
    "scene_states": {}
  }
}
```

Runtime logs contained only the MCP game helper registration line. Editor logs
returned `0` lines after the run. MCP game screenshot was non-empty at 640x360
and showed the main 2D scene with player, enemy, HUD, and background visible.

## Notes

- No new visual assets were added in this story.
- `hub` is temporarily mapped to `res://scenes/main.tscn` because a dedicated
  hub scene does not exist yet.
- AudioSystem remains an existing ADR-0001 drift and was not implemented here.
- Full async scene-tree replacement, deferred unload, timeout/retry, transition
  presentation, and fast travel remain future SceneManagement stories.
