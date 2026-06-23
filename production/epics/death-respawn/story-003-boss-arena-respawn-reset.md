# Story 003: Boss Arena Respawn Reset

> **Epic**: Death & Respawn
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/death-respawn.md`
**Requirements**: `TR-respawn-002`, `TR-respawn-003`

## Acceptance Criteria

- [ ] Boss-fight death respawns at the boss arena entrance.
- [ ] Boss HP and phase state reset to the arena-entry snapshot.
- [ ] Temporary summons, arena locks, and combat adapters are cleaned up.
- [ ] Victory state still writes its reward path once and does not reset.

## Test Evidence

**Required evidence**: integration test and MCP runtime smoke.
**Status**: [ ] Not yet created

## Dependencies

- Depends on: BossConfigComponent story 004 arena locks, Story 001 runtime loop.
