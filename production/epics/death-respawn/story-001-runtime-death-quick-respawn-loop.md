# Story 001: Runtime Death + Quick Respawn Loop

> **Epic**: Death & Respawn
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/death-respawn.md`
**Requirements**: `TR-respawn-001`, `TR-respawn-006`, `TR-respawn-007`

## Acceptance Criteria

- [x] Player death enters `dying` and locks player control.
- [x] Respawn is delayed until the 1.5 second death beat completes.
- [x] Respawn requests the stored respawn position and 50% revive HP.
- [x] Revived state keeps control locked during the 2 second invincibility
  window.
- [x] Control returns after the invincibility window.

## Test Evidence

**Required evidence**: `tests/unit/gameplay/game_flow_controller_test.gd`
**Status**: [x] Created and passing

- Story green: `reports/report_295/` — game-flow suite 3/3 passing.
- Runtime evidence: `reports/visual/cinderpaw-mcp-game-flow-initial-20260623.png`.
- Runtime evidence: `reports/visual/cinderpaw-mcp-game-flow-respawn-20260623.png`.

## Dependencies

- Depends on: HealthComponent revive API, PlayerController respawn adapter.
- Unlocks: respawn visual feedback and boss arena reset.
