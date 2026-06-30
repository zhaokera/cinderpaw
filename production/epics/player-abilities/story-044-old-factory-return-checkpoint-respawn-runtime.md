# Story 044: Old Factory Return Checkpoint Respawn Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Death & Respawn / Scene Management
> **Type**: Integration + Gameplay Runtime + Scene Management
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-ability-005`, `TR-scene-001`, `TR-scene-003`,
`TR-scene-005`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system.

Story043 added the visible Old Factory return checkpoint and made
`GameFlowController` select it for non-boss death. The remaining player-facing
gap was runtime landing: with a real `SceneManager`, death needed to request an
actual runtime scene swap to `area_03_factory / return_checkpoint` and then
place Cinderpaw on the checkpoint in the loaded Factory scene.

## Acceptance Criteria

- [x] Non-boss death after activating `FactoryReturnCheckpoint` requests a real
  `SceneManager.request_scene_change("area_03_factory", "return_checkpoint")`
  when that API is available.
- [x] Existing adapters that only expose `change_scene()` remain compatible for
  older respawn-selection tests and lightweight fakes.
- [x] After async load completes, the runtime scene root contains
  `FactoryRouteTransitionShellScene`, `SceneManager.current_scene` is
  `area_03_factory`, and `SceneManager.current_spawn_point` is
  `return_checkpoint`.
- [x] If the current runtime scene is already Factory, reloading Factory through
  the checkpoint preserves scene-local checkpoint, return-patrol, and
  service-lift state before applying the return-checkpoint landing.
- [x] The loaded Factory scene applies the `return_checkpoint` spawn from
  `SceneManager`, moving `Player` to `FactoryReturnCheckpoint`.
- [x] `RouteLabel` displays `Returned to Factory Savepoint` after the runtime
  respawn landing.
- [x] Existing savepoint selection, Factory route roundtrip, service-lift exit,
  and respawn visual regressions remain green.
- [x] Godot MCP 4.7 runtime confirms the Factory scene runs, target nodes exist,
  return-checkpoint landing diagnostics are correct, logs are clean, and a
  nonblank screenshot is captured.

## Out of Scope

- New checkpoint art, SaveSystem slot schema changes, minimap markers,
  fast-travel UI, new Old Factory rooms, new enemies, new audio, service-lift
  animation, Factory-owned production death-signal wiring, or broader
  death/respawn redesign.

## Implementation Notes

- `GameFlowController._apply_scene_transition()` now prefers
  `request_scene_change()` when the transition adapter supports it, and falls
  back to the existing `change_scene()` contract for older tests/fakes.
- `SceneManager._finish_pending_load()` refreshes
  `configure_scene_manager_runtime(self)` after logical scene commit so a newly
  loaded runtime scene can read the final current scene/spawn pair.
- `OldFactoryEntranceScene` applies only `area_03_factory` spawn points from the
  active scene manager. `factory_gate_entry` uses the existing gate spawn;
  `return_checkpoint` moves the player to the checkpoint and updates the route
  label.

## Asset Pipeline

No new visual assets were generated. This story reuses the Story043
image-generated checkpoint asset:

- `res://assets/environment/old_factory_return_checkpoint/old_factory_return_checkpoint.png`
- `res://assets/generated/source/old_factory_return_checkpoint_imagegen_20260630.png`
- `res://assets/generated/source/old_factory_return_checkpoint_alpha_20260630.png`
- `res://assets/generated/source/old_factory_return_checkpoint_imagegen_20260630.json`

## Test Evidence

- Focused RED:
  - `reports/old_factory_return_checkpoint_runtime_swap_red.log` /
    `reports/report_960/` failed after adding the runtime-root swap assertion:
    the old flow called logical `change_scene()` only, `SceneManager` was not
    loading, and the runtime root still contained Main.
- Focused GREEN:
  - `reports/old_factory_return_checkpoint_respawn_runtime_green.log` /
    `reports/report_965/` passed Story043/044 focused tests `6/6` with `0`
    errors, failures, flaky tests, skipped tests, or orphans on Godot
    `4.7.stable.official.5b4e0cb0f`.
- Related regression:
  - `reports/old_factory_return_checkpoint_respawn_related.log` /
    `reports/report_964/` passed savepoint respawn selection, Factory route
    runtime roundtrip, service-lift SceneManager exit, and player respawn visual
    regressions `10/10` with `0` orphans.
- Headless and MCP evidence:
  - `reports/old_factory_return_checkpoint_respawn_project_boot.log` exited `0`;
    keyword scan found no script, parse, invalid-call, invalid-access,
    missing-resource, or resource-load errors. The log retains the known Godot
    cleanup-time ObjectDB/resource messages at process exit.
  - Godot MCP runtime evidence:
    `production/qa/evidence/old-factory-return-checkpoint-respawn-runtime-2026-06-30.md`.

**Status**: [x] Complete.
