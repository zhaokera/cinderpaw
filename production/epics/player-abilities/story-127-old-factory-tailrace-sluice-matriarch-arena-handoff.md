# Story 127: Old Factory Tailrace Sluice Matriarch Arena Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Feature / Gameplay Runtime / Scene Management / Presentation
> **Type**: Integration + Gameplay Runtime + Visual
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-11

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/art/art-bible.md`

**Requirements**: `TR-ability-003`, `TR-explore-002`, `TR-scene-001`,
`TR-scene-002`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0002 Signal Communication; ADR-0007
Scene Management; ADR-0018 Player Abilities; ADR-0021 Save System.

Story126 ends the current Tailrace route with a distinct Sluice Leech combat
beat. Extending the same horizontal Factory scene again would add distance
without advancing the game. The GDD instead places an `aerial_attack` gate on
the Factory-to-underground route and grants that ability only after Boss3.
Story127 therefore turns the Sluice Leech clear into a real asynchronous handoff
to a dedicated Sluice Matriarch arena scene. The arena is an authored,
image-generated destination with a functional return route; Boss3 combat lands
in the immediately following story.

## Acceptance Criteria

- [x] `FactoryTailraceSluiceMatriarchRoute` exists in
  `factory_route_transition_shell.tscn` near the Story126 combat pocket. It uses
  `RouteTransitionShell`, targets `boss_03_sluice_matriarch_arena / boss_entry`,
  shows `Defeat Sluice Leech` while locked, and shows
  `Enter Sluice Matriarch Lair` after Story126 is cleared.
- [x] Factory contact with the available route requests
  `SceneManager.request_scene_change()` exactly once, exposes deterministic
  pending/rejection diagnostics, and rejects missing/loading/locked/unknown
  SceneManager states without latching the route requested state.
- [x] `data/scene_registry.json` and its schema register
  `boss_03_sluice_matriarch_arena` at
  `res://scenes/bosses/sluice_matriarch_arena.tscn` as a non-preloaded
  `boss_arena` with default spawn `boss_entry` and display name
  `Sluice Matriarch Lair`.
- [x] The arena scene contains Cinderpaw at a named `BossEntrySpawn`, a bounded
  floor and side walls, a player Camera2D, a route/objective label, and an
  authored full-screen environment backdrop. No visible ColorRect,
  Polygon2D, or plain block stands in for the arena art.
- [x] The arena backdrop is an imported opaque `1280x720` PNG generated through
  built-in image generation. Source, runtime output, prompt/processing record,
  manifest entry, and QA evidence are retained in the project asset pipeline.
- [x] `FactoryReturnRoute` in the arena targets
  `area_03_factory / tailrace_matriarch_gate_return`, automatically requests
  the return transition on player contact, and rejects duplicate requests.
- [x] Returning to Factory places Cinderpaw at
  `FactoryTailraceSluiceMatriarchReturnSpawn`, keeps Story126 cleared and the
  enemy hidden, preserves the Story119 Tailrace Relay checkpoint, and leaves
  the Matriarch route available for re-entry.
- [x] Focused/related GdUnit, one targeted headless smoke, and Godot MCP runtime
  checks pass under Godot 4.7 / Godot AI MCP 2.9.1. MCP confirms both scenes,
  actual transition request state, clean current-run logs, and non-empty
  screenshots of the Factory gate and authored arena.

## Out of Scope

- Sluice Matriarch boss AI, character frames, HP/HUD, room seals, phase logic,
  defeat handling, rewards, aerial-attack unlock, cutscene, authored audio, or
  underground-passage gameplay. These form Story128 and later slices.
- New Autoloads, synchronous scene changes, SaveSystem schema changes, minimap
  UI, fast travel, or refactoring the full Old Factory route controller.
- Further extension of the 18,140-pixel Factory corridor beyond the small
  transition marker and return spawn already inside the Story126 bounds.

## Implementation Notes

- Reuse `RouteTransitionShell` and the existing deep-bulkhead gate art for the
  Factory and arena endpoints. The only new visual asset is the arena backdrop.
