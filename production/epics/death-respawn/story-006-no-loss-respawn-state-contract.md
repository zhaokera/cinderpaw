# Story 006: No-Loss Respawn State Contract

> **Epic**: Death & Respawn
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/death-respawn.md`
**Requirements**: `TR-respawn-005`

## Acceptance Criteria

- [x] Currency amount is unchanged after death and respawn.
- [x] Inventory and acquired weapon state are unchanged after respawn.
- [x] World progress flags are unchanged after respawn.
- [x] Health is restored by HealthComponent revive percentage only.

## Test Evidence

**Required evidence**: integration tests with economy/save adapters.
**Status**: [x] Complete

- TDD RED: `reports/report_312/` — `GameFlowController` lacked
  `set_no_loss_state_adapter()` and no-loss snapshot restore behavior.
- Story GREEN: `reports/report_313/` —
  `tests/unit/gameplay/no_loss_respawn_state_contract_test.gd` passed 2/2.
- Gameplay regression: `reports/report_314/` — GameFlow, no-loss, and boss
  respawn gameplay suites passed 8/8.
- Startup: `godot --headless --path . --quit-after 1` exited 0.
- MCP runtime smoke: Godot AI 3.4.2 session `cinderpaw@c4d7` ran
  `res://scenes/main.tscn`; runtime `game_eval` captured a no-loss state with
  `currency=42`, inventory items, Long Tail acquired/current weapon, and two
  world flags, corrupted that state during `dying`, then advanced respawn and
  returned the original state restored plus player HP 50/100.
- MCP screenshot:
  `reports/visual/cinderpaw-mcp-no-loss-respawn-state-20260624.png`.
- QA evidence:
  `production/qa/evidence/no-loss-respawn-state-contract-2026-06-24.md`.

## Dependencies

- Depends on: SaveSystem, weapon serialization, economy/currency source.
- Dependency note: full SaveSystem is still pending. This story implements the
  current runtime no-loss adapter contract and a SaveSystem-compatible snapshot
  shape so the future SaveSystem can supply the same adapter boundary.
