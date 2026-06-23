# Story 002: Pause + Retry Menu Focus Loop

> **Epic**: HUD/UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/hud-ui.md`
**Requirements**: `TR-hud-002`, `TR-hud-003`

## Acceptance Criteria

- [x] Pause menu opens from the pause action and grabs Resume focus.
- [x] Resume hides the overlay and restores gameplay.
- [x] Retry reloads the current encounter scene.
- [x] Victory state can show a retry/continue menu.
- [x] Menu buttons are focusable for keyboard/gamepad use.

## Test Evidence

**Required evidence**: `tests/unit/presentation/hud_manager_test.gd`
**Status**: [x] Created and passing

- RED/green regression: presentation suite `reports/report_299/` — 10/10 passing.
- Runtime evidence: `reports/visual/cinderpaw-mcp-pause-menu-20260624.png`.
- Runtime evidence: `reports/visual/cinderpaw-mcp-victory-retry-menu-20260624.png`.

## Dependencies

- Depends on: MainScene pause/retry adapters.
- Unlocks: settings menu shell, save/load menu shell.
