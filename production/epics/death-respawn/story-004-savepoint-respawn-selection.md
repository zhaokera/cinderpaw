# Story 004: Savepoint Respawn Selection

> **Epic**: Death & Respawn
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/death-respawn.md`
**Requirements**: `TR-respawn-002`

## Acceptance Criteria

- [ ] Last discovered savepoint is preferred when valid.
- [ ] Clan base fallback is used when no savepoint exists or the saved point is
  invalid.
- [ ] Scene transition uses SceneManager instead of direct reload logic.
- [ ] Respawn point selection is deterministic and testable without full scene
  loading.

## Test Evidence

**Required evidence**: SaveSystem/SceneManagement integration tests.
**Status**: [ ] Ready

## Readiness

SaveSystem is complete and SceneManagement Story 001 provides the logical
SceneManager interface needed for deterministic scene/spawn transition tests.
Full async scene-tree replacement remains a future SceneManagement story and is
not required for this respawn-selection slice.

## Dependencies

- Depends on: SaveSystem Epic, SceneManagement Story 001.
