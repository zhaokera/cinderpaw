# QA Evidence: Scene Memory Budget Diagnostics - 2026-06-25

## Scope

Verifies Scene Management Story010: `SceneManager` now exposes deterministic
runtime memory-budget diagnostics, platform budget normalization, a one-shot
memory-budget warning signal, and emergency eviction of the non-current deferred
runtime cache.

This evidence covers the deterministic estimator required for Story010. It does
not claim real mobile/PC/console platform profiler certification, low-memory UI
prompt routing, or ResourceLoader cache policy changes.

## Design Contract

- Platform memory budgets use decimal bytes:
  - `mobile`: `1,000,000,000`.
  - `pc`: `2,000,000,000`.
  - `console`: `4,000,000,000`.
- Empty or unknown platform values normalize to `pc`.
- Runtime resident scenes include the current runtime scene, deferred previous
  cache, and pending reused quick-return scene, deduplicated by instance id.
- Memory estimates are read only through optional
  `get_estimated_memory_bytes()`. Missing, invalid, or negative estimates count
  as `0`.
- `enforce_runtime_memory_budget()` may evict only the non-current previous
  cache. It must preserve the current runtime scene and configured runtime root.
- `on_memory_budget_exceeded(diagnostics)` emits once per over-budget state and
  resets after the budget returns to pass.

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene/story_010_scene_memory_budget_diagnostics_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_520/`.

Summary: expected failure because `SceneManager` did not yet expose
`get_memory_budget_diagnostics()`, `check_runtime_memory_budget()`,
`enforce_runtime_memory_budget()`, or `on_memory_budget_exceeded`.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene/story_010_scene_memory_budget_diagnostics_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_526/`.

Summary: `7/7` passing, `0` errors, `0` failures, `0` orphans. Coverage
includes platform normalization, current+previous estimates, missing estimator
fallback, quick-return pending reused diagnostics, deferred unload diagnostic
updates, enforcement no-op, enforcement eviction, and warning latch reset.

### SceneManager Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/scene --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_527/`.

Summary: `34/34` passing, `0` errors, `0` failures, `0` orphans across
SceneManager Story001, Story003, Story005, Story006, Story007, and Story010.

### MainScene Related Regression

Commands:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_scene_transition_ui_test.gd --ignoreHeadlessMode
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/main_scene_title_load_handoff_test.gd --ignoreHeadlessMode
```

Results:

- `reports/report_528/`: transition UI shell regression, `2/2` passing,
  `0` errors, `0` failures, `0` orphans.
- `reports/report_529/`: title/load handoff regression, `7/7` passing,
  `0` errors, `0` failures, `0` orphans.

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --quit-after 2 > reports/scene_memory_budget_diagnostics_headless_smoke.log 2>&1
rg -n "ERROR|Error|WARNING|Warning|SCRIPT ERROR|push_error|failed|Failed" reports/scene_memory_budget_diagnostics_headless_smoke.log
```

Result: Godot exited `0`; the log scan returned no matches.

Log path: `reports/scene_memory_budget_diagnostics_headless_smoke.log`.

## Godot MCP Evidence

Session:

- Godot version: `4.6.3-stable (official)`.
- Editor scene: `res://scenes/main.tscn`.
- Runtime state: playing, game capture ready.

Autoload probe:

```json
{
  "has_scene_manager": true,
  "has_get_memory_budget_diagnostics": true,
  "has_check_runtime_memory_budget": true,
  "has_enforce_runtime_memory_budget": true,
  "has_on_memory_budget_exceeded": true,
  "mobile_budget": 1000000000,
  "pc_budget": 2000000000,
  "console_budget": 4000000000,
  "unknown_platform": "pc",
  "empty_platform": "pc"
}
```

Runtime-root diagnostics/enforcement probe:

```json
{
  "configured": true,
  "changed": true,
  "runtime_root_configured": true,
  "before": {
    "platform": "mobile",
    "resident_runtime_scene_count": 2,
    "resident_runtime_scene_ids": ["main", "hub"],
    "resident_runtime_scene_roles": ["current", "previous"],
    "estimated_runtime_memory_bytes": 1700000000,
    "platform_budget_bytes": 1000000000,
    "over_budget_bytes": 700000000,
    "within_memory_budget": false,
    "within_resident_count_budget": true,
    "within_budget": false
  },
  "first_check": false,
  "second_check": false,
  "enforced": true,
  "after_enforce": {
    "resident_runtime_scene_count": 1,
    "resident_runtime_scene_ids": ["main"],
    "estimated_runtime_memory_bytes": 800000000,
    "within_budget": true
  },
  "previous_cleared": true,
  "previous_queued": true,
  "current_preserved": true,
  "reset_check": true,
  "third_check": false,
  "after_second_over_budget": {
    "resident_runtime_scene_count": 1,
    "resident_runtime_scene_ids": ["main"],
    "estimated_runtime_memory_bytes": 1200000000,
    "over_budget_bytes": 200000000,
    "within_budget": false
  }
}
```

Warning latch probe:

```json
{
  "first_check": false,
  "second_check": false,
  "count_after_repeated_checks": 1,
  "reset_check": true,
  "third_check": false,
  "final_count": 2,
  "second_event_platform": "mobile"
}
```

Logs:

- `logs_read(source="game", count=100, include_details=true)` returned only MCP
  helper registration and DataManager domain load lines for `boss_configs` and
  `enemy_stats`.
- `logs_read(source="editor", count=100, include_details=true)` returned
  `0` lines.

Screenshot:

- Runtime screenshot saved at
  `reports/visual/cinderpaw-mcp-scene-memory-budget-diagnostics-20260625.png`.
- Godot saved the viewport as a `1280x720` PNG, `error=0`, `is_empty=false`.
- Screenshot is nonblank and shows the playable main scene with Rat King,
  Player, HUD, and environment background visible.

## Acceptance Verdict

| Criterion | Evidence | Status |
|-----------|----------|--------|
| Deterministic diagnostics expose budget, resident IDs/count, estimates, pass/fail flags, and over-budget bytes | Story010 GdUnit and MCP autoload/runtime-root probes | PASS |
| Platform budgets normalize mobile/pc/console and fallback unknown/empty to pc | Story010 GdUnit and MCP autoload probe | PASS |
| Optional `get_estimated_memory_bytes()` seam handles current/previous/pending reused scenes and missing estimators | Story010 GdUnit | PASS |
| Diagnostics update after quick-return pending reuse and deferred unload | Story010 GdUnit | PASS |
| One-shot `on_memory_budget_exceeded` warning resets after returning in budget | Story010 GdUnit and MCP warning latch probe | PASS |
| Enforcement evicts only non-current previous cache and preserves current scene | Story010 GdUnit and MCP runtime-root probe | PASS |
| SceneManager async/load/cache regressions remain compatible | `reports/report_527/` | PASS |
| MainScene transition/title handoff regressions remain compatible | `reports/report_528/`, `reports/report_529/` | PASS |
| Runtime logs are clean | Headless smoke log scan and MCP logs | PASS |
| Runtime screenshot is nonblank | MCP saved screenshot | PASS |

## Final Status

PASS. Story010 is implemented and verified by RED/GREEN TDD, SceneManager
regression, MainScene related regression, Godot headless smoke, and Godot MCP
runtime/log/screenshot evidence. Real platform peak-memory profiling remains a
future performance/release gate, not part of this deterministic Story010 slice.
