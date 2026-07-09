# Story 102: Old Factory Route Floor Platform Visual Pass

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Visual
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-09

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/art/art-bible.md`

**Requirements**: `TR-ability-003`, `TR-explore-001`, `TR-explore-006`,
`TR-scene-001`

**ADR Governing Implementation**: ADR-0004 Scene Tree Composition; ADR-0005
Combat State Machine; ADR-0007 Scene Management; ADR-0018 Player Abilities;
ADR-0021 Save System.

The Old Factory route has accumulated playable ACT content, enemies, hazards,
savepoints, rewards, and route handoffs, but the long route floor and the early
combat platforms still read as collision blocks in the player-facing view.
Story102 replaces those visible floor/platform placeholders with generated
factory metal sprites while preserving the existing 7040px route collision,
platform collisions, cache behavior, route state, and save/runtime contracts.

## Acceptance Criteria

- [x] `Ground` in `res://scenes/factory_route_transition_shell.tscn` has visible
  generated floor sprites covering at least the full 7040px collision width.
- [x] `EntryPlatform` and `FactoryCachePlatform` each have a visible generated
  platform sprite under `assets/environment/old_factory_route_platform/`.
- [x] The floor and platform textures are transparent PNGs imported through
  Godot, with source, alpha, runtime paths, prompt summary, and usage recorded
  in the asset manifest and QA evidence.
- [x] The new floor/platform visuals do not use `ColorRect`, `Polygon2D`, pure
  color rectangles, or one-off debug blocks as player-facing art.
- [x] Existing route behavior remains intact: player spawn, long route width,
  entry/cache platform collision, room-clear cache, service lift, and route
  save-state contracts are unchanged.
- [x] Runtime diagnostics expose floor tile count, texture paths, texture sizes,
  world coverage, platform world sizes, collision width, and placeholder checks
  for tests and Godot MCP probes.
- [x] Godot MCP verifies the factory scene runs, the three visual groups exist
  with generated textures, logs have no new current-run script/resource errors,
  and a non-empty screenshot clearly shows the route floor/platform visuals.

## Out of Scope

- New route geometry, enemy placement, AI, ability unlocks, reward economy,
  save schema, minimap/fast travel, authored audio, or particle/shader polish.
- New or changed character animation. This story adds environment floor and
  platform sprites only; the AGENTS character frame-animation rule is not
  triggered.
- Full Old Factory tileset replacement or biome-wide art pass.

## Implementation Notes

- The floor uses 28 repeated `Sprite2D` tiles using
  `res://assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`,
  covering 7168px of the 7040px collision span.
- `EntryPlatform/FactoryRouteEntryPlatformVisual` uses
  `res://assets/environment/old_factory_route_platform/env_old_factory_route_entry_platform_320x96.png`.
- `FactoryCachePlatform/FactoryRouteCachePlatformVisual` uses
  `res://assets/environment/old_factory_route_platform/env_old_factory_route_cache_platform_320x96.png`.
- `OldFactoryEntranceScene.get_factory_route_visual_diagnostics()` is a
  diagnostics-only API for tests and MCP. It does not change collision,
  gameplay state, or save data.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/old_factory_route_floor_platform_visual_pass_test.gd`
- `tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd`
- `tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd`
- `tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd`
- `tests/unit/gameplay/factory_route_runtime_roundtrip_test.gd`
- Headless factory scene smoke
- Godot MCP runtime evidence under
  `production/qa/evidence/old-factory-route-floor-platform-visual-pass-2026-07-09.md`

**Status**: [x] RED/GREEN focused evidence, related regression, import,
headless smoke, and MCP runtime evidence complete.

- RED focused: `reports/report_1264/` failed as expected because
  `OldFactoryEntranceScene.get_factory_route_visual_diagnostics()` did not exist
  yet.
- Godot import:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --import --quit`
  exited `0` and imported the new runtime/source PNG files.
- GREEN focused: `reports/report_1265/` passed Story102 route floor/platform
  visual coverage `1/1`.
- Related regression: `reports/report_1267/` passed Story102 plus factory route,
  entrance combat, room-clear cache, and route roundtrip coverage `12/12`.
- Headless smoke:
  `reports/old_factory_route_floor_platform_visual_pass_smoke.log` exited `0`.
- Godot MCP evidence:
  `production/qa/evidence/old-factory-route-floor-platform-visual-pass-2026-07-09.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Floor visuals cover at least 7040px | `report_1265`, MCP probe | COVERED |
| Entry/cache platform visuals use generated textures | `report_1265`, MCP probe | COVERED |
| No placeholder visible rectangle art | `report_1265`, MCP probe | COVERED |
| Route/cache/roundtrip behavior preserved | `report_1267` | COVERED |
| Image generation and import documented | Asset manifest; QA evidence | COVERED |
| Runtime scene, current-run errors, and screenshot verified through MCP | Headless smoke; QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-07-09
**Criteria**: 7/7 passing
**Deviations**: MCP editor hierarchy briefly showed a stale in-memory scene tree,
so no MCP `scene_save` was used. Disk file reads, headless tests, headless smoke,
and MCP `project_run` runtime probes all confirmed the submitted scene state.
**QA Evidence**:
`production/qa/evidence/old-factory-route-floor-platform-visual-pass-2026-07-09.md`
