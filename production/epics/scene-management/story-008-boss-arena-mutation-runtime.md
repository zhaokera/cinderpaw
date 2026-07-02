# Story 008: Boss Arena Mutation Runtime

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/scene-management.md`
**Requirements**: `TR-boss-004`, `TR-scene-005`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at review time)*

**ADR Governing Implementation**: ADR-0007: Scene management architecture

**ADR Decision Summary**: SceneManager owns boss scene locking and scene
coordination. BossConfigComponent requests phase arena changes through a scene
adapter; this story connects that adapter to the playable MainScene runtime.

**Engine**: Godot 4.7 | **Risk**: LOW

**Control Manifest Rules (Feature layer)**:
- Required: boss battle scene lock prevents scene switching during boss fights.
- Required: scene-local state and boss arena reset paths remain deterministic.
- Required: no synchronous scene switch is introduced for arena mutation.
- Required: runtime changes stay under Feature layer ownership and do not push
  Presentation code upward into Core/Feature systems.

---

## Acceptance Criteria

- [x] RatKingBoss passes a SceneManager-compatible arena adapter to
  BossConfigComponent when mounted in MainScene.
- [x] Phase 2 arena change `garbage_pile` creates a visible obstacle runtime
  node under a dedicated arena mutation container.
- [x] Phase 3 arena changes create an `overturned_trash_can` obstacle and an
  `electric_leak` damage-zone runtime node without duplicating already-applied
  phase changes.
- [x] Runtime arena mutation nodes expose stable metadata for boss id, phase,
  change id, and change type so save/reset/debug systems can inspect them.
- [x] Boss death, arena reset, and MainScene cleanup remove all active arena
  mutation nodes and clear internal applied-change state.
- [x] Existing boss scene lock/unlock and phase transition presentation/audio
  routing remain source-compatible.

## Implementation Notes

- Reuse the BossConfigComponent scene adapter method
  `apply_arena_changes(boss_id, phase, changes)`.
- MainScene should own runtime nodes in a dedicated `ArenaMutations` container,
  similar to the existing `Summons` container ownership pattern.
- Runtime obstacles are lightweight Godot physics nodes with deterministic
  collision shapes, metadata, generated PNG sprites, and a low-alpha Polygon2D
  debug silhouette; they are not ColorRect-only gameplay blockers.
- Damage-zone behavior may be metadata-only in this story if no player contact
  damage loop exists yet; it must still be represented as a runtime node with
  collision shape and deterministic metadata.
- Generated PNG props are included only to remove square/block placeholders from
  the playable arena mutation runtime; final particles, shader polish, and
  contact-damage gameplay remain later stories.

## Out of Scope

- Per-pixel arena VFX, particles, shader work, or camera choreography.
- Player contact damage from the electric leak.
- New scene streaming, boss-room scene split, or platform memory profiler work.
- Save serialization of persistent destroyed arena mutation state.

## QA Test Cases

- **AC-1**: MainScene exposes the scene adapter contract.
  - Given: MainScene instantiates RatKingBoss.
  - When: the boss enters phase 2.
  - Then: BossConfigComponent calls MainScene `apply_arena_changes(...)`.

- **AC-2**: Phase 2 creates a garbage pile obstacle.
  - Given: Rat King HP crosses the 66% threshold.
  - When: phase transition runtime advances.
  - Then: `ArenaMutations` contains one visible `garbage_pile` obstacle node
    with boss id and phase metadata.

- **AC-3**: Phase 3 creates obstacle and damage-zone nodes without duplicates.
  - Given: phase 2 mutation already exists.
  - When: Rat King HP crosses the 33% threshold and the transition is advanced
    more than once.
  - Then: `ArenaMutations` contains exactly one `overturned_trash_can` obstacle
    and one `electric_leak` damage zone.

- **AC-4**: Death/reset cleanup.
  - Given: phase 2 and phase 3 mutations are active.
  - When: boss death cleanup or arena reset runs.
  - Then: all mutation nodes are removed and reapplied phase changes can be
    spawned again in a fresh encounter.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/gameplay/rat_king_arena_mutation_runtime_test.gd`
  must exist and pass.

**Status**: [x] RED/GREEN complete

**Evidence**:
- RED: `reports/report_501/` failed on missing MainScene arena mutation adapter
  methods and missing `ArenaMutations` runtime container.
- GREEN focused: `reports/report_506/`, `4/4` passing, `0` errors,
  `0` failures.
- Related regression: `reports/report_509/`, `24/24` passing across Story008,
  BossConfig arena adapter, Rat King runtime contract, live summon runtime, and
  MainScene visual contract.
- Headless smoke: `reports/rat_king_arena_mutation_main_scene_smoke.log`,
  Godot exited `0`; error/warning scan returned no matches.
- MCP runtime: running `res://scenes/main.tscn` created three arena mutation
  nodes with expected classes, metadata, collision, Polygon2D visuals, Sprite2D
  children, generated texture resource paths, cleanup/reapply/reset behavior,
  and clean game logs.
- QA evidence:
  `production/qa/evidence/rat-king-arena-mutation-runtime-2026-06-25.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| MainScene scene adapter contract | `test_main_scene_exposes_boss_arena_mutation_adapter_contract`; MCP runtime probe | PASS |
| Phase 2 creates garbage pile obstacle | `test_phase_two_creates_garbage_pile_obstacle_runtime_node`; MCP runtime probe | PASS |
| Phase 3 creates obstacle and damage zone once | `test_phase_three_creates_overturned_trash_and_electric_leak_once`; MCP runtime probe | PASS |
| Death/reset cleanup removes mutations | `test_boss_death_and_arena_reset_clear_arena_mutations`; MCP cleanup/reset probe | PASS |

## Dependencies

- Depends on: Boss Configuration Story 004 Complete.
- Depends on: Boss Configuration Story 007 Complete.
- Depends on: Boss Configuration Story 009 Complete.
- Unlocks: final arena art/VFX, electric leak damage behavior, and boss arena
  save-state persistence stories.

## Completion Notes

Story008 is complete as a runtime integration slice. `RatKingBoss` forwards a
scene adapter to `BossConfigComponent`; `MainScene` owns `ArenaMutations`,
creates generated visual props as `StaticBody2D`/`Area2D` runtime nodes, avoids
duplicate phase application, and cleans mutation state on boss death, arena
reset, and scene cleanup. Final VFX, electric leak contact damage, and persistent
arena mutation save state remain future work.
