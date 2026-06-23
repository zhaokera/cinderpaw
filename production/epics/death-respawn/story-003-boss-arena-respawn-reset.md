# Story 003: Boss Arena Respawn Reset

> **Epic**: Death & Respawn
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/death-respawn.md`
**Requirements**: `TR-respawn-002`, `TR-respawn-003`

## Acceptance Criteria

- [x] Boss-fight death respawns at the boss arena entrance.
- [x] Boss HP and phase state reset to the arena-entry snapshot.
- [x] Temporary summons, arena locks, and combat adapters are cleaned up.
- [x] Victory state still writes its reward path once and does not reset.

## Test Evidence

**Required evidence**: integration test and MCP runtime smoke.
**Status**: [x] Complete

- TDD RED:
  - `reports/report_307/` — `GameFlowController` lacked
    `start_boss_encounter()`.
  - `reports/report_309/` — `SimpleEnemy` lacked respawn snapshot APIs.
- Story GREEN: `reports/report_311/` — gameplay story tests passed 6/6:
  - `tests/unit/gameplay/game_flow_controller_test.gd`
  - `tests/unit/gameplay/simple_enemy_respawn_reset_test.gd`
- Startup: `godot --headless --path . --quit-after 1` exited 0.
- MCP runtime smoke: Godot AI 3.4.2 session `cinderpaw@c4d7` ran
  `res://scenes/main.tscn`; `game_eval` damaged Shadow Beast from 3 HP to 1 HP,
  killed the player, advanced the death timer, and returned restored boss HP
  3/3, player respawn HP 50/100, and flow state `revived`.
- MCP screenshot:
  `reports/visual/cinderpaw-mcp-boss-respawn-reset-20260624.png`.
- QA evidence:
  `production/qa/evidence/boss-arena-respawn-reset-2026-06-24.md`.

## Dependencies

- Depends on: BossConfigComponent story 004 arena locks, Story 001 runtime loop.
