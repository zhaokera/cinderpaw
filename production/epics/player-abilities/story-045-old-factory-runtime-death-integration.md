# Story 045: Old Factory Runtime Death Integration

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

Story044 made the Old Factory return checkpoint drive a real
`SceneManager.request_scene_change("area_03_factory", "return_checkpoint")`
runtime landing. This story closes the remaining production gap: the Factory
scene now owns death-signal wiring instead of depending on a test-created
`GameFlowController`.

## Acceptance Criteria

- [x] `OldFactoryEntranceScene` creates or reuses a local
  `FactoryGameFlowController` at runtime.
- [x] The Factory scene connects `Player.player_died` to
  `GameFlowController.handle_player_death()`.
- [x] The Factory-owned `GameFlowController` uses the scene as savepoint
  adapter and uses the active `SceneManager` as scene transition adapter.
- [x] After activating `FactoryReturnCheckpoint`, fatal player damage selects
  `area_03_factory / return_checkpoint` as the non-boss respawn point.
- [x] After the death delay, Cinderpaw respawns at `FactoryReturnCheckpoint`
  with 50% HP and the existing revive/invincibility visual feedback active.
- [x] `RouteLabel` displays `Returned to Factory Savepoint` after the runtime
  respawn.
- [x] Existing `change_scene()` fallback, return-checkpoint runtime swap,
  savepoint selection, Factory roundtrip, service-lift exit, and respawn visual
  regressions remain green on Godot 4.7.
- [x] Godot MCP 4.7 confirms the running Factory scene contains
  `FactoryGameFlowController`, the runtime probe revives Cinderpaw at the
  checkpoint, logs are clean, and the game screenshot is non-empty.

## Out of Scope

- New visual assets, new rooms, new enemies, SaveSystem schema changes,
  minimap markers, fast-travel UI, service-lift animation, boss-respawn
  behavior, or a broader death/respawn redesign.

## Implementation Notes

- `OldFactoryEntranceScene` dynamically adds `FactoryGameFlowController` when
  the scene is ready. This avoids committing scene-file churn while still
  creating a real runtime node visible to MCP.
- `configure_scene_manager_runtime()` now also refreshes the Factory respawn
  flow's scene transition adapter, keeping Story044 runtime scene swaps and
  newly loaded Factory instances aligned.
- `advance_factory_respawn_flow(delta_sec)` and
  `get_factory_respawn_flow_diagnostics()` are deterministic test/MCP probes
  for the Factory-owned flow.
- The respawn callback calls the existing `Player.respawn_at()` path, so
  revive HP, iframe state, and visual feedback remain owned by the player
  controller.

## Asset Pipeline

No new visual assets were generated. This story reuses existing runtime assets,
including the Story043 image-generated checkpoint asset:

- `res://assets/environment/old_factory_return_checkpoint/old_factory_return_checkpoint.png`
- `res://assets/generated/source/old_factory_return_checkpoint_imagegen_20260630.png`
- `res://assets/generated/source/old_factory_return_checkpoint_alpha_20260630.png`
- `res://assets/generated/source/old_factory_return_checkpoint_imagegen_20260630.json`

## Test Evidence

- Focused RED:
  - `reports/old_factory_runtime_death_integration_red.log` /
    `reports/report_968/` failed after adding the production death-signal
    acceptance test because `OldFactoryEntranceScene` did not expose
    `advance_factory_respawn_flow()` and had no Factory-owned respawn flow.
- Focused GREEN:
  - `reports/old_factory_runtime_death_integration_green.log` /
    `reports/report_974/` passed return-checkpoint focused tests `7/7` with
    `0` errors, failures, flaky tests, skipped tests, or orphans on Godot
    `4.7.stable.official.5b4e0cb0f`.
- Related regression:
  - `reports/old_factory_runtime_death_integration_related.log` /
    `reports/report_975/` passed return checkpoint, savepoint respawn
    selection, player respawn visual feedback, Factory route roundtrip, and
    service-lift SceneManager exit regressions `17/17` with `0` orphans.
- Headless and MCP evidence:
  - `reports/old_factory_runtime_death_integration_factory_scene_smoke.log`
    exited `0`. Keyword scan found no script, parse, invalid-call,
    invalid-access, missing-resource, or resource-load errors. The stdout copy
    retains the known Godot cleanup-time ObjectDB/resource warnings at process
    exit.
  - Godot MCP runtime evidence:
    `production/qa/evidence/old-factory-runtime-death-integration-2026-06-30.md`.

**Status**: [x] Complete.
