# Story 001: Combat HUD Baseline

> **Epic**: HUD/UI
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/hud-ui.md`
**Requirements**: `TR-hud-001`, `TR-hud-004`, `TR-hud-007`

## Acceptance Criteria

- [x] Player HP displays current/max HP and a stable health color.
- [x] Low HP uses warning red without pulsing.
- [x] Boss HP displays a named target, phase, and current/max HP.
- [x] Weapon/cooldown and currency slots are present for Feature systems.
- [x] Notifications can display and expire without blocking input.

## Test Evidence

**Required evidence**: `tests/unit/presentation/hud_manager_test.gd`
**Status**: [x] Created and passing

- HUD focused suite: `reports/report_289/` — 3/3 passing.
- Presentation regression: `reports/report_292/` — 7/7 passing.
- Runtime evidence: `reports/visual/cinderpaw-mcp-hud-vertical-slice-20260623.png`.

## Dependencies

- Depends on: HealthComponent HP signals, boss HP source, weapon source.
- Unlocks: pause/retry menu, settings/accessibility controls.
