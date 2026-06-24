# Story 004: Savepoint Respawn Selection

> **Epic**: Death & Respawn
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/death-respawn.md`
**Requirements**: `TR-respawn-002`

## Acceptance Criteria

- [x] Last discovered savepoint is preferred when valid.
- [x] Clan base fallback is used when no savepoint exists or the saved point is
  invalid.
- [x] Scene transition uses SceneManager instead of direct reload logic.
- [x] Respawn point selection is deterministic and testable without full scene
  loading.

## Test Evidence

**Required evidence**: SaveSystem/SceneManagement integration tests.
**Status**: [x] Complete

- QA evidence:
  `production/qa/evidence/savepoint-respawn-selection-2026-06-25.md`.
- Story GREEN: `reports/report_405/` (`4/4` passing).
- Related regression: `reports/report_406/` (`24/24` passing).
- Godot MCP runtime probe verified valid savepoint, invalid fallback, boss
  entrance priority, clean game/editor logs, and non-empty screenshot evidence.

## Readiness

SaveSystem is complete and SceneManagement Story 001 provides the logical
SceneManager interface needed for deterministic scene/spawn transition tests.
Full async scene-tree replacement remains a future SceneManagement story and is
not required for this respawn-selection slice.

## Implementation Notes

`GameFlowController` owns respawn-point selection and exposes deterministic
adapter seams for the last discovered savepoint and SceneManager. `MainScene`
captures/restores the last savepoint through its SaveSystem payload and injects
the root `SceneManager` into GameFlow at runtime. Boss entrance respawn has its
own scene/spawn configuration so it does not inherit clan-base routing.

## Dependencies

- Depends on: SaveSystem Epic, SceneManagement Story 001.
