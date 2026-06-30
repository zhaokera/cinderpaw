# Story 039: Scrap Roost Return Hub Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Scene Management / Savepoint Feedback
> **Type**: Integration + Gameplay Runtime + UI
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/scene-management.md`, `design/gdd/death-respawn.md`

**Requirements**: `TR-ability-005`, `TR-scene-001`, `TR-scene-003`,
`TR-scene-005`, `TR-respawn-001`

**ADR Governing Implementation**: ADR-0007 Scene management; ADR-0018 Player
abilities; ADR-0021 Save system.

Story037 makes the runtime route
`main -> area_03_factory -> main/scrap_roost` playable. Story038 clarifies the
main-scene Factory route prompt after that loop. This story closes the player
feedback loop by treating the service-lift return to Scrap Roost as a hub
reconnection moment: the existing Scrap Roost savepoint is rediscovered,
progress records the hub as secured, and the HUD acknowledges the return without
triggering a save.

## Acceptance Criteria

- [x] When SceneManager reports current scene `main`, current spawn point
  `scrap_roost`, Factory route is unlocked, and `area_03_factory` scene state
  records the full service-lift return contract back to `main / scrap_roost`,
  `MainScene` records `last_savepoint.id == "scrap_roost"`.
- [x] The discovered savepoint uses the existing `ScrapRoostSavepoint` runtime
  node and records its authored world position.
- [x] The runtime progress world flag
  `scrap_roost_return_hub_secured=true` is recorded for no-loss/save-state
  snapshots.
- [x] The HUD shows `Returned to Scrap Roost` once when the hub is secured.
- [x] Story038's return prompt remains intact:
  `FactoryRouteTransitionShell` still shows `Return to Factory Route` and keeps
  target `area_03_factory / factory_gate_entry`.
- [x] Incomplete service-lift return state does not secure the Scrap Roost hub,
  does not discover a savepoint, and does not show the return notification.
- [x] The hub closure records savepoint progress through
  `discover_savepoint()` only; it does not trigger savepoint autosave.
- [x] Focused and related GdUnit regressions, headless main-scene smoke, and
  Godot MCP runtime evidence pass with no new project script errors.

## Out of Scope

- SaveSystem schema changes, fast travel UI, minimap markers, new rooms,
  enemies, combat encounters, new visual/audio assets, new character animation
  states, moving service-lift animation, or broad SceneManager architecture
  changes.

## Implementation Notes

- `MainScene` now owns `SCRAP_ROOST_RETURN_HUB_FLAG` and
  `SCRAP_ROOST_RETURN_HUB_NOTIFICATION`.
- `_sync_scrap_roost_return_hub()` requires all of:
  - Factory route unlocked
  - SceneManager current scene `main`
  - SceneManager current spawn point `scrap_roost`
  - `area_03_factory` scene state proving the service lift returned to
    `main / scrap_roost`
  - an existing `ScrapRoostSavepoint` node
- The sync runs from SceneManager configuration, SceneManager change signals,
  and Factory route unlock flag changes so both tests and runtime handoffs share
  the same path.
- The story deliberately calls `discover_savepoint()` instead of
  `activate_runtime_savepoint()` so it does not autosave or show the normal
  `Scrap Roost saved` notification.
- No new visual assets were generated. This story reuses the existing
  image-generated Scrap Roost savepoint prop and existing Cinderpaw/Boss2/Spark
  Rat `AnimatedSprite2D + SpriteFrames` assets.

## Test Evidence

- Story039 valid RED: `reports/report_916/` failed because MainScene did not
  yet secure the hub, record the Scrap Roost savepoint position, or show the
  return notification.
- Story039 focused GREEN: `reports/report_917/` passed `2/2` with `0` orphans.
- Related regression:
  - `reports/report_918/` Story038 Factory route return prompt `2/2`
  - `reports/report_919/` Factory route runtime roundtrip `1/1`
  - `reports/report_920/` Main scene savepoint runtime `3/3`
  - `reports/report_921/` Factory route transition shell runtime `3/3`
  - `reports/report_922/` Old Factory service-lift SceneManager exit `2/2`
  - `reports/report_923/` Old Factory service-lift handoff `2/2`
- Headless main-scene smoke:
  `reports/scrap_roost_return_hub_main_scene_smoke.log` exited `0`; keyword
  scan found no script, parse, invalid-call, invalid-access, missing-resource,
  or resource-load failures. Godot still reports existing cleanup-time
  ObjectDB/resource messages after process exit.
- Godot MCP runtime evidence:
  `production/qa/evidence/scrap-roost-return-hub-runtime-2026-06-30.md`.

**Status**: [x] Complete.
