# Story 012: Boss Arena Mutation Save-State Persistence

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/scene-management.md`, `design/gdd/save-system.md`,
`design/gdd/boss-config.md`
**Requirements**: `TR-scene-004`, `TR-scene-005`, `TR-save-001`,
`TR-save-002`, `TR-save-006`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` -- read fresh at
review time)*

**ADR Governing Implementation**: ADR-0007: Scene management architecture

**Related ADRs**: ADR-0008: Save serialization pattern, ADR-0021: Save system
architecture, ADR-0004: Collision Detection, ADR-0019: HealthComponent

**ADR Decision Summary**: Scene-local state must serialize into save-compatible
world state and restore when the scene loads. MainScene owns the Rat King arena
mutation runtime nodes created by Story008/009/011; this story persists those
active mutation descriptors through the existing SaveSystem runtime handoff.

**Engine**: Godot 4.6.3 | **Risk**: MEDIUM

**Control Manifest Rules (Feature layer)**:
- Required: scene-local state and boss arena reset paths remain deterministic.
- Required: boss battle scene lock prevents scene switching during boss fights.
- Required: save/load APIs remain dependency-injectable for tests.
- Required: save payloads stay JSON-safe; engine values must be converted to
  strings, numbers, arrays, or dictionaries.
- Forbidden: no new Autoload, no synchronous scene switch, and no Presentation
  dependency from SaveSystem or SceneManager.

---

## Acceptance Criteria

- [x] `MainScene.capture_save_snapshot()` includes active Rat King arena
  mutations in `world_state.arena_mutations` as deterministic JSON-safe
  descriptors with boss id, phase, change id, and change type.
- [x] `MainScene.restore_save_snapshot()` rebuilds saved arena mutation nodes
  after cleanup, preserving Story008 collision/metadata contracts, Story009
  electric leak hazard behavior, and Story011 VFX children.
- [x] Runtime `save_runtime_to_slot()` / `load_runtime_from_slot()` persists and
  restores active arena mutations through the injected or Autoload SaveSystem.
- [x] Restoring a saved mutation state is idempotent: repeated restore or
  reapplying the same BossConfig arena changes does not duplicate mutation or VFX
  nodes.
- [x] Boss defeat, arena reset, and explicit cleanup save an empty mutation list
  so defeated/cleared arenas do not resurrect hazards on load.
- [x] Older saves without `arena_mutations` remain loadable and clear stale
  runtime mutation nodes rather than crashing.

## Implementation Notes

- Reuse Story008's `ArenaMutations` container and `apply_arena_changes(...)`
  adapter; persist only descriptors, not Node paths, Resource references,
  cooldown timers, or Vector2 layout values.
- Keep VFX and collision reconstruction centralized in existing mutation builders
  so restored nodes match fresh phase-transition nodes.
- Treat active arena mutations as MainScene scene-local world state. SaveSystem
  still coordinates file I/O and registered serializables; it must not know Rat
  King gameplay rules.
- Clear contact cooldowns when restoring or loading mutation state. Cooldowns are
  runtime-only and should not survive save/load.

## Out of Scope

- New Rat King arena art, particles, shaders, camera choreography, or audio.
- Persisting electric leak contact cooldown timers.
- Persisting Rat Minion summons or Boss AI scheduler internals.
- Changing SaveSystem slot, backup, migration, or async write behavior.
- New character frame animation assets.

## QA Test Cases

- **AC-1**: Snapshot descriptor capture.
  - Given: phase 2 and phase 3 Rat King arena mutations are active.
  - When: MainScene captures a save snapshot.
  - Then: `world_state.arena_mutations` contains three JSON-safe descriptors for
    `garbage_pile`, `overturned_trash_can`, and `electric_leak`.

- **AC-2**: Snapshot restore rebuilds runtime nodes.
  - Given: a snapshot captured with all three mutations active.
  - When: arena mutations are cleaned up and the snapshot is restored.
  - Then: the three mutation nodes return with expected classes, metadata,
    collision, generated sprites, VFX, and electric leak signal wiring.

- **AC-3**: SaveSystem runtime slot persistence.
  - Given: MainScene is configured with a SaveSystem and active arena mutations.
  - When: slot 1 is saved, mutations are cleared, and slot 1 is loaded.
  - Then: MainScene restores the same active mutation set without duplicates.

- **AC-4**: Boss defeat autosave clears mutation state.
  - Given: active mutations exist before Rat King defeat.
  - When: boss defeat triggers slot 0 autosave.
  - Then: the autosave payload records an empty mutation list.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/gameplay/rat_king_arena_mutation_save_state_test.gd`
  must exist and pass.
- Related regression: Story008, Story009, Story011, Save Story004, and MainScene
  save/load menu runtime suites must pass.
- Runtime: Godot headless smoke and Godot MCP must confirm `res://scenes/main.tscn`
  can save/load active arena mutations, logs are clean, restored VFX/hazard nodes
  are visible/inspectable, and the screenshot is nonblank.

**Status**: [x] Complete

Evidence:
- RED: the initial focused run failed before implementation because
  `world_state.arena_mutations` was absent; the transient report was not
  retained in the working tree.
- GREEN focused: `reports/report_577/` passed `6/6`, `0` errors, `0`
  failures, `0` orphans.
- Related regression: `reports/report_578/` passed `26/26`, `0` errors, `0`
  failures, `0` orphans. Godot reported an existing ObjectDB/resource cleanup
  warning at process exit; the focused Story012 suite is clean.
- Title/load handoff guard: `reports/report_579/` passed `7/7`, confirming the
  same-scene load short-circuit does not break menu save-load handoff.
- Headless smoke: `reports/boss_arena_mutation_save_state_main_scene_smoke.log`
  from `res://scenes/main.tscn` had no error/warning keyword matches.
- Godot MCP: runtime probe saved slot 1, cleaned mutations, loaded slot 1, and
  restored `3` mutation nodes with Story008/009/011 contracts intact. Logs were
  clean and screenshot was saved to
  `reports/visual/cinderpaw-mcp-arena-mutation-save-state-20260625.png`.
- QA evidence:
  `production/qa/evidence/boss-arena-mutation-save-state-persistence-2026-06-25.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Snapshot descriptor capture | `test_save_snapshot_captures_active_arena_mutations_json_safe` | PASS |
| Snapshot restore rebuilds nodes | `test_restore_save_snapshot_rebuilds_mutations_with_vfx_and_idempotence` | PASS |
| SaveSystem slot load restores mutations | `test_save_system_slot_load_restores_active_arena_mutations` | PASS |
| Defeat autosave clears mutation list | `test_boss_defeat_autosave_records_empty_arena_mutations` | PASS |
| Older snapshot clears stale nodes | `test_restore_older_snapshot_without_arena_mutations_clears_stale_nodes` | PASS |
| Defeated Rat King state clears stale saved mutations | `test_restore_snapshot_with_defeated_rat_king_clears_saved_mutations` | PASS |
| MCP runtime save/load probe | `game_eval` on `res://scenes/main.tscn` | PASS |

## Dependencies

- Depends on: Scene Management Story 008 Complete.
- Depends on: Scene Management Story 009 Complete.
- Depends on: Scene Management Story 011 Complete.
- Depends on: Save System Story 004 Complete.
- Unlocks: Rat King boss arena persistence polish, broader save/load runtime QA,
  and later shader/camera arena polish.
