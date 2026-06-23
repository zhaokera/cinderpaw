# Story 004: Savepoint Respawn Selection

> **Epic**: Death & Respawn
> **Status**: Blocked
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

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
**Status**: [ ] Blocked

## Blocker

SaveSystem and SceneManagement production epics are not yet formalized.

## Dependencies

- Depends on: SaveSystem Epic, SceneManagement Epic.
