# Story 010: Scene Memory Budget Diagnostics

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature
> **Type**: Logic / Performance
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/scene-management.md`
**Requirement**: `TR-scene-007`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` -- read fresh at
review time)*

**ADR Governing Implementation**: ADR-0007: Scene management architecture

**ADR Decision Summary**: SceneManager owns runtime scene residency, async load
state, deferred unload, and memory-budget guardrails. The production runtime
must never keep more than current scene plus one cached runtime scene resident,
and memory diagnostics must make platform budget breaches visible before later
UI/profile integration stories.

**Engine**: Godot 4.7 | **Risk**: LOW

**Control Manifest Rules (Feature layer)**:
- Required: async scene loading uses `ResourceLoader.load_threaded_request()`.
- Required: deferred unload keeps at most two simultaneous runtime scenes.
- Required: memory peak stays under 1GB mobile / 2GB PC budgets.
- Forbidden: no synchronous scene switching and no extra Autoload for memory
  diagnostics.

---

## Acceptance Criteria

- [x] SceneManager exposes deterministic memory budget diagnostics with
  platform, platform budget bytes, resident runtime scene count, resident
  runtime scene IDs, estimated runtime memory bytes, max resident runtime scene
  count, memory-budget pass/fail, resident-count pass/fail, combined pass/fail,
  and over-budget bytes.
- [x] Platform budgets are normalized to `mobile` = 1,000,000,000 bytes,
  `pc` = 2,000,000,000 bytes, and `console` = 4,000,000,000 bytes; empty or
  unknown platforms fall back to `pc`.
- [x] Diagnostics estimate the current runtime scene, deferred previous scene,
  and pending reused scene through optional `get_estimated_memory_bytes()`;
  scenes without that method count as `0` bytes and do not error.
- [x] Diagnostics update after runtime swaps, quick-return cache hits, and
  deferred unload eviction.
- [x] SceneManager can check the active memory budget and emit
  `on_memory_budget_exceeded(diagnostics)` once when it enters an over-budget
  state, without spamming repeated checks for the same state.
- [x] `enforce_runtime_memory_budget(platform)` evicts non-current deferred
  cache when diagnostics exceed the platform memory budget or resident-count
  budget, preserves the current runtime scene, and reports whether an eviction
  happened.
- [x] Returning to an in-budget state resets the one-shot warning guard so a
  later budget breach can emit a new warning.

## Implementation Notes

- Keep the estimator deterministic and test-local. Use optional scene methods
  rather than platform profiler APIs so GdUnit can exercise the budget logic.
- Keep current runtime scene ownership intact. Emergency enforcement may evict
  only non-current cached runtime scenes in this story.
- Preserve Story006 quick-return behavior and max-two resident cache semantics.
- Emit one Dictionary payload for memory-budget diagnostics; this stays within
  ADR-0002 signal payload rules because the diagnostic object is the event
  contract.

## Out of Scope

- Real platform memory profiler integration.
- Low-memory UI prompt text or presentation routing.
- ResourceLoader cache policy changes.
- Scene request queue coalescing during active loading.
- New visual assets, character art, or frame animation work.

## QA Test Cases

- **AC-1**: Platform diagnostics.
  - Given: one current scene and one deferred cache scene expose deterministic
    memory estimates.
  - When: mobile diagnostics are requested.
  - Then: SceneManager reports the mobile budget, resident scene IDs, total
    estimate, and over-budget bytes.

- **AC-2**: Emergency cache eviction.
  - Given: current + cached scenes exceed the selected memory budget.
  - When: SceneManager enforces the runtime memory budget.
  - Then: only the cached previous scene is evicted and the current scene stays
    attached under the runtime root.

- **AC-3**: Unknown platform fallback.
  - Given: diagnostics are requested for an unknown platform.
  - When: scenes do not expose memory estimators.
  - Then: SceneManager falls back to the PC budget and reports zero estimated
    memory without errors.

- **AC-4**: Warning one-shot.
  - Given: diagnostics are over budget.
  - When: the budget check is called repeatedly.
  - Then: `on_memory_budget_exceeded` emits once until the budget returns to an
    in-budget state.

## Test Evidence

**Story Type**: Logic / Performance
**Required evidence**:
- Unit: `tests/unit/scene/story_010_scene_memory_budget_diagnostics_test.gd`
  must exist and pass.
- Regression: Story003, Story005, Story006, Story007, and Story010 SceneManager
  tests must pass together.
- Runtime: Godot headless smoke and Godot MCP runtime probe must confirm
  SceneManager loads, exposes diagnostics, game/editor logs are clean, and the
  running scene screenshot is nonblank.

**Status**: [x] Complete

**RED evidence**:
- `reports/report_520/`: expected RED, exit `100`, because SceneManager did not
  yet expose `get_memory_budget_diagnostics()`,
  `check_runtime_memory_budget()`, `enforce_runtime_memory_budget()`, or
  `on_memory_budget_exceeded`.

**GREEN / regression evidence**:
- `reports/report_526/`: focused Story010 suite, `7/7` passing, `0` errors,
  `0` failures, `0` orphans.
- `reports/report_527/`: SceneManager regression, `34/34` passing, `0` errors,
  `0` failures, `0` orphans.
- `reports/report_528/`: MainScene transition UI regression, `2/2` passing.
- `reports/report_529/`: MainScene title/load handoff regression, `7/7`
  passing.

**Runtime evidence**:
- Headless smoke log:
  `reports/scene_memory_budget_diagnostics_headless_smoke.log`, exit `0`, no
  error/warning matches.
- Godot MCP autoload probe confirmed `/root/SceneManager` exposes all three new
  methods plus `on_memory_budget_exceeded`, and reports platform budgets:
  mobile `1,000,000,000`, pc `2,000,000,000`, console `4,000,000,000`, unknown
  and empty platform fallback to `pc`.
- Godot MCP isolated runtime-root probe confirmed mobile diagnostics for
  current `main` + previous `hub` scenes estimate `1,700,000,000` bytes,
  `700,000,000` bytes over budget; enforcement evicts only previous cache,
  preserves current scene, and returns diagnostics to `800,000,000` bytes
  in-budget.
- Godot MCP warning latch probe confirmed repeated over-budget checks emit once,
  returning in-budget resets the latch, and a later over-budget check emits a
  second event.
- Godot MCP logs: game log contained only MCP helper and DataManager load lines;
  editor log returned `0` lines.
- MCP screenshot:
  `reports/visual/cinderpaw-mcp-scene-memory-budget-diagnostics-20260625.png`,
  `1280x720`, nonblank, showing the running main scene.

**QA evidence**:
- `production/qa/evidence/scene-memory-budget-diagnostics-2026-06-25.md`

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Platform diagnostics | Story010 GdUnit and MCP autoload/runtime-root probes | PASS |
| Emergency cache eviction | Story010 GdUnit and MCP runtime-root probe | PASS |
| Unknown platform fallback | Story010 GdUnit and MCP autoload probe | PASS |
| Warning one-shot reset | Story010 GdUnit and MCP warning latch probe | PASS |
| MCP runtime availability | MCP probe/log/screenshot | PASS |

## Dependencies

- Depends on: Scene Management Story 006 Complete.
- Unlocks: low-memory UI prompt, platform profiler integration, and final
  SceneManagement performance QA.
