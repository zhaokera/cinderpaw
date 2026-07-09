# Story 103: Main Scene Boundary Wall Visual Pass

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + Visual
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-09

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`,
`design/art/art-bible.md`

**Requirements**: `TR-explore-001`, `TR-explore-006`, `TR-scene-001`,
`TR-presentation-001`

**ADR Governing Implementation**: ADR-0004 Scene Tree Composition; ADR-0005
Combat State Machine; ADR-0007 Scene Management; ADR-0018 Player Abilities.

Story100 replaced the MainScene Dash gate placeholder. Story103 continues the
same player-visible art cleanup by replacing the main scene's old wall
`ColorRect` presentation nodes with generated vertical boundary wall sprites
while preserving collision bounds, platform layout, Dash gate behavior, Boss2
state, HUD, and save/runtime contracts.

## Acceptance Criteria

- [x] `LeftWall/BoundaryWallVisual` and `RightWall/BoundaryWallVisual` exist in
  `res://scenes/main.tscn` as visible `Sprite2D` nodes.
- [x] Both wall sprites use
  `res://assets/environment/main_scene_boundary_wall/main_scene_boundary_wall_96x720.png`,
  a transparent imported PNG generated through image generation.
- [x] The left wall uses the normal sprite orientation and the right wall uses
  horizontal flip, keeping a matched side-boundary language without a second
  generated file.
- [x] The old `LeftWall/WallVisual` and `RightWall/WallVisual` `ColorRect`
  presentation nodes are removed from the scene file.
- [x] Wall collisions, player spawn, ground/platform visuals, Dash gate,
  Double Jump gate, Boss2 arena, and HUD visual contract remain unchanged.
- [x] Source, alpha, runtime path, prompt summary, import status, and usage are
  recorded in asset manifest and QA evidence.
- [x] Godot MCP verifies the main scene runs, both wall sprites exist with the
  generated texture, logs have no new current-run script/resource errors, and a
  non-empty screenshot shows the authored boundary wall.

## Out of Scope

- Full MainScene tileset replacement, camera layout, Boss2 scale/framing, prompt
  label layout, HUD redesign, new gameplay routes, or save schema changes.
- New character or enemy animation. Story103 adds environment boundary art only;
  the AGENTS character frame-animation rule is not triggered.

## Implementation Notes

- `main_scene_boundary_wall_96x720.png` is a reusable transparent wall strip.
  `RightWall/BoundaryWallVisual` flips it horizontally through `Sprite2D.flip_h`.
- The existing `RectangleShape2D_wall` collision remains `40x720`.
- The new sprites use `z_index = 8` and `z_as_relative = false`, placing them
  above the background and below the `z_index = 10` ground/platform collision
  visuals.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/main_scene_boundary_wall_visual_pass_test.gd`
- `tests/unit/gameplay/main_scene_visual_contract_test.gd`
- `tests/unit/gameplay/main_scene_dash_gate_authored_visual_test.gd`
- `tests/unit/gameplay/exploration_dash_gate_runtime_test.gd`
- Headless main-scene smoke
- Godot MCP runtime evidence under
  `production/qa/evidence/main-scene-boundary-wall-visual-pass-2026-07-09.md`

**Status**: [x] RED/GREEN focused evidence, related regression, import,
headless smoke, and MCP runtime evidence complete.

- RED focused: `reports/report_1268/` failed as expected because
  `BoundaryWallVisual` Sprite2D nodes did not exist and `WallVisual` ColorRects
  were still present.
- Godot import:
  `"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --import --quit`
  exited `0` and imported the new runtime/source PNG files.
- GREEN focused: `reports/report_1269/` passed Story103 boundary-wall visual
  replacement coverage `1/1`.
- Related regression: `reports/report_1270/` passed Story103, main-scene visual
  contract, authored Dash gate, and Dash gate runtime coverage `9/9`.
- Headless smoke:
  `reports/main_scene_boundary_wall_visual_pass_smoke.log` exited `0`.
- Godot MCP evidence:
  `production/qa/evidence/main-scene-boundary-wall-visual-pass-2026-07-09.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Left/right boundary walls are visible Sprite2D nodes | `report_1269`, MCP probe | COVERED |
| Generated texture path, size, import, z order, and flip contract | `report_1269`, asset manifest, MCP probe | COVERED |
| Old ColorRect wall visuals removed | `report_1268`, `report_1269`, MCP probe | COVERED |
| MainScene visual and Dash gate contracts remain green | `report_1270` | COVERED |
| Runtime scene, current-run logs, and screenshot verified through MCP | Headless smoke; QA evidence | COVERED |

## Completion Notes

**Completed**: 2026-07-09
**Criteria**: 7/7 passing
**Deviations**: None.
**QA Evidence**:
`production/qa/evidence/main-scene-boundary-wall-visual-pass-2026-07-09.md`