- Keep transition-request flags transient. Scene-local persistence continues to
  own Story126 clear state; returning from the arena must not restore a stale
  `transition_requested=true` latch.
- The arena root script owns only spawn alignment, contact-driven return, route
  diagnostics, and SceneManager integration. Boss combat remains a separate
  bounded implementation surface.
- The generated backdrop should show a side-view tailrace pressure cathedral,
  a dormant giant leech cocoon silhouette, readable floor plane, blue exit
  lighting, rusted steel, damp pipes, and restrained mutation seams without
  embedding text or UI into the image.

## QA Test Cases

- **AC-1: Factory-to-arena transition**
  - Given: Story126 is locked or restored cleared.
  - When: Cinderpaw reaches the Tailrace Matriarch route.
  - Then: locked state never requests; cleared state requests the registered
    arena and `boss_entry` once through asynchronous SceneManager.
- **AC-2: Authored arena and return**
  - Given: the arena scene is loaded at `boss_entry`.
  - When: Cinderpaw inspects the arena and reaches `FactoryReturnRoute`.
  - Then: the generated backdrop and bounded gameplay surface are visible, and
    return requests `area_03_factory / tailrace_matriarch_gate_return` once.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_tailrace_sluice_matriarch_arena_handoff_test.gd`
- `tests/smoke/old_factory_tailrace_sluice_matriarch_arena_handoff_smoke.gd`
- `production/qa/evidence/old-factory-tailrace-sluice-matriarch-arena-handoff-2026-07-11.md`

**Status**: [x] RED/GREEN focused evidence, related regression, targeted smoke,
Godot import, and MCP bidirectional runtime evidence complete.

- RED focused: `reports/report_1391/` captured the missing arena, route,
  registry, and backdrop contracts.
- GREEN focused: `reports/report_1393/` passed Story127 `2/2` after correcting
  the test-only Godot 4.7 `Image.detect_alpha()` enum expectation.
- Related GREEN: `reports/report_1395/` passed Story127, Story126, and the two
  relevant SceneManager suites `17/17`.
- Headless smoke:
  `reports/old_factory_tailrace_sluice_matriarch_arena_handoff_smoke.log`
  exited `0` and printed
  `old_factory_tailrace_sluice_matriarch_arena_handoff_smoke=passed`.
- Godot MCP evidence:
  `production/qa/evidence/old-factory-tailrace-sluice-matriarch-arena-handoff-2026-07-11.md`.

## Dependencies

- Depends on: Story126 Old Factory Tailrace Exit Spillway Sluice Leech
  Skirmish.
- Unlocks: Story128 Sluice Matriarch Boss3 playable combat slice.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Story126-gated Factory route, labels, one-shot request, and rejection diagnostics | `reports/report_1393`; smoke; MCP Factory eval | COVERED |
| Registry/schema entry and actual SceneManager tree swap | `reports/report_1395`; smoke; MCP transition eval | COVERED |
| Authored bounded arena, spawn, camera, backdrop, and no visible placeholder blocks | Focused GdUnit; image audit; MCP hierarchy/screenshot | COVERED |
| Arena return request and exact Factory return spawn | Focused GdUnit; smoke; MCP round-trip eval | COVERED |
| Story126 clear and Story119 checkpoint preservation | `reports/report_1395`; smoke clear-state check; MCP restore eval | COVERED |
| Godot 4.7 import, clean MCP current run, and non-empty screenshots | QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-07-11
**Criteria**: 8/8 passing
**Deviations**: The Factory gate and arena return endpoint reuse existing
image-generated route-shell/deep-bulkhead art as planned; the only new visual is
the dedicated arena backdrop. The active Sluice Matriarch is intentionally not
represented by a static prop: boss frames, AI, HUD, seals, phases, defeat, and
reward remain Story128 scope. Two Story126 label assertions were updated from
the old terminal clear text to the new next objective after related regression
proved the gameplay behavior itself remained intact.
**QA Evidence**:
`production/qa/evidence/old-factory-tailrace-sluice-matriarch-arena-handoff-2026-07-11.md`
