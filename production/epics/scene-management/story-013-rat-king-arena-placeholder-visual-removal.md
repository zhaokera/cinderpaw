# Story 013: Rat King Arena Placeholder Visual Removal

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Presentation Boundary
> **Type**: Visual / Integration
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/scene-management.md`, `design/gdd/boss-config.md`,
`design/gdd/combat-presentation.md`
**Requirements**: `TR-scene-005`, `TR-boss-004`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` -- read fresh at
review time)*

**ADR Governing Implementation**: ADR-0007: Scene management architecture

**Related ADRs**: ADR-0004 Collision Detection, ADR-0019 HealthComponent

**ADR Decision Summary**: MainScene owns deterministic Rat King arena mutation
runtime nodes during boss phase transitions. Story008 created collision and
damage-zone nodes, Story009 added electric leak contact damage, Story011 added
image-generated VFX, and Story012 persisted active mutation state. This story
removes the remaining player-visible low-alpha placeholder shape so arena
mutations render through imported generated sprites and VFX only.

**Engine**: Godot 4.6.3 | **Risk**: LOW

**Control Manifest Rules (Feature layer)**:
- Required: boss scene lock and arena mutation reset remain deterministic.
- Required: no synchronous scene switching is introduced for arena visual polish.
- Required: visual cleanup must not change collision, electric leak damage,
  cooldown, VFX, save/load, or arena cleanup behavior.
- Required: Godot MCP must validate runtime node visibility and logs after the
  scene-facing change.

---

## Acceptance Criteria

- [x] Rat King phase 2/3 arena mutation nodes no longer create a visible
  `Polygon2D` or `ColorRect` placeholder child.
- [x] Runtime mutations still create generated `Sprite2D` visuals using the
  imported `rat_king_arena_mutations` PNG assets.
- [x] Runtime mutations still create Story011 `Vfx` children with generated
  debris/electric VFX sprites.
- [x] Story008 collision metadata and Story009 electric leak contact damage
  behavior remain intact.
- [x] Story012 save/load restore rebuilds mutations without visible placeholder
  nodes and without duplicating VFX.
- [x] Godot MCP runtime validation confirms three active arena mutations, no
  visible placeholder visuals, clean game/editor logs, and a nonblank screenshot.

## Implementation Notes

- Keep `_add_arena_mutation_visual(...)` as a compatibility seam for the
  Story008 builder call path, but make it a no-op so gameplay logic and test
  entry points remain stable.
- Do not change collision shapes, node classes, metadata, damage-zone wiring,
  or the image-generated `Sprite` and `Vfx` children.
- Reuse existing image-generated arena mutation and VFX assets. No new visual
  asset generation is required for this cleanup slice.

## Out of Scope

- New arena mutation art, particles, shaders, camera choreography, or audio.
- New Rat King or player character frame animation assets.
- New boss phase scheduling, damage tuning, save schema, or SceneManager
  transition behavior.

## QA Test Cases

- **AC-1**: Placeholder removal.
  - Given: Rat King phase 2/3 arena mutations are active.
  - When: mutation children are inspected.
  - Then: no visible `Polygon2D` or `ColorRect` placeholder child exists.

- **AC-2**: Runtime visual contract remains textured.
  - Given: the same mutations are active.
  - When: `Sprite` and `Vfx` children are inspected.
  - Then: each mutation has a generated `Sprite2D`, and electric leak keeps two
    VFX children while obstacle mutations keep debris VFX.

- **AC-3**: Gameplay contracts stay intact.
  - Given: electric leak contact damage and save/load restore tests run.
  - When: placeholders are removed.
  - Then: collision, damage, cooldown cleanup, persistence, and idempotence
    still pass.

## Test Evidence

**Story Type**: Visual / Integration
**Required evidence**:
- Regression: `tests/unit/gameplay/rat_king_arena_mutation_runtime_test.gd`,
  `tests/unit/gameplay/rat_king_arena_mutation_save_state_test.gd`, and
  `tests/unit/gameplay/rat_king_arena_vfx_polish_test.gd` must pass with no
  visible placeholder child assertions failing.
- Related regression: electric leak contact damage and MainScene visual contract
  suites must pass.
- Runtime: Godot headless smoke and Godot MCP must confirm `res://scenes/main.tscn`
  runs, logs are clean, generated Sprite2D/VFX nodes are present, no visible
  placeholder child exists, and the screenshot is nonblank.

**Status**: [x] Complete

**RED evidence**:
- `reports/report_608/`: expected RED, exit `100`, because the old runtime
  builder still created visible `Polygon2D` children named `Visual`.

**GREEN / regression evidence**:
- `reports/report_609/`: initial focused Story008/011/012 regression, `14/14`
  passing, `0` errors, `0` failures.
- `reports/report_610/`: final focused + related regression, `23/23` passing,
  `0` errors, `0` failures, `0` orphans. Covered arena mutation runtime,
  save-state restore, VFX polish, electric leak contact damage, and MainScene
  visual contract. Godot process exit still reported the existing
  ObjectDB/resource cleanup warning; test results were clean.

**Runtime evidence**:
- Headless smoke:
  `reports/rat_king_arena_placeholder_visual_removal_smoke.log` from
  `res://scenes/main.tscn`, exit `0`, with no script/resource/node error keyword
  matches.
- Godot MCP runtime probe on `res://scenes/main.tscn` confirmed `3` active
  mutation nodes:
  - `ArenaMutation_garbage_pile`: `StaticBody2D`, generated sprite,
    `1` VFX child, `visible_placeholders=[]`.
  - `ArenaMutation_overturned_trash_can`: `StaticBody2D`, generated sprite,
    `1` VFX child, `visible_placeholders=[]`.
  - `ArenaMutation_electric_leak`: `Area2D`, generated sprite, `2` VFX
    children, `visible_placeholders=[]`.
- Godot MCP game log contained only MCP helper/DataManager informational lines;
  editor log returned `0` lines after the successful probe.
- MCP screenshot:
  `reports/visual/cinderpaw-mcp-rat-king-arena-placeholder-visual-removal-20260626.png`,
  `1280x720`, save result `0`, nonblank.

**QA evidence**:
- `production/qa/evidence/rat-king-arena-placeholder-visual-removal-2026-06-26.md`

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| No visible placeholder child | Story008/011/012 GdUnit assertions + MCP probe | PASS |
| Generated Sprite2D visuals remain | Story008 GdUnit + MCP probe | PASS |
| VFX children remain | Story011 GdUnit + MCP probe | PASS |
| Electric leak damage intact | `rat_king_electric_leak_contact_damage_test.gd` | PASS |
| Save/load restore intact | `rat_king_arena_mutation_save_state_test.gd` | PASS |
| Runtime logs/screenshot | MCP game/editor logs + screenshot | PASS |

## Completion Notes

Story013 removes the remaining shape-based placeholder presentation from Rat
King arena mutations. Collision and damage-zone nodes still exist for gameplay,
but the player-facing visual layer is now the generated `Sprite2D` prop plus
Story011 generated VFX only.

## Dependencies

- Depends on: Scene Management Story 008 Complete.
- Depends on: Scene Management Story 009 Complete.
- Depends on: Scene Management Story 011 Complete.
- Depends on: Scene Management Story 012 Complete.
- Unlocks: later shader/camera arena polish and richer authored arena VFX.
