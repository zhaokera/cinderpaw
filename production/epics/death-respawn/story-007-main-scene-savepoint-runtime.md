# Story 007: Main Scene Savepoint Runtime

> **Epic**: Death & Respawn
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-26
> **Last Updated**: 2026-06-26

## Context

**GDD**: `design/gdd/death-respawn.md`
**Requirements**: `TR-respawn-002`, `TR-respawn-005`, `TR-save-006`
**Architecture**: `MainScene`, `GameFlowController`, `SaveSystem`, `SceneManager`

Story 004 established savepoint respawn selection through adapters. This story
turns that contract into a player-visible main-scene runtime savepoint instead
of leaving savepoints as test-only data.

## Acceptance Criteria

- [x] `res://scenes/main.tscn` contains a visible `ScrapRoostSavepoint` node with
  generated non-placeholder art, prompt text, `Area2D`, and enabled
  `CollisionShape2D`.
- [x] The runtime savepoint exposes stable IDs:
  `savepoint_id="scrap_roost"`, `scene_id="main"`, and
  `spawn_point="scrap_roost"`.
- [x] Player contact discovers the savepoint through `MainScene`, writes
  autosave slot `0`, and records `world_state.last_savepoint`.
- [x] A non-boss death after touching the savepoint respawns at
  `main/scrap_roost` through `GameFlowController`.
- [x] Loading a same-main-scene save remains stable even if the root
  `SceneManager` still has a stale pending `main` async request from an earlier
  runtime handoff.
- [x] Godot MCP verifies scene load, runtime nodes, savepoint trigger,
  autosave payload, respawn selection, clean logs, and a nonblank screenshot.

## Test Evidence

**Required evidence**: focused GdUnit, save/respawn/title related regression,
MCP runtime probe, screenshot, headless smoke.
**Status**: [x] Complete

- TDD RED: `reports/report_739/` — focused runtime test failed because
  `ScrapRoostSavepoint` was missing from `res://scenes/main.tscn`.
- Import RED: `reports/report_740/` — scene referenced the new PNG before Godot
  import metadata existed.
- Story GREEN: `reports/report_752/` —
  `tests/unit/gameplay/main_scene_savepoint_runtime_test.gd` passed 3/3.
- Related regression: `reports/report_755/` — save trigger, SaveSystem handoff,
  async write, savepoint respawn selection, GameFlow, no-loss respawn, and title
  load handoff passed 29/29.
- Headless smoke: `godot --headless --path . --scene res://scenes/main.tscn --quit-after 3`
  exited `0`; output had no script, parse, invalid-call, invalid-access, or
  missing-resource failures. Godot emitted known cleanup-time ObjectDB/resource
  messages after exit.
- MCP runtime evidence: see
  `production/qa/evidence/main-scene-savepoint-runtime-2026-06-26.md`.

## Asset Pipeline

- Source image:
  `assets/generated/source/scrap_roost_savepoint_imagegen_20260626.png`
- Alpha source:
  `assets/generated/source/scrap_roost_savepoint_alpha_20260626.png`
- Runtime PNG:
  `assets/environment/savepoints/scrap_roost_savepoint.png`
- Manifest:
  `design/assets/asset-manifest.md`

The savepoint is an environment prop, not a visible character. The Godot frame
animation rule does not require `AnimatedSprite2D` for this prop; MCP evidence
still confirms the player and enemy visible characters are `AnimatedSprite2D`.

## Dependencies

- Depends on Story 004 savepoint respawn selection and SaveSystem Story 003/004
  autosave/runtime handoff.
- Keeps full multi-savepoint networks, minimap/fast travel, dedicated hub scene,
  and savepoint UI polish out of scope.
