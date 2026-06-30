# Story 043: Old Factory Return Checkpoint

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Death & Respawn
> **Type**: Integration + Gameplay Runtime + Visual
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

Stories040-042 made the Old Factory return route readable and rewardable after
the service-lift roundtrip, but non-boss death still fell back to older
savepoint selection. This story adds a visible repair checkpoint inside the
return route so clearing the return patrol gives the player a local respawn
anchor before pushing deeper into the Factory.

## Acceptance Criteria

- [x] `FactoryReturnCheckpoint` exists in
  `res://scenes/factory_route_transition_shell.tscn` as a `SavepointRuntime`
  node with `Visual`, `PromptLabel`, `InteractionArea`, and
  `CollisionShape2D`.
- [x] The checkpoint uses generated transparent PNG art at
  `res://assets/environment/old_factory_return_checkpoint/old_factory_return_checkpoint.png`,
  with source, alpha source, and metadata preserved under
  `assets/generated/source/`.
- [x] Before `factory_return_patrol_defeated=true`, checkpoint diagnostics
  report `visible=false`, `available=false`, and activation returns false.
- [x] After the return patrol is defeated, checkpoint diagnostics report
  `visible=true`, `available=true`, prompt text `Repair Savepoint`, and stable
  ids `old_factory_return_checkpoint / area_03_factory / return_checkpoint`.
- [x] Activating the checkpoint records scene-local checkpoint state, updates
  `RouteLabel` to `Factory Savepoint Secured`, persists through
  `get_local_state()` / `set_local_state()`, and exposes
  `get_last_discovered_savepoint()` for death-respawn selection.
- [x] Non-boss death through `GameFlowController` chooses the Old Factory
  checkpoint and requests `area_03_factory / return_checkpoint` instead of
  falling back to clan base.
- [x] Existing return patrol, service-lift handoff/SceneManager exit, and
  savepoint respawn selection regressions remain green.
- [x] Godot MCP runtime confirms the target scene runs, checkpoint node exists
  with the generated texture, hidden/available/activated state transitions are
  correct, logs are clean, and the screenshot is non-empty with the checkpoint
  visible.

## Out of Scope

- Global SaveSystem schema changes, slot-0 autosave, minimap markers,
  fast-travel network, new Old Factory rooms, new enemies, currency economy
  changes, new audio, or service-lift movement animation.

## Implementation Notes

- Reuse `SavepointRuntime` instead of creating a second savepoint component.
- Keep checkpoint ownership inside `OldFactoryEntranceScene`; this story records
  scene-local checkpoint state and exposes it to `GameFlowController`, but does
  not change `SaveSystem` world-state schema.
- The checkpoint only becomes available after the return patrol is defeated.
  It must not bypass the return patrol or service-lift route contract.

## Test Evidence

- Focused RED:
  - `reports/report_952/` failed after the Story043 test was expanded because
    the old Factory scene still lacked checkpoint diagnostics and activation
    APIs.
- Focused GREEN:
  - `reports/report_954/` passed Story043 `3/3` with `0` errors, failures,
    flaky tests, skipped tests, or orphans on Godot
    `4.7.stable.official.5b4e0cb0f`.
- Related regression:
  - `reports/report_955/` passed return patrol ambush `3/3`.
  - `reports/report_956/` passed savepoint respawn selection `4/4`; the suite
    still emits known Godot cleanup-time ObjectDB/resource warnings after
    passing.
  - `reports/report_957/` plus saved command logs passed service-lift handoff
    and SceneManager exit regressions `4/4`.
- Godot import/headless/MCP evidence:
  - Godot import on 4.7 reimported the new source, alpha, and runtime PNG.
  - Headless Factory scene smoke exited `0`; keyword scan found no project
    script, parse, invalid-call, missing-resource, or resource-load failures.
    The smoke log still contains the project's known Godot cleanup-time
    ObjectDB/resource messages at exit.
  - Godot MCP runtime evidence:
    `production/qa/evidence/old-factory-return-checkpoint-2026-06-30.md`.

**Status**: [x] Complete.
