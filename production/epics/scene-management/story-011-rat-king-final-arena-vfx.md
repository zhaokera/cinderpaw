# Story 011: Rat King Final Arena VFX

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature / Presentation Boundary
> **Type**: Visual / Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/combat-presentation.md`,
`design/gdd/scene-management.md`
**Requirements**: `TR-boss-004`, `TR-scene-005`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` -- read fresh at
review time)*

**ADR Governing Implementation**: ADR-0007: Scene management architecture

**Related ADRs**: ADR-0004 Collision Detection, ADR-0019 HealthComponent

**ADR Decision Summary**: MainScene owns Rat King arena mutation runtime nodes.
Story008 created deterministic obstacle/damage-zone nodes and Story009 added
electric leak damage behavior. This story adds authored, generated visual VFX to
those same runtime nodes without moving gameplay rules out of MainScene or
creating another manager.

**Engine**: Godot 4.7 | **Risk**: LOW

**Control Manifest Rules (Feature layer)**:
- Required: boss scene lock and arena mutation reset remain deterministic.
- Required: no synchronous scene switch is introduced for arena polish.
- Required: visual polish must not change electric leak damage, cooldown, or
  collision behavior.
- Required: generated visual assets must be recorded in the asset manifest or QA
  evidence.

---

## Acceptance Criteria

- [x] Phase 2 `garbage_pile`, phase 3 `overturned_trash_can`, and phase 3
  `electric_leak` arena mutation nodes each create a dedicated visible `Vfx`
  child container.
- [x] Each `Vfx` container includes at least one `Sprite2D` child backed by an
  image-generated transparent PNG under `res://assets/environment/rat_king_arena/vfx/`.
- [x] Obstacle mutations use debris/dust impact VFX metadata so they read as
  arena destruction rather than static blocks.
- [x] The `electric_leak` mutation includes separate hazard glow and spark VFX
  roles, with metadata identifying the effect as an electric hazard.
- [x] Reapplying already-applied arena phase changes does not duplicate mutation
  nodes or VFX children.
- [x] Boss death, arena reset, and explicit arena mutation cleanup remove all VFX
  with their parent mutation nodes; reapplying after cleanup restores valid VFX.
- [x] Asset manifest and QA evidence record image-generation prompts, generated
  source paths, runtime import paths, and MCP runtime verification.

## Implementation Notes

- Keep Story008's `ArenaMutations` ownership model. Add VFX as child nodes under
  each mutation rather than creating a global presentation singleton.
- Favor low-risk `Sprite2D` VFX layers for this slice. Particles, shaders, and
  camera choreography can follow once the authored texture layer is stable.
- Preserve existing `CollisionShape2D`, `Sprite`, and low-alpha `Visual`
  children for compatibility with Story008 tests; VFX should add visual
  information without replacing gameplay collision.
- Use semantic metadata on VFX nodes: `change_id`, `vfx_role`, and
  `asset_source`.

## Out of Scope

- New damage tuning, electric leak cooldown changes, or hazard behavior changes.
- Persistent save serialization for destroyed or disabled arena mutations.
- Camera choreography, screen shake, shader distortion, or particle pooling.
- New character frame animation work.

## QA Test Cases

- **AC-1**: VFX container presence.
  - Given: Rat King arena mutations are applied.
  - When: MainScene inspects the mutation nodes.
  - Then: each mutation has a visible `Vfx` container with generated textured
    VFX children.

- **AC-2**: Electric hazard identity.
  - Given: the phase 3 `electric_leak` mutation is active.
  - When: its VFX children are inspected.
  - Then: separate `hazard_glow` and `electric_spark` roles are present and use
    the expected generated asset paths.

- **AC-3**: Reapply idempotence.
  - Given: phase 2 and phase 3 arena changes are already applied.
  - When: the same changes are applied again.
  - Then: mutation count and VFX child counts remain unchanged.

- **AC-4**: Cleanup and reapply.
  - Given: VFX-backed arena mutations are active.
  - When: arena mutation cleanup removes the boss mutations.
  - Then: no VFX nodes remain, and reapplying the changes creates valid VFX
    again.

## Test Evidence

**Story Type**: Visual / Integration
**Required evidence**:
- Unit: `tests/unit/gameplay/rat_king_arena_vfx_polish_test.gd` must exist and
  pass.
- Regression: Story008 and Story009 Rat King arena mutation suites must pass
  with Story011.
- Runtime: Godot headless smoke and Godot MCP must confirm the scene loads,
  logs are clean, VFX nodes are visible, generated textures are loaded, and the
  screenshot is nonblank.

**Status**: [x] Complete

**RED evidence**:
- `reports/report_530/`: expected RED, exit `100`, because Story008/009 arena
  mutations had no `Vfx` child container or generated VFX sprites.

**GREEN / regression evidence**:
- `reports/report_531/`: focused Story011 suite, `4/4` passing, `0` errors,
  `0` failures.
- `reports/report_534/`: final related Story011 + Story008 + Story009 + MainScene
  visual + Rat King runtime regression, `22/22` passing, `0` errors,
  `0` failures.

**Runtime evidence**:
- Headless smoke log:
  `reports/rat_king_final_arena_vfx_headless_smoke.log`, exit `0`, no
  error/warning matches.
- Godot MCP runtime node probe confirmed three active mutation nodes, four VFX
  sprites, generated texture paths and dimensions, `asset_source=image_generation`
  metadata, no duplicate VFX after reapply, cleanup to `0`, and reapply of
  `electric_leak` with two VFX children.
- Godot MCP logs: game log contained only MCP helper and DataManager load lines;
  editor log returned `0` lines after clearing eval-debugger warnings.
- MCP visual fixture screenshot:
  `reports/visual/cinderpaw-mcp-rat-king-final-arena-vfx-20260625.png`,
  `1280x720`, nonblank, visibly showing debris dust, overturned trash can,
  electric hazard glow, and electric sparks in the Rat King arena.

**QA evidence**:
- `production/qa/evidence/rat-king-final-arena-vfx-2026-06-25.md`

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Mutation VFX containers | Story011 GdUnit + MCP node probe | PASS |
| Generated VFX textures | Story011 GdUnit + asset manifest + MCP texture probe | PASS |
| Electric hazard glow/spark roles | Story011 GdUnit + MCP node probe | PASS |
| Reapply idempotence | Story011 GdUnit + MCP node probe | PASS |
| Cleanup/reapply | Story011 GdUnit + MCP cleanup probe | PASS |

## Completion Notes

Story011 is complete as a final arena VFX slice. `MainScene` still owns
deterministic arena mutation gameplay nodes, while each mutation now adds a
texture-backed `Vfx` container with image-generated debris/electric sprites and
stable semantic metadata. Electric leak collision, damage, cooldown, and cleanup
contracts remain unchanged from Story009. Shader, particle-pool, camera, music,
and persistent save-state polish remain later stories.

## Dependencies

- Depends on: Scene Management Story 008 Complete.
- Depends on: Scene Management Story 009 Complete.
- Unlocks: shader/particle/camera boss arena polish and persistent arena
  mutation save-state behavior.
